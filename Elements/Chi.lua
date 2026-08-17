local _, nPlates = ...
local oUF = nPlates.oUF

nPlatesChiMixin = {}

function nPlatesChiMixin:OnLoad()
    self.requiredClass = "MONK"
    self.requiredSpec = _G.SPEC_MONK_WINDWALKER

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
end

function nPlatesChiMixin:OnEvent(event, ...)
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

function nPlatesChiMixin:OnShow()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    FrameUtil.RegisterFrameForUnitEvents(self, self.PowerEvents, "player")
    self:Update(self:GetParent().__unit)
end

function nPlatesChiMixin:OnHide()
	for i, event in ipairs(self.PowerEvents) do
		self:UnregisterEvent(event)
	end
end

function nPlatesChiMixin:UpdatePower()
    self:Update(self:GetParent().__unit)
end

function nPlatesChiMixin:UnitMaxPower()
    self.maxPower = UnitPowerMax("player", Enum.PowerType.Chi)
    self:UpdateSize()
end

function nPlatesChiMixin:Update(unit)
    if ( not unit or not self or not self.Points ) then
		return
	end

    if ( not Settings.GetValue("NPLATES_SHOW_RESOURCE") or not self:ShouldShow(unit) ) then
		self:Hide()
		return
	end

	local currentPower = UnitPower("player", Enum.PowerType.Chi) or 0
    local maxPower = self.maxPower or UnitPowerMax("player", Enum.PowerType.Chi)

    for index, power in ipairs(self.Points) do
        if index <= maxPower then
            power.Point:SetShown(index <= currentPower)
            power.Background:SetAtlas("uf-chi-bg-active", true)
            power:Show()
        else
            power.Background:SetAtlas("uf-chi-bg", true)
            power:Hide()
        end
    end

    self:Show()
end

function nPlatesChiMixin:UpdateSize()
	local totalWidth = (self.maxPower * self.indicatorSize) + (self.maxPower * self.spacing)
	self:SetWidth(totalWidth)
end

function nPlatesChiMixin:ShouldShow(unit)
    if ( self.requiredSpec ~= C_SpecializationInfo.GetSpecialization() ) then
        return false
    end

    if ( not unit or not self:GetParent():IsTarget() or self:GetParent():IsFriend() ) then
        return false
    end

    return not UnitHasVehicleUI("player")
end

function nPlatesChiMixin:UpdateVisibility()
    local shouldShow = self:ShouldShow(self:GetParent().__unit)
    self:SetShown(shouldShow)
end

function nPlatesChiMixin:Toggle(value)
    local shouldHide = self:IsShown() and value == false
    if shouldHide then self:Hide() else self:UpdateVisibility() end
end

local function Path(self, ...)
    local element = self.Chi
    if ( element ) then
        element:Update(self.__unit)
    end
end

local function Enable(self)
    local element = self.Chi

    if ( element ) then
        element.__owner = self

        element:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
        element:RegisterEvent("TRAIT_CONFIG_UPDATED")
        element:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

        element.maxPower = UnitPowerMax("player", Enum.PowerType.Chi)
        element:UpdateSize()

        element:Show()
    end
end

local function Disable(self)
    local element = self.Chi
    if ( element ) then
        element:UnregisterEvent("UNIT_DISPLAYPOWER")
        element:UnregisterEvent("TRAIT_CONFIG_UPDATED")
        element:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        element:Hide()
    end
end

oUF:AddElement("Chi", Path, Enable, Disable)
