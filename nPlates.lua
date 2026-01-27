local _, nPlates = ...
local oUF = nPlates.oUF

local function Layout(self, unit)
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

    self.QuestIndicator = self:CreateTexture("$parentQuestIcon", "OVERLAY")
    self.QuestIndicator:SetSize(25, 25)
    self.QuestIndicator:SetPoint("LEFT", self.Health, "RIGHT", 0, 0)
    self.QuestIndicator:SetAtlas("QuestNormal", false)
    self.QuestIndicator.Override = function(self, event, unit)
        local element = self.QuestIndicator
        local shouldShow = nPlates:GetSetting("NPLATES_SHOWQUEST") and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
        element:SetShown(shouldShow)
    end

    self.classificationIndicator = self:CreateTexture("$parentClassificationIndicator", "OVERLAY", nil, 7)
    self.classificationIndicator:SetSize(20, 20)
    self.classificationIndicator:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
    self.classificationIndicator:SetCollapsesLayout(true)

    self.RaidTargetIndicator = self:CreateTexture("$parentRaidTargetIcon", "OVERLAY")
    self.RaidTargetIndicator:SetPoint("RIGHT", self.classificationIndicator, "LEFT", -4, 0)
    self.RaidTargetIndicator:SetSize(22, 22)
    self.RaidTargetIndicator:SetCollapsesLayout(true)

    self.Debuffs = CreateFrame("Frame", "$parentAuras", self)
    self.Debuffs:SetScale(nPlates:GetSetting("NPLATES_AURA_SCALE"))
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
    nPlates:UpdateDebuffAnchors(self)

    self.Buffs = CreateFrame("Frame", "$parenBuffs", self)
    self.Buffs:SetIgnoreParentScale(true)
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
    self.Buffs:SetCollapsesLayout(true)

    self.ComboPoints = nPlates:CreateComboPointsElement(self)
	self.ComboPoints:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.ComboPoints:SetPoint("CENTER", self)

    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FACTION", nPlates.UpdateHealth)
    self:RegisterEvent("UNIT_FLAGS", nPlates.UpdateHealth)

    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", function(self, event, unit)
        nPlates:UpdateClassification(self, event, self.unit)
        nPlates:UpdateName(self, event, self.unit)
    end)

    -- We use a custom "PLAYER_TARGET_CHANGED" because the oUF verion
    -- doesn't fire when you lose target.
    self:RegisterEvent("PLAYER_TARGET_CHANGED", function(self, event)
        nPlates:OnTargetChanged(self, "PLAYER_TARGET_CHANGED", self.unit)
    end, true)

    self:RegisterEvent("PLAYER_FOCUS_CHANGED", function(self, event)
        nPlates:UpdateAllNameplatesWithFunction(function(plate, unitToken)
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
    nPlates.Media.OffTankColorHex = CreateColorFromHexString(nPlates:GetSetting("NPLATES_OFF_TANK_COLOR_HEX"));
    nPlates.Media.SelectionColorHex = CreateColorFromHexString(nPlates:GetSetting("NPLATES_SELECTION_COLOR_HEX"));
    nPlates.Media.FocusColorHex = CreateColorFromHexString(nPlates:GetSetting("NPLATES_FOCUS_COLOR_HEX"));

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
    nameplate:Hide()
end

function nPlates:OnNamePlateAdded(nameplate, event, unit)
    nameplate.unit = unit
    nameplate.ComboPoints:UpdateVisibility()

    nPlates:UpdateWidgetsOnlyMode(nameplate, unit)
    nPlates:UpdateClassification(nameplate, event, unit)
    nPlates.UpdateHealth(nameplate, event, unit)
    nPlates:UpdateName(nameplate, event, unit)
    nPlates:UpdateNameLocation(nameplate, event, unit)
    nPlates:UpdateDebuffAnchors(nameplate)
    nameplate.Debuffs:SetScale(nPlates:GetSetting("NPLATES_AURA_SCALE"))

    nameplate:Show()
end

function nPlates:OnTargetChanged(nameplate, event, unit)
    nPlates:UpdateAllNameplatesWithFunction(function(plate, unitToken)
        nPlates:SetSelectionColor(plate)
    end)

    nPlates:UpdateName(nameplate, event, unit)
    nPlates:UpdateDebuffAnchors(nameplate)
    nameplate.ComboPoints:UpdateVisibility()
end

function nPlates:UpdateWidgetsOnlyMode(nameplate, unit)
    local widgetsOnlyMode = unit ~= nil and UnitNameplateShowsWidgetsOnly(unit);
    nameplate.Health:SetShown(not widgetsOnlyMode)
    nameplate.classificationIndicator:SetShown(not widgetsOnlyMode)
    nameplate.Debuffs:SetShown(not widgetsOnlyMode)
    nameplate.Buffs:SetShown(not widgetsOnlyMode)
    nameplate.Name:SetShown(not widgetsOnlyMode)
    nameplate.isWidget = widgetsOnlyMode

    nameplate.WidgetContainer:ClearAllPoints();

    if widgetsOnlyMode then
        PixelUtil.SetPoint(nameplate.WidgetContainer, "BOTTOM", nameplate, "BOTTOM", 0, 0);
        PixelUtil.SetPoint(nameplate.WidgetContainer, "CENTER", nameplate, "CENTER", 0, 0);
    else
        PixelUtil.SetPoint(nameplate.WidgetContainer, "TOP", nameplate.Castbar, "BOTTOM", 0, 0);
    end
end
