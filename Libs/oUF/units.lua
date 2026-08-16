local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitExists = Private.unitExists

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
	unit = object.__unit or unit
	if(unit == 'target') then
		object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements, true)
	elseif(unit == 'mouseover') then
		object:RegisterEvent('UPDATE_MOUSEOVER_UNIT', object.UpdateAllElements, true)
	elseif(unit == 'focus') then
		object:RegisterEvent('PLAYER_FOCUS_CHANGED', object.UpdateAllElements, true)
	end
end

local eventlessObjects = {}
local eventlessTimerObjects = {}
local onUpdates = {}

local function createOnUpdate(timer)
	if(not onUpdates[timer]) then
		local frame = CreateFrame('Frame')
		local objects = eventlessTimerObjects[timer]

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if(self.elapsed > timer) then
				for _, object in next, objects do
					if(object:IsVisible() and object.__unit and unitExists(object.__unit)) then
						object:UpdateAllElements('OnUpdate')
					end
				end

				self.elapsed = 0
			end
		end)

		onUpdates[timer] = frame
	end
end

function oUF:HandleEventlessUnit(object)
	eventlessObjects[object] = true

	-- It's impossible to set onUpdateFrequency before the frame is created, so
	-- by default all eventless frames are created with the 0.5s timer.
	-- To change it you'll need to call oUF:HandleEventlessUnit(frame) one more
	-- time from the layout code after oUF:Spawn(unit) returns the frame.
	local timer = object.onUpdateFrequency or 0.5

	-- Remove it, in case it's already registered with any timer
	for _, objects in next, eventlessTimerObjects do
		for i, obj in next, objects do
			if(obj == object) then
				table.remove(objects, i)
				break
			end
		end
	end

	if(not eventlessTimerObjects[timer]) then eventlessTimerObjects[timer] = {} end
	table.insert(eventlessTimerObjects[timer], object)

	createOnUpdate(timer)
end

--[[ Units: frame:IsEventless()
Returns whether the unit frame is considered eventless or not.
--]]
oUF:RegisterMetaFunction('IsEventless', function(self)
	return eventlessObjects[self]
end)
