local _, nPlates = ...

nPlatesComboPointsMixin = {}

function nPlatesComboPointsMixin:OnLoad()
    self.PowerEvents = {
        "UNIT_POWER_FREQUENT",
        "UNIT_MAXPOWER"
    }

    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
end

function nPlatesComboPointsMixin:OnEvent(event, ...)
    if ( event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" ) then
        self:UpdatePower()
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UpdatePower()
    elseif ( event == "UNIT_MAXPOWER" ) then
        self:UnitMaxPower()
    end
end

function nPlatesComboPointsMixin:OnShow()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    FrameUtil.RegisterFrameForUnitEvents(self, self.PowerEvents, "player")
    self:Update(self:GetParent().unit)
end

function nPlatesComboPointsMixin:OnHide()
	for i, event in ipairs(self.PowerEvents) do
		self:UnregisterEvent(event);
	end
end

function nPlatesComboPointsMixin:UpdatePower()
    self:Update(self:GetParent().unit)
end

function nPlatesComboPointsMixin:UnitMaxPower()
    self.maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    self:UpdateSize()
end

function nPlatesComboPointsMixin:Update(unit)
    if ( not unit or not self or not self.Points ) then
		return
	end

    if ( not Settings.GetValue("NPLATES_COMBO_POINTS") or not self:ShouldShowComboPoints(unit) ) then
		self:Hide()
		return
	end

    local chargedPowerPoints = GetUnitChargedPowerPoints("player")
	local currentPoints = GetComboPoints("player", "target") or 0

    for index, power in ipairs(self.Points) do
        local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, index) or false

        if index <= self.maxPoints then
            power.Point:SetShown(index <= currentPoints)
            power:Show()

            if ( isCharged ) then
                power.Point:SetAtlas("uf-roguecp-icon-blue", true)
                power.Overlay:SetAtlas("uf-roguecp-bg-anima", true)
                power.Overlay:SetBlendMode("BLEND")
                power.Overlay:Show()
            else
                power.Point:SetAtlas("uf-roguecp-icon-red", true)
                power.Overlay:Hide()
            end
        else
            power:Hide()
        end
    end

    self:Show()
end

function nPlatesComboPointsMixin:UpdateSize()
	local totalWidth = (self.maxPoints * self.indicatorSize) + ((self.maxPoints) * self.spacing)
	self:SetWidth(totalWidth)
end

function nPlatesComboPointsMixin:ShouldShowComboPoints(unit)
    if ( not UnitIsUnit(unit, "target") or not UnitCanAttack("player", unit) ) then
        return false
    end

    return UnitPowerType("player") == Enum.PowerType.Energy or self:VehicleHasComboPoints()
end

function nPlatesComboPointsMixin:UpdateVisibility()
    local shouldShow = self:ShouldShowComboPoints(self:GetParent().unit)
    self:SetShown(shouldShow)
end

function nPlatesComboPointsMixin:Toggle(value)
    local shouldHide = self:IsShown() and value == false
    if shouldHide then self:Hide() else self:UpdateVisibility() end
end

function nPlatesComboPointsMixin:VehicleHasComboPoints()
    return UnitHasVehicleUI("player") and PlayerVehicleHasComboPoints()
end

function nPlates:CreateComboPointsElement(nameplate)
	local frame = CreateFrame("Frame", "$parentComboPoints", nameplate, "nPlatesComboPoints")
	frame:SetHeight(20)

	frame.spacing = 2
	frame.indicatorSize = 20
	frame.comboPoints = GetComboPoints("player", "target")
	frame.maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)

	for i = 1, 9 do
		local container = CreateFrame("Frame", "$parentContainer"..i, frame, "nPlatesComboPower")

		if ( i == 1 ) then
			container:SetPoint("LEFT", frame, "LEFT", 0, 0)
		else
			container:SetPoint("LEFT", frame.Points[i - 1], "RIGHT", frame.spacing, 0)
		end
	end

    frame:UpdateSize()

	return frame
end

