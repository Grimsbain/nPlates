local addon, nPlates = ...

local unpack = unpack
local borderColor = {0.40, 0.40, 0.40, 1}
local castbarFont = SystemFont_Shadow_Small:GetFont()
local nameFont = SystemFont_NamePlate:GetFont()
local texturePath = "Interface\\AddOns\\nPlates\\media\\"
local statusBar = texturePath.."UI-StatusBar"
local playerFaction, _ = UnitFactionGroup("player")
local _, playerClass = UnitClass("player")

    -- Set Options

function nPlates_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("RAID_TARGET_UPDATE")
end

function nPlates_OnEvent(self, event, ...)
    if ( event == "ADDON_LOADED" ) then
        local name = ...
        if ( name == "nPlates" ) then
            nPlates.RegisterDefaultSetting("TankMode", false)
            nPlates.RegisterDefaultSetting("ColorNameByThreat", false)
            nPlates.RegisterDefaultSetting("ShowHP", true)
            nPlates.RegisterDefaultSetting("ShowCurHP", true)
            nPlates.RegisterDefaultSetting("ShowPercHP", true)
            nPlates.RegisterDefaultSetting("ShowFullHP", true)
            nPlates.RegisterDefaultSetting("ShowLevel", true)
            nPlates.RegisterDefaultSetting("ShowServerName", false)
            nPlates.RegisterDefaultSetting("AbrrevLongNames", true)
            nPlates.RegisterDefaultSetting("UseLargeNameFont", false)
            nPlates.RegisterDefaultSetting("HideFriendly", false)
            nPlates.RegisterDefaultSetting("SmallStacking", false)
            nPlates.RegisterDefaultSetting("ShowFriendlyClassColors", true)
            nPlates.RegisterDefaultSetting("ShowEnemyClassColors", true)
            nPlates.RegisterDefaultSetting("DontClamp", false)
            nPlates.RegisterDefaultSetting("ShowExecuteRange", false)
            nPlates.RegisterDefaultSetting("ExecuteValue", 35)
            nPlates.RegisterDefaultSetting("ExecuteColor", { r = 0, g = 71/255, b = 126/255})
            nPlates.RegisterDefaultSetting("UseOffTankColor", false)
            nPlates.RegisterDefaultSetting("OffTankColor", { r = 0.60, g = 0.20, b = 1.0})
            nPlates.RegisterDefaultSetting("ShowPvP", false)
            nPlates.RegisterDefaultSetting("FelExplosives", true)
            nPlates.RegisterDefaultSetting("FelExplosivesColor", { r = 197/255, g = 1, b = 0})
            nPlates.RegisterDefaultSetting("RaidMarkerColoring", false)

                -- Set CVars

            if not nPlates.IsTaintable() then
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

                -- Set small stacking nameplates.
                if ( nPlatesDB.SmallStacking ) then
                    SetCVar("nameplateOverlapH", 1.1) SetCVar("nameplateOverlapV", 0.9)
                else
                    for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do SetCVar(v, GetCVarDefault(v),true) end
                end
            end
        end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
			CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
		end
    end
end

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

    --- Skin Castbar

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
            spellName = nPlates.Abbrev(spellName,20)
            frame.castBar.Text:SetText(spellName)
        end
    end
end

    -- Updated Health Text

hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame.displayedUnit) ) then
        if ( frame.healthBar.healthString ) then
            frame.healthBar.healthString:Hide()
            return
        end
    end

    if ( nPlatesDB.ShowHP ) then
        if ( not frame.healthBar.healthString ) then
            frame.healthBar.healthString = frame.healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
            frame.healthBar.healthString:Hide()
            frame.healthBar.healthString:SetPoint("CENTER", frame.healthBar, 0, 0)
            frame.healthBar.healthString:SetFont(nameFont, 10)
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
        if ( nPlatesDB.ShowCurHP and perc >= 100 ) then
            frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
        elseif ( nPlatesDB.ShowCurHP and nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s - %s%%", nPlates.FormatValue(health), nPlates.FormatValue(perc))
        elseif ( nPlatesDB.ShowCurHP ) then
            frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
        elseif ( nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s%%", nPlates.FormatValue(perc))
        else
            frame.healthBar.healthString:SetText("")
        end
    elseif ( perc < 100 and health > 5 ) then
        if ( nPlatesDB.ShowCurHP and nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s - %s%%", nPlates.FormatValue(health), nPlates.FormatValue(perc))
        elseif ( nPlatesDB.ShowCurHP ) then
            frame.healthBar.healthString:SetFormattedText("%s", nPlates.FormatValue(health))
        elseif ( nPlatesDB.ShowPercHP ) then
            frame.healthBar.healthString:SetFormattedText("%s%%", nPlates.FormatValue(perc))
        else
            frame.healthBar.healthString:SetText("")
        end
    else
        frame.healthBar.healthString:SetText("")
    end
    frame.healthBar.healthString:Show()
end)

    -- Update Health Color

local MARKER_COLORS = {
	["1"] = { r = 1, g = 1, b = 0 },
	["2"] = { r = 1, g = 127/255, b = 63/255 },
	["3"] = { r = 163/255, g = 53/255, b = 238/255 },
	["4"] = { r = 30/255, g = 1, b = 0 },
	["5"] = { r = 170/255, g = 170/255, b = 221/255 },
	["6"] = { r = 0, g = 112/255, b = 221/255 },
	["7"] = { r = 1, g = 32/255, b = 32/255 },
	["8"] = { r = 1, g = 1, b = 1 },
}

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame.displayedUnit) ) then return end

	local r, g, b
    if ( not UnitIsConnected(frame.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
			local raidMarker = GetRaidTargetIndex(frame.displayedUnit)

            if ( UnitIsPlayer(frame.unit) and classColor and nPlates.UseClassColors(playerFaction,frame.displayedUnit) )then
                    r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
			elseif ( raidMarker ) then
				local markerColor = MARKER_COLORS[tostring(raidMarker)]
				r, g, b = markerColor.r, markerColor.g, markerColor.b
            elseif ( nPlates.IsPriority(frame.displayedUnit) and nPlatesDB.FelExplosives) then
                r, g, b = nPlatesDB.FelExplosivesColor.r, nPlatesDB.FelExplosivesColor.g, nPlatesDB.FelExplosivesColor.b
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and nPlates.IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    if ( nPlatesDB.TankMode ) then
                        local target = frame.displayedUnit.."target"
                        local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                        if ( isTanking and threatStatus ) then
                            if ( threatStatus >= 3 ) then
                                r, g, b = 0.0, 1.0, 0.0
                            elseif ( threatStatus == 2 ) then
                                r, g, b = 1.0, 0.6, 0.2
                            end
                        elseif ( nPlates.UseOffTankColor(target) ) then
                            r, g, b = nPlatesDB.OffTankColor.r, nPlatesDB.OffTankColor.g, nPlatesDB.OffTankColor.b
                        else
                            r, g, b = 1.0, 0.0, 0.0
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

        -- Execute Range Coloring

    if ( nPlatesDB.ShowExecuteRange and nPlates.IsInExecuteRange(frame.displayedUnit) ) then
        r, g, b = nPlatesDB.ExecuteColor.r, nPlatesDB.ExecuteColor.g, nPlatesDB.ExecuteColor.b
    end

    local cR,cG,cB = frame.healthBar:GetStatusBarColor()
    if ( r ~= cR or g ~= cG or b ~= cB ) then

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1, 1, 1)
        end

        frame.healthBar:SetStatusBarColor(r,g,b)
    end

        -- Healthbar Border Coloring

    if ( frame.healthBar.beautyBorder ) then
        for i = 1, 8 do
            if ( UnitIsUnit(frame.displayedUnit, "target") ) then
                frame.healthBar.beautyBorder[i]:SetVertexColor(r,g,b,1)
            else
                frame.healthBar.beautyBorder[i]:SetVertexColor(unpack(borderColor))
            end
        end
    end
end)

    -- Skin Nameplate

hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame:GetName()) ) then return end

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:Hide()
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.2)
    frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.2)
    frame.healthBar:SetStatusBarTexture(statusBar)
    frame.healthBar:Show()

    frame.healthBar.barTexture:SetTexture(statusBar)

        -- Healthbar Border

    if ( not frame.healthBar.beautyBorder ) then
        nPlates.SetBorder(frame.healthBar)
    end

        -- Castbar

    frame.castBar:SetHeight(12)
    frame.castBar:SetStatusBarTexture(statusBar)

        -- Castbar Border

    if ( not frame.castBar.beautyBorder ) then
        nPlates.SetBorder(frame.castBar)
    end

        -- Hide Border Shield

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
    frame.castBar.Icon:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMRIGHT", 4.9, 0)
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

        -- Castbar Icon Border

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

    -- Personal Resource Display

hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", function(frame, setupOptions, frameOptions)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame:GetName()) ) then return end

        -- Healthbar

    frame.healthBar:SetHeight(12)
end)

    -- Hide Beauty Border for Personal Frame

hooksecurefunc("CompactUnitFrame_UpdateHealthBorder", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame.displayedUnit) ) then return end

    if ( UnitGUID(frame.displayedUnit) == UnitGUID("player") ) then
        if ( frame.healthBar.border ) then frame.healthBar.border:Show() end
        if ( frame.healthBar.beautyBorder and frame.healthBar.beautyShadow ) then
            for i = 1, 8 do
                frame.healthBar.beautyBorder[i]:Hide()
                frame.healthBar.beautyShadow[i]:Hide()
            end
        end
    else
        if ( frame.healthBar.border ) then frame.healthBar.border:Hide() end
        if ( frame.healthBar.beautyBorder and frame.healthBar.beautyShadow ) then
            for i = 1, 8 do
                frame.healthBar.beautyBorder[i]:Show()
                frame.healthBar.beautyShadow[i]:Show()
            end
        end
    end
 end)

    -- Change Border Color on Target

hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame.displayedUnit) ) then return end

    local r,g,b = frame.healthBar:GetStatusBarColor()

    if ( frame.healthBar.beautyBorder ) then
        for i = 1, 8 do
            if ( UnitIsUnit(frame.displayedUnit, "target") ) then
                frame.healthBar.beautyBorder[i]:SetVertexColor(r,g,b,1)
            else
                frame.healthBar.beautyBorder[i]:SetVertexColor(unpack(borderColor))
            end
        end
    end
end)

    -- Update Name

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not nPlates.FrameIsNameplate(frame.displayedUnit) ) then return end

        -- Update Name Size

    nPlates.NameSize(frame)

        -- Hide Friendly Nameplates

    if ( nPlatesDB.HideFriendly ) then
        if ( UnitIsFriend(frame.displayedUnit,"player") and not UnitCanAttack(frame.displayedUnit,"player") ) then
            frame.healthBar:Hide()
        else
            frame.healthBar:Show()
        end
    end

    if ( not ShouldShowName(frame) ) then
        frame.name:Hide()
    else

            -- PvP Icon

        local pvpIcon = nPlates.PvPIcon(frame.displayedUnit)

            -- Class Color Names

        if ( UnitIsPlayer(frame.displayedUnit) ) then
            local r,g,b = frame.healthBar:GetStatusBarColor()
            frame.name:SetTextColor(r,g,b)
        end

            -- Shorten Long Names

        local newName = GetUnitName(frame.displayedUnit, nPlatesDB.ShowServerName) or UNKNOWN
        if ( nPlatesDB.AbrrevLongNames ) then
            newName = nPlates.Abbrev(newName,20)
        end

            -- Level

        if ( nPlatesDB.ShowLevel ) then
            local playerLevel = UnitLevel("player")
            local targetLevel = UnitLevel(frame.displayedUnit)
            local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
            local levelColor = nPlates.RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

            if ( targetLevel == -1 ) then
                frame.name:SetText(pvpIcon..newName)
            else
                frame.name:SetText(pvpIcon.."|cffffff00|r"..levelColor..targetLevel.."|r "..newName)
            end
        else
            frame.name:SetText(pvpIcon..newName or newName)
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
                if ( nPlates.UseOffTankColor(target) ) then
                    frame.name:SetTextColor(nPlatesDB.OffTankColor.r, nPlatesDB.OffTankColor.g, nPlatesDB.OffTankColor.b)
                end
            end
        end
    end
end)

    -- Buff Frame Offsets

local function UpdateBuffFrame(...)
    for _,v in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not v.UnitFrame:IsForbidden() ) then
            local bf = v.UnitFrame.BuffFrame

            if ( v.UnitFrame.displayedUnit and UnitShouldDisplayName(v.UnitFrame.displayedUnit) ) then
                bf.baseYOffset = v.UnitFrame.name:GetHeight()+1
            elseif ( v.UnitFrame.displayedUnit ) then
                bf.baseYOffset = 0
            end

            bf:UpdateAnchor()
        end
    end
end
NamePlateDriverFrame:HookScript("OnEvent", UpdateBuffFrame)
