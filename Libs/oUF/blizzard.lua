local _, ns = ...
local oUF = ns.oUF

local hookedNameplates = {}

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local reparentedKeys = {
    "HealthBarsContainer",
    "castBar",
    "RaidTargetFrame",
    "ClassificationFrame",
    "PlayerLevelDiffFrame",
    "SoftTargetFrame",
    "name",
    "aggroHighlight",
    "aggroHighlightBase",
    "aggroHighlightAdditive",
}

function oUF:DisableBlizzardNamePlate(frame)
	if(not(frame and frame.UnitFrame)) then return end
	if(frame.UnitFrame:IsForbidden()) then return end

	if(not hookedNameplates[frame]) then
		-- BUG: the hit rect (for clicking) is tied to the original UnitFrame object on the
		--      nameplate, so we can't hide it. instead we force it to be invisible, and adjust
		--      the hit rect insets around it so it matches the nameplate object itself, but we
		--      do that in SpawnNamePlates instead
		-- TODO: remove this hack once we can adjust hitrects ourselves, coming in a later build
        frame.UnitFrame:SetAlpha(0)

        frame.UnitFrame.AurasFrame.DebuffListFrame:SetParent(hiddenParent)
        frame.UnitFrame.AurasFrame.BuffListFrame:SetParent(hiddenParent)
        frame.UnitFrame.AurasFrame.CrowdControlListFrame:SetParent(hiddenParent)
        frame.UnitFrame.AurasFrame.LossOfControlFrame:SetParent(hiddenParent)
        for _, key in ipairs(reparentedKeys) do
          frame.UnitFrame[key]:SetParent(hiddenParent)
        end

        frame.UnitFrame:UnregisterAllEvents()
        if frame.UnitFrame.castBar then
            frame.UnitFrame.castBar:UnregisterAllEvents()
        end

        if frame.UnitFrame.healthBar then
            frame.UnitFrame.healthBar:UnregisterAllEvents()
        end

		local locked = false
		hooksecurefunc(frame.UnitFrame, 'SetAlpha', function(UnitFrame)
			if(locked or UnitFrame:IsForbidden()) then return end
			locked = true
			UnitFrame:SetAlpha(0)
			locked = false
		end)

		hookedNameplates[frame] = true
	end
end
