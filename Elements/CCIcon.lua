local _, nPlates = ...

function nPlates.CreateCCIcon(self)
    self.CCIcon = CreateFrame("Frame", "$parentCCIcon", self)
    self.CCIcon:SetFrameLevel(self:GetFrameLevel()+5)
    self.CCIcon:SetSize(20, 14)
    self.CCIcon:SetPoint("LEFT", self.QuestIndicator, "RIGHT", 4, 0)
    self.CCIcon:SetCollapsesLayout(true)
    self.CCIcon:SetIgnoreParentScale(true)
    self.CCIcon.PreUpdate = function(element)
        local shouldShow = not self:IsWidgetMode() and not self:IsSimplified() and Settings.GetValue("NPLATES_CROWD_CONTROL")
        element:SetShown(shouldShow)
    end

    self.CCIcon.Cooldown = CreateFrame("Cooldown", "$parentCooldown", self.CCIcon, "CooldownFrameTemplate")
    self.CCIcon.Cooldown:SetAllPoints(self.CCIcon)
    self.CCIcon.Cooldown:SetCountdownFont("nPlate_CooldownFont")
    self.CCIcon.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    self.CCIcon.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    self.CCIcon.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))

    self.CCIcon.Icon = self.CCIcon:CreateTexture("$parentIcon", "ARTWORK")
    self.CCIcon.Icon:SetPoint("CENTER")
    self.CCIcon.Icon:SetSize(18, 12)
    self.CCIcon.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)

    self.CCIcon.Background = self.CCIcon:CreateTexture("$parentBackground", "BACKGROUND")
    self.CCIcon.Background:SetAllPoints(self.CCIcon)
    self.CCIcon.Background:SetColorTexture(0, 0, 0)
end
