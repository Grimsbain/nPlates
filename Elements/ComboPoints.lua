local _, nPlates = ...
local oUF = nPlates.oUF

nPlatesComboPointsMixin = {}

function nPlatesComboPointsMixin:OnLoad()
    self.PowerEvents = {
        "UNIT_POWER_FREQUENT",
        "UNIT_MAXPOWER",
    }
end

function nPlatesComboPointsMixin:OnEvent(event, ...)
    if ( event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" ) then
        self:UpdatePower()
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UpdatePower()
    elseif ( event == "UNIT_MAXPOWER" or "TRAIT_CONFIG_UPDATED" ) then
        self:UnitMaxPower()
    end
end

function nPlatesComboPointsMixin:OnShow()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    FrameUtil.RegisterFrameForUnitEvents(self, self.PowerEvents, "player")
    self:Update(self:GetParent().__unit)
end

function nPlatesComboPointsMixin:OnHide()
	for i, event in ipairs(self.PowerEvents) do
		self:UnregisterEvent(event)
	end
end

function nPlatesComboPointsMixin:UpdatePower()
    self:Update(self:GetParent().__unit)
end

function nPlatesComboPointsMixin:UnitMaxPower()
    self.maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    self:UpdateSize()
end

function nPlatesComboPointsMixin:Update(unit)
    if ( not unit or not self or not self.Points ) then
		return
	end

    if ( not Settings.GetValue("NPLATES_SHOW_RESOURCE") or not self:ShouldShowComboPoints(unit) ) then
		self:Hide()
		return
	end

    local chargedPowerPoints = GetUnitChargedPowerPoints("player")
    local currentPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)

    for index, power in ipairs(self.Points) do
        local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, index) or false

        if index <= maxPoints then
            power.Point:SetShown(index <= currentPoints)
            power:Show()

            if ( isCharged ) then
                power.Point:SetAtlas("uf-roguecp-icon-blue", true)
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
	local totalWidth = (self.maxPoints * self.indicatorSize) + (self.maxPoints * self.spacing)
	self:SetWidth(totalWidth)
end

function nPlatesComboPointsMixin:ShouldShowComboPoints(unit)
    if ( UnitHasVehicleUI("player") or PlayerVehicleHasComboPoints() ) then
        return false
    end

    if ( not unit or not self:GetParent():IsTarget() or self:GetParent():IsFriend() ) then
        return false
    end

    return UnitPowerType("player") == Enum.PowerType.Energy
end

function nPlatesComboPointsMixin:UpdateVisibility()
    local shouldShow = self:ShouldShowComboPoints(self:GetParent().__unit)
    self:SetShown(shouldShow)
end

function nPlatesComboPointsMixin:Toggle(value)
    local shouldHide = self:IsShown() and value == false
    if shouldHide then self:Hide() else self:UpdateVisibility() end
end

local function Path(self, ...)
    local element = self.ComboPoints
    if ( element ) then
        element:Update(self.__unit)
    end
end

local function Enable(self)
    local element = self.ComboPoints

    if ( element ) then
        element.__owner = self

        element:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
        element:RegisterEvent("TRAIT_CONFIG_UPDATED")
        element:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

        element.comboPoints = GetComboPoints("player", "target")
	    element.maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
        element:UpdateSize()

        element:Show()
    end
end

local function Disable(self)
    local element = self.ComboPoints
    if ( element ) then
        element:UnregisterEvent("UNIT_DISPLAYPOWER")
        element:UnregisterEvent("TRAIT_CONFIG_UPDATED")
        element:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        element:Hide()
    end
end

oUF:AddElement("ComboPoints", Path, Enable, Disable)
