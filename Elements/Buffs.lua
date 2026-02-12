local _, nPlates = ...

function nPlates.CreateBuffs(self)
    self.BetterBuffs = CreateFrame("Frame", "$parentBuffs", self)
    self.BetterBuffs:SetIgnoreParentScale(true)
    self.BetterBuffs:SetCollapsesLayout(true)
    self.BetterBuffs.size = 20
    self.BetterBuffs.width = 20
    self.BetterBuffs.height = 14
    self.BetterBuffs:SetHeight(20)
    self.BetterBuffs:SetWidth(50)
    self.BetterBuffs.initialAnchor = "RIGHT"
    self.BetterBuffs.growthX = "LEFT"
    self.BetterBuffs.growthY = "UP"
    self.BetterBuffs.spacing = 2
    self.BetterBuffs.reanchorIfVisibleChanged = true
    self.BetterBuffs.numTotal = 2
    self.BetterBuffs.helpfulFilter = "HELPFUL|IMPORTANT"
    self.BetterBuffs.harmfulFilter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY"
    self.BetterBuffs:SetPoint("RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)
    self.BetterBuffs.PostCreateButton = nPlates.PostCreateButton
    self.BetterBuffs.PostUpdateButton = nPlates.PostUpdateButton
    self.BetterBuffs.PreUpdate = function(buffs, unit)
        local shouldShow = not self:IsWidgetMode() and self:ShouldShowBuffs()
        buffs:SetShown(shouldShow)
    end
end
