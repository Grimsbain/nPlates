local _, nPlates = ...

function nPlates.CreateCCIcon(self)
    local CCIcon = self:CreateAuras()
    CCIcon.maxFrameCount = 1
    CCIcon.size = 20
    CCIcon.width = 20
    CCIcon.height = 14
    CCIcon.showCount = true
    CCIcon.growthX = "RIGHT"
    CCIcon.growthY = "UP"
    CCIcon.elementSpacing = 2
    CCIcon.showDuration = false
    CCIcon:SetIgnoreParentScale(true)
    CCIcon.PostCreateButton = nPlates.PostCreateButton

    PixelUtil.SetPoint(CCIcon, "LEFT", self.QuestIndicator, "RIGHT", 4, 0)

    -- Register a group using a filter and some options
    CCIcon:AddGroup("HARMFUL|CROWD_CONTROL", {})

    self.CCIcon = CCIcon
end
