
local _, nPlates = ...
local cfg = nPlates.Config

local len = string.len
local gsub = string.gsub

local texturePath = 'Interface\\AddOns\\nPlates\\media\\'
local iconOverlay = texturePath..'textureIconOverlay'
local overlayTexture = texturePath..'textureOverlay'

local borderColor = {0.47, 0.47, 0.47}

DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(0, 0, 0, .55)

local function GetUnitReaction(r, g, b)
    if (g + b == 0) then
        return true
    end

    return false
end

local function RGBHex(r, g, b)
    if (type(r) == 'table') then
        if (r.r) then
            r, g, b = r.r, r.g, r.b
        else
            r, g, b = unpack(r)
        end
    end

    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local function FormatValue(number)
    if (number >= 1e6) then
        return tonumber(format('%.1f', number/1e6))..'m'
    elseif (number >= 1e3) then
        return tonumber(format('%.1f', number/1e3))..'k'
    else
        return number
    end
end

    -- Updated Health Text

local function UpdateHealthText(frame)
    local health = UnitHealth(frame.displayedUnit)
    local maxHealth = UnitHealthMax(frame.displayedUnit)
    local perc = (health/maxHealth)*100

    if (perc >= 100 and health > 5 and cfg.showFullHP) then
        frame.healthBar.healthString:SetFormattedText('%s', FormatValue(health))
    elseif (perc < 100 and health > 5) then
        frame.healthBar.healthString:SetFormattedText('%s - %.0f%%', FormatValue(health), perc-0.5)
    else
        frame.healthBar.healthString:SetText('')
    end
end

    -- Update Castbar

local function UpdateCastbar(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.maxValue - frame.castBar.value)
        else
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.value)
        end

        local r, g, b = frame.name:GetTextColor()
        frame.castBar.Icon.Overlay:SetVertexColor(r, g, b)
    end
end

    -- Setup Frames

local function SetupNamePlate(frame, setupOptions, frameOptions)

        -- Name

    frame.name:SetFont('Fonts\\ARIALN.ttf', 11, 'OUTLINE')

        -- Healthbar

    frame.healthBar:SetHeight(12)

    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.5);
    frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.5);

        -- Healthbar Overlay

    if not frame.healthBar.Overlay then
        frame.healthBar.Overlay = frame.healthBar:CreateTexture('$parentOverlay', 'BORDER')
        frame.healthBar.Overlay:ClearAllPoints()
        frame.healthBar.Overlay:SetTexture(overlayTexture)
        frame.healthBar.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.healthBar.Overlay:SetVertexColor(unpack(borderColor))
    end

        -- Update Health Text

    if (not frame.healthBar.healthString) then
        frame.healthBar.healthString = frame.healthBar:CreateFontString('$parentHeathValue', 'OVERLAY')
        frame.healthBar.healthString:SetPoint('CENTER', frame.healthBar, 0, 0)
        frame.healthBar.healthString:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')
    end

    frame.healthBar:SetScript('OnValueChanged', function()
        UpdateHealthText(frame)
    end)

        -- Castbar

    frame.castBar:SetHeight(12)

    if not frame.castBar.Overlay then
        frame.castBar.Overlay = frame.castBar:CreateTexture('$parentOverlay', 'BORDER')
        frame.castBar.Overlay:SetTexture(overlayTexture)
        frame.castBar.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.castBar.Overlay:SetVertexColor(unpack(borderColor))
    end

        -- Border Shield

    frame.castBar.BorderShield:ClearAllPoints()
    frame.castBar.BorderShield:SetPoint('CENTER',frame.castBar,'LEFT',-2.4,0)

        -- Spell Name

    frame.castBar.Text:ClearAllPoints()
    frame.castBar.Text:SetFont('Fonts\\ARIALN.ttf', 7.5)
    frame.castBar.Text:SetShadowOffset(1, -1)
    frame.castBar.Text:SetPoint('LEFT',frame.castBar, 'LEFT',4,0)

        -- Set Castbar Timer

    if (not frame.castBar.CastTime) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, 'OVERLAY')
        frame.castBar.CastTime:SetPoint('BOTTOMRIGHT', frame.castBar.Icon, 'BOTTOMRIGHT', 0, 0)
        frame.castBar.CastTime:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')
    end

    frame.castBar:SetScript('OnValueChanged', function()
        UpdateCastbar(frame)
    end)

        -- Castbar Icon

    frame.castBar.Icon:SetSize(24,24)
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint('BOTTOMLEFT', frame.castBar, 'BOTTOMRIGHT', 4.5, 0)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        -- Castbar Icon Background

    if (not frame.castBar.Icon.Background ) then
        frame.castBar.Icon.Background = frame.castBar:CreateTexture('$parentIconBackground', 'BACKGROUND')
        frame.castBar.Icon.Background:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.castBar.Icon.Background:ClearAllPoints()
        frame.castBar.Icon.Background:SetAllPoints(frame.castBar.Icon)
    end

        -- Castbar Icon Overlay

    if (not frame.castBar.Icon.Overlay ) then
        frame.castBar.Icon.Overlay = frame.castBar:CreateTexture('$parentIconOverlay', 'OVERLAY')
        frame.castBar.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.castBar.Icon.Overlay:ClearAllPoints()
        frame.castBar.Icon.Overlay:SetPoint('TOPRIGHT', frame.castBar.Icon, 2.5, 2.5)
        frame.castBar.Icon.Overlay:SetPoint('BOTTOMLEFT', frame.castBar.Icon, -2.5, -2.5)
        frame.castBar.Icon.Overlay:SetTexture(iconOverlay)
    end

        -- Set Healthbar / Castbar Overlay based on current nameplate scale.

    frame:SetScript('OnSizeChanged', function()
        frame.healthBar.Overlay:ClearAllPoints()
        frame.castBar.Overlay:ClearAllPoints()
        if tonumber(GetCVar("NamePlateVerticalScale")) == 1 then
            frame.healthBar.Overlay:SetPoint('TOPRIGHT', frame.healthBar, 29, 5.66666667)
            frame.healthBar.Overlay:SetPoint('BOTTOMLEFT', frame.healthBar, -30, -5.66666667)

            frame.castBar.Overlay:SetPoint('TOPRIGHT', frame.castBar, 29, 5.66666667)
            frame.castBar.Overlay:SetPoint('BOTTOMLEFT', frame.castBar, -30, -5.66666667)
        else
            frame.healthBar.Overlay:SetPoint('TOPRIGHT', frame.healthBar, 43, 5.66666667)
            frame.healthBar.Overlay:SetPoint('BOTTOMLEFT', frame.healthBar, -45, -5.66666667)

            frame.castBar.Overlay:SetPoint('TOPRIGHT', frame.castBar, 43, 5.66666667)
            frame.castBar.Overlay:SetPoint('BOTTOMLEFT', frame.castBar, -45, -5.66666667)
        end
    end)
end
hooksecurefunc('DefaultCompactNamePlateFrameSetupInternal', SetupNamePlate)

    -- Update Name

local function UpdateName(frame)

        -- Shorten Long Names

    local newName = GetUnitName(frame.displayedUnit, cfg.showServerName) or 'Unknown'
    if (cfg.abbrevLongNames) then
        newName = (len(newName) > 20) and gsub(newName, '%s?(.[\128-\191]*)%S+%s', '%1. ') or newName
    end

        -- Level

    if cfg.showLevel then
        local playerLevel = UnitLevel('player')
        local targetLevel = UnitLevel(frame.displayedUnit)
        local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
        local levelColor = RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

        if (targetLevel == -1) then
            frame.name:SetText(newName)
        else
            frame.name:SetText('|cffffff00|r'..levelColor..targetLevel..'|r '..newName)
        end
    else
        frame.name:SetText(newName)
    end

        -- Backup Icon Textures

    local _,class = UnitClass(frame.displayedUnit)
    if frame.castBar then
        if not class then
            frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\Ability_DualWield')
        else
            frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\ClassIcon_'..class)
        end
    end

        -- Color Name To Threat Status

    if cfg.colorNameWithThreat then
        local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
        if isTanking and threatStatus then
            if threatStatus >= 3 then
                frame.name:SetTextColor(0,1,0)
            elseif threatStatus == 2 then
                frame.name:SetTextColor(1,0.6,0.2)
            end
        end
    end
end
hooksecurefunc('CompactUnitFrame_UpdateName', UpdateName)

    -- Update Border Color

local function UpdateBorder(frame)
    local r,g,b = frame.healthBar:GetStatusBarColor()
    if frame.healthBar.Overlay then
        frame.healthBar.Overlay:SetVertexColor(r,g,b)
    end
end
hooksecurefunc('CompactUnitFrame_UpdateHealthBorder',UpdateBorder)

    -- Update Health Color

local function UpdateHealthColor(frame)
    if not cfg.enableTankMode then return end
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		if ( frame.optionTable.healthBarColorOverride ) then
			local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
		else
			--Try to color it by class.
			local localizedClass, englishClass = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[englishClass];
			if ( UnitIsPlayer(frame.unit) and classColor and frame.optionTable.useClassColors ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = 0.1, 0.1, 0.1;
			elseif ( frame.optionTable.colorHealthBySelection ) then
				-- Use color based on the type of unit (neutral, etc.)
				if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
                    if isTanking and threatStatus then
                        if threatStatus >= 3 then
                            r, g, b = 0.0, 1.0, 0.0;
                        elseif threatStatus == 2 then
                            r, g, b = 1.0, 0.6, 0.2;
                        end
                    else
                        r, g, b = 1.0, 0.0, 0.0;
                    end
                else
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
				end
			elseif ( UnitIsFriend("player", frame.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
		frame.healthBar:SetStatusBarColor(r, g, b);

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b);
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1);
		end
		
		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b;
	end
end
hooksecurefunc('CompactUnitFrame_UpdateHealthColor',UpdateHealthColor)