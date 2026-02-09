local _, nPlates = ...

local function DebuffPostUpdate(auras, unit)
    local parent = auras:GetParent()

    if ( parent:IsWidgetMode() ) then
        auras:Hide()
        return
    end

    local relativeTo = auras.visibleButtons > 0 and parent.Debuffs or parent.Name
    parent.ClassFrameContainer:ClearAllPoints()
    parent.ClassFrameContainer:SetPoint("BOTTOM", relativeTo, "TOP", 0, 4)
    parent.ClassFrameContainer:SetPoint("CENTER", parent)
end

function nPlates.CreateDebuffs(self)
    self.Debuffs = CreateFrame("Frame", "$parentAuras", self)
    self.Debuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
    self.Debuffs:SetIgnoreParentScale(true)
    self.Debuffs.size = 20
    self.Debuffs.width = 20
    self.Debuffs.height = 14
    self.Debuffs:SetHeight(14)
    self.Debuffs:SetWidth(175)
    self.Debuffs.initialAnchor = "BOTTOMLEFT"
    self.Debuffs.growthX = "RIGHT"
    self.Debuffs.growthY = "UP"
    self.Debuffs.spacing = 2
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.reanchorIfVisibleChanged = true
    self.Debuffs.numTotal = 6
    self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
    self.Debuffs.PostCreateButton = nPlates.PostCreateButton
    self.Debuffs.PostUpdateButton = nPlates.PostUpdateButton
    self.Debuffs.PostUpdate = DebuffPostUpdate
    self.Debuffs.PreUpdate = function(auras, unit)
        auras:SetShown(not self:IsWidgetMode())
    end
end