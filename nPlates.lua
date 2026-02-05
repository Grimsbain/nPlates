local _, nPlates = ...
local oUF = nPlates.oUF

local PlateMixin = {}

function PlateMixin:GetUnitFrame()
	return self:GetParent().UnitFrame
end

function PlateMixin:UpdateIsPlayer()
    self.isPlayer = self.unit and UnitIsPlayer(self.unit) or false
end

function PlateMixin:IsPlayer()
    return self.isPlayer
end

function PlateMixin:IsFriend()
    local isFriend = false

    if self.unit ~= nil then
		isFriend = UnitIsFriend("player", self.unit)

		-- Cross faction players who are in the local players party but not in an instance are attackable and should appear as enemies.
		if isFriend and self:IsPlayer() and UnitInParty(self.unit) and UnitCanAttack("player", self.unit) then
			isFriend = false
		end
	end

    return isFriend
end

function PlateMixin:IsFriendlyPlayer()
    return self:IsPlayer() and self:IsFriend()
end

function PlateMixin:UpdateIsTarget()
    self.isTarget = self.unit and UnitIsUnit(self.unit, "target") or false
end

function PlateMixin:IsTarget()
    return self.isTarget == true
end

function PlateMixin:UpdateIsFocus()
    self.isFocus = self.unit and UnitIsUnit(self.unit, "focus") or false
end

function PlateMixin:IsFocus()
    return self.isFocus == true
end

function PlateMixin:IsSimplified()
    -- Get the status from Blizzard since they already did the work.
	return self:GetUnitFrame().isSimplified == true
end

function PlateMixin:IsWidgetMode()
    return self.widgetsOnlyMode
end

function PlateMixin:UpdateWidgetsOnlyMode()
    self.widgetsOnlyMode = self.unit ~= nil and UnitNameplateShowsWidgetsOnly(self.unit)
    self.Health:SetShown(not self.widgetsOnlyMode)
    self.ComboPoints:SetWidgetMode(self.widgetsOnlyMode)
    self.Chi:SetWidgetMode(self.widgetsOnlyMode)
    self.Essence:SetWidgetMode(self.widgetsOnlyMode)

    self.WidgetContainer:ClearAllPoints()

    if self.widgetsOnlyMode then
        PixelUtil.SetPoint(self.WidgetContainer, "BOTTOM", self, "BOTTOM", 0, 0)
        PixelUtil.SetPoint(self.WidgetContainer, "CENTER", self, "CENTER", 0, 0)
    else
        PixelUtil.SetPoint(self.WidgetContainer, "TOP", self.Castbar, "BOTTOM", 0, 0)
    end
end

function PlateMixin:UpdateHealth()
    nPlates.UpdateHealth(self, "FORCE", self.unit)
end

function PlateMixin:SetSelectionColor()
    if ( not self.unit ) then
        return
    end

    local healthBar = self.Health
    local unit = self.unit

    if ( Settings.GetValue("NPLATES_FOCUS_COLOR") ) then
        if ( self:IsFocus() ) then
            nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.FocusColor)
            return
        end
    end

    if ( self:IsTarget() ) then
        if ( Settings.GetValue("NPLATES_SELECTION_COLOR") ) then
            nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.SelectionColor)
        else
            local r, g, b = healthBar:GetStatusBarColor()
            nPlates.Media.BorderColor:SetRGB(r, g, b)
            nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.BorderColor)
        end
    else
        nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.DefaultBorderColor)
    end
end

-- function PlateMixin:ShouldShowBuffs()
--     return self.showBuffs == true
-- end

-- function PlateMixin:UpdateBuffs()
--     self.showBuffs = Settings.GetValue("NPLATES_SHOW_BUFFS")
--     nPlates:UpdateElement("Buffs")
-- end

function PlateMixin:UpdateClassPower()
    self.ComboPoints:UpdateVisibility()
    self.Chi:UpdateVisibility()
    self.Essence:UpdateVisibility()
end

function PlateMixin:UpdateDebuffs()
    self.Debuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
end

function PlateMixin:UpdateDebuffLocation()
    local offset = self:ShouldShowName() and 17 or 5
    PixelUtil.SetPoint(self.Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, offset)
end

function PlateMixin:ShouldShowName()
    if ( self:IsWidgetMode() ) then
        return false
    end

    if ( Settings.GetValue("NPLATES_FORCE_NAME") ) then
        return true
    end

    if ( self:IsPlayer() or self:IsTarget() ) then
        return true
    end

    if ( UnitIsEnemy("player", self.unit) ) then
        return true
    end

    return false
end

function PlateMixin:ToggleName(shouldShow)
    self.Name:SetShown(shouldShow)
end

function PlateMixin:UpdateName()
    if ( not self:ShouldShowName() ) then
        self.Name:Hide()
        return
    else
        local unitName = UnitName(self.unit) or UNKOWN

        if ( Settings.GetValue("NPLATES_SHOWLEVEL") and not self:IsPlayer() ) then
            local targetLevel = UnitLevel(self.unit)

            if ( targetLevel == -1 ) then
                self.Name:SetText(unitName)
            else
                local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
                local color = GetDifficultyColor(difficulty)
                self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB())
                self.Name:SetFormattedText("%s%d|r %s", ConvertRGBtoColorString(color), targetLevel, unitName)
            end
        else
            if ( self:IsPlayer() ) then
                if ( not self:IsFriend() and Settings.GetValue("NPLATES_PLAYER_THREAT") ) then
                    local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
                    local color = GetDifficultyColor(difficulty)

                    self.Name:SetText(unitName)
                    self.Name:SetTextColor(color.r, color.g, color.b)
                else
                self.Name:SetText(GetClassColoredTextForUnit(self.unit, unitName))
                end
            else
                self.Name:SetText(unitName)
                self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB())
            end
        end

        self.Name:Show()
    end
end

function PlateMixin:UpdateNameLocation()
    if ( self:IsWidgetMode() ) then
        self.Name:Hide()
        return
    end

    self.Name:ClearAllPoints()

    if ( Settings.GetValue("NPLATES_ONLYNAME") and self:IsFriendlyPlayer() ) then
        self.Name:SetPoint("BOTTOM", self, "TOP", 0, 5)
        self.Health:ClearAllPoints()
    else
        self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)

        self.Health:ClearAllPoints()
        self.Health:SetPoint("TOP")
    end
end

function PlateMixin:UpdateClassification()
    local element = self.classificationIndicator

    if ( not self.unit or self:IsWidgetMode() ) then
        element:Hide()
        return
    end

    local classification = UnitClassification(self.unit)

    if ( classification == "elite" or classification == "worldboss" ) then
        element:SetAtlas("nameplates-icon-elite-gold")
        element:Show()
    elseif ( classification == "rareelite" or classification == "rare" ) then
        element:SetAtlas("nameplates-icon-elite-silver")
        element:Show()
    else
        element:Hide()
    end
end

local function Layout(self, unit)
    Mixin(self, PlateMixin)

    self.Name = self:CreateFontString(nil, "OVERLAY", "nPlate_NameFont")
    self.Name:SetJustifyH("CENTER")
    self.Name:SetIgnoreParentScale(true)

    nPlates.CreateHealth(self)
    nPlates.CreateCastbar(self)

    -- Right
    nPlates.CreateCCIcon(self)
    nPlates.CreateQuestIcon(self)

    -- Left
    nPlates.CreateClassificationIndicator(self)
    nPlates.CreateRaidTargetIndicator(self)
    -- nPlates.CreateBuffs(self)
    nPlates.UpdateSoftTarget(self)

    -- Top
    nPlates.CreateDebuffs(self)
    nPlates.CreateClassPowers(self)

    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FACTION", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FLAGS", nPlates.UpdateHealth)

    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", function(self, event, unit)
        self:UpdateClassification()
        self:UpdateName()
    end)

    -- We use a custom "PLAYER_TARGET_CHANGED" because the oUF version
    -- doesn't fire when you lose target.
    self:RegisterEvent("PLAYER_TARGET_CHANGED", function(self, event)
        nPlates:OnTargetChanged(self, "PLAYER_TARGET_CHANGED", self.unit)
    end, true)

    self:RegisterEvent("PLAYER_FOCUS_CHANGED", function(self, event)
        self:UpdateIsFocus()
        nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
            plate:SetSelectionColor()
        end)
    end, true)

    -- Waiting on Blizzard
    -- self.HitTest = CreateFrame("Frame", "$parentHitTest", self)
    -- self.HitTest:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -10, 10)
    -- self.HitTest:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 10, -10)

    -- C_NamePlateManager.SetNamePlateHitTestFrame(unit, self.HitTest);

    return self
end

nPlatesMixin = {}

function nPlatesMixin:OnLoad()
    EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
        nPlates:RegisterSettings()
        nPlates:CVarCheck()
        self:Initialize()
    end)
end

function nPlatesMixin:Initialize()
    nPlates.Media.OffTankColor = CreateColorFromHexString(Settings.GetValue("NPLATES_OFF_TANK_COLOR_HEX"))
    nPlates.Media.SelectionColor = CreateColorFromHexString(Settings.GetValue("NPLATES_SELECTION_COLOR_HEX"))
    nPlates.Media.FocusColor = CreateColorFromHexString(Settings.GetValue("NPLATES_FOCUS_COLOR_HEX"))

    oUF:RegisterStyle("nPlate3", Layout)
    oUF:Factory(function(self)
        self:SetActiveStyle("nPlate3")

        local driver = self:SpawnNamePlates("nPlate3")

        driver:SetAddedCallback(function(nameplate, event, unit)
            nPlates:OnNamePlateAdded(nameplate, event, unit)
        end)

        driver:SetRemovedCallback(function(nameplate, event, unit)
            nPlates:OnNamePlateRemoved(nameplate, event, unit)
        end)
    end)
end

function nPlates:OnNamePlateRemoved(nameplate, event, unit)
    nameplate.unit = nil
    nameplate.widgetsOnlyMode = nil
    nameplate:Hide()
end

function nPlates:OnNamePlateAdded(nameplate, event, unit)
    if ( unit == "preview" ) then
        return
    end

    nameplate.unit = unit

    nameplate:UpdateIsPlayer()
    nameplate:UpdateIsTarget()
    nameplate:UpdateIsFocus()

    nameplate:UpdateWidgetsOnlyMode()
    nameplate:UpdateClassification()
    nameplate:UpdateName()
    nameplate:UpdateNameLocation()
    -- nameplate:UpdateBuffs()
    nameplate:UpdateDebuffs()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()

    nameplate:Show()
end

function nPlates:OnTargetChanged(nameplate, event, unit)
    nameplate:UpdateIsTarget()
    nameplate:UpdateName()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()
    nameplate:SetSelectionColor()
end
