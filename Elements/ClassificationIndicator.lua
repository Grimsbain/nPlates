local _, nPlates = ...

function nPlates.CreateClassificationIndicator(self)
    self.ClassificationIndicator = self:CreateTexture("$parentClassificationIndicator", "OVERLAY", nil, 7)
    self.ClassificationIndicator:SetSize(20, 20)
    self.ClassificationIndicator:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
    self.ClassificationIndicator:SetCollapsesLayout(true)
end
