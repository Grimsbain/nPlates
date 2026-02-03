local _, nPlates = ...

nPlatesEssenceMixin = {}

function nPlatesEssenceMixin:OnLoad()
    self.requiredClass = "EVOKER"

    self.PowerEvents = {
        "UNIT_POWER_FREQUENT",
        "UNIT_MAXPOWER"
    }

    local _, class = UnitClass("player")
    if class ~= self.requiredClass then
        self:Hide()
        self:UnregisterAllEvents()
        return
    end

    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED")
end

function nPlatesEssenceMixin:OnEvent(event, ...)
    if ( event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" ) then
        self:UpdatePower()
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UpdatePower()
    elseif ( event == "UNIT_MAXPOWER" ) then
        self:UnitMaxPower()
    elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
        self:UpdateVisibility()
    elseif ( event == "TRAIT_CONFIG_UPDATED" ) then
        self:UpdatePower()
        self:UnitMaxPower()
    end
end

function nPlatesEssenceMixin:OnShow()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    FrameUtil.RegisterFrameForUnitEvents(self, self.PowerEvents, "player")
    self:Update(self:GetParent().unit)
end

function nPlatesEssenceMixin:OnHide()
	for i, event in ipairs(self.PowerEvents) do
		self:UnregisterEvent(event);
	end
end

function nPlatesEssenceMixin:UpdatePower()
    self:Update(self:GetParent().unit)
end

function nPlatesEssenceMixin:UnitMaxPower()
    self.maxPower = UnitPowerMax("player", Enum.PowerType.Essence)
    self:UpdateSize()
end

function nPlatesEssenceMixin:Update(unit)
    if ( not unit or not self or not self.Points ) then
		return
	end

    if ( not Settings.GetValue("NPLATES_SHOW_RESOURCE") or not self:ShouldShow(unit) ) then
		self:Hide()
		return
	end

	local currentPower = UnitPower("player", Enum.PowerType.Essence) or 0
    local maxPower = UnitPowerMax("player", Enum.PowerType.Essence)

    for index, power in ipairs(self.Points) do
        if index <= maxPower then
            power.Point:SetShown(index <= currentPower)
            power:Show()
        else
            power:Hide()
        end
    end

    self:Show()
end

function nPlatesEssenceMixin:UpdateSize()
	local totalWidth = (self.maxPower * self.indicatorSize) + ((self.maxPower) * self.spacing)
	self:SetWidth(totalWidth)
end

function nPlatesEssenceMixin:ShouldShow(unit)
    if ( self:IsWidgetMode() ) then
        return false
    end

    if ( not unit or not UnitIsUnit(unit, "target") or not UnitCanAttack("player", unit) ) then
        return false
    end

    return not UnitHasVehicleUI("player")
end

function nPlatesEssenceMixin:UpdateVisibility()
    local shouldShow = self:ShouldShow(self:GetParent().unit)
    self:SetShown(shouldShow)
end

function nPlatesEssenceMixin:Toggle(value)
    local shouldHide = self:IsShown() and value == false
    if shouldHide then self:Hide() else self:UpdateVisibility() end
end

function nPlatesEssenceMixin:SetWidgetMode(isWidgetMode)
    self.isWidgetMode = isWidgetMode
end

function nPlatesEssenceMixin:IsWidgetMode()
    return self.isWidgetMode == true
end

function nPlates:CreateEssence(nameplate)
	local frame = CreateFrame("Frame", "$parentEssence", nameplate, "nPlatesEssenceFrame")
	frame.maxPower = UnitPowerMax("player", Enum.PowerType.Essence)
    frame:UpdateSize()

	return frame
end

