local addon, nPlates = ...

local playerFaction, _ = UnitFactionGroup("player")
local _, playerClass = UnitClass("player")

function nPlates_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("NAME_PLATE_CREATED")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("RAID_TARGET_UPDATE")
	self:RegisterEvent("UNIT_AURA")
end

function nPlates_OnEvent(self, event, ...)
    if ( event == "ADDON_LOADED" ) then
        local name = ...
        if ( name == "nPlates" ) then
            nPlates:SetDefaultOptions()
            nPlates:CVarCheck()
			self:UnregisterEvent("ADDON_LOADED")
        end
	elseif ( event == "NAME_PLATE_CREATED" ) then
		local nameplate = ...
		nPlates:AddHealthbarText(nameplate)
		nameplate.UnitFrame.isNameplate = true
	elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then
		local unit = ...
		nPlates:FixPlayerBorder(unit)
		nPlates:UpdateBuffFrameAnchorsByUnit(unit)
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		nPlates:UpdateAllBuffFrameAnchors()
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
		if ( nPlatesDB.CombatPlates ) then
			SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
		else
			SetCVar("nameplateShowEnemies", 1)
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		nPlates:UpdateRaidMarkerColoring()
	elseif ( event == "UNIT_AURA" ) then
		local unit = ...
		nPlates:UpdateBuffFrameAnchorsByUnit(unit)
    end
end

    -- Update Castbar Time

local function UpdateCastbarTimer(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0 ) then
                frame.castBar.CastTime:SetText(nPlates:FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetText(nPlates:FormatTime(frame.castBar.value))
            end
        end
    end
end

    --- Skin Castbar

local function UpdateCastbar(frame)

        -- Castbar Overlay Coloring

    local notInterruptible

    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            notInterruptible = select(9, UnitCastingInfo(frame.displayedUnit))
        else
            notInterruptible = select(8, UnitChannelInfo(frame.displayedUnit))
        end

        if ( UnitCanAttack("player", frame.displayedUnit) ) then
            if ( notInterruptible ) then
                nPlates:SetCastbarBorderColor(frame, nPlates.nonInterruptibleColor)
            else
                nPlates:SetCastbarBorderColor(frame, nPlates.interruptibleColor)
            end
        else
            nPlates:SetCastbarBorderColor(frame, nPlates.defaultBorderColor)
        end
    end

        -- Force Icon Texture

    if ( notInterruptible or not frame.castBar.Icon:IsVisible() and frame.castBar.Background ) then
        local _, class = UnitClass(frame.displayedUnit)
        if ( class ) then
            frame.castBar.Background:SetTexture("Interface\\Icons\\ClassIcon_"..class)
        else
            frame.castBar.Background:SetTexture("Interface\\Icons\\Ability_DualWield")
        end
        frame.castBar.Background:Show()
    else
        frame.castBar.Background:Hide()
    end

        -- Abbreviate Long Spell Names

    if ( not nPlates:IsUsingLargerNamePlateStyle() ) then
        local name = frame.castBar.Text:GetText()
        if ( name ) then
            name = nPlates:Abbrev(name, 20)
            frame.castBar.Text:SetText(name)
        end
    end
end

	-- Updated Health Text

hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
    if ( frame:IsForbidden() ) then return end
	if ( not frame.healthBar.value ) then
		return
	end

	local option = nPlatesDB.CurrentHealthOption

	if ( option ~= 1 ) then
		local health = UnitHealth(frame.displayedUnit)
		local maxHealth = UnitHealthMax(frame.displayedUnit)
		local perc = math.floor(100 * (health/maxHealth))

		if ( health > 5 ) then
			if ( option == 2 and perc >= 100 ) then
				frame.healthBar.value:SetFormattedText("%s", nPlates:FormatValue(health))
			elseif ( option == 2 ) then
				frame.healthBar.value:SetFormattedText("%s - %s%%", nPlates:FormatValue(health), perc)
			elseif ( option == 3 ) then
				frame.healthBar.value:SetFormattedText("%s", nPlates:FormatValue(health))
			elseif ( option == 4 ) then
				frame.healthBar.value:SetFormattedText("%s%%", perc)
			else
				frame.healthBar.value:SetText("")
			end
		else
			frame.healthBar.value:SetText("")
		end

		frame.healthBar.value:Show()
	else
		frame.healthBar.value:Hide()
	end
end)

    -- Update Health Color

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

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

            if ( frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) and classColor and nPlates:UseClassColors(playerFaction, frame.displayedUnit) ) then
                    r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
			elseif ( nPlatesDB.RaidMarkerColoring and raidMarker ) then
				local markerColor = nPlates.markerColors[tostring(raidMarker)]
				r, g, b = markerColor.r, markerColor.g, markerColor.b
            elseif ( nPlatesDB.FelExplosives and nPlates:IsPriority(frame.displayedUnit) ) then
                r, g, b = nPlatesDB.FelExplosivesColor.r, nPlatesDB.FelExplosivesColor.g, nPlatesDB.FelExplosivesColor.b
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and nPlates:IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    if ( nPlatesDB.TankMode ) then
                        local target = frame.displayedUnit.."target"
                        local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                        if ( isTanking and threatStatus ) then
                            if ( threatStatus >= 3 ) then
                                r, g, b = 0.0, 1.0, 0.0
                            elseif ( threatStatus == 2 ) then
                                r, g, b = 1.0, 0.6, 0.2
                            end
                        elseif ( nPlates:UseOffTankColor(target) ) then
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

    if ( nPlatesDB.ShowExecuteRange and nPlates:IsInExecuteRange(frame.displayedUnit) ) then
        r, g, b = nPlatesDB.ExecuteColor.r, nPlatesDB.ExecuteColor.g, nPlatesDB.ExecuteColor.b
    end

		-- Update Healthbar Color

    local cR,cG,cB = frame.healthBar:GetStatusBarColor()
    if ( r ~= cR or g ~= cG or b ~= cB ) then

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1.0, 1.0, 1.0)
        end

        frame.healthBar:SetStatusBarColor(r, g, b)
    end

        -- Update Border Color

	if ( frame.healthBar.beautyBorder ) then
		nPlates:SetHealthBorderColor(frame, r, g, b)
    end
end)

    -- Update Border Color

hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
    if ( frame:IsForbidden() ) then return end
	if ( not frame.isNameplate ) then return end

	if ( frame.healthBar.beautyBorder ) then
		local r, g, b = frame.healthBar:GetStatusBarColor()
		nPlates:SetHealthBorderColor(frame, r, g, b)
    end
end)

    -- Update Name

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( frame:IsForbidden() ) then return end
	if ( not frame.isNameplate ) then return end

        -- Hide Friendly Nameplates

    if ( nPlatesDB.HideFriendly ) then
        if ( UnitIsFriend(frame.displayedUnit, "player") and not
			 UnitCanAttack(frame.displayedUnit, "player") and not
			 UnitIsUnit(frame.displayedUnit, "player")
		) then
            frame.healthBar:Hide()
        else
            frame.healthBar:Show()
        end
	else
		frame.healthBar:Show()
    end

    if ( not ShouldShowName(frame) ) then
        frame.name:Hide()
    else

			-- Update Name Size

		nPlates:UpdateNameSize(frame)

            -- PvP Icon

        local pvpIcon = nPlates:PvPIcon(frame.displayedUnit)

            -- Class Color Names

        if ( UnitIsPlayer(frame.displayedUnit) ) then
            local r, g, b = frame.healthBar:GetStatusBarColor()
            frame.name:SetTextColor(r, g, b)
        end

            -- Shorten Long Names

        local name = GetUnitName(frame.displayedUnit, nPlatesDB.ShowServerName) or UNKNOWN
        if ( nPlatesDB.AbrrevLongNames ) then
            name = nPlates:Abbrev(name, 20)
        end

            -- Level

        if ( nPlatesDB.ShowLevel ) then
            local playerLevel = UnitLevel("player")
            local targetLevel = UnitLevel(frame.displayedUnit)
            local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
			local levelColor = nPlates:RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

            if ( targetLevel == -1 ) then
                frame.name:SetText(pvpIcon..name)
            else
                frame.name:SetText(pvpIcon.."|cffffff00|r"..levelColor..targetLevel.."|r "..name)
            end
        else
            frame.name:SetText(pvpIcon..name)
        end

            -- Color Name To Threat Status

        if ( nPlatesDB.ColorNameByThreat ) then
            local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
            if ( isTanking and threatStatus ) then
                if ( threatStatus >= 3 ) then
                    frame.name:SetTextColor(0.0, 1.0, 0.0)
                elseif ( threatStatus == 2 ) then
                    frame.name:SetTextColor(1.0, 0.6, 0.2)
                end
            else
                local target = frame.displayedUnit.."target"
                if ( nPlates:UseOffTankColor(target) ) then
                    frame.name:SetTextColor(nPlatesDB.OffTankColor.r, nPlatesDB.OffTankColor.g, nPlatesDB.OffTankColor.b)
                end
            end
        end
    end
end)

    -- Skin Nameplate

hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options)
	if ( frame:IsForbidden() ) then return end
	if ( not frame.isNameplate ) then return end

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.2)
    frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.2)
    frame.healthBar:SetStatusBarTexture(nPlates.statusBar)

    frame.healthBar.barTexture:SetTexture(nPlates.statusBar)

        -- Healthbar Border

	frame.healthBar.border:Hide()

    if ( not frame.healthBar.beautyBorder ) then
        nPlates:SetBorder(frame.healthBar)
    end

        -- Castbar

    frame.castBar:SetHeight(12)
    frame.castBar:SetStatusBarTexture(nPlates.statusBar)

        -- Castbar Border

    if ( not frame.castBar.beautyBorder ) then
        nPlates:SetBorder(frame.castBar)
    end

        -- Hide Border Shield

    frame.castBar.BorderShield:Hide()
    frame.castBar.BorderShield:ClearAllPoints()

        -- Spell Name

    frame.castBar.Text:ClearAllPoints()
    frame.castBar.Text:SetFont(nPlates.castbarFont, 8)
    frame.castBar.Text:SetShadowOffset(.5, -.5)
    frame.castBar.Text:SetPoint("LEFT", frame.castBar, "LEFT", 2, 0)

        -- Set Castbar Timer

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.CastTime:SetPoint("BOTTOMRIGHT", frame.castBar.Icon)
        frame.castBar.CastTime:SetFont(nPlates.castbarFont, 12, "OUTLINE")
    end

        -- Castbar Icon

    frame.castBar.Icon:SetSize(24, 24)
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMRIGHT", 4.9, 0)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        -- Castbar Icon Border

    if ( not frame.castBar.Icon.beautyBorder ) then
        nPlates:SetBorder(frame.castBar.Icon)
    end

        -- Castbar Icon Background

    if ( not frame.castBar.Background ) then
        frame.castBar.Background = frame.castBar:CreateTexture("$parent_Background", "BACKGROUND")
        frame.castBar.Background:SetAllPoints(frame.castBar.Icon)
        frame.castBar.Background:SetTexture("Interface\\Icons\\Ability_DualWield")
        frame.castBar.Background:SetTexCoord(0.1, 0.9, 0.1, 0.9)
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
	if ( not frame.isNameplate ) then return end

        -- Healthbar

    frame.healthBar:SetHeight(12)
end)
