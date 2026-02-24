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

    if ( self.unit ~= nil ) then
		isFriend = UnitIsFriend("player", self.unit)

		-- Cross faction players who are in the local players party but not in an instance are attackable and should appear as enemies.
		if ( isFriend and self:IsPlayer() and UnitInParty(self.unit) and UnitCanAttack("player", self.unit) ) then
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
    if not self:GetUnitFrame() then
        return false
    end

    -- Get the status from Blizzard since they already did the work.
	return self:GetUnitFrame().isSimplified == true
end

function PlateMixin:IsGameObject()
    return self.isGameObject == true
end

function PlateMixin:IsWidgetMode()
    return self.widgetsOnlyMode
end

function PlateMixin:SetWidgetMode(isWidgetMode)
    self.widgetsOnlyMode = isWidgetMode
end

function PlateMixin:UpdateWidgetsOnlyMode()
    local widgetsOnlyMode = self.unit ~= nil and UnitNameplateShowsWidgetsOnly(self.unit)
    self:SetWidgetMode(widgetsOnlyMode)
    self.Health:SetShown(not widgetsOnlyMode)

    if self.ComboPoints then self.ComboPoints:SetWidgetMode(widgetsOnlyMode) end
    if self.Chi then self.Chi:SetWidgetMode(widgetsOnlyMode) end
    if self.Essence then self.Essence:SetWidgetMode(widgetsOnlyMode) end

    self.WidgetContainer:ClearAllPoints()

    if widgetsOnlyMode then
        PixelUtil.SetPoint(self.WidgetContainer, "BOTTOM", self, "BOTTOM", 0, 0)
        PixelUtil.SetPoint(self.WidgetContainer, "CENTER", self, "CENTER", 0, 0)
    else
        PixelUtil.SetPoint(self.WidgetContainer, "TOP", self.Castbar, "BOTTOM", 0, 0)
    end
end

function PlateMixin:UpdateClassification()
    if ( self:IsPlayer() ) then
        self.mobType = "Player"
        return
    end

    local classification = UnitClassification(self.unit)

    if ( classification == "elite" ) then
        local level = UnitEffectiveLevel(self.unit)
        local playerLevel = nPlatesDriverFrame.playerLevel

        if ( level >= playerLevel + 2 or level == -1 ) then
            self.mobType = "Boss"
            return
        elseif ( level == playerLevel + 1 ) then
            self.mobType = "MiniBoss"
            return
        elseif ( level == playerLevel ) then
            local class = UnitClassBase(self.unit)
            self.mobType = (class == "PALADIN" and "Caster") or "Melee"
            return
        end
    end

    self.mobType = "Trivial"
end

function PlateMixin:UpdateHealth()
    self.Health:ForceUpdate()
end

function PlateMixin:ShouldShowMobColoring(forType)
    if ( not nPlatesDriverFrame.inInstance or not self.mobType ) then
        return false
    end

    return (self[forType] == "mobType" or self[forType] == "mobTypeOrThreat") and nPlates.MobColors[self.mobType]
end

function PlateMixin:ShouldShowThreat(forType)
    return (self[forType]== "threat" or self[forType] == "mobTypeOrThreat")
end

function PlateMixin:SetSelectionColor()
    if ( not self.unit ) then
        return
    end

    local healthBar = self.Health

    if ( self:IsTarget() and self.useSelectionColor ) then
        nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.SelectionColor)
        return
    elseif ( self:IsFocus() and self.useFocusColor ) then
            nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.FocusColor)
            return
    else
        if ( self:ShouldShowMobColoring("borderStyle") ) then
            local color = nPlates.MobColors[self.mobType]
            nPlates:SetBeautyBorderColor(healthBar, color)
            return
        elseif ( self:ShouldShowThreat("borderStyle") and nPlates.IsOnThreatListWithPlayer(self.unit) ) then
            local color = nPlates.GetThreatColor(self)
            nPlates:SetBeautyBorderColor(healthBar, color)
            return
        else
            if ( self:IsTarget() ) then
            local r, g, b = healthBar:GetStatusBarColor()
                nPlates:SetBeautyBorderColorByRGB(healthBar, r, g, b)
    else
        nPlates:SetBeautyBorderColor(healthBar, nPlates.Media.DefaultBorderColor)
    end
end
    end
end

function PlateMixin:ShouldShowBuffs()
    return self.showBuffs == true
end

function PlateMixin:ShouldShowCrowdControl()
    return self.showCrowdControl == true
end

function PlateMixin:UpdateClassPower()
    if self.ComboPoints then self.ComboPoints:UpdateVisibility() end
    if self.Chi then self.Chi:UpdateVisibility() end
    if self.Essence then self.Essence:UpdateVisibility() end
end

function PlateMixin:UpdateClassColor()
    local _, class = UnitClass(self.unit)
    self.classColor = C_ClassColor.GetClassColor(class)
end

function PlateMixin:UpdateDebuffLocation()
    local offset = self:ShouldShowName() and 17 or 5
    PixelUtil.SetPoint(self.BetterDebuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, offset)
end

function PlateMixin:UpdateOptions()
    -- Auras
    self.showBuffs = Settings.GetValue("NPLATES_SHOW_BUFFS")
    self.showCrowdControl = Settings.GetValue("NPLATES_CROWD_CONTROL")

    -- Castbar
    self.Castbar.showTarget = Settings.GetValue("NPLATES_CAST_TARGET")

    -- Coloring
    self.borderStyle = Settings.GetValue("NPLATES_BORDER_COLOR")
    self.healthStyle = Settings.GetValue("NPLATES_HEALTH_COLOR")
    self.useOffTankColor = Settings.GetValue("NPLATES_OFF_TANK_COLOR")
    self.useClassColors = self:IsPlayer() or UnitInPartyIsAI(self.unit)
    self.useSelectionColor = Settings.GetValue("NPLATES_SELECTION_COLOR")
    self.useFocusColor = Settings.GetValue("NPLATES_FOCUS_COLOR")

    -- Health
    self.statusTextStyle = Settings.GetValue("NPLATES_HEALTH_STYLE")

    -- Name
    self.alwaysShowName = Settings.GetValue("NPLATES_FORCE_NAME")
    self.showLevel = Settings.GetValue("NPLATES_SHOWLEVEL")
    self.colorEnemyNames = Settings.GetValue("NPLATES_PLAYER_THREAT")
    self.nameOnly = Settings.GetValue("NPLATES_ONLYNAME")
end

function PlateMixin:ShouldShowName()
    if ( self:IsWidgetMode() or self:IsGameObject() ) then
        return false
    end

    if ( self:IsSimplified() and not self:IsTarget() ) then
        return false
    end

    if ( self.alwaysShowName ) then
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

function PlateMixin:UpdateName()
    if ( not self:ShouldShowName() ) then
        self.Name:Hide()
        return
    else
        local name = UnitName(self.unit) or UNKOWN

        if ( self:IsPlayer() ) then
            if ( not self:IsFriend() and self.colorEnemyNames ) then
                self.Name:SetFormattedText("%s%s|r", nPlates.DifficultyColor(self.unit), name)
            else
                self.Name:SetText(GetClassColoredTextForUnit(self.unit, name))
            end
        else
            if ( self.showLevel ) then
                local level = UnitLevel(self.unit)

                if ( level == -1 ) then
                    self.Name:SetText(name)
                else
                    self.Name:SetFormattedText("%s%d|r %s", nPlates.DifficultyColor(self.unit), level, name)
                end
            else
                self.Name:SetText(name)
            end
        end

        self.Name:Show()
    end
end

function PlateMixin:UpdateNameLocation()
    if ( self:IsWidgetMode() or self:IsGameObject() ) then
        self.Name:Hide()
        return
    end

    self.Name:ClearAllPoints()

    if ( self:IsFriendlyPlayer() and self.nameOnly ) then
        self.Name:SetPoint("BOTTOM", self, "TOP", 0, 5)
        self.Health:ClearAllPoints()
    else
        self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)

        self.Health:ClearAllPoints()
        self.Health:SetPoint("TOP")
    end
end

function PlateMixin:OnEvent(event, ...)
    if ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
        self:UpdateClassification()
    elseif ( event == "PLAYER_TARGET_CHANGED" ) then
        self:UpdateIsTarget()
        self:UpdateName()
        self:UpdateDebuffLocation()
        self:UpdateClassPower()
        self:SetSelectionColor()
    elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
        self:UpdateIsFocus()
        self:SetSelectionColor()
    end
end

local function Layout(self, unit)
    Mixin(self, PlateMixin)
    self:HookScript("OnEvent", self.OnEvent)

    self.Name = self:CreateFontString(nil, "OVERLAY", "nPlate_NameFont")
    self.Name:SetJustifyH("CENTER")
    self.Name:SetIgnoreParentScale(true)

    nPlates.CreateHealth(self)
    nPlates.CreateCastbar(self)

    -- Right
    nPlates.CreateQuestIcon(self)
    nPlates.CreateCCIcon(self)

    -- Left
    nPlates.CreateClassificationIndicator(self)
    nPlates.CreateRaidTargetIndicator(self)
    nPlates.CreateBuffs(self)
    nPlates.UpdateSoftTarget(self)

    -- Top
    nPlates.CreateDebuffs(self)
    nPlates.CreateClassPowers(self)

    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", self.OnEvent)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", self.OnEvent, true)
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", self.OnEvent, true)

    -- Waiting on Blizzard
    -- self.HitTest = CreateFrame("Frame", "$parentHitTest", self)
    -- self.HitTest:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -10, 10)
    -- self.HitTest:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 10, -10)

    -- C_NamePlateManager.SetNamePlateHitTestFrame(unit, self.HitTest);

    return self
end

nPlatesMixin = {}

function nPlatesMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEVEL_UP")

    EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
        nPlates:RegisterSettings()
        nPlates:CVarCheck()
        self:Initialize()
    end)
end

function nPlatesMixin:OnEvent(event, ...)
    if ( event == "PLAYER_ENTERING_WORLD" ) then
        self:InInstance()
        self:UpdateLevel()
    else
        self:UpdateLevel()
    end
    end

function nPlatesMixin:UpdateLevel()
    self.playerLevel = UnitLevel("player")
end

function nPlatesMixin:InInstance()
    local inInstance, instanceType = IsInInstance()
    local shouldShow = inInstance and (instanceType == "party" or instanceType == "raid")
    self.inInstance = shouldShow
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
    nameplate.widgetsOnlyMode = nil
    nameplate:Hide()
end

function nPlates:OnNamePlateAdded(nameplate, event, unit)
    nameplate.isGameObject = unit ~= nil and UnitIsGameObject(unit);

    nameplate:UpdateOptions()
    nameplate:UpdateIsPlayer()
    nameplate:UpdateIsTarget()
    nameplate:UpdateIsFocus()
    nameplate:UpdateWidgetsOnlyMode()

    nameplate:UpdateClassification()
    nameplate:UpdateName()
    nameplate:UpdateNameLocation()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()
    nameplate:UpdateClassColor()

    nameplate:Show()
end
