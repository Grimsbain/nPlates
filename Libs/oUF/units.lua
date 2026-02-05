local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitExists = Private.unitExists

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
	unit = object.unit or unit
end

local eventlessObjects = {}
local onUpdates = {}

local function createOnUpdate(timer)
	if(not onUpdates[timer]) then
		local frame = CreateFrame('Frame')
		local objects = eventlessObjects[timer]

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if(self.elapsed > timer) then
				for _, object in next, objects do
					if(object:IsVisible() and object.unit and unitExists(object.unit)) then
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
	object.__eventless = true

	-- It's impossible to set onUpdateFrequency before the frame is created, so
	-- by default all eventless frames are created with the 0.5s timer.
	-- To change it you'll need to call oUF:HandleEventlessUnit(frame) one more
	-- time from the layout code after oUF:Spawn(unit) returns the frame.
	local timer = object.onUpdateFrequency or 0.5

	-- Remove it, in case it's already registered with any timer
	for _, objects in next, eventlessObjects do
		for i, obj in next, objects do
			if(obj == object) then
				table.remove(objects, i)
				break
			end
		end
	end

	if(not eventlessObjects[timer]) then eventlessObjects[timer] = {} end
	table.insert(eventlessObjects[timer], object)

	createOnUpdate(timer)
end
