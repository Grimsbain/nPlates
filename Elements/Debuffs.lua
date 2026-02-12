local _, nPlates = ...

local function DebuffPostUpdate(auras, unit)
    local parent = auras:GetParent()

    if ( parent:IsWidgetMode() ) then
        auras:Hide()
        return
    end

    local relativeTo = auras.visibleButtons > 0 and parent.BetterDebuffs or parent.Name
    parent.ClassFrameContainer:ClearAllPoints()
    parent.ClassFrameContainer:SetPoint("BOTTOM", relativeTo, "TOP", 0, 4)
    parent.ClassFrameContainer:SetPoint("CENTER", parent)
end

function nPlates.CreateDebuffs(self)
    self.BetterDebuffs = CreateFrame("Frame", "$parentDebuffs", self)
    self.BetterDebuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
    self.BetterDebuffs:SetIgnoreParentScale(true)
    self.BetterDebuffs.size = 20
    self.BetterDebuffs.width = 20
    self.BetterDebuffs.height = 14
    self.BetterDebuffs:SetHeight(14)
    self.BetterDebuffs:SetWidth(175)
    self.BetterDebuffs.initialAnchor = "BOTTOMLEFT"
    self.BetterDebuffs.growthX = "RIGHT"
    self.BetterDebuffs.growthY = "UP"
    self.BetterDebuffs.spacing = 2
    self.BetterDebuffs.reanchorIfVisibleChanged = true
    self.BetterDebuffs.numTotal = 12
    self.BetterDebuffs.filter = "PLAYER|HARMFUL|INCLUDE_NAME_PLATE_ONLY"
    self.BetterDebuffs.sortRule = Settings.GetValue("NPLATES_SORT_BY")
    self.BetterDebuffs.PostCreateButton = nPlates.PostCreateButton
    self.BetterDebuffs.PostUpdateButton = nPlates.PostUpdateButton
    self.BetterDebuffs.showType = Settings.GetValue("NPLATES_DEBUFF_TYPE")
    self.BetterDebuffs.sortDirection = Settings.GetValue("NPLATES_SORT_DIRECTION")
    self.BetterDebuffs.PostUpdate = DebuffPostUpdate
    self.BetterDebuffs.PreUpdate = function(debuffs, unit)
        debuffs:SetShown(not self:IsWidgetMode())
    end
end