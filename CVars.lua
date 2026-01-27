local _, nPlates = ...

local events = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
}

local watcher = CreateFrame("Frame")
watcher:SetScript("OnEvent", function(self, event, ...)
    if ( event == "PLAYER_REGEN_ENABLED" ) then
        nPlates:CVarCheck()
        self:UnregisterAllEvents()
    end
end)

function nPlates:IsTaintable()
    return (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet")))
end

function nPlates:ResetCVars(...)
    for _, cvar in ipairs({...}) do
        SetCVar(cvar, GetCVarDefault(cvar))
    end
end

function nPlates:CVarCheck()
    if ( self:IsTaintable() ) then
        FrameUtil.RegisterFrameForEvents(watcher, events)
        return
    end

    SetCVar("nameplateOccludedAlphaMult", nPlates:GetSetting("NPLATES_ALPHA"))
    SetCVar("nameplateMaxDistance", nPlates:GetSetting("NPLATES_DISTANCE_NPC"))
    SetCVar("nameplatePlayerMaxDistance", nPlates:GetSetting("NPLATES_DISTANCE_PLAYER"))
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", nPlates:GetSetting("NPLATES_ONLYNAME") and 1 or 0)
end

function nPlates:RestoreCVars()
    for _, setting in pairs({
        "nameplateMaxDistance",
        "nameplatePlayerMaxDistance",
        "nameplateOccludedAlphaMult",
    })
    do
        local default = GetCVarDefault(setting)

        if ( default ) then
            SetCVar(setting, default)
        end
    end
end
