
local _, nPlates = ...
local cfg = nPlates.Config

local len = string.len
local gsub = string.gsub

local texturePath = 'Interface\\AddOns\\nPlates\\media\\'
local iconOverlay = texturePath..'textureIconOverlay'

DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(0, 0, 0, .55)

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

    -- Update Castbar Timer

local function UpdateCastbarTime(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.maxValue - frame.castBar.value)
        else
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.value)
        end
    end
end

    -- Setup Frames

local function SetupNamePlate(frame, setupOptions, frameOptions)

        -- Name

    frame.name:SetFont('Fonts\\ARIALN.ttf', 11, 'OUTLINE')

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:CreateBeautyBorder(7)
    frame.healthBar:SetBeautyBorderPadding(1)
    frame.healthBar:SetBeautyShadowColor(0,0,0)

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
    frame.castBar:CreateBeautyBorder(7)
    frame.castBar:SetBeautyBorderPadding(1)
    frame.castBar:SetBeautyShadowColor(0,0,0)

        -- BorderShield

    frame.castBar.BorderShield:ClearAllPoints()
    frame.castBar.BorderShield:SetPoint('CENTER',frame.castBar,'LEFT',-2.2,0)

        -- Spell Name

    frame.castBar.Text:ClearAllPoints()
    frame.castBar.Text:SetFont('Fonts\\ARIALN.ttf', 8)
    frame.castBar.Text:SetShadowOffset(1, -1)
    frame.castBar.Text:SetPoint('LEFT',frame.castBar, 'LEFT',3,0)

        -- Set Castbar Timer

    if (not frame.castBar.CastTime) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, 'OVERLAY')
        frame.castBar.CastTime:SetPoint('RIGHT', frame.castBar, -1.6666667, 0)
        frame.castBar.CastTime:SetFont('Fonts\\ARIALN.ttf', 9)
        frame.castBar.CastTime:SetShadowOffset(1, -1)
    end

    frame.castBar:SetScript('OnValueChanged', function()
        UpdateCastbarTime(frame)
    end)

        -- Castbar Icon

    frame.castBar.Icon:SetSize(24,24)
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint('BOTTOMLEFT', frame.castBar, 'BOTTOMRIGHT', 4, .5)
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

        -- BeautyBroder for Personal Resource Display

    ClassNameplateManaBarFrame:CreateBeautyBorder(4)
    ClassNameplateManaBarFrame:SetBeautyBorderPadding(0)
    ClassNameplateManaBarFrame:SetBeautyShadowColor(0,0,0)
end
hooksecurefunc('DefaultCompactNamePlateFrameSetupInternal', SetupNamePlate)

    -- Update Name

local function UpdateName(frame)

        -- Shorten Long Names

    local newName = GetUnitName(frame.unit, showServerName)
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

        -- Icon Overlay Color / Backup Icon Textures

    local _,class = UnitClass(frame.displayedUnit)

    if not class then
        frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\Ability_DualWield')
        frame.castBar.Icon.Overlay:SetVertexColor(.5,.5,.5)
    else
        frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\ClassIcon_'..class)
        local r, g, b
        r = RAID_CLASS_COLORS[class].r
        g = RAID_CLASS_COLORS[class].g
        b = RAID_CLASS_COLORS[class].b
        frame.castBar.Icon.Overlay:SetVertexColor(r, g, b)
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