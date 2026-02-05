local _, nPlates = ...

function nPlates.UpdateSoftTarget(self)
    self.SoftTargetFrame = self:GetUnitFrame().SoftTargetFrame
    self.SoftTargetFrame:ClearAllPoints()
    self.SoftTargetFrame:SetPoint("LEFT", self.RaidTargetIndicator, "RIGHT", 4, 0)
    self.SoftTargetFrame:SetCollapsesLayout(true)
end
