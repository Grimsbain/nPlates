local _, nPlates = ...

local function Override(self, event, unit)
    local element = self.QuestIndicator

    if ( self:IsWidgetMode() ) then
        element:Hide()
        return
    end

    local shouldShow = Settings.GetValue("NPLATES_SHOWQUEST") and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
    element:SetShown(shouldShow)
end

function nPlates.CreateQuestIcon(self)
    self.QuestIndicator = self:CreateTexture("$parentQuestIcon", "OVERLAY")
    self.QuestIndicator:SetSize(25, 25)
    self.QuestIndicator:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
    self.QuestIndicator:SetAtlas("QuestNormal", false)
    self.QuestIndicator:SetCollapsesLayout(true)
    self.QuestIndicator.Override = Override
end
