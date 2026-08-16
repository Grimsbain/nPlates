local _, nPlates = ...

function nPlates.CreateDebuffs(self)
    local Debuffs = self:CreateAuras()
    Debuffs.maxFrameCount = 12
    Debuffs.size = 20
    Debuffs.width = 20
    Debuffs.height = 14
    Debuffs.showCount = true
    Debuffs.growthX = "RIGHT"
    Debuffs.growthY = "UP"
    Debuffs.elementSpacing = 2
    Debuffs.showDuration = false
    Debuffs:SetIgnoreParentScale(true)
    Debuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
    Debuffs.PostCreateButton = nPlates.PostCreateButton
    Debuffs.sortMethod = Settings.GetValue("NPLATES_SORT_BY")
    Debuffs.sortDirection = Settings.GetValue("NPLATES_SORT_DIRECTION")

    PixelUtil.SetPoint(Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, 17)

    -- Register a group using a filter and some options
    local key = Debuffs:AddGroup("PLAYER|HARMFUL|INCLUDE_NAME_PLATE_ONLY", {})
    Debuffs.key = key

    self.Debuffs = Debuffs
end