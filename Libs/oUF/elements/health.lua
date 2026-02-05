--[[
# Element: Health Bar

Handles the updating of a status bar that displays the unit's health.

## Widget

Health - A `StatusBar` used to represent the unit's health.

## Examples

    -- Position and size
    local Health = CreateFrame('StatusBar', nil, self)
    Health:SetHeight(20)
    Health:SetPoint('TOP')
    Health:SetPoint('LEFT')
    Health:SetPoint('RIGHT')

    -- Register it with oUF
    self.Health = Health

    self.Health = Health
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	--[[ Callback: Health:PreUpdate(unit)
	Called before the element has been updated.

	* self - the Health element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	element:SetMinMaxValues(0, max)
    element:SetValue(cur)

	element.cur = cur
	element.max = max

	--[[ Callback: Health:PostUpdate(unit, cur, max, lossPerc)
	Called after the element has been updated.

	* self     - the Health element
	* unit     - the unit for which the update has been triggered (string)
	* cur      - the unit's current health value (number)
	* max      - the unit's maximum possible health value (number)
	* lossPerc - the percent by which the unit's max health has been temporarily reduced (number)
	--]]
	if(element.PostUpdate) then
		element:PostUpdate(unit, cur, max, lossPerc)
	end
end

local function Path(self, ...)
	--[[ Override: Health.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	do
		(self.Health.Override or Update) (self, ...)
	end
end

local function ForceUpdate(element)
	Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Health
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Health
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
	end
end

oUF:AddElement('Health', Path, Enable, Disable)
