local addon, nPlates = ...
local L = nPlates.L

local len = string.len
local gsub = string.gsub
local lower = string.lower
local format = string.format
local floor = math.floor
local ceil = math.ceil

local texturePath = "Interface\\AddOns\\nPlates\\media\\"

local pvpIcons = {
    ["Alliance"] = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
    ["Horde"] = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t",
}

nPlates.statusBar = texturePath.."UI-StatusBar"
nPlates.border = texturePath.."borderTexture"
nPlates.shadow = texturePath.."textureShadow"
nPlates.defaultBorderColor = CreateColor(0.40, 0.40, 0.40, 1)
nPlates.interruptibleColor = CreateColor(0.0, 0.75, 0.0, 1)
nPlates.nonInterruptibleColor = CreateColor(0.75, 0.0, 0.0, 1)

nPlates.markerColors = {
    ["1"] = { r = 1.0, g = 1.0, b = 0.0 },
    ["2"] = { r = 1.0, g = 127/255, b = 63/255 },
    ["3"] = { r = 163/255, g = 53/255, b = 238/255 },
    ["4"] = { r = 30/255, g = 1.0, b = 0.0 },
    ["5"] = { r = 170/255, g = 170/255, b = 221/255 },
    ["6"] = { r = 0.0, g = 112/255, b = 221/255 },
    ["7"] = { r = 1.0, g = 32/255, b = 32/255 },
    ["8"] = { r = 1.0, g = 1.0, b = 1.0 },
}

    -- RBG to Hex Colors

function nPlates:RGBToHex(r, g, b)
    if ( type(r) == "table" ) then
        return RGBTableToColorCode(r)
    end

    return RGBToColorCode(r, g, b)
end

    -- Format Health

function nPlates:FormatValue(number)
    if ( number < 1e3 ) then
        return floor(number)
    elseif ( number >= 1e12 ) then
        return format("%.3ft", number/1e12)
    elseif ( number >= 1e9 ) then
        return format("%.3fb", number/1e9)
    elseif ( number >= 1e6 ) then
        return format("%.2fm", number/1e6)
    elseif ( number >= 1e3 ) then
        return format("%.1fk", number/1e3)
    end
end

    -- Format Time

function nPlates:FormatTime(seconds)
    if ( seconds > 86400 ) then
        -- Days
        return ceil(seconds/86400) .. "d", seconds%86400
    elseif ( seconds >= 3600 ) then
        -- Hours
        return ceil(seconds/3600) .. "h", seconds%3600
    elseif ( seconds >= 60 ) then
        -- Minutes
        return ceil(seconds/60) .. "m", seconds%60
    elseif ( seconds <= 10 ) then
        -- Seconds
        return format("%.1f", seconds)
    end

    return floor(seconds), seconds - floor(seconds)
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
    for setting, value in pairs(nPlates.defaultOptions) do
        nPlates:RegisterDefaultSetting(setting, value)
    end

    local currentHealthOption = nPlatesDB["CurrentHealthOption"]
    if type(currentHealthOption) == "number" then
        if currentHealthOption == 1 then
            currentHealthOption = "HealthDisable"
        elseif currentHealthOption == 2 then
            currentHealthOption = "HealthBoth"
        elseif currentHealthOption == 3 then
            currentHealthOption = "HealthValueOnly"
        elseif currentHealthOption == 4 then
            currentHealthOption = "HealthPercOnly"
        end

        nPlatesDB["CurrentHealthOption"] = currentHealthOption
    end
end

    -- Set Cvars

function nPlates:CVarCheck()
    if ( not nPlates:IsTaintable() ) then
        -- Combat Plates
        if ( nPlatesDB.CombatPlates ) then
            C_CVar.SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)
        else
            C_CVar.SetCVar("nameplateShowEnemies", 1)
        end

        -- Set min and max scale.
        C_CVar.SetCVar("namePlateMinScale", 1)
        C_CVar.SetCVar("namePlateMaxScale", 1)

        -- Set sticky nameplates.
        if ( not nPlatesDB.DontClamp ) then
            C_CVar.SetCVar("nameplateOtherTopInset", -1)
            C_CVar.SetCVar("nameplateOtherBottomInset", -1)
        else
            for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do
                C_CVar.SetCVar(v, GetCVarDefault(v))
            end
        end

        -- Set small stacking nameplates.
        if ( nPlatesDB.SmallStacking ) then
            C_CVar.SetCVar("nameplateOverlapH", 1.1) C_CVar.SetCVar("nameplateOverlapV", 0.9)
        else
            for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do
                C_CVar.SetCVar(v, GetCVarDefault(v))
            end
        end
    end
end

    -- Force Nameplate Update

function nPlates:UpdateAllNameplates()
    for _, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not frame:IsForbidden() ) then
            CompactUnitFrame_UpdateAll(frame.UnitFrame)
        end
    end
end

    -- Check for Combat

function nPlates:IsTaintable()
    return (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet")))
end

    -- Set Name Size

function nPlates:UpdateNameSize(self)
    if ( not self ) then
        return
    end

    local size = nPlatesDB.NameSize or 10
    self.name:SetFontObject("nPlate_NameFont"..size)
    self.name:SetShadowOffset(0.5, -0.5)
    self.name:SetJustifyV("BOTTOM")
end

    -- Abbreviate Long Strings

function nPlates:Abbrev(text, length)
    if ( not text ) then
        return UNKNOWN
    end

    length = length or 20

    text = (len(text) > length) and gsub(text, "%s?(.[\128-\191]*)%S+%s", "%1. ") or text
    return text
end

    -- PvP Icon

function nPlates:PvPIcon(unit)
    if ( not nPlatesDB.ShowPvP or not UnitIsPlayer(unit) ) then
        return ""
    end

    local faction = UnitFactionGroup(unit)
    local icon = (UnitIsPVP(unit) and faction) and pvpIcons[faction] or ""

    return icon
end

    -- Raid Marker Coloring Update

function nPlates:UpdateRaidMarkerColoring()
    if ( not nPlatesDB.RaidMarkerColoring ) then return end

    for i, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not frame or not frame:IsForbidden() ) then
            CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
        end
    end
end

    -- Check if class colors should be used.

function nPlates:UseClassColors(playerFaction, unit)
    local targetFaction, _ = UnitFactionGroup(unit)
    return ( playerFaction == targetFaction and nPlatesDB.ShowFriendlyClassColors) or ( playerFaction ~= targetFaction and nPlatesDB.ShowEnemyClassColors )
end

    -- Check for "Larger Nameplates"

function nPlates:IsUsingLargerNamePlateStyle()
    local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
    return namePlateVerticalScale > 1.0
end

    -- Check for threat.

function nPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

    -- Checks to see if unit has tank role.

local function PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

    -- Off Tank Color Checks

function nPlates:UseOffTankColor(unit)
    if ( nPlatesDB.UseOffTankColor and ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) ) then
        if ( not UnitIsUnit("player", unit) and PlayerIsTank("player") and PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

    -- Execute Range Check

function nPlates:IsInExecuteRange(unit)
    if ( not unit or not UnitCanAttack("player", unit) ) then
        return
    end

    local executeValue = nPlatesDB.ExecuteValue or 35
    local perc = floor(100*(UnitHealth(unit)/UnitHealthMax(unit)))

    return perc < executeValue
end

    -- Fel Explosive Check

local moblist = {
    [L.FelExplosivesMobName] = true,
    -- ["Dungeoneer's Training Dummy"] = true,
}

function nPlates:IsPriority(unit)
    if ( not unit or UnitIsPlayer(unit) or not UnitCanAttack("player", unit) ) then
        return false
    end

    return moblist[UnitName(unit)] == true
end

    -- Update BuffFrame Anchors

function nPlates:UpdateAllBuffFrameAnchors()
    for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not frame:IsForbidden() ) then
            local BuffFrame = frame.UnitFrame.BuffFrame

            if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
                BuffFrame.baseYOffset = frame.UnitFrame.name:GetHeight() + 1
            elseif ( frame.UnitFrame.displayedUnit ) then
                BuffFrame.baseYOffset = 0
            end

            BuffFrame:UpdateAnchor()
        end
    end
end

function nPlates:UpdateBuffFrameAnchorsByUnit(unit)
    if ( not unit ) then
        return
    end

    local frame = C_NamePlate.GetNamePlateForUnit(unit, issecure())

    if ( not frame or frame:IsForbidden() ) then
        return
    end

    local BuffFrame = frame.UnitFrame.BuffFrame

    if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
        BuffFrame.baseYOffset = frame.UnitFrame.name:GetHeight()+1
    elseif ( frame.UnitFrame.displayedUnit ) then
        BuffFrame.baseYOffset = 0
    end

    BuffFrame:UpdateAnchor()
end

    -- Fixes the border when using the Personal Resource Display.

function nPlates:FixPlayerBorder(unit)
    local showSelf = GetCVar("nameplateShowSelf")
    if ( showSelf == "0" ) then
        return
    end

    if ( not UnitIsUnit(unit, "player") ) then return end

    local frame = C_NamePlate.GetNamePlateForUnit("player", issecure())

    if ( frame ) then
        local HealthBar = frame.UnitFrame.healthBar

        if ( HealthBar.beautyBorder and HealthBar.beautyShadow ) then
            for i = 1, 8 do
                HealthBar.beautyBorder[i]:Hide()
                HealthBar.beautyShadow[i]:Hide()
            end
            HealthBar.border:Show()
            HealthBar.beautyBorder = nil
            HealthBar.beautyShadow = nil
        end
    end
end

    -- Set Border

function nPlates:SetBorder(frame)
    if ( frame.beautyBorder ) then
        return
    end

    local objectType = frame:GetObjectType()
    local padding = 2
    local size = 8
    local space = size/3.5

    frame.beautyBorder = {}
    frame.beautyShadow = {}

    for i = 1, 8 do
        if ( objectType == "Frame" or objectType == "StatusBar" ) then
            -- Border
            frame.beautyBorder[i] = frame:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
            frame.beautyBorder[i]:SetParent(frame)
            -- Shadow
            frame.beautyShadow[i] = frame:CreateTexture("$parentBeautyShadow"..i, "BORDER")
            frame.beautyShadow[i]:SetParent(frame)

        elseif ( objectType == "Texture") then
            local frameParent = frame:GetParent()

            -- Border
            frame.beautyBorder[i] = frameParent:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
            frame.beautyBorder[i]:SetParent(frameParent)

            -- Shadow
            frame.beautyShadow[i] = frameParent:CreateTexture("$parentBeautyShadow"..i, "BORDER")
            frame.beautyShadow[i]:SetParent(frameParent)
        end
    end

    for _, texture in ipairs(frame.beautyBorder) do
        texture:SetTexture(nPlates.border)
        texture:SetSize(size, size)
        texture:SetVertexColor(nPlates.defaultBorderColor:GetRGB())
        texture:ClearAllPoints()
    end

    for _, texture in ipairs(frame.beautyShadow) do
        texture:SetTexture(nPlates.shadow)
        texture:SetSize(size, size)
        texture:SetVertexColor(0, 0, 0, 1)
        texture:ClearAllPoints()
    end

    frame.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyBorder[1]:SetPoint("TOPLEFT", frame, -padding, padding)

    frame.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyBorder[2]:SetPoint("TOPRIGHT", frame, padding, padding)

    frame.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyBorder[3]:SetPoint("BOTTOMLEFT", frame, -padding, -padding)

    frame.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyBorder[4]:SetPoint("BOTTOMRIGHT", frame, padding, -padding)

    frame.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyBorder[5]:SetPoint("TOPLEFT", frame.beautyBorder[1], "TOPRIGHT")
    frame.beautyBorder[5]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "TOPLEFT")

    frame.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyBorder[6]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "BOTTOMRIGHT")
    frame.beautyBorder[6]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "BOTTOMLEFT")

    frame.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyBorder[7]:SetPoint("TOPLEFT", frame.beautyBorder[1], "BOTTOMLEFT")
    frame.beautyBorder[7]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "TOPLEFT")

    frame.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyBorder[8]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "BOTTOMRIGHT")
    frame.beautyBorder[8]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "TOPRIGHT")

    frame.beautyShadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyShadow[1]:SetPoint("TOPLEFT", frame, -padding-space, padding+space)

    frame.beautyShadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyShadow[2]:SetPoint("TOPRIGHT", frame, padding+space, padding+space)

    frame.beautyShadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyShadow[3]:SetPoint("BOTTOMLEFT", frame, -padding-space, -padding-space)

    frame.beautyShadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyShadow[4]:SetPoint("BOTTOMRIGHT", frame, padding+space, -padding-space)

    frame.beautyShadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyShadow[5]:SetPoint("TOPLEFT", frame.beautyShadow[1], "TOPRIGHT")
    frame.beautyShadow[5]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "TOPLEFT")

    frame.beautyShadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyShadow[6]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "BOTTOMRIGHT")
    frame.beautyShadow[6]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "BOTTOMLEFT")

    frame.beautyShadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyShadow[7]:SetPoint("TOPLEFT", frame.beautyShadow[1], "BOTTOMLEFT")
    frame.beautyShadow[7]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "TOPLEFT")

    frame.beautyShadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyShadow[8]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "BOTTOMRIGHT")
    frame.beautyShadow[8]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "TOPRIGHT")
end

-- Set Castbar Border Colors

function nPlates:SetCastbarBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    if ( frame.castBar.beautyBorder ) then
        for _, texture in ipairs(frame.castBar.beautyBorder) do
            texture:SetVertexColor(color:GetRGB())
        end
    end

    if ( frame.castBar.Icon.beautyBorder ) then
        for _, texture in ipairs(frame.castBar.Icon.beautyBorder) do
            texture:SetVertexColor(color:GetRGB())
        end
    end
end

    -- Set Healthbar Border Color

function nPlates:SetHealthBorderColor(frame, r, g, b)
    if ( not frame ) then
        return
    end

    local border = frame.healthBar.beautyBorder

    if ( border ) then
        for _, texture in ipairs(border) do
            if ( UnitIsUnit(frame.displayedUnit, "target") ) then
                if ( nPlatesDB.WhiteSelectionColor ) then
                    texture:SetVertexColor(1, 1, 1, 1)
                else
                    texture:SetVertexColor(r, g, b, 1)
                end
            else
                texture:SetVertexColor(nPlates.defaultBorderColor:GetRGB())
            end
        end
    end
end
