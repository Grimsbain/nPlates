local _, nPlates = ...

function nPlates.CreateClassPowers(self)
    self.ComboPoints = nPlates:CreateComboPoints(self)
	self.ComboPoints:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.ComboPoints:SetPoint("CENTER", self)

    self.Chi = nPlates:CreateChi(self)
    self.Chi:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.Chi:SetPoint("CENTER", self)

    self.Essence = nPlates:CreateEssence(self)
    self.Essence:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 4)
    self.Essence:SetPoint("CENTER", self)
end
