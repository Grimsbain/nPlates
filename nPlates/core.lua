
local _, nPlates = ...
local cfg = nPlates.Config

local len = string.len
local gsub = string.gsub

local texturePath = 'Interface\\AddOns\\nPlates\\media\\'
local statusBar = texturePath..'UI-StatusBar'
local overlayTexture = texturePath..'textureOverlay'
local iconOverlay = texturePath..'textureIconOverlay'
local borderColor = {0.47, 0.47, 0.47}

local groups = {
  "Friendly",
  "Enemy",
}

local options = {
  displaySelectionHighlight = cfg.displaySelectionHighlight,
  showClassificationIndicator = cfg.showClassificationIndicator,

  tankBorderColor = false,
  selectedBorderColor = CreateColor(0, 0, 0, 0.8),
  defaultBorderColor = CreateColor(0, 0, 0, 0.5),
}

for i, group  in next, groups do
  for key, value in next, options do
    _G["DefaultCompactNamePlate"..group.."FrameOptions"][key] = value
  end
end

    -- Set CVar Options

C_Timer.After(.1, function()
	if not InCombatLockdown() then
        -- Sets nameplate non-target alpha.
        if cfg.nameplateMinAlpha then
            SetCVar("nameplateMinAlpha", cfg.nameplateMinAlpha)
        else
            SetCVar("nameplateMinAlpha", GetCVarDefault("nameplateMinAlpha"))
        end
        
		-- Makes all nameplates the same size.
        if cfg.dontZoom then
            SetCVar("namePlateMinScale", 1)
        else
            SetCVar("namePlateMinScale", GetCVarDefault("namePlateMinScale"))
        end
        
        -- Stop nameplates from clamping to screen.
        if cfg.dontClampToBorder then
            SetCVar("nameplateOtherTopInset", -1)
            SetCVar("nameplateOtherBottomInset", -1)
        else
            for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v)) end
        end
	end
end)

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

    -- Check for 'Larger Nameplates'

function IsUsingLargerNamePlateStyle()
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
    local name = UnitName(frame.displayedUnit)

    if name == nil then return end
    if (totemData[name]) then
        if (not frame.TotemIcon) then
            frame.TotemIcon = CreateFrame('Frame', '$parentTotem', frame)
            frame.TotemIcon:EnableMouse(false)
            frame.TotemIcon:SetSize(24, 24)
            frame.TotemIcon:SetPoint('BOTTOM', frame.BuffFrame, 'TOP', 0, 10)
            frame.TotemIcon:Show()
        end

        if (not frame.TotemIcon.Icon) then
            frame.TotemIcon.Icon = frame.TotemIcon:CreateTexture('$parentIcon','BACKGROUND')
            frame.TotemIcon.Icon:SetSize(24,24)
            frame.TotemIcon.Icon:SetAllPoints(frame.TotemIcon)
            frame.TotemIcon.Icon:SetTexture(totemData[name])
            frame.TotemIcon.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end

        if (not frame.TotemIcon.Icon.Overlay) then
            frame.TotemIcon.Icon.Overlay = frame.TotemIcon:CreateTexture('$parentOverlay', 'OVERLAY')
            frame.TotemIcon.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
            frame.TotemIcon.Icon.Overlay:ClearAllPoints()
            frame.TotemIcon.Icon.Overlay:SetPoint('TOPRIGHT', frame.TotemIcon.Icon, 2.5, 2.5)
            frame.TotemIcon.Icon.Overlay:SetPoint('BOTTOMLEFT', frame.TotemIcon.Icon, -2.5, -2.5)
            frame.TotemIcon.Icon.Overlay:SetTexture(iconOverlay)
            frame.TotemIcon.Icon.Overlay:SetVertexColor(unpack(borderColor))
        end
    else
        if (frame.TotemIcon) then
            frame.TotemIcon:Hide()
        end
    end
end

    -- Update Border Color

local function UpdateBorder(frame)
    local r,g,b = frame.healthBar:GetStatusBarColor()
    if frame.healthBar.Overlay then
        frame.healthBar.Overlay:SetVertexColor(r,g,b)

        if UnitIsUnit(frame.displayedUnit,'player')then
            frame.healthBar.Overlay:ClearAllPoints()
            frame.healthBar.Overlay:SetTexture(nil)
        end
    end
end
hooksecurefunc('CompactUnitFrame_UpdateHealthBorder',UpdateBorder)

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

    -- Update Health Color

local function UpdateHealthColor(frame)
    if not cfg.enableTankMode then return end
    local r, g, b
    if ( not UnitIsConnected(frame.unit) ) then
        --Color it gray
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            --Try to color it by class.
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            if ( UnitIsPlayer(frame.unit) and classColor and frame.optionTable.useClassColors ) then
                -- Use class colors for players if class color option is turned on
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                -- Use grey if not a player and can't get tap on unit
                r, g, b = 0.1, 0.1, 0.1
            elseif ( frame.optionTable.colorHealthBySelection ) then
                -- Use color based on the type of unit (neutral, etc.)
                if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation('player', frame.displayedUnit)
                    if isTanking and threatStatus then
                        if threatStatus >= 3 then
                            r, g, b = 0.0, 1.0, 0.0
                        elseif threatStatus == 2 then
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

        if (frame.optionTable.colorHealthWithExtendedColors) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1, 1, 1)
        end

        frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
    end
end
hooksecurefunc('CompactUnitFrame_UpdateHealthColor',UpdateHealthColor)

    -- Update Castbar

local function UpdateCastbar(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.maxValue - frame.castBar.value)
        else
            frame.castBar.CastTime:SetFormattedText('%.1fs', frame.castBar.value)
        end

        local r, g, b = frame.healthBar:GetStatusBarColor()
        frame.castBar.Overlay:SetVertexColor(r,g,b)
        frame.castBar.Icon.Overlay:SetVertexColor(r, g, b)
    end

        -- Backup Icon Textures

    if frame.castBar.Icon.Background then
        local _,class = UnitClass(frame.displayedUnit)
        if frame.castBar then
            if not class then
                frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\Ability_DualWield')
            else
                frame.castBar.Icon.Background:SetTexture('Interface\\Icons\\ClassIcon_'..class)
            end
        end
    end
end

    -- Setup Frames

local function SetupNamePlate(frame, options)

        -- Name

    frame.name:SetFont('Fonts\\ARIALN.ttf', 11, 'OUTLINE')

        -- Healthbar

    frame.healthBar:SetHeight(12)
    frame.healthBar:ClearAllPoints()
    frame.healthBar:SetPoint('BOTTOMLEFT', frame.castBar, 'TOPLEFT', 0, 4.5)
    frame.healthBar:SetPoint('BOTTOMRIGHT', frame.castBar, 'TOPRIGHT', 0, 4.5)
    frame.healthBar:SetStatusBarTexture(statusBar)

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
    frame.castBar:SetStatusBarTexture(statusBar)

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

        -- Update Castbar

    frame.castBar:SetScript('OnValueChanged', function()
        UpdateCastbar(frame)
    end)

        -- Set Healthbar / Castbar Overlay based on current nameplate scale.

    frame:SetScript('OnSizeChanged', function()
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
    end)
end
hooksecurefunc('DefaultCompactNamePlateFrameSetup', SetupNamePlate)

    -- Personal Resource Display

local function PersonalFrame(frame)
    
        -- Check to see if personal should be skinned.
    
    if not cfg.skinPersonalResourceDisplay then return end
    
        -- Healthbar

    frame.healthBar:SetHeight(12)

        -- Update Health Text

    if (not frame.healthBar.healthString) then
        frame.healthBar.healthString = frame.healthBar:CreateFontString('$parentHeathValue', 'OVERLAY')
        frame.healthBar.healthString:SetPoint('CENTER', frame.healthBar, 0, 0)
        frame.healthBar.healthString:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')
    end

    frame.healthBar:SetScript('OnValueChanged', function()
        UpdateHealthText(frame)
    end)
end
hooksecurefunc('DefaultCompactNamePlatePlayerFrameSetup',PersonalFrame)

    -- Update Name

local function UpdateName(frame)

        -- Friendly Nameplate Class Color

    if cfg.alwaysUseClassColors then
        if UnitIsPlayer(frame.displayedUnit) then
            frame.name:SetTextColor(frame.healthBar:GetStatusBarColor())
            DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = true
        end
    end

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

        -- Totem Icon

    if cfg.showTotemIcon then
        UpdateTotemIcon(frame)
    end
end
hooksecurefunc('CompactUnitFrame_UpdateName', UpdateName)

    -- Fix for broken Blizzard function.

function DebuffOffsets(self)
    local showSelf = GetCVarBool('nameplateShowSelf')
    local targetMode = GetCVarBool('nameplateResourceOnTarget')
    if showSelf and targetMode then
        if self.driverFrame:IsUsingLargerNamePlateStyle() then
            self.UnitFrame.BuffFrame:SetBaseYOffset(0)
        else
            self.UnitFrame.BuffFrame:SetBaseYOffset(0)
        end
    end
    if showSelf and targetMode then
        self.UnitFrame.BuffFrame:SetTargetYOffset(18)
    else
        self.UnitFrame.BuffFrame:SetTargetYOffset(0)
    end
end
hooksecurefunc(NamePlateBaseMixin,'ApplyOffsets',DebuffOffsets)

    -- Move Nameplate Debuff Frames

function DebuffAnchor(self)
    local showSelf = GetCVarBool('nameplateShowSelf')
    local targetMode = GetCVarBool('nameplateResourceOnTarget')
    local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, 'target')
    local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0)

        -- Check for large nameplates.

    if IsUsingLargerNamePlateStyle() then
        -- Check if nameplate is showing name.
        if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
            -- Check if personal resources are on.
            if showSelf and targetMode then
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, 7)
            else
                self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, targetYOffset)
            end
        else
            self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, 5)
        end
    else
        if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
            if showSelf and targetMode then
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, targetYOffset+8)
            else
                self:SetPoint('BOTTOM', self:GetParent(), 'TOP', 0, targetYOffset+5)
            end
        else
            self:SetPoint('BOTTOM', self:GetParent().healthBar, 'TOP', 0, targetYOffset+5)
        end
    end
end
hooksecurefunc(NameplateBuffContainerMixin,'UpdateAnchor',DebuffAnchor)