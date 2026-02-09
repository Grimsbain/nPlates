local _, nPlates = ...

function nPlates.CreateClassPowers(self)
    self.ClassFrameContainer = CreateFrame("Frame", "$parentClassFrameContainer", self)
    self.ClassFrameContainer:SetSize(175, 20)
    -- For testing.
    -- self.ClassFrameContainer.Bg = self.ClassFrameContainer:CreateTexture("$parentBG", "BACKGROUND")
    -- self.ClassFrameContainer.Bg:SetAllPoints(self.ClassFrameContainer)
    -- self.ClassFrameContainer.Bg:SetColorTexture(1, 0, 0, 0.2)

    self.ComboPoints = nPlates:CreateComboPoints(self)
    self.ComboPoints:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")

    self.Chi = nPlates:CreateChi(self)
    self.Chi:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")

    self.Essence = nPlates:CreateEssence(self)
    self.Essence:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")
end
