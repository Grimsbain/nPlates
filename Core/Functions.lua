local _, nPlates = ...

local pvpIcons = {
    ["Alliance"] = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
    ["Horde"] = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t",
}

local texturePath = [[Interface\AddOns\nPlates\Media\]]
nPlates.statusBar = texturePath.."UI-StatusBar"
nPlates.borderTexture = texturePath.."borderTexture"
nPlates.shadowTexture = texturePath.."textureShadow"

nPlates.borderColor = CreateColor(1, 1, 1, 1)
nPlates.defaultBorderColor = CreateColor(0.40, 0.40, 0.40, 1)
nPlates.nonInterruptibleColor = CreateColor(0.75, 0.0, 0.0, 1)

nPlates.markerColors = {
    [1] = { r = 1.0, g = 1.0, b = 0.0 },
    [2] = { r = 1.0, g = 127/255, b = 63/255 },
    [3] = { r = 163/255, g = 53/255, b = 238/255 },
    [4] = { r = 30/255, g = 1.0, b = 0.0 },
    [5] = { r = 170/255, g = 170/255, b = 221/255 },
    [6] = { r = 0.0, g = 112/255, b = 221/255 },
    [7] = { r = 1.0, g = 32/255, b = 32/255 },
    [8] = { r = 1.0, g = 1.0, b = 1.0 },
}

nPlates.TimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
nPlates.TimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
nPlates.TimeLeftFormatter:SetStripIntervalWhitespace(true);
nPlates.TimeLeftFormatter:SetDesiredUnitCount(1)

function nPlates:IsRetail()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

function nPlates:IsTaintable()
    return (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet")))
end

function nPlates:IsFrameBlocked(frame)
    if ( not frame or frame:IsForbidden() ) then
        return true
    end

    return not frame.isNameplate
end

function nPlates:RGBToHex(r, g, b)
    if ( type(r) == "table" ) then
        return RGBTableToColorCode(r)
    end

    return RGBToColorCode(r, g, b)
end

function nPlates:FormatValue(number)
    if ( number < 1e3 ) then
        return math.floor(number)
    elseif ( number >= 1e12 ) then
        return string.format("%.3ft", number / 1e12)
    elseif ( number >= 1e9 ) then
        return string.format("%.3fb", number / 1e9)
    elseif ( number >= 1e6 ) then
        return string.format("%.2fm", number / 1e6)
    elseif ( number >= 1e3 ) then
        return string.format("%.1fk", number / 1e3)
    end
end

function nPlates:FormatTime(seconds)
    if ( seconds > 10 ) then
        return self.TimeLeftFormatter:Format(seconds)
    end

    return string.format("%.1f", seconds)
end

function nPlates:RegisterDefaultSetting(key, value)
    if ( nPlatesDB == nil ) then
        nPlatesDB = {}
    end
    if ( nPlatesDB[key] == nil ) then
        nPlatesDB[key] = value
    end
end

function nPlates:SetDefaultOptions()
    for setting, value in pairs(self.defaultOptions) do
        self:RegisterDefaultSetting(setting, value)
    end
end

function nPlates:GetOption(variable)
    local option = _G.nPlatesDB[variable]

    if ( option == nil ) then
        option = self.defaultOptions[variable]
    end

    return option
end

function nPlates:ResetCVars(...)
    for _, cvar in ipairs({...}) do
        C_CVar.SetCVar(cvar, GetCVarDefault(cvar))
    end
end

function nPlates:CVarCheck()
    if ( self:IsTaintable() ) then
        return
    end

    -- Combat Plates
    if ( self:GetOption("CombatPlates") ) then
        C_CVar.SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)
    else
        self:ResetCVars("nameplateShowEnemies")
    end

    C_CVar.SetCVar("namePlateMinScale", 0.8)
    C_CVar.SetCVar("namePlateMaxScale", 1)

    -- Sticky Nameplates
    if ( self:GetOption("DontClamp") ) then
        C_CVar.SetCVar("nameplateOtherTopInset", -1)
        C_CVar.SetCVar("nameplateOtherBottomInset", -1)
    else
        self:ResetCVars("nameplateOtherTopInset", "nameplateOtherBottomInset")
    end

    if ( self:GetOption("SmallStacking") ) then
        C_CVar.SetCVar("nameplateOverlapH", 1.1)
        C_CVar.SetCVar("nameplateOverlapV", 0.9)
    else
        self:ResetCVars("nameplateOverlapH", "nameplateOverlapV")
    end
end

function nPlates:UpdateNameplateWithFunction(func)
    if ( not func or not type(func) == "function" ) then
        return
    end

    for _, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not frame:IsForbidden() ) then
            func(frame.UnitFrame)
        end
    end
end

function nPlates:UpdateAllNameplates()
    self:UpdateNameplateWithFunction(CompactUnitFrame_UpdateAll)
end

function nPlates:UpdateRaidMarkerColoring()
    if ( not self:GetOption("RaidMarkerColoring") ) then
        return
    end

    self:UpdateNameplateWithFunction(CompactUnitFrame_UpdateHealthColor)
end

function nPlates:UpdateNameSize(frame)
    if ( not frame ) then
        return
    end

    local size = self:GetOption("NameSize")
    frame.name:SetFontObject("nPlate_NameFont"..size)
    frame.name:SetJustifyV("BOTTOM")
end

function nPlates:UpdateNameColor(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    if ( UnitIsPlayer(frame.unit) ) then
        local r, g, b = frame.healthBar:GetStatusBarColor()
        frame.name:SetTextColor(r, g, b)
        return
    else
        if ( UnitCanAttack("player", frame.unit) ) then
            if ( self:GetOption("ColorNameByThreat") ) then
                local target = frame.displayedUnit.."target"
                local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)

                if ( isTanking and threatStatus ) then
                    if ( threatStatus >= 3 ) then
                        frame.name:SetTextColor(0.0, 1.0, 0.0)
                        return
                    else
                        frame.name:SetTextColor(GetThreatStatusColor(threatStatus))
                        return
                    end
                elseif ( self:UseOffTankColor(target) ) then
                    local color = self:GetOption("OffTankColor")
                    frame.name:SetTextColor(color.r, color.g, color.b)
                    return
                end
            end

            frame.name:SetTextColor(1, 1, 1)
            return
        else
            frame.name:SetTextColor(1, 1, 1)
            return
        end
    end
end

function nPlates:Abbreviate(text)
    if ( not text ) then
        return UNKNOWN
    end

    if ( #text > 20 ) then
        text = text:gsub("(%s?[%z\1-\127\194-\244][\128-\191]*)%S+%s", "%1. ")
    end

    return text
end

function nPlates:PvPIcon(unit)
    if ( not self:GetOption("ShowPvP") or not UnitIsPlayer(unit) ) then
        return ""
    end

    local faction = UnitFactionGroup(unit)
    local icon = ""

    if ( UnitIsPVP(unit) and faction and pvpIcons[faction] ) then
        icon = pvpIcons[faction]
    end

    return icon
end

function nPlates:UseClassColors(playerFaction, unit)
    local inArena = IsActiveBattlefieldArena()

    if ( inArena and self:GetOption("ShowEnemyClassColors") ) then
        return true
    end

    local targetFaction, _ = UnitFactionGroup(unit)

    if ( playerFaction == targetFaction ) then
        return self:GetOption("ShowFriendlyClassColors")
    else
        return self:GetOption("ShowEnemyClassColors")
    end
end

function nPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

local function PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

function nPlates:UseOffTankColor(unit)
    if ( not self:GetOption("UseOffTankColor") or not PlayerIsTank("player") ) then
        return false
    end

    if ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) then
        if ( not UnitIsUnit("player", unit) and PlayerIsTank(unit) ) then
            return true
        end
    end

    return false
end

function nPlates:IsInExecuteRange(unit)
    if ( not unit or not UnitCanAttack("player", unit) ) then
        return false
    end

    local executeValue = self:GetOption("ExecuteValue")
    local healthPercent = UnitHealth(unit) / UnitHealthMax(unit) * 100

    return healthPercent <= executeValue
end

function nPlates:HasBeautyBorder(frame)
    if ( not frame ) then
        return
    end

    return frame.beautyBorder ~= nil
end

function nPlates:SetBorder(frame)
    if ( self:HasBeautyBorder(frame) ) then
        return
    end

    local padding = 2.5
    local size = 8
    local space = size/3.5
    local objectType = frame:GetObjectType()
    local textureParent = (objectType == "Frame" or objectType == "StatusBar") and frame or frame:GetParent()

    frame.beautyBorder = {}
    frame.beautyShadow = {}

    for i = 1, 8 do
        frame.beautyBorder[i] = textureParent:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
        frame.beautyBorder[i]:SetTexture(self.borderTexture)
        frame.beautyBorder[i]:SetSize(size, size)
        frame.beautyBorder[i]:SetVertexColor(self.defaultBorderColor:GetRGB())
        frame.beautyBorder[i]:ClearAllPoints()

        frame.beautyShadow[i] = textureParent:CreateTexture("$parentBeautyShadow"..i, "BORDER")
        frame.beautyShadow[i]:SetTexture(self.shadowTexture)
        frame.beautyShadow[i]:SetSize(size, size)
        frame.beautyShadow[i]:SetVertexColor(0, 0, 0, 1)
        frame.beautyShadow[i]:ClearAllPoints()
    end

    -- TOPLEFT
    frame.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyBorder[1]:SetPoint("TOPLEFT", frame, -padding, padding)
    -- TOPRIGHT
    frame.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyBorder[2]:SetPoint("TOPRIGHT", frame, padding, padding)
    -- BOTTOMLEFT
    frame.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyBorder[3]:SetPoint("BOTTOMLEFT", frame, -padding, -padding)
    -- BOTTOMRIGHT
    frame.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyBorder[4]:SetPoint("BOTTOMRIGHT", frame, padding, -padding)
    -- TOP
    frame.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyBorder[5]:SetPoint("TOPLEFT", frame.beautyBorder[1], "TOPRIGHT")
    frame.beautyBorder[5]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "TOPLEFT")
    -- BOTTOM
    frame.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyBorder[6]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "BOTTOMRIGHT")
    frame.beautyBorder[6]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "BOTTOMLEFT")
    -- LEFT
    frame.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyBorder[7]:SetPoint("TOPLEFT", frame.beautyBorder[1], "BOTTOMLEFT")
    frame.beautyBorder[7]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "TOPLEFT")
    -- RIGHT
    frame.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyBorder[8]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "BOTTOMRIGHT")
    frame.beautyBorder[8]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "TOPRIGHT")

    -- TOPLEFT
    frame.beautyShadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyShadow[1]:SetPoint("TOPLEFT", frame, -padding-space, padding+space)
    -- TOPRIGHT
    frame.beautyShadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyShadow[2]:SetPoint("TOPRIGHT", frame, padding+space, padding+space)
    -- BOTTOMLEFT
    frame.beautyShadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyShadow[3]:SetPoint("BOTTOMLEFT", frame, -padding-space, -padding-space)
    -- BOTTOMRIGHT
    frame.beautyShadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyShadow[4]:SetPoint("BOTTOMRIGHT", frame, padding+space, -padding-space)
    -- TOP
    frame.beautyShadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyShadow[5]:SetPoint("TOPLEFT", frame.beautyShadow[1], "TOPRIGHT")
    frame.beautyShadow[5]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "TOPLEFT")
    -- BOTTOM
    frame.beautyShadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyShadow[6]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "BOTTOMRIGHT")
    frame.beautyShadow[6]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "BOTTOMLEFT")
    -- LEFT
    frame.beautyShadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyShadow[7]:SetPoint("TOPLEFT", frame.beautyShadow[1], "BOTTOMLEFT")
    frame.beautyShadow[7]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "TOPLEFT")
    -- RIGHT
    frame.beautyShadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyShadow[8]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "BOTTOMRIGHT")
    frame.beautyShadow[8]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "TOPRIGHT")
end

function nPlates:SetBeautyBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    if ( self:HasBeautyBorder(frame) ) then
        for _, texture in ipairs(frame.beautyBorder) do
            texture:SetVertexColor(color:GetRGB())
        end
    end
end

function nPlates:SetSelectionColor(frame)
    if ( not frame ) then
        return
    end

    local r, g, b = frame.healthBar:GetStatusBarColor()
    self.borderColor:SetRGB(r, g, b)

    if ( UnitIsUnit(frame.displayedUnit, "target") ) then
        if ( self:GetOption("WhiteSelectionColor") ) then
            self.borderColor:SetRGB(1, 1, 1)
        end

        self:SetBeautyBorderColor(frame.healthBar, self.borderColor)
    else
        self:SetBeautyBorderColor(frame.healthBar, self.defaultBorderColor)
    end
end

function nPlates:SetCastbarBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    self:SetBeautyBorderColor(frame, color)
    self:SetBeautyBorderColor(frame.Icon, color)
end

-- Retail Only --

function nPlates:IsUsingLargerNamePlateStyle()
    local namePlateVerticalScale = GetCVarNumberOrDefault("NamePlateVerticalScale")
    return namePlateVerticalScale > 1.0
end

function nPlates:UpdateBuffFrameAnchorsByFrame(frame)
    if ( self:IsFrameBlocked(frame) or not frame.BuffFrame ) then
        return
    end

    if ( frame.displayedUnit ) then
        if ( UnitShouldDisplayName(frame.displayedUnit) ) then
            local height = frame.name:GetHeight()

            if ( self:IsUsingLargerNamePlateStyle() ) then
                frame.BuffFrame.baseYOffset = height - 28
            else
                frame.BuffFrame.baseYOffset = height - 7
            end
        else
            frame.BuffFrame.baseYOffset = 0
        end
    end

    frame.BuffFrame:UpdateAnchor()
end

function nPlates:FixPersonalResourceDisplay(unit)
    local showSelf = C_CVar.GetCVar("nameplateShowSelf")
    if ( showSelf == "0" ) then
        return
    end

    if ( not UnitIsUnit(unit, "player") ) then
        return
    end

    local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit("player", issecure())

    if ( namePlateFrameBase ) then
        local healthBar = namePlateFrameBase.UnitFrame.healthBar

        if ( self:HasBeautyBorder(healthBar) ) then
            for i = 1, 8 do
                healthBar.beautyBorder[i]:Hide()
                healthBar.beautyShadow[i]:Hide()
            end

            healthBar.border:Show()
            healthBar.beautyBorder = nil
            healthBar.beautyShadow = nil
        end
    end
end

-- Wrath Only --

function nPlates:UpdateClassification(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    if ( not frame.classificationIndicator ) then
        frame.classificationIndicator = frame:CreateTexture("$parentClassificationIndicator", "OVERLAY")
        frame.classificationIndicator:SetSize(14, 13)
        frame.classificationIndicator:SetPoint("RIGHT", frame.healthBar, "LEFT")
        frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", frame.unit, frame.displayedUnit)
    end

    local classification = UnitClassification(frame.unit)
    if ( classification == "elite" or classification == "worldboss" ) then
        frame.classificationIndicator:SetAtlas("nameplates-icon-elite-gold")
        frame.classificationIndicator:Show()
    elseif ( classification == "rareelite" or classification == "rare" ) then
        frame.classificationIndicator:SetAtlas("nameplates-icon-elite-silver")
        frame.classificationIndicator:Show()
    else
        frame.classificationIndicator:Hide()
    end
end
