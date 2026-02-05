local _, nPlates = ...

function nPlates.CreateClassificationIndicator(self)
    self.classificationIndicator = self:CreateTexture("$parentClassificationIndicator", "OVERLAY", nil, 7)
    self.classificationIndicator:SetSize(20, 20)
    self.classificationIndicator:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
    self.classificationIndicator:SetCollapsesLayout(true)
end
