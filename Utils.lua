local _, nPlates = ...
local oUF = nPlates.oUF

nPlates.Media = {
    -- Status Bar
    StatusBarTexture = [[Interface\AddOns\nPlates\Media\UI-StatusBar]],
    StatusBarColor = CreateColor(1, 0.7, 0),

    -- Border
    BorderColor = CreateColor(1.0, 1.0, 1.0),
    DefaultBorderColor = CreateColor(0.4, 0.4, 0.4),
    ImportantCastColor = CreateColor(1, 0, 0.5),
    FocusColor = CreateColor(1.0, 0.49, 0.039),
    SelectionColor = CreateColor(1.0, 1.0, 1.0),

    -- Castbar
    InteruptibleColor = CreateColor(0.75, 0.0, 0.0),

    -- Health
    OffTankColor =  CreateColor(174/255, 0.0, 1.0),
}

-- Threat Functions

local function IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

local function UseOffTankColor(unit)
    if ( not Settings.GetValue("NPLATES_OFF_TANK_COLOR") or not PlayerUtil.IsPlayerEffectivelyTank() ) then
        return false
    end

    return IsInRaid() and UnitGroupRolesAssignedEnum(unit.."target") == Enum.LFGRole.Tank
end

    -- Health Functions

local function UpdateStatusText(self, currentHealth)
    local text = self.Health.Value
    local style = Settings.GetValue("NPLATES_HEALTH_STYLE")

    if ( style == "disabled" ) then
        text:Hide()
        return
    else
        local health = AbbreviateNumbers(currentHealth)
        local percent = UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)

        if ( style == "cur_perc" ) then
            text:SetFormattedText("%s - %.0f%%", health, percent)
        elseif ( style == "perc_cur" ) then
            text:SetFormattedText("%.0f%% - %s", percent, health)
        elseif ( style  == "cur" ) then
            text:SetFormattedText("%s", health)
        elseif ( style == "perc" ) then
            text:SetFormattedText("%.0f%%", percent)
        end

        text:Show()
    end
end

function nPlates.UpdateHealth(self, event, unit)
    if ( not unit or self.unit ~= unit ) then return end

	local element = self.Health
    if not element:IsShown() then return end

    local r, g, b
    local currentHealth, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)

    if ( UnitIsDeadOrGhost(self.unit) or UnitIsTapDenied(self.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( UnitIsPlayer(self.unit) or UnitInPartyIsAI(self.unit) ) then
            local _, class = UnitClass(self.unit)
            local color = RAID_CLASS_COLORS[class]
            r, g, b = color:GetRGB()
        else
            if ( IsOnThreatListWithPlayer(self.unit) ) then
                if ( Settings.GetValue("NPLATES_TANKMODE") ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.unit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.0, 1.0, 0.0
                        else
                            r, g, b = GetThreatStatusColor(threatStatus)
                        end
                    elseif ( UseOffTankColor(self.unit) ) then
                        r, g, b = nPlates.Media.OffTankColor:GetRGB()
                    else
                        r, g, b = 1, 0, 0
                    end
                else
                    r, g, b = 1, 0, 0
                end
            else
                r, g, b = UnitSelectionColor(self.unit, true)
            end
        end
    end

	element:SetMinMaxValues(0, maxHealth)
    element:SetValue(currentHealth)
    element:SetStatusBarColor(r, g, b)
    nPlates:SetSelectionColor(self)
    UpdateStatusText(self, currentHealth)
end

-- Aura Functions

nPlates.PostCreateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")

    button.Overlay:ClearAllPoints()

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

nPlates.PostUpdateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
end

nPlates.DebuffPostUpdate = function(auras, unit)
    local parent = auras:GetParent()

    if ( parent:IsWidgetMode() ) then
        auras:Hide()
        return
    end

    parent.ComboPoints:ClearAllPoints()

    if auras.visibleButtons > 0 then
        parent.ComboPoints:SetPoint("BOTTOM", parent.Debuffs, "TOP", 0, 4)
        parent.ComboPoints:SetPoint("CENTER", parent)
    else
        parent.ComboPoints:SetPoint("BOTTOM", parent.Name, "TOP", 0, 4)
        parent.ComboPoints:SetPoint("CENTER", parent)
    end

    parent.Chi:ClearAllPoints()

    if auras.visibleButtons > 0 then
        parent.Chi:SetPoint("BOTTOM", parent.Debuffs, "TOP", 0, 5)
        parent.Chi:SetPoint("CENTER", parent)
    else
        parent.Chi:SetPoint("BOTTOM", parent.Name, "TOP", 0, 5)
        parent.Chi:SetPoint("CENTER", parent)
    end
end

nPlates.BuffsLayout = function(element, from, to)
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

    -- Castbar Functions

nPlates.PostCastStart = function(castbar, unit)
    local isImportant = C_Spell.IsSpellImportant(castbar.spellID)
    castbar:GetStatusBarTexture():SetVertexColorFromBoolean(isImportant, nPlates.Media.ImportantCastColor, nPlates.Media.StatusBarColor)

    local borderColor = C_CurveUtil.EvaluateColorFromBoolean(castbar.notInterruptible, nPlates.Media.InteruptibleColor, nPlates.Media.DefaultBorderColor)
    nPlates:SetCastbarBorderColor(castbar, borderColor)
end

    -- QuestIndicator Functions

nPlates.QuestIndicator = function(self, event, unit)
    local element = self.QuestIndicator

    if self:IsWidgetMode() then
        element:Hide()
        return
    end

    local shouldShow = Settings.GetValue("NPLATES_SHOWQUEST") and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
    element:SetShown(shouldShow)
end

-- oUF Functions

function nPlates:UpdateAllNameplates()
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            obj:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateNameplatesWithFunction(func, ...)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            if func then
                func(obj, obj.unit, ...)
            end
        end
    end
end

function nPlates:UpdateElement(name)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj:IsShown() and obj.unit ) then
            local element = obj[name]
            if element and element.ForceUpdate then
                element:ForceUpdate()
            end
        end
    end
end
