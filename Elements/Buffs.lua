local _, nPlates = ...

local function SetPosition(element, from, to)
    local lastButton = nil
    for i = from, to do
        local button = element[i]
        if(not button) then break end

        local data = element.all[button.auraInstanceID]
        local spellID = (data and data.spellId) or 0
        local isImportant = C_Spell.IsSpellImportant(spellID)

        button:SetAlphaFromBoolean(isImportant, 1, 0)
        button:ClearAllPoints()

        if button:IsVisible() then
            if lastButton == nil then
                lastButton = button
                button:SetPoint("RIGHT", element, "RIGHT", 0, 0)
            else
                button:SetPoint("RIGHT", lastButton, "LEFT", -element.spacing, 0)
                lastButton = button
            end
        end
    end
end

function nPlates.CreateBuffs(self)
    self.Buffs = CreateFrame("Frame", "$parentBuffs", self)
    self.Buffs:SetIgnoreParentScale(true)
    self.Buffs:SetCollapsesLayout(true)
    self.Buffs.size = 20
    self.Buffs.width = 20
    self.Buffs.height = 14
    self.Buffs:SetHeight(20)
    self.Buffs:SetWidth(50)
    self.Buffs.initialAnchor = "RIGHT"
    self.Buffs.growthX = "LEFT"
    self.Buffs.growthY = "UP"
    self.Buffs.spacing = 2
    self.Buffs.reanchorIfVisibleChanged = true
    self.Buffs.num = 2
    self.Buffs.filter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY"
    self.Buffs:SetPoint("RIGHT", self.RaidTargetIndicator, "LEFT", -4, 0)
    self.Buffs.PostCreateButton = nPlates.PostCreateButton
    self.Buffs.PostUpdateButton = nPlates.PostUpdateButton
    self.Buffs.SetPosition = SetPosition
    self.Buffs.PreUpdate = function(auras, unit)
        local shouldShow = not self:IsWidgetMode() and self:ShouldShowBuffs()
        auras:SetShown(shouldShow)
    end
end
