local _, nPlates = ...
local _, class = UnitClass("player")

function nPlates.CreateClassPowers(self)
    self.ClassFrameContainer = CreateFrame("Frame", "$parentClassFrameContainer", self)
    self.ClassFrameContainer:SetSize(175, 20)
    self.ClassFrameContainer:ClearAllPoints()
    self.ClassFrameContainer:SetPoint("TOP", self.Health, "BOTTOM", 0, -5)
    self.ClassFrameContainer:SetPoint("CENTER", self.Health)

    -- For testing.
    -- self.ClassFrameContainer.Bg = self.ClassFrameContainer:CreateTexture("$parentBG", "BACKGROUND")
    -- self.ClassFrameContainer.Bg:SetAllPoints(self.ClassFrameContainer)
    -- self.ClassFrameContainer.Bg:SetColorTexture(1, 0, 0, 0.2)

    if ( class == "ROGUE" or class == "DRUID" ) then
        self.ComboPoints = CreateFrame("Frame", "$parentComboPoints", self, "nPlatesComboPoints")
    self.ComboPoints:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")
        self.ClassFrameContainer.Power = self.ComboPoints
    end

    if ( class == "MONK" ) then
        self.Chi = CreateFrame("Frame", "$parentChi", self, "nPlatesChiFrame")
    self.Chi:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")
        self.ClassFrameContainer.Power = self.Chi
    end

    if ( class == "EVOKER" ) then
        self.Essence = CreateFrame("Frame", "$parentEssence", self, "nPlatesEssenceFrame")
    self.Essence:SetPoint("CENTER", self.ClassFrameContainer, "CENTER")
        self.ClassFrameContainer.Power = self.Essence
    end
end

function nPlates:ToggleClassPower(self, shouldShow)
    if ( self.ClassFrameContainer.Power ) then
        self.ClassFrameContainer.Power:Toggle(shouldShow)
    end
end
