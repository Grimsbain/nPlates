
local ADDON, nPlates = ...

local len = string.len
local gsub = string.gsub

local texturePath = "Interface\\AddOns\\nPlates\\media\\"
local statusBar = texturePath.."UI-StatusBar"
local borderTexture = texturePath.."borderTexture"
local borderColor = {0.47, 0.47, 0.47, 1}

    -- First Run Settings

if ( nPlatesDB == nil ) then
    nPlatesDB = {
        ["TankMode"] = false,
        ["ColorNameByThreat"] = false,
        ["ShowHP"] = true,
        ["ShowCurHP"] = true,
        ["ShowPercHP"] = true,
        ["ShowFullHP"] = true,
        ["ShowLevel"] = true,
        ["ShowServerName"] = false,
        ["AbrrevLongNames"] = true,
        ["UseLargeNameFont"] = false,
        ["HideFriendly"] = false,
        ["ShowClassColors"] = true,
        ["DontClamp"] = false,
        ["ShowTotemIcon"] = false,
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

        -- Set sticky nameplates.
        if ( not nPlatesDB.DontClamp ) then
            SetCVar("nameplateOtherTopInset", -1,true)
            SetCVar("nameplateOtherBottomInset", -1,true)
        else
            for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
        end
    end
end)

    -- Updated Health Text

hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
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
        if ( nPlatesDB.ShowCurHP and nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s - %.0f%%", nPlates.FormatValue(health), perc-0.5)
        elseif ( nPlatesDB.ShowCurHP ) then
            frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
        elseif ( nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%.0f%%", perc-0.5)
        else
            frame.healthBar.healthString:SetText("")
        end
    elseif ( perc < 100 and health > 5 ) then
        if ( nPlatesDB.ShowCurHP and nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s - %.0f%%", nPlates.FormatValue(health), perc-0.5)
        elseif ( nPlatesDB.ShowCurHP ) then
            frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
        elseif ( nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%.0f%%", perc-0.5)
        else
            frame.healthBar.healthString:SetText("")
        end
    else
        frame.healthBar.healthString:SetText("")
    end
    frame.healthBar.healthString:Show()
end)

    -- Update Health Color

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
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
                        local target = frame.displayedUnit.."target"
                        if ( nPlates.PlayerIsTank(target) and nPlates.PlayerIsTank("player") and not UnitIsUnit("player",target) ) then
                            r, g, b = 0.60, 0.20, 1.0
                        else
                            r, g, b = 1.0, 0.0, 0.0
                        end
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

    if ( frame.healthBar.beautyBorder ) then
        for i = 1, 8 do
            frame.healthBar.beautyBorder[i]:SetVertexColor(r/2,g/2,b/2,1)
        end
    end
        -- Hide Overlay for Personal Frame

    if ( UnitGUID(frame.displayedUnit) == UnitGUID("player") ) then
        if ( frame.healthBar.beautyBorder ) then
            for i = 1, 8 do
                frame.healthBar.beautyBorder[i]:Hide()
            end
        end
    else
        if ( frame.healthBar.beautyBorder ) then
            for i = 1, 8 do
                frame.healthBar.beautyBorder[i]:Show()
            end
        end
    end
end)

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

    local notInterruptible
    local red = {.75,0,0,1}
    local green = {0,.75,0,1}

    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            notInterruptible = select(9,UnitCastingInfo(frame.displayedUnit))
        else
            notInterruptible = select(8,UnitChannelInfo(frame.displayedUnit))
        end

        if ( UnitCanAttack("player",frame.displayedUnit) ) then
            if ( notInterruptible ) then
                nPlates.SetManabarColors(frame,red)
            else
                nPlates.SetManabarColors(frame,green)
            end
        else
            nPlates.SetManabarColors(frame,borderColor)
        end
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

    if ( not nPlates.IsUsingLargerNamePlateStyle() ) then
        local spellName = frame.castBar.Text:GetText()
        if ( spellName ~= nil ) then
            spellName = (len(spellName) > 20) and gsub(spellName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or spellName
            frame.castBar.Text:SetText(spellName)
        end
    end
end

    -- Setup Frames

local listener = CreateFrame("Frame")
listener:RegisterEvent("NAME_PLATE_CREATED")
listener:SetScript("OnEvent", function(self, event, ...)
    if ( event == "NAME_PLATE_CREATED" ) then
        hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options, ...)

                -- Name

            nPlates.NameSize(frame)

                -- Healthbar

            frame.healthBar:SetHeight(12)
            frame.healthBar:Hide()
            frame.healthBar:ClearAllPoints()
            frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.5)
            frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.5)
            frame.healthBar:SetStatusBarTexture(statusBar)
            frame.healthBar:Show()

                -- Healthbar Border Overlay

            if (not frame.healthBar.beautyBorder) then
                local padding = 2
                frame.healthBar.beautyBorder = {}
                for i = 1, 8 do
                    frame.healthBar.beautyBorder[i] = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                    frame.healthBar.beautyBorder[i]:SetParent(frame.healthBar)
                    frame.healthBar.beautyBorder[i]:SetTexture(borderTexture)
                    frame.healthBar.beautyBorder[i]:SetSize(8, 8)
                    frame.healthBar.beautyBorder[i]:SetVertexColor(unpack(borderColor))
                    frame.healthBar.beautyBorder[i]:Hide()
                end

                frame.healthBar.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
                frame.healthBar.beautyBorder[1]:SetPoint('TOPLEFT', frame.healthBar, -padding, padding)

                frame.healthBar.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
                frame.healthBar.beautyBorder[2]:SetPoint('TOPRIGHT', frame.healthBar, padding, padding)

                frame.healthBar.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
                frame.healthBar.beautyBorder[3]:SetPoint('BOTTOMLEFT', frame.healthBar, -padding, -padding)

                frame.healthBar.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
                frame.healthBar.beautyBorder[4]:SetPoint('BOTTOMRIGHT', frame.healthBar, padding, -padding)

                frame.healthBar.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
                frame.healthBar.beautyBorder[5]:SetPoint('TOPLEFT', frame.healthBar.beautyBorder[1], 'TOPRIGHT')
                frame.healthBar.beautyBorder[5]:SetPoint('TOPRIGHT', frame.healthBar.beautyBorder[2], 'TOPLEFT')

                frame.healthBar.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
                frame.healthBar.beautyBorder[6]:SetPoint('BOTTOMLEFT', frame.healthBar.beautyBorder[3], 'BOTTOMRIGHT')
                frame.healthBar.beautyBorder[6]:SetPoint('BOTTOMRIGHT', frame.healthBar.beautyBorder[4], 'BOTTOMLEFT')

                frame.healthBar.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
                frame.healthBar.beautyBorder[7]:SetPoint('TOPLEFT', frame.healthBar.beautyBorder[1], 'BOTTOMLEFT')
                frame.healthBar.beautyBorder[7]:SetPoint('BOTTOMLEFT', frame.healthBar.beautyBorder[3], 'TOPLEFT')

                frame.healthBar.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
                frame.healthBar.beautyBorder[8]:SetPoint('TOPRIGHT', frame.healthBar.beautyBorder[2], 'BOTTOMRIGHT')
                frame.healthBar.beautyBorder[8]:SetPoint('BOTTOMRIGHT', frame.healthBar.beautyBorder[4], 'TOPRIGHT')

                for i = 1, 8 do
                    frame.healthBar.beautyBorder[i]:Show()
                end
            end

                -- Castbar

            local castbarFont = select(1,frame.castBar.Text:GetFont())

            frame.castBar:SetHeight(12)
            frame.castBar:SetStatusBarTexture(statusBar)

            if (not frame.castBar.beautyBorder) then
                local padding = 2
                frame.castBar.beautyBorder = {}
                for i = 1, 8 do
                    frame.castBar.beautyBorder[i] = frame.castBar:CreateTexture(nil, 'OVERLAY')
                    frame.castBar.beautyBorder[i]:SetParent(frame.castBar)
                    frame.castBar.beautyBorder[i]:SetTexture(borderTexture)
                    frame.castBar.beautyBorder[i]:SetSize(8, 8)
                    frame.castBar.beautyBorder[i]:SetVertexColor(unpack(borderColor))
                    frame.castBar.beautyBorder[i]:Hide()
                end

                frame.castBar.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
                frame.castBar.beautyBorder[1]:SetPoint('TOPLEFT', frame.castBar, -padding, padding)

                frame.castBar.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
                frame.castBar.beautyBorder[2]:SetPoint('TOPRIGHT', frame.castBar, padding, padding)

                frame.castBar.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
                frame.castBar.beautyBorder[3]:SetPoint('BOTTOMLEFT', frame.castBar, -padding, -padding)

                frame.castBar.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
                frame.castBar.beautyBorder[4]:SetPoint('BOTTOMRIGHT', frame.castBar, padding, -padding)

                frame.castBar.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
                frame.castBar.beautyBorder[5]:SetPoint('TOPLEFT', frame.castBar.beautyBorder[1], 'TOPRIGHT')
                frame.castBar.beautyBorder[5]:SetPoint('TOPRIGHT', frame.castBar.beautyBorder[2], 'TOPLEFT')

                frame.castBar.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
                frame.castBar.beautyBorder[6]:SetPoint('BOTTOMLEFT', frame.castBar.beautyBorder[3], 'BOTTOMRIGHT')
                frame.castBar.beautyBorder[6]:SetPoint('BOTTOMRIGHT', frame.castBar.beautyBorder[4], 'BOTTOMLEFT')

                frame.castBar.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
                frame.castBar.beautyBorder[7]:SetPoint('TOPLEFT', frame.castBar.beautyBorder[1], 'BOTTOMLEFT')
                frame.castBar.beautyBorder[7]:SetPoint('BOTTOMLEFT', frame.castBar.beautyBorder[3], 'TOPLEFT')

                frame.castBar.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
                frame.castBar.beautyBorder[8]:SetPoint('TOPRIGHT', frame.castBar.beautyBorder[2], 'BOTTOMRIGHT')
                frame.castBar.beautyBorder[8]:SetPoint('BOTTOMRIGHT', frame.castBar.beautyBorder[4], 'TOPRIGHT')

                for i = 1, 8 do
                    frame.castBar.beautyBorder[i]:Show()
                end
            end

                -- Border Shield

            frame.castBar.BorderShield:Hide()
            frame.castBar.BorderShield:ClearAllPoints()

                -- Spell Name

            frame.castBar.Text:Hide()
            frame.castBar.Text:ClearAllPoints()
            frame.castBar.Text:SetFont(castbarFont, 8)
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

            if ( not frame.castBar.Icon.beautyBorder ) then
                nPlates.SetBorder(frame.castBar.Icon)
            end

                -- Update Castbar

            frame.castBar:SetScript("OnValueChanged", function(self, value)
                UpdateCastbarTimer(frame)
            end)

            frame.castBar:SetScript("OnShow", function(self)
                UpdateCastbar(frame)
            end)
        end)
    end
end)

    -- Player Frame

hooksecurefunc("DefaultCompactNamePlatePlayerFrameSetup", function(frame, setupOptions, frameOptions)
    frame.healthBar:SetHeight(12)
end)

    -- Update Name

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( not nPlates.FrameIsNameplate(frame) ) then return end

        -- Totem Icon

    if ( nPlatesDB.ShowTotemIcon ) then
        nPlates.UpdateTotemIcon(frame)
    end

        -- Hide Friendly Nameplates

    if ( UnitIsFriend(frame.displayedUnit,"player") and not UnitCanAttack(frame.displayedUnit,"player") and nPlatesDB.HideFriendly ) then
        frame.healthBar:Hide()
    else
        frame.healthBar:Show()
    end

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
            else
                local target = frame.displayedUnit.."target"
                if ( UnitPlayerOrPetInRaid(target) or UnitPlayerOrPetInParty(target) ) then
                    if ( nPlates.PlayerIsTank(target) and nPlates.PlayerIsTank("player") and not UnitIsUnit("player",target) ) then
                        frame.name:SetTextColor(0.60, 0.20, 1.0)
                    end
                end
            end
        end
    end
end)

    -- Buff Frame Offsets

hooksecurefunc(NamePlateBaseMixin,"ApplyOffsets", function(self)
    local targetMode = GetCVarBool("nameplateShowSelf") and GetCVarBool("nameplateResourceOnTarget")

    self.UnitFrame.BuffFrame:SetBaseYOffset(0)

    if ( targetMode ) then
        self.UnitFrame.BuffFrame:SetTargetYOffset(25)
    else
        self.UnitFrame.BuffFrame:SetTargetYOffset(0)
    end
end)

    -- Update Buff Frame Anchor

hooksecurefunc(NameplateBuffContainerMixin,"UpdateAnchor", function(self)
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
end)