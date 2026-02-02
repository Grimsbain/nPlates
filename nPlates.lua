local _, nPlates = ...
local oUF = nPlates.oUF

local PlateMixin = {}

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

function PlateMixin:UpdateClassPower()
    self.ComboPoints:UpdateVisibility()
    self.Chi:UpdateVisibility()
end

function PlateMixin:IsWidgetMode()
    return self.widgetsOnlyMode
end

function PlateMixin:UpdateWidgetsOnlyMode()
    self.widgetsOnlyMode = self.unit ~= nil and UnitNameplateShowsWidgetsOnly(self.unit)
    self.Health:SetShown(not self.widgetsOnlyMode)
    self.Chi:SetWidgetMode(self.widgetsOnlyMode)
    self.ComboPoints:SetWidgetMode(self.widgetsOnlyMode)

    self.WidgetContainer:ClearAllPoints()

    if self.widgetsOnlyMode then
        PixelUtil.SetPoint(self.WidgetContainer, "BOTTOM", self, "BOTTOM", 0, 0)
        PixelUtil.SetPoint(self.WidgetContainer, "CENTER", self, "CENTER", 0, 0)
    else
        PixelUtil.SetPoint(self.WidgetContainer, "TOP", self.Castbar, "BOTTOM", 0, 0)
    end
end

function PlateMixin:UpdateBuffs()
    self.showBuffs = Settings.GetValue("NPLATES_SHOW_BUFFS")
    nPlates:UpdateElement("Buffs")
end

function PlateMixin:ShouldShowBuffs()
    return self.showBuffs == true
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
                self.Name:SetFormattedText("%s%d|r %s", ConvertRGBtoColorString(color), targetLevel, unitName)
            end
        else
            if ( self:IsPlayer() ) then
                self.Name:SetText(GetClassColoredTextForUnit(self.unit, unitName))
            else
                self.Name:SetText(unitName)
            end
        end

        self.Name:Show()
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

    self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
    self.Health:SetPoint("TOP")
    self.Health:SetWidth(175)
    self.Health:SetHeight(18)
    self.Health:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    self.Health.Override = nPlates.UpdateHealth
    self.Health.frequentUpdates = true
    nPlates:SetBorder(self.Health)

    self.Health.Background = self.Health:CreateTexture("$parentBackground", "BACKGROUND")
    self.Health.Background:SetAllPoints(self.Health)
    self.Health.Background:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    self.Health.Value = self.Health:CreateFontString("$parentHealthText", "OVERLAY", "nPlate_HealthFont")
    self.Health.Value:SetShadowOffset(1, -1)
    self.Health.Value:SetPoint("TOPLEFT", self.Health, 0, 0)
    self.Health.Value:SetPoint("BOTTOMRIGHT", self.Health, 0, 0)
    self.Health.Value:SetJustifyH("CENTER")
    self.Health.Value:SetJustifyV("MIDDLE")
    self.Health.Value:SetTextColor(1, 1, 1)

    self.Castbar = CreateFrame("StatusBar", "$parentCastbar", self)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
    self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -5)
    self.Castbar:SetHeight(18)
    self.Castbar:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    self.Castbar:GetStatusBarTexture():SetVertexColor(nPlates.Media.StatusBarColor:GetRGB())
    self.Castbar.PostCastStart = nPlates.PostCastStart
    nPlates:SetBorder(self.Castbar)

    self.Castbar.Background = self.Castbar:CreateTexture("$parentBackground", "BACKGROUND")
    self.Castbar.Background:SetAllPoints(self.Castbar)
    self.Castbar.Background:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    self.Castbar.Text = self.Castbar:CreateFontString("$parentText", "OVERLAY", "nPlate_CastbarFont")
    self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, 2, 1)
    self.Castbar.Text:SetPoint("BOTTOMRIGHT")
    self.Castbar.Text:SetJustifyH("LEFT")
    self.Castbar.Text:SetJustifyV("MIDDLE")
    self.Castbar.Text:SetTextColor(1, 1, 1)

    self.Castbar.Icon = self.Castbar:CreateTexture("$parentIcon", "OVERLAY")
    self.Castbar.Icon:SetSize(33, 33)
    self.Castbar.Icon:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMRIGHT", 4.9, 0)
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    nPlates:SetBorder(self.Castbar.Icon)

    -- Waiting on Blizzard timer formatting function.
    -- self.Castbar.Time = self.Castbar:CreateFontString("$parentTime", "OVERLAY", "nPlate_CastbarTimerFont")
    -- self.Castbar.Time:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, -1, 1)
    -- self.Castbar.Time:SetJustifyH("RIGHT")
    -- self.Castbar.Time:SetTextColor(1, 1, 1)

    self.Name = self:CreateFontString(nil, "OVERLAY", "nPlate_NameFont")
    self.Name:SetJustifyH("CENTER")
    self.Name:SetIgnoreParentScale(true)

    self.CCIcon = CreateFrame("Frame", "$parentCCIcon", self)
    self.CCIcon:SetSize(20, 14)
    self.CCIcon:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
    self.CCIcon:SetCollapsesLayout(true)
    self.CCIcon:SetIgnoreParentScale(true)
    self.CCIcon.PreUpdate = function(element)
        local shouldShow = not self:IsWidgetMode() and Settings.GetValue("NPLATES_CROWD_CONTROL")
        element:SetShown(shouldShow)
    end

    self.CCIcon.Cooldown = CreateFrame("Cooldown", "$parentCooldown", self.CCIcon, "CooldownFrameTemplate")
    self.CCIcon.Cooldown:SetAllPoints(self.CCIcon)
    self.CCIcon.Cooldown:SetHideCountdownNumbers(false)
    self.CCIcon.Cooldown:SetCountdownFont("nPlate_CooldownFont")

    self.CCIcon.Icon = self.CCIcon:CreateTexture("$parentIcon", "ARTWORK")
    self.CCIcon.Icon:SetPoint("CENTER")
    self.CCIcon.Icon:SetSize(18, 12)
    self.CCIcon.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)

    self.CCIcon.Background = self.CCIcon:CreateTexture("$parentBackground", "BACKGROUND")
    self.CCIcon.Background:SetAllPoints(self.CCIcon)
    self.CCIcon.Background:SetColorTexture(0, 0, 0)

    self.QuestIndicator = self:CreateTexture("$parentQuestIcon", "OVERLAY")
    self.QuestIndicator:SetSize(25, 25)
    self.QuestIndicator:SetPoint("LEFT", self.CCIcon, "RIGHT", 0, 0)
    self.QuestIndicator:SetAtlas("QuestNormal", false)
    self.QuestIndicator:SetCollapsesLayout(true)
    self.QuestIndicator.Override = nPlates.QuestIndicator

    self.classificationIndicator = self:CreateTexture("$parentClassificationIndicator", "OVERLAY", nil, 7)
    self.classificationIndicator:SetSize(20, 20)
    self.classificationIndicator:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
    self.classificationIndicator:SetCollapsesLayout(true)

    self.RaidTargetIndicator = self:CreateTexture("$parentRaidTargetIcon", "OVERLAY")
    self.RaidTargetIndicator:SetPoint("RIGHT", self.classificationIndicator, "LEFT", -4, 0)
    self.RaidTargetIndicator:SetSize(22, 22)
    self.RaidTargetIndicator:SetCollapsesLayout(true)
    self.RaidTargetIndicator.PostUpdate = function(element, index)
        if self:IsWidgetMode() then
            element:Hide()
        end
    end

    self.Debuffs = CreateFrame("Frame", "$parentAuras", self)
    self.Debuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
    self.Debuffs:SetIgnoreParentScale(true)
    self.Debuffs.size = 20
    self.Debuffs.width = 20
    self.Debuffs.height = 14
    self.Debuffs:SetHeight(14)
    self.Debuffs:SetWidth(175)
    self.Debuffs.initialAnchor = "BOTTOMLEFT"
    self.Debuffs.growthX = "RIGHT"
    self.Debuffs.growthY = "UP"
    self.Debuffs.spacing = 2
    self.Debuffs.showStealableBuffs = true
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.reanchorIfVisibleChanged = true
    self.Debuffs.numTotal = 6
    self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
    self.Debuffs.PostCreateButton = nPlates.PostCreateButton
    self.Debuffs.PostUpdateButton = nPlates.PostUpdateButton
    self.Debuffs.PostUpdate = nPlates.DebuffPostUpdate
    self.Debuffs.PreUpdate = function(auras, unit)
        auras:SetShown(not self:IsWidgetMode())
    end

    self.Buffs = CreateFrame("Frame", "$parentBuffs", self)
    self.Buffs:SetIgnoreParentScale(true)
    self.Buffs:SetCollapsesLayout(true)
    self.Buffs.size = 20
    self.Buffs.width = 20
    self.Buffs.height = 14
    self.Buffs:SetHeight(20)
    self.Buffs:SetWidth(50)
    self.Buffs.initialAnchor = "RIGHT"
    self.Buffs.growthX = "LEFT"
    self.Buffs.growthY = "UP"
    self.Buffs.spacing = 2
    self.Buffs.reanchorIfVisibleChanged = true
    self.Buffs.num = 2
    self.Buffs.filter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY"
    self.Buffs:SetPoint("RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)
    self.Buffs.PostCreateButton = nPlates.PostCreateButton
    self.Buffs.PostUpdateButton = nPlates.PostUpdateButton
    self.Buffs.SetPosition = nPlates.BuffsLayout
    self.Buffs.PreUpdate = function(auras, unit)
        local shouldShow = not self:IsWidgetMode() and self:ShouldShowBuffs()
        auras:SetShown(shouldShow)
    end

    local softTarget = self:GetParent().UnitFrame.SoftTargetFrame
    if softTarget then
        softTarget:ClearAllPoints()
        softTarget:SetPoint("LEFT", self.Buffs, "RIGHT", 4, 0)
        softTarget:SetCollapsesLayout(true)
    end

    self.ComboPoints = nPlates:CreateComboPoints(self)
	self.ComboPoints:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.ComboPoints:SetPoint("CENTER", self)

    self.Chi = nPlates:CreateChi(self)
    self.Chi:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.Chi:SetPoint("CENTER", self)

    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FACTION", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FLAGS", nPlates.UpdateHealth)

    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", function(self, event, unit)
        self:UpdateClassification()
        self:UpdateName()
    end)

    -- We use a custom "PLAYER_TARGET_CHANGED" because the oUF verion
    -- doesn't fire when you lose target.
    self:RegisterEvent("PLAYER_TARGET_CHANGED", function(self, event)
        nPlates:OnTargetChanged(self, "PLAYER_TARGET_CHANGED", self.unit)
    end, true)

    self:RegisterEvent("PLAYER_FOCUS_CHANGED", function(self, event)
        self:UpdateIsFocus()
        nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
            nPlates:SetSelectionColor(plate)
        end)
    end, true)

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
    nameplate.unit = unit

    nameplate:UpdateIsPlayer()
    nameplate:UpdateIsTarget()
    nameplate:UpdateIsFocus()

    nameplate:UpdateWidgetsOnlyMode()
    nameplate:UpdateClassification()
    nameplate:UpdateName()
    nameplate:UpdateNameLocation()
    nameplate:UpdateBuffs()
    nameplate:UpdateDebuffs()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()
    nPlates.UpdateHealth(nameplate, event, unit)

    nameplate:Show()
end

function nPlates:OnTargetChanged(nameplate, event, unit)
    nameplate:UpdateIsTarget()

    nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
        nPlates:SetSelectionColor(plate)
    end)

    nameplate:UpdateName()
    nameplate:UpdateDebuffLocation()
    nameplate:UpdateClassPower()
end
