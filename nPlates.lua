local _, nPlates = ...
local oUF = nPlates.oUF

local PlateMixin = {}

function PlateMixin:GetUnitFrame()
	return self:GetParent().UnitFrame
end

function PlateMixin:UpdateIsPlayer()
    self.isPlayer = self.__unit and UnitIsPlayer(self.__unit) or false
end

function PlateMixin:IsPlayer()
    return self.isPlayer
end

function PlateMixin:IsFriend()
    local isFriend = false

    if ( self.__unit ~= nil ) then
		isFriend = UnitIsFriend("player", self.__unit)

		-- Cross faction players who are in the local players party but not in an instance are attackable and should appear as enemies.
		if ( isFriend and self:IsPlayer() and UnitInParty(self.__unit) and UnitCanAttack("player", self.__unit) ) then
			isFriend = false
		end
	end

    return isFriend
end

function PlateMixin:IsFriendlyPlayer()
    return self:IsPlayer() and self:IsFriend()
end

function PlateMixin:UpdateIsTarget()
    self.isTarget = self.__unit and UnitIsUnit(self.__unit, "target") or false
end

function PlateMixin:IsTarget()
    return self.isTarget == true
end

function PlateMixin:UpdateIsFocus()
    self.isFocus = self.__unit and UnitIsUnit(self.__unit, "focus") or false
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

function PlateMixin:UpdateClassColor()
    local _, class = UnitClass(self.__unit)
    self.classColor = (class and C_ClassColor.GetClassColor(class)) or BATTLENET_FONT_COLOR
end

function PlateMixin:UpdateClassification()
    if ( self:IsPlayer() ) then
        self.mobType = "Player"
        return
    end

    local classification = UnitClassification(self.__unit)

    if ( classification == "elite" ) then
        local level = UnitEffectiveLevel(self.__unit)
        local playerLevel = nPlatesDriverFrame:GetPlayerLevel()

        if ( level >= playerLevel + 2 or level == -1 ) then
            self.mobType = "Boss"
            return
        elseif ( level == playerLevel + 1 ) then
            self.mobType = "MiniBoss"
            return
        elseif ( level == playerLevel ) then
            self.mobType = "Other"
            return
        end
    end

    self.mobType = "Trivial"
end

function PlateMixin:UseMobColoring(forType)
    if ( not nPlatesDriverFrame:InInstance() or not self.mobType ) then
        return false
    end

    return (self[forType] == "mobType" or self[forType] == "mobTypeOrThreat") and nPlates.MobColors[self.mobType]
end

function PlateMixin:UseThreatColoring(forType)
    return (self[forType]== "threat" or self[forType] == "mobTypeOrThreat")
end

function PlateMixin:SetSelectionColor()
    if ( not self.__unit ) then
        return
    end

    local healthBar = self.Health

    if ( self:IsTarget() and self.useSelectionColor ) then
        nPlates:SetBeautyBorderColor(healthBar, nPlates.Colors.SelectionColor)
        return
    elseif ( self:IsFocus() and self.useFocusColor ) then
        nPlates:SetBeautyBorderColor(healthBar, nPlates.Colors.FocusColor)
            return
    else
        if ( self:UseMobColoring("borderStyle") ) then
            local color = nPlates.MobColors[self.mobType]
            nPlates:SetBeautyBorderColor(healthBar, color)
            return
        elseif ( self:UseThreatColoring("borderStyle") and nPlates.IsOnThreatListWithPlayer(self.__unit) ) then
            local r, g, b = nPlates.GetThreatColor(self.__unit)
            nPlates:SetBeautyBorderColorByRGB(self, r, g, b)
            return
        else
            if ( self:IsTarget() ) then
            local r, g, b = healthBar:GetStatusBarColor()
                nPlates:SetBeautyBorderColorByRGB(healthBar, r, g, b)
    else
                nPlates:SetBeautyBorderColor(healthBar, nPlates.Colors.DefaultBorderColor)
    end
end
    end
end

function PlateMixin:UpdateClassPower()
    if ( self.ClassFrameContainer.Power ) then
        self.ClassFrameContainer.Power:UpdateVisibility()
    end
end

function PlateMixin:UpdateAuras()
    local filterString = self:IsPlayer() and "HELPFUL|IMPORTANT" or "HELPFUL|INCLUDE_NAME_PLATE_ONLY"
    self.Buffs:SetAuraGroupFilterString(self.Buffs.groupKey, filterString)
    self.Buffs:SetEnabled(Settings.GetValue("NPLATES_SHOW_BUFFS"))

    self.CCIcon:SetEnabled(Settings.GetValue("NPLATES_CROWD_CONTROL"))
end

function PlateMixin:UpdateDebuffLocation()
    local offset = self:ShouldShowName() and 17 or 5
    PixelUtil.SetPoint(self.Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, offset)
end

function PlateMixin:UpdateOptions()
    self:UpdateIsPlayer()
    self:UpdateIsTarget()
    self:UpdateIsFocus()
    self:UpdateClassColor()

    -- Auras
    self.Buffs:SetEnabled(Settings.GetValue("NPLATES_SHOW_BUFFS"))
    self.CCIcon:SetEnabled(Settings.GetValue("NPLATES_CROWD_CONTROL"))

    -- Castbar
    self.Castbar.showTarget = Settings.GetValue("NPLATES_CAST_TARGET")
    self.Castbar.useImportantCast = Settings.GetValue("NPLATES_IMPORTANT_CAST_COLOR")

    -- Coloring
    self.borderStyle = Settings.GetValue("NPLATES_BORDER_COLOR")
    self.healthStyle = Settings.GetValue("NPLATES_HEALTH_COLOR")
    self.useClassColor = self:IsPlayer() or UnitInPartyIsAI(self.__unit)
    self.useFocusColor = Settings.GetValue("NPLATES_FOCUS_COLOR")
    self.useSelectionColor = Settings.GetValue("NPLATES_SELECTION_COLOR")

    -- Health
    self.healthTag = Settings.GetValue("NPLATES_HEALTH_STYLE")

    -- Name
    self.alwaysShowName = Settings.GetValue("NPLATES_FORCE_NAME")
    self.colorEnemyNames = Settings.GetValue("NPLATES_PLAYER_THREAT")
    self.nameOnly = Settings.GetValue("NPLATES_ONLYNAME")
    self.showLevel = Settings.GetValue("NPLATES_SHOWLEVEL")
end

function PlateMixin:UpdateWidgets()
    self:UpdateClassification()

    if ( self:IsFriendlyPlayer() and self.nameOnly ) then
        self:DisableElement("Auras")
        self:DisableElement("Health")
		self:DisableElement("ClassificationIndicator")
		self:DisableElement("Castbar")
        self:UpdateNameLocation()
        self.Health:Hide()
        self.Name:Show()
        return
	else
		self:EnableElement("Auras")
		self:EnableElement("Health")
		self:EnableElement("ClassificationIndicator")
		self:EnableElement("Castbar")
        self.Health:Show()
	end
end

function PlateMixin:ShouldShowName()
    if ( self:IsSimplified() and not self:IsTarget() ) then
        return false
    end

    if ( self.alwaysShowName ) then
        return true
    end

    if ( self:IsPlayer() or self:IsTarget() ) then
        return true
    end

    if ( UnitIsEnemy("player", self.__unit) ) then
        return true
    end

    return false
end

function PlateMixin:UpdateName()
    if ( not self:ShouldShowName() ) then
        self.Name:Hide()
        return
    else
        local name = UnitNameUnmodified(self.__unit) or UNKNOWN

        if ( self:IsPlayer() ) then
            if ( not self:IsFriend() and self.colorEnemyNames ) then
                self.Name:SetFormattedText("%s%s|r", nPlates.DifficultyColor(self.__unit), name)
            else
                local color = self.classColor or WHITE_FONT_COLOR
                self.Name:SetText(color:WrapTextInColorCode(name))
            end
        else
            if ( self.showLevel ) then
                local level = UnitLevel(self.__unit) or -1

                if ( level == -1 ) then
                    self.Name:SetText(name)
                else
                    self.Name:SetFormattedText("%s%s|r %s", nPlates.DifficultyColor(self.__unit), level, name)
                end
            else
                self.Name:SetText(name)
            end
        end

        self.Name:Show()
    end
end

function PlateMixin:UpdateNameLocation()
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
    if ( event == "UNIT_NAME_UPDATE" ) then
        self:UpdateName()
    elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
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

local nPlatesDriverMixin = {}
nPlates.nPlatesDriverMixin = nPlatesDriverMixin

function nPlatesDriverMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEVEL_UP")

    EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
        nPlates:RegisterSettings()
        nPlates:CVarCheck()
        self:Initialize()
    end)
end

function nPlatesDriverMixin:OnEvent(event, ...)
    if ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UpdateInstance()
        self:UpdateLevel()
    elseif ( event == "PLAYER_LEVEL_UP" ) then
        self:UpdateLevel()
    end
    end

function nPlatesDriverMixin:UpdateLevel()
    self.playerLevel = UnitLevel("player")
end

function nPlatesDriverMixin:GetPlayerLevel()
    return self.playerLevel
end

function nPlatesDriverMixin:UpdateInstance()
    local inInstance, instanceType = IsInInstance()
    local shouldShow = inInstance and (instanceType == "party" or instanceType == "raid")
    self.inInstance = shouldShow
end

function nPlatesDriverMixin:InInstance()
    return self.inInstance == true
end

function nPlatesDriverMixin:Initialize()
    nPlates.Colors.SelectionColor = CreateColorFromHexString(Settings.GetValue("NPLATES_SELECTION_COLOR_HEX"))
    nPlates.Colors.FocusColor = CreateColorFromHexString(Settings.GetValue("NPLATES_FOCUS_COLOR_HEX"))
    nPlates.Colors.ImportantCastColor = CreateColorFromHexString(Settings.GetValue("NPLATES_IMPORTANT_CAST_COLOR_HEX"))
end

local styleName = "nPlates3"

local function OnNamePlateAdded(nameplate)
    nameplate:UpdateOptions()
    nameplate:UpdateWidgets()
    nameplate:UpdateAuras()

    nameplate:UpdateName()
    nameplate:UpdateNameLocation()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()

    C_Timer.After(0, GenerateClosure(nameplate.Health.ForceUpdate, nameplate.Health))
end

oUF:RegisterStyle(styleName, function(self, unit)
    Mixin(self, PlateMixin)
    self:HookScript("OnEvent", self.OnEvent)

    self.Name = self:CreateFontString("$parentName", "OVERLAY", "nPlate_NameFont")
    self.Name:SetJustifyH("CENTER")
    self.Name:SetSmoothScaling(true)

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

    self:RegisterEvent("UNIT_NAME_UPDATE", self.OnEvent)
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", self.OnEvent)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", self.OnEvent, true)
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", self.OnEvent, true)

    return self
end)

oUF:SetActiveStyle(styleName)

local driver = oUF:SpawnNamePlates(styleName)
driver:SetAddedCallback(OnNamePlateAdded)
