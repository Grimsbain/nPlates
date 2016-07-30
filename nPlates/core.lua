
local _, nPlates = ...
local cfg = nPlates.Config

local len = string.len
local gsub = string.gsub

local texturePath = 'Interface\\AddOns\\nPlates\\media\\'
local statusBar = texturePath..'UI-StatusBar'
local overlayTexture = texturePath..'textureOverlay'
local iconOverlay = texturePath..'textureIconOverlay'
local borderColor = {0.47, 0.47, 0.47}

    -- Set DefaultCompactNamePlate Options

local groups = {
    'Friendly',
    'Enemy',
}

local options = {
    displaySelectionHighlight = cfg.displaySelectionHighlight,
    showClassificationIndicator = cfg.showClassificationIndicator,

    tankBorderColor = false,
    selectedBorderColor = false,
    defaultBorderColor = false,
}

for i, group  in next, groups do
    for key, value in next, options do
        _G['DefaultCompactNamePlate'..group..'FrameOptions'][key] = value
    end
end

    -- Set CVar Options

C_Timer.After(.1, function()
    if not InCombatLockdown() then
        -- Nameplate Scale
        if ( cfg.nameplateScale ) then
            SetCVar('nameplateGlobalScale', cfg.nameplateScale)
        else
            SetCVar('nameplateGlobalScale', GetCVarDefault('nameplateGlobalScale'))
        end

        -- Sets nameplate non-target alpha.
        if ( cfg.nameplateMinAlpha ) then
            SetCVar('nameplateMinAlpha', cfg.nameplateMinAlpha)
        else
            SetCVar('nameplateMinAlpha', GetCVarDefault('nameplateMinAlpha'))
        end

        -- Set min and max scale. (For performance issues.)
        SetCVar('namePlateMinScale', 1)
        SetCVar('namePlateMaxScale', 1)

        -- Stop nameplates from clamping to screen.
        if ( cfg.dontClampToBorder ) then
            SetCVar('nameplateOtherTopInset', -1)
            SetCVar('nameplateOtherBottomInset', -1)
        else
            for _, v in pairs({'nameplateOtherTopInset', 'nameplateOtherBottomInset'}) do SetCVar(v, GetCVarDefault(v)) end
        end
    end
end)

local function RGBHex(r, g, b)
    if ( type(r) == 'table' ) then
        if ( r.r ) then
            r, g, b = r.r, r.g, r.b
        else
            r, g, b = unpack(r)
        end
    end

    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local function FormatValue(number)
    if number < 1e3 then
        return floor(number)
    elseif number >= 1e12 then
        return string.format('%.3ft', number/1e12)
    elseif number >= 1e9 then
        return string.format('%.3fb', number/1e9)
    elseif number >= 1e6 then
        return string.format('%.2fm', number/1e6)
    elseif number >= 1e3 then
        return string.format('%.1fk', number/1e3)
    end
end

local function FormatTime(s)
    if s > 86400 then
        -- Days
        return ceil(s/86400) .. 'd', s%86400
    elseif s >= 3600 then
        -- Hours
        return ceil(s/3600) .. 'h', s%3600
    elseif s >= 60 then
        -- Minutes
        return ceil(s/60) .. 'm', s%60
    elseif s <= 10 then
        -- Seconds
        return format('%.1f', s)
    end

    return floor(s), s - floor(s)
end

    -- Check for 'Larger Nameplates'

local function IsUsingLargerNamePlateStyle()
    local namePlateVerticalScale = tonumber(GetCVar('NamePlateVerticalScale'))
    return namePlateVerticalScale > 1.0
end

    -- Totem Data and Functions

local function TotemName(SpellID)
    local name = GetSpellInfo(SpellID)
    return name
end

local totemData = {
    [TotemName(192058)] = 'Interface\\Icons\\spell_nature_brilliance',          -- Lightning Surge Totem
    [TotemName(98008)]  = 'Interface\\Icons\\spell_shaman_spiritlink',          -- Spirit Link Totem
    [TotemName(192077)] = 'Interface\\Icons\\ability_shaman_windwalktotem',     -- Wind Rush Totem
    [TotemName(204331)] = 'Interface\\Icons\\spell_nature_wrathofair_totem',    -- Counterstrike Totem
    [TotemName(204332)] = 'Interface\\Icons\\spell_nature_windfury',            -- Windfury Totem
    [TotemName(204336)] = 'Interface\\Icons\\spell_nature_groundingtotem',      -- Grounding Totem
    -- Water
    [TotemName(157153)] = 'Interface\\Icons\\ability_shaman_condensationtotem', -- Cloudburst Totem
    [TotemName(5394)]   = 'Interface\\Icons\\INV_Spear_04',                     -- Healing Stream Totem
    [TotemName(108280)] = 'Interface\\Icons\\ability_shaman_healingtide',       -- Healing Tide Totem
    -- Earth
    [TotemName(207399)] = 'Interface\\Icons\\spell_nature_reincarnation',       -- Ancestral Protection Totem
    [TotemName(198838)] = 'Interface\\Icons\\spell_nature_stoneskintotem',      -- Earthen Shield Totem
    [TotemName(51485)]  = 'Interface\\Icons\\spell_nature_stranglevines',       -- Earthgrab Totem
    [TotemName(61882)]  = 'Interface\\Icons\\spell_shaman_earthquake',          -- Earthquake Totem
    [TotemName(196932)] = 'Interface\\Icons\\spell_totem_wardofdraining',       -- Voodoo Totem
    -- Fire
    [TotemName(192222)] = 'Interface\\Icons\\spell_shaman_spewlava',            -- Liquid Magma Totem
    [TotemName(204330)] = 'Interface\\Icons\\spell_fire_totemofwrath',          -- Skyfury Totem
    -- Totem Mastery
    [TotemName(202188)] = 'Interface\\Icons\\spell_nature_stoneskintotem',      -- Resonance Totem
    [TotemName(210651)] = 'Interface\\Icons\\spell_shaman_stormtotem',          -- Storm Totem
    [TotemName(210657)] = 'Interface\\Icons\\spell_fire_searingtotem',          -- Ember Totem
    [TotemName(210660)] = 'Interface\\Icons\\spell_nature_invisibilitytotem',   -- Tailwind Totem
}

local function UpdateTotemIcon(frame)
    if string.match(frame.displayedUnit,'nameplate') ~= 'nameplate' then return end
    local name = UnitName(frame.displayedUnit)

    if name == nil then return end
    if (totemData[name]) then
        if (not frame.TotemIcon) then
            frame.TotemIcon = CreateFrame('Frame', '$parentTotem', frame)
            frame.TotemIcon:EnableMouse(false)
            frame.TotemIcon:SetSize(24, 24)
            frame.TotemIcon:Hide()
            frame.TotemIcon:SetPoint('BOTTOM', frame.BuffFrame, 'TOP', 0, 10)
            frame.TotemIcon:Show()
        end

        if (not frame.TotemIcon.Icon) then
            frame.TotemIcon.Icon = frame.TotemIcon:CreateTexture('$parentIcon','BACKGROUND')
            frame.TotemIcon.Icon:SetSize(24,24)
            frame.TotemIcon.Icon:Hide()
            frame.TotemIcon.Icon:SetAllPoints(frame.TotemIcon)
            frame.TotemIcon.Icon:SetTexture(totemData[name])
            frame.TotemIcon.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.TotemIcon.Icon:Show()
        end

        if (not frame.TotemIcon.Icon.Overlay) then
            frame.TotemIcon.Icon.Overlay = frame.TotemIcon:CreateTexture('$parentOverlay', 'OVERLAY')
            frame.TotemIcon.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
            frame.TotemIcon.Icon.Overlay:Hide()
            frame.TotemIcon.Icon.Overlay:ClearAllPoints()
            frame.TotemIcon.Icon.Overlay:SetPoint('TOPRIGHT', frame.TotemIcon.Icon, 2.5, 2.5)
            frame.TotemIcon.Icon.Overlay:SetPoint('BOTTOMLEFT', frame.TotemIcon.Icon, -2.5, -2.5)
            frame.TotemIcon.Icon.Overlay:SetTexture(iconOverlay)
            frame.TotemIcon.Icon.Overlay:SetVertexColor(unpack(borderColor))
            frame.TotemIcon.Icon.Overlay:Show()
        end
    else
        if (frame.TotemIcon) then
            frame.TotemIcon:Hide()
        end
    end
end

    -- Updated Health Text

local function UpdateHealthText(frame)
    if ( string.match(frame.displayedUnit,'nameplate') ~= 'nameplate' or not cfg.showHP ) then return end

    local health = UnitHealth(frame.displayedUnit)
    local maxHealth = UnitHealthMax(frame.displayedUnit)
    local perc = (health/maxHealth)*100

    if ( not frame.healthBar.healthString ) then
        frame.healthBar.healthString = frame.healthBar:CreateFontString('$parentHeathValue', 'OVERLAY')
        frame.healthBar.healthString:Hide()
        frame.healthBar.healthString:SetPoint('CENTER', frame.healthBar, 0, 0)
        frame.healthBar.healthString:SetFont('Fonts\\ARIALN.ttf', 10)--, 'OUTLINE')
        frame.healthBar.healthString:SetShadowOffset(.5, -.5)
    end

    if ( perc >= 100 and health > 5 and cfg.showFullHP ) then
        frame.healthBar.healthString:SetFormattedText('%s', FormatValue(health))
    elseif ( perc < 100 and health > 5 ) then
        frame.healthBar.healthString:SetFormattedText('%s - %.0f%%', FormatValue(health), perc-0.5)
    else
        frame.healthBar.healthString:SetText('')
    end
    frame.healthBar.healthString:Show()
end
hooksecurefunc('CompactUnitFrame_UpdateStatusText',UpdateHealthText)

    -- Update Health Color

local function UpdateHealthColor(frame)
    if ( string.match(frame.displayedUnit,'nameplate') ~= 'nameplate' ) then return end

    if ( not UnitIsConnected(frame.unit) ) then
        local r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            if ( UnitIsPlayer(frame.unit) and classColor and frame.optionTable.useClassColors ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) and cfg.enableTankMode ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
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
            elseif ( UnitIsFriend('player', frame.unit) ) then
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

    r,g,b = frame.healthBar:GetStatusBarColor()
    if ( frame.healthBar.Overlay ) then
        frame.healthBar.Overlay:SetVertexColor(r,g,b)

        if ( UnitIsUnit(frame.displayedUnit,'player') ) then
            frame.healthBar.Overlay:Hide()
        else
            frame.healthBar.border:Hide()
        end
    end
end
hooksecurefunc('CompactUnitFrame_UpdateHealthColor',UpdateHealthColor)

    -- Update Castbar

local function UpdateCastbar(frame)

        -- Cast Time

    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0.0 ) then
                frame.castBar.CastTime:SetText(FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetFormattedText('%.1f', frame.castBar.value)
            end
        end
    end

            -- Castbar Overlay Coloring / Icon Background

    if ( frame.castBar.Overlay ) then frame.castBar.Overlay:SetVertexColor(r,g,b) end
    if ( frame.castBar.Icon.Overlay ) then frame.castBar.Icon.Overlay:SetVertexColor(r, g, b) end

    if ( frame.castBar.Icon.Background ) then
        local _,class = UnitClass(frame.displayedUnit)

        if ( not class ) then
            frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\Ability_DualWield')
        else
            frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\ClassIcon_'..class)
        end
    end
end

    -- Setup Frames

local function SetupNamePlate(frame, options)

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:Hide()
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint('BOTTOMLEFT', frame.castBar, 'TOPLEFT', 0, 4.5)
    frame.healthBar:SetPoint('BOTTOMRIGHT', frame.castBar, 'TOPRIGHT', 0, 4.5)
    frame.healthBar:Show()
    frame.healthBar:SetStatusBarTexture(statusBar)

        -- Healthbar Overlay

    if not frame.healthBar.Overlay then
        frame.healthBar.Overlay = frame.healthBar:CreateTexture('$parentOverlay', 'BORDER')
        frame.healthBar.Overlay:ClearAllPoints()
        frame.healthBar.Overlay:SetTexture(overlayTexture)
        frame.healthBar.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.healthBar.Overlay:SetVertexColor(unpack(borderColor))
        frame.healthBar.Overlay:Hide()
        if ( not IsUsingLargerNamePlateStyle() ) then
            frame.healthBar.Overlay:SetPoint('TOPRIGHT', frame.healthBar, 29, 5.66666667)
            frame.healthBar.Overlay:SetPoint('BOTTOMLEFT', frame.healthBar, -30, -5.66666667)
        else
            frame.healthBar.Overlay:SetPoint('TOPRIGHT', frame.healthBar, 43, 5.66666667)
            frame.healthBar.Overlay:SetPoint('BOTTOMLEFT', frame.healthBar, -45, -5.66666667)
        end
        frame.healthBar.Overlay:Show()
    end

        -- Castbar

    frame.castBar:SetHeight(12)
    frame.castBar:SetStatusBarTexture(statusBar)

    if not frame.castBar.Overlay then
        frame.castBar.Overlay = frame.castBar:CreateTexture('$parentOverlay', 'BORDER')
        frame.castBar.Overlay:ClearAllPoints()
        frame.castBar.Overlay:SetTexture(overlayTexture)
        frame.castBar.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.castBar.Overlay:SetVertexColor(unpack(borderColor))
        frame.castBar.Overlay:Hide()
        if ( not IsUsingLargerNamePlateStyle() ) then
            frame.castBar.Overlay:SetPoint('TOPRIGHT', frame.castBar, 29, 5.66666667)
            frame.castBar.Overlay:SetPoint('BOTTOMLEFT', frame.castBar, -30, -5.66666667)
        else
            frame.castBar.Overlay:SetPoint('TOPRIGHT', frame.castBar, 43, 5.66666667)
            frame.castBar.Overlay:SetPoint('BOTTOMLEFT', frame.castBar, -45, -5.66666667)
        end
        frame.castBar.Overlay:Show()
    end

        -- Border Shield

    frame.castBar.BorderShield:Hide()
    frame.castBar.BorderShield:ClearAllPoints()
    frame.castBar.BorderShield:SetPoint('CENTER',frame.castBar,'LEFT',-2.4,0)
    frame.castBar.BorderShield:Show()

        -- Spell Name

    frame.castBar.Text:Hide()
    frame.castBar.Text:ClearAllPoints()
    frame.castBar.Text:SetFont('Fonts\\ARIALN.ttf', 7.5)
    frame.castBar.Text:SetShadowOffset(.5, -.5)
    frame.castBar.Text:SetPoint('LEFT',frame.castBar, 'LEFT',4,0)
    frame.castBar.Text:Show()

        -- Set Castbar Timer

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, 'OVERLAY')
        frame.castBar.CastTime:Hide()
        frame.castBar.CastTime:SetPoint('BOTTOMRIGHT', frame.castBar.Icon, 'BOTTOMRIGHT', 0, 0)
        frame.castBar.CastTime:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')
        frame.castBar.CastTime:Show()
    end

        -- Castbar Icon

    frame.castBar.Icon:SetSize(24,24)
    frame.castBar.Icon:Hide()
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint('BOTTOMLEFT', frame.castBar, 'BOTTOMRIGHT', 4.5, 0)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.castBar.Icon:Show()

        -- Castbar Icon Background

    if ( not frame.castBar.Icon.Background ) then
        frame.castBar.Icon.Background = frame.castBar:CreateTexture('$parentIconBackground', 'BACKGROUND')
        frame.castBar.Icon.Background:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.castBar.Icon.Background:Hide()
        frame.castBar.Icon.Background:ClearAllPoints()
        frame.castBar.Icon.Background:SetAllPoints(frame.castBar.Icon)
        frame.castBar.Icon.Background:Show()
    end

        -- Castbar Icon Overlay

    if ( not frame.castBar.Icon.Overlay ) then
        frame.castBar.Icon.Overlay = frame.castBar:CreateTexture('$parentIconOverlay', 'OVERLAY')
        frame.castBar.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
        frame.castBar.Icon.Overlay:Hide()
        frame.castBar.Icon.Overlay:ClearAllPoints()
        frame.castBar.Icon.Overlay:SetPoint('TOPRIGHT', frame.castBar.Icon, 2.5, 2.5)
        frame.castBar.Icon.Overlay:SetPoint('BOTTOMLEFT', frame.castBar.Icon, -2.5, -2.5)
        frame.castBar.Icon.Overlay:SetTexture(iconOverlay)
        frame.castBar.Icon.Overlay:Show()
    end

        -- Update Castbar

    frame.castBar:SetScript('OnValueChanged', function(self, value)
        UpdateCastbar(frame)
    end)

    frame:SetScript('OnShow', function(self)
        frame.healthBar.Overlay:Hide()
        frame.castBar.Overlay:Hide()
        frame.healthBar.Overlay:ClearAllPoints()
        frame.castBar.Overlay:ClearAllPoints()
        if not IsUsingLargerNamePlateStyle() then
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
        frame.healthBar.Overlay:Show()
        frame.castBar.Overlay:Show()
    end)
end
hooksecurefunc('DefaultCompactNamePlateFrameSetup', SetupNamePlate)

    -- Update Name

local function UpdateName(frame)
    if ( string.match(frame.displayedUnit,'nameplate') ~= 'nameplate' ) then return end

        -- Totem Icon

    if cfg.showTotemIcon then
        UpdateTotemIcon(frame)
    end

    if ( not ShouldShowName(frame) ) then
        frame.name:Hide()
    else

            -- Friendly Nameplate Class Color

        if ( cfg.alwaysUseClassColors ) then
            if ( UnitIsPlayer(frame.displayedUnit) ) then
                frame.name:SetTextColor(frame.healthBar:GetStatusBarColor())
                DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = true
            end
        end

            -- Shorten Long Names

        local newName = GetUnitName(frame.displayedUnit, cfg.showServerName) or 'Unknown'
        if ( cfg.abbrevLongNames ) then
            newName = (len(newName) > 20) and gsub(newName, '%s?(.[\128-\191]*)%S+%s', '%1. ') or newName
        end

            -- Level

        if ( cfg.showLevel ) then
            local playerLevel = UnitLevel('player')
            local targetLevel = UnitLevel(frame.displayedUnit)
            local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
            local levelColor = RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

            if ( targetLevel == -1 ) then
                frame.name:SetText(newName)
            else
                frame.name:SetText('|cffffff00|r'..levelColor..targetLevel..'|r '..newName)
            end
        else
            frame.name:SetText(newName)
        end

            -- Color Name To Threat Status

        if ( cfg.colorNameWithThreat ) then
            local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
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
hooksecurefunc('CompactUnitFrame_UpdateName', UpdateName)

    -- Fix for broken Blizzard function.

local function DebuffOffsets(self)
    local showSelf = GetCVarBool('nameplateShowSelf')
    local targetMode = GetCVarBool('nameplateResourceOnTarget')
    if ( showSelf and targetMode ) then
        if ( self.driverFrame:IsUsingLargerNamePlateStyle() ) then
            self.UnitFrame.BuffFrame:SetBaseYOffset(0)
        else
            self.UnitFrame.BuffFrame:SetBaseYOffset(0)
        end
    end
    if ( showSelf and targetMode ) then
        self.UnitFrame.BuffFrame:SetTargetYOffset(18)
    else
        self.UnitFrame.BuffFrame:SetTargetYOffset(0)
    end
end
hooksecurefunc(NamePlateBaseMixin,'ApplyOffsets',DebuffOffsets)

    -- Move Nameplate Debuff Frames

local function DebuffAnchor(self)
    local showSelf = GetCVarBool('nameplateShowSelf')
    local targetMode = GetCVarBool('nameplateResourceOnTarget')
    local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, 'target')
    local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0)

    self:Hide()
    if ( IsUsingLargerNamePlateStyle() ) then
        if ( self:GetParent().unit and ShouldShowName(self:GetParent()) ) then
            if ( showSelf and targetMode ) then
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, 7)
            else
                self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, targetYOffset)
            end
        else
            self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, 5)
        end
    else
        if ( self:GetParent().unit and ShouldShowName(self:GetParent()) ) then
            if ( showSelf and targetMode ) then
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, targetYOffset+10)
            else
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, targetYOffset+10)
            end
        else
            self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, targetYOffset+10)
        end
    end
    self:Show()
end
hooksecurefunc(NameplateBuffContainerMixin,'UpdateAnchor',DebuffAnchor)