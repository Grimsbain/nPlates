local _, nPlates = ...

function nPlates.CreateRaidTargetIndicator(self)
    self.RaidTargetIndicator = self:CreateTexture("$parentRaidTargetIcon", "OVERLAY")
    self.RaidTargetIndicator:SetPoint("RIGHT", self.ClassificationIndicator, "LEFT", -4, 0)
    self.RaidTargetIndicator:SetSize(22, 22)
    self.RaidTargetIndicator:SetCollapsesLayout(true)
end
