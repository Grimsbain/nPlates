local _, nPlates = ...

function nPlates.CreateBuffs(self)
    local Buffs = self:CreateAuras()
    Buffs.maxFrameCount = 2
    Buffs.size = 20
    Buffs.width = 20
    Buffs.height = 14
    Buffs.showCount = true
    Buffs.initialAnchor = "RIGHT"
    Buffs.growthX = "LEFT"
    Buffs.growthY = "UP"
    Buffs.elementSpacing = 2
    Buffs.showDuration = false
    Buffs:SetIgnoreParentScale(true)
    Buffs:SetCollapsesLayout(true)
    Buffs.PostCreateButton = nPlates.PostCreateButton
    Buffs.sortMethod = AuraContainerSortMethod.ExpirationOnly
    Buffs.sortDirection = AuraContainerSortDirection.Normal

    PixelUtil.SetPoint(Buffs, "RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)

    -- Register a group using a filter and some options
    Buffs:AddGroup("HELPFUL|IMPORTANT", {})

    Buffs:SetEnabled(Settings.GetValue("NPLATES_SHOW_BUFFS"))

    self.Buffs = Buffs
end
