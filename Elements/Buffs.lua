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
    self.BetterBuffs.friendFilter = "HELPFUL|IMPORTANT"
    self.BetterBuffs.enemyFilter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY"
    self.BetterBuffs:SetPoint("RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)
    self.BetterBuffs.PostCreateButton = nPlates.PostCreateButton
    self.BetterBuffs.PostUpdateButton = nPlates.PostUpdateButton
    self.BetterBuffs:SetShown(Settings.GetValue("NPLATES_SHOW_BUFFS"))

    self.BetterBuffs.PreUpdate = function(buffs, unit)
        local shouldShow = not self:IsWidgetMode() and self:ShouldShowBuffs()
        buffs:SetShown(shouldShow)
    end

    self.BetterBuffs.PostUpdate = function(element)
        if element.Cooldown then
            element.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
            element.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
            element.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
        end
    end
end
