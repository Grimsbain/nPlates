local _, ns = ...
local oUF = ns.oUF

function oUF:DisableBlizzardNamePlate(frame)
	if ( not frame or frame:IsForbidden() ) then return end

    frame:UnregisterAllEvents()
    frame:Hide()
end
