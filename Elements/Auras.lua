local _, nPlates = ...

nPlates.PostCreateButton = function(element, button, options)
    button.Cooldown:SetHideCountdownNumbers(false)
    button.Cooldown:SetDrawEdge(true)
    button.Cooldown:SetDrawSwipe(false)
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")
    button.Cooldown:SetUseAuraDisplayTime(true)

    button.Background = button:CreateTexture("$parentBackground", "BACKGROUND")
    button.Background:SetAllPoints(button)
    button.Background:SetColorTexture(0, 0, 0)

    button.Count:SetFontObject("nPlate_CountFont")
    button.Count:ClearAllPoints()
    button.Count:SetPoint("CENTER", button.Icon, "TOPLEFT", 1, 1)
    button.Count:SetJustifyH("RIGHT")

    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("CENTER")
    button.Icon:SetSize(18, 12)
    button.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
end

function nPlates.CreateBuffs(self)
    local Buffs = self:CreateAuras()
    Buffs.showCount = true
    Buffs.showDuration = false
    Buffs.maxFrameCount = 2
    Buffs.size = 20
    Buffs.width = 20
    Buffs.height = 14
    Buffs.initialAnchor = "RIGHT"
    Buffs.growthX = "LEFT"
    Buffs.growthY = "UP"
    Buffs.elementSpacing = 2
    Buffs:SetIgnoreParentScale(true)
    Buffs:SetCollapsesLayout(true)
    Buffs.PostCreateButton = nPlates.PostCreateButton

    Buffs.sortMethod = AuraContainerSortMethod.ExpirationOnly
    Buffs.sortDirection = AuraContainerSortDirection.Normal

    PixelUtil.SetPoint(Buffs, "RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)

    local groupKey = Buffs:AddGroup("HELPFUL|IMPORTANT", {})
    Buffs.groupKey = groupKey

    self.Buffs = Buffs
end

function nPlates.CreateCCIcon(self)
    local CCIcon = self:CreateAuras()
    CCIcon.showCount = true
    CCIcon.showDuration = false
    CCIcon.maxFrameCount = 1
    CCIcon.size = 20
    CCIcon.width = 20
    CCIcon.height = 14
    CCIcon.initialAnchor = "LEFT"
    CCIcon.growthX = "RIGHT"
    CCIcon.growthY = "UP"
    CCIcon.elementSpacing = 2
    CCIcon:SetIgnoreParentScale(true)
    CCIcon:SetCollapsesLayout(true)
    CCIcon.PostCreateButton = nPlates.PostCreateButton

    PixelUtil.SetPoint(CCIcon, "LEFT", self.QuestIndicator, "RIGHT", 4, 0)

    local groupKey = CCIcon:AddGroup("HARMFUL|CROWD_CONTROL", {})
    CCIcon.groupKey = groupKey

    self.CCIcon = CCIcon
end

function nPlates.CreateDebuffs(self)
    local Debuffs = self:CreateAuras()
    Debuffs.showCount = true
    Debuffs.showDuration = false
    Debuffs.maxFrameCount = 12
    Debuffs.size = 20
    Debuffs.width = 20
    Debuffs.height = 14
    Debuffs.growthX = "RIGHT"
    Debuffs.growthY = "UP"
    Debuffs.elementSpacing = 2
    Debuffs:SetIgnoreParentScale(true)
    Debuffs:SetScale(Settings.GetValue("NPLATES_AURA_SCALE"))
    Debuffs.PostCreateButton = nPlates.PostCreateButton

    Debuffs.sortMethod = Settings.GetValue("NPLATES_SORT_BY")
    Debuffs.sortDirection = Settings.GetValue("NPLATES_SORT_DIRECTION")

    PixelUtil.SetPoint(Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, 17)

    local groupKey = Debuffs:AddGroup("PLAYER|HARMFUL|INCLUDE_NAME_PLATE_ONLY", {})
    Debuffs.groupKey = groupKey

    self.Debuffs = Debuffs
end
