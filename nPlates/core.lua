
local ADDON, nPlates = ...

local len = string.len
local gsub = string.gsub

local texturePath = "Interface\\AddOns\\nPlates\\media\\"
local statusBar = texturePath.."UI-StatusBar"
local overlayTexture = texturePath.."textureOverlay_new"
local iconOverlay = texturePath.."textureIconOverlay"
local borderColor = {0.47, 0.47, 0.47, 1}

    -- First Run Settings

if ( nPlatesDB == nil ) then
    nPlatesDB = {
        ["TankMode"] = false,
        ["ColorNameByThreat"] = false,
        ["ShowHP"] = true,
        ["ShowFullHP"] = true,
        ["ShowLevel"] = true,
        ["ShowServerName"] = false,
        ["AbrrevLongNames"] = true,
        ["UseLargeNameFont"] = false,
        ["ShowClassColors"] = true,
        ["DontClamp"] = false,
    }
end

    -- Set DefaultCompactNamePlate Options

local groups = {
    "Friendly",
    "Enemy",
}

local options = {
    displaySelectionHighlight = true,
    useClassColors = nPlatesDB.ShowClassColors,

    tankBorderColor = CreateColor(.45,.45,.45,.55),
    selectedBorderColor = CreateColor(.45,.45,.45,.55),
    defaultBorderColor = CreateColor(.45,.45,.45,.55),
}

for i, group  in next, groups do
    for key, value in next, options do
        _G["DefaultCompactNamePlate"..group.."FrameOptions"][key] = value
    end
end

    -- Set CVar Options

C_Timer.After(.1, function()
    if not InCombatLockdown() then
        -- Set min and max scale.
        SetCVar("namePlateMinScale", 1)
        SetCVar("namePlateMaxScale", 1)
    end
end)

    -- Updated Health Text

local function UpdateHealthText(frame)
    if ( not nPlates.FrameIsNameplate(frame) ) then return end

    local font = select(1,frame.name:GetFont())

    if ( nPlatesDB.ShowHP ) then
        if ( not frame.healthBar.healthString ) then
            frame.healthBar.healthString = frame.healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
            frame.healthBar.healthString:Hide()
            frame.healthBar.healthString:SetPoint("CENTER", frame.healthBar, 0, 0)
            frame.healthBar.healthString:SetFont(font, 10)
            frame.healthBar.healthString:SetShadowOffset(.5, -.5)
        end
    else
        if ( frame.healthBar.healthString ) then frame.healthBar.healthString:Hide() end
        return
    end

    local health = UnitHealth(frame.displayedUnit)
    local maxHealth = UnitHealthMax(frame.displayedUnit)
    local perc = (health/maxHealth)*100

    if ( perc >= 100 and health > 5 and nPlatesDB.ShowFullHP ) then
        frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
    elseif ( perc < 100 and health > 5 ) then
        frame.healthBar.healthString:SetFormattedText("%s - %.0f%%", nPlates.FormatValue(health), perc-0.5)
    else
        frame.healthBar.healthString:SetText("")
    end
    frame.healthBar.healthString:Show()
end
hooksecurefunc("CompactUnitFrame_UpdateStatusText",UpdateHealthText)

    -- Update Health Color

local function UpdateHealthColor(frame)
    if ( not nPlates.FrameIsNameplate(frame) ) then return end

    if ( not UnitIsConnected(frame.unit) ) then
        local r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            if ( UnitIsPlayer(frame.unit) and classColor and nPlatesDB.ShowClassColors ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) and nPlatesDB.TankMode ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.0, 1.0, 0.0
                        elseif ( threatStatus == 2 ) then
                            r, g, b = 1.0, 0.6, 0.2
                        end
                    else
                        r, g, b = 1.0, 0.0, 0.0
                    end
                else
                    r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors)
                end
            elseif ( UnitIsFriend("player", frame.unit) ) then
                r, g, b = 0.0, 1.0, 0.0
            else
                r, g, b = 1.0, 0.0, 0.0
            end
        end
    end
    if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
        frame.healthBar:SetStatusBarColor(r, g, b)

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1, 1, 1)
        end

        frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
    end

        -- Healthbar Overlay Coloring

    if ( frame.healthBar.border.Overlay ) then frame.healthBar.border.Overlay:SetVertexColor(r/2,g/2,b/2,1) end

        -- Hide Overlay for Personal Frame

    if ( UnitGUID(frame.displayedUnit) == UnitGUID("player") ) then
        if ( frame.healthBar.border.Overlay ) then frame.healthBar.border.Overlay:Hide() end
    else
        if ( frame.healthBar.border.Overlay ) then frame.healthBar.border.Overlay:Show() end
    end
end
hooksecurefunc("CompactUnitFrame_UpdateHealthColor",UpdateHealthColor)

    -- Update Castbar Time

local function UpdateCastbarTimer(frame)

    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0.0 ) then
                frame.castBar.CastTime:SetText(nPlates.FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetText(nPlates.FormatTime(frame.castBar.value))
            end
        end
    end
end

local function UpdateCastbar(frame)

        -- Castbar Overlay Coloring

    local notInterruptible = select(9,UnitCastingInfo(frame.displayedUnit))

    if ( UnitCanAttack("player",frame.displayedUnit) ) then
        if ( notInterruptible ) then
            if ( frame.castBar.Border ) then frame.castBar.Border:SetVertexColor(.75,0,0,1) end
            if ( frame.castBar.Icon.Border ) then frame.castBar.Icon.Border:SetVertexColor(.75,0,0,1) end
        else
            if ( frame.castBar.Border ) then frame.castBar.Border:SetVertexColor(0,.75,0,1) end
            if ( frame.castBar.Icon.Border ) then frame.castBar.Icon.Border:SetVertexColor(0,.75,0,1) end
        end
    else
        if ( frame.castBar.Border ) then frame.castBar.Border:SetVertexColor(unpack(borderColor)) end
        if ( frame.castBar.Icon.Border ) then frame.castBar.Icon.Border:SetVertexColor(unpack(borderColor)) end
    end

        -- Backup Icon Background

    if ( frame.castBar.Icon.Background ) then
        local _,class = UnitClass(frame.displayedUnit)
        if ( not class ) then
            frame.castBar.Icon.Background:SetTexture("Interface\\Icons\\Ability_DualWield")
        else
            frame.castBar.Icon.Background:SetTexture("Interface\\Icons\\ClassIcon_"..class)
        end
    end

        -- Abbreviate Long Spell Names

    local spellName = frame.castBar.Text:GetText()
    if ( spellName ~= nil ) then
        spellName = (len(spellName) > 20) and gsub(spellName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or spellName
        frame.castBar.Text:SetText(spellName)
    end
end

    -- Setup Frames

local function NamePlateFrameSetup(frame, options)

        -- Name

    nPlates.NameSize(frame)

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:Hide()
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.5)
    frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.5)
    frame.healthBar:Show()
    frame.healthBar:SetStatusBarTexture(statusBar)

        -- Healthbar Border Overlay

    if ( not frame.healthBar.border.Overlay ) then
        frame.healthBar.border.Overlay = frame.healthBar.border:CreateTexture("$parentCustomTexture","BORDER")
        frame.healthBar.border.Overlay:SetTexture(overlayTexture)
        frame.healthBar.border.Overlay:SetTexCoord(0,0.921875,0,0.625)
        frame.healthBar.border.Overlay:Hide()
        frame.healthBar.border.Overlay:SetAllPoints(frame.healthBar.border)
        frame.healthBar.border.Overlay:SetPoint("TOPLEFT", frame.healthBar.border, -3.1, 3.1)
        frame.healthBar.border.Overlay:SetPoint("TOPRIGHT", frame.healthBar.border, 3.1, 3.1)
        frame.healthBar.border.Overlay:SetPoint("BOTTOMLEFT", frame.healthBar.border, -3.1, -3.1)
        frame.healthBar.border.Overlay:SetPoint("BOTTOMRIGHT", frame.healthBar.border, 3.1, -3.1)
        frame.healthBar.border.Overlay:SetVertexColor(unpack(borderColor))
        frame.healthBar.border.Overlay:Show()
    end

        -- Castbar

    local castbarFont = select(1,frame.castBar.Text:GetFont())

    frame.castBar:SetHeight(12)
    frame.castBar:SetStatusBarTexture(statusBar)

    if not frame.castBar.Border then
        frame.castBar.Border = frame.castBar:CreateTexture("$parentBorder", "BORDER")
        frame.castBar.Border:ClearAllPoints()
        frame.castBar.Border:SetTexture(overlayTexture)
        frame.castBar.Border:SetTexCoord(0,0.921875,0,0.625)
        frame.castBar.Border:SetVertexColor(unpack(borderColor))
        frame.castBar.Border:Hide()
        frame.castBar.Border:SetPoint("TOPLEFT", frame.castBar, -3.1, 3.1)
        frame.castBar.Border:SetPoint("TOPRIGHT", frame.castBar, 3.1, 3.1)
        frame.castBar.Border:SetPoint("BOTTOMLEFT", frame.castBar, -3.1, -3.1)
        frame.castBar.Border:SetPoint("BOTTOMRIGHT", frame.castBar, 3.1, -3.1)
        frame.castBar.Border:Show()
    end

        -- Border Shield

    frame.castBar.BorderShield:Hide()
    frame.castBar.BorderShield:ClearAllPoints()

        -- Spell Name

    frame.castBar.Text:Hide()
    frame.castBar.Text:ClearAllPoints()
    frame.castBar.Text:SetFont(castbarFont, 8.5)
    frame.castBar.Text:SetShadowOffset(.5, -.5)
    frame.castBar.Text:SetPoint("LEFT", frame.castBar, "LEFT", 2, 0)
    frame.castBar.Text:Show()

        -- Set Castbar Timer

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.CastTime:Hide()
        frame.castBar.CastTime:SetPoint("BOTTOMRIGHT", frame.castBar.Icon, "BOTTOMRIGHT", 0, 0)
        frame.castBar.CastTime:SetFont(castbarFont, 12, "OUTLINE")
        frame.castBar.CastTime:Show()
    end

        -- Castbar Icon

    frame.castBar.Icon:SetSize(24,24)
    frame.castBar.Icon:Hide()
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMRIGHT", 4.9, -0.5)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.castBar.Icon:Show()

        -- Castbar Icon Background

    if ( not frame.castBar.Icon.Background ) then
        frame.castBar.Icon.Background = frame.castBar:CreateTexture("$parentIconBackground", "BACKGROUND")
        frame.castBar.Icon.Background:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.castBar.Icon.Background:Hide()
        frame.castBar.Icon.Background:ClearAllPoints()
        frame.castBar.Icon.Background:SetAllPoints(frame.castBar.Icon)
        frame.castBar.Icon.Background:Show()
    end

        -- Castbar Icon Overlay

    if ( not frame.castBar.Icon.Border ) then
        frame.castBar.Icon.Border = frame.castBar:CreateTexture("$parentIconBorder", "BORDER")
        frame.castBar.Icon.Border:SetTexCoord(0, 1, 0, 1)
        frame.castBar.Icon.Border:Hide()
        frame.castBar.Icon.Border:ClearAllPoints()
        frame.castBar.Icon.Border:SetPoint("TOPRIGHT", frame.castBar.Icon, 2.5, 2.5)
        frame.castBar.Icon.Border:SetPoint("BOTTOMLEFT", frame.castBar.Icon, -2.5, -2.5)
        frame.castBar.Icon.Border:SetTexture(iconOverlay)
        frame.castBar.Icon.Border:SetVertexColor(unpack(borderColor))
        frame.castBar.Icon.Border:Show()
    end

        -- Update Castbar

    frame.castBar:SetScript("OnValueChanged", function(self, value)
        UpdateCastbarTimer(frame)
    end)

    frame.castBar:SetScript("OnShow", function(self)
        UpdateCastbar(frame)
    end)
end
hooksecurefunc("DefaultCompactNamePlateFrameSetup", NamePlateFrameSetup)

    -- Player Frame

local function InternalSetup(frame, setupOptions, frameOptions)
    frame.healthBar:SetHeight(12)
end
hooksecurefunc("DefaultCompactNamePlatePlayerFrameSetup", InternalSetup)

    -- Update Name

local function UpdateName(frame)
    if ( not nPlates.FrameIsNameplate(frame) ) then return end

    if ( not ShouldShowName(frame) ) then
        frame.name:Hide()
    else

            -- Friendly Nameplate Class Color

        if ( nPlatesDB.ShowClassColors and UnitIsPlayer(frame.displayedUnit) ) then
            frame.name:SetTextColor(frame.healthBar:GetStatusBarColor())
        end

            -- Shorten Long Names

        local newName = GetUnitName(frame.displayedUnit, nPlatesDB.ShowServerName) or UNKNOWN
        if ( nPlatesDB.AbrrevLongNames ) then
            newName = (len(newName) > 20) and gsub(newName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or newName
        end

            -- Level

        if ( nPlatesDB.ShowLevel ) then
            local playerLevel = UnitLevel("player")
            local targetLevel = UnitLevel(frame.displayedUnit)
            local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
            local levelColor = nPlates.RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

            if ( targetLevel == -1 ) then
                frame.name:SetText(newName)
            else
                frame.name:SetText("|cffffff00|r"..levelColor..targetLevel.."|r "..newName)
            end
        else
            frame.name:SetText(newName)
        end

            -- Color Name To Threat Status

        if ( nPlatesDB.ColorNameByThreat ) then
            local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
            if ( isTanking and threatStatus ) then
                if ( threatStatus >= 3 ) then
                    frame.name:SetTextColor(0,1,0)
                elseif ( threatStatus == 2 ) then
                    frame.name:SetTextColor(1,0.6,0.2)
                end
            end
        end
    end
end
hooksecurefunc("CompactUnitFrame_UpdateName", UpdateName)

    -- Buff Frame Offsets

local function ApplyOffsets(self)
    local targetMode = GetCVarBool("nameplateShowSelf") and GetCVarBool("nameplateResourceOnTarget")

    self.UnitFrame.BuffFrame:SetBaseYOffset(0);

    if ( targetMode ) then
        self.UnitFrame.BuffFrame:SetTargetYOffset(25)
    else
        self.UnitFrame.BuffFrame:SetTargetYOffset(0)
    end
end
hooksecurefunc(NamePlateBaseMixin,"ApplyOffsets",ApplyOffsets)

    -- Update Buff Frame Anchor

local function UpdateAnchor(self)
    local targetMode = GetCVarBool("nameplateShowSelf") and GetCVarBool("nameplateResourceOnTarget")
    local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target")
    local targetYOffset = isTarget and self:GetTargetYOffset() or 0.0
    local nameHeight = self:GetParent().name:GetHeight()

    if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
        if ( targetMode ) then
            if ( nPlates.IsUsingLargerNamePlateStyle() ) then
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset+5 )
            else
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, nameHeight+targetYOffset+5 )
            end
        else
            if ( nPlates.IsUsingLargerNamePlateStyle() ) then
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, 0 )
            else
                self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, nameHeight+5 )
            end
        end
    else
        self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 )
    end
end
hooksecurefunc(NameplateBuffContainerMixin,"UpdateAnchor",UpdateAnchor)