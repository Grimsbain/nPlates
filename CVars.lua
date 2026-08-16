local _, nPlates = ...
local L = nPlates.L

local cVars = {
    "nameplateOccludedAlphaMult",
    "nameplateMaxDistance",
    "nameplatePlayerMaxDistance",
    "nameplateSimplifiedScale",
    "nameplateShowOnlyNameForFriendlyPlayerUnits",
}

local WatcherMixin = {}

function WatcherMixin:OnLoad()
    self.defered = {}
    self.isDeferring = false

    self:SetScript("OnEvent", self.OnEvent)
end

function WatcherMixin:OnEvent(event, ...)
    if ( event == "PLAYER_REGEN_ENABLED" ) then
        self.isDeferring = false

        for cvar, value in pairs(self.defered) do
            SetCVar(cvar, value)
        end

        wipe(self.defered)

        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
    end

function WatcherMixin:AddDeferedCVar(cvar, value)
    self.defered[cvar] = value
    self:RegisterDefer()
end

function WatcherMixin:RegisterDefer()
    if ( not self.isDeferring ) then
        self.isDeferring = true
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
end

local watcher = CreateFrame("Frame")
Mixin(watcher, WatcherMixin)
watcher:OnLoad()

function nPlates:UpdateCVar(cvar, value)
    if ( self:IsTaintable() ) then
        watcher:AddDeferedCVar(cvar, value)
        return
    end

    SetCVar(cvar, value)
end

function nPlates:RestoreCVars()
    if ( nPlates:IsTaintable() ) then
        print(L.CVarUpdate)
        return
    end

    for _, cvar in ipairs(cVars) do
        local default = GetCVarDefault(cvar)
        if default ~= nil then
            SetCVar(cvar, default)
        end
    end
end

function nPlates:CVarCheck()
    if ( self:IsTaintable() ) then
        print(L.CVarUpdate)
        end

    local settings = {
        ["nameplateOccludedAlphaMult"] = Settings.GetValue("NPLATES_ALPHA"),
        ["nameplateMaxDistance"] = Settings.GetValue("NPLATES_DISTANCE_NPC"),
        ["nameplatePlayerMaxDistance"] = Settings.GetValue("NPLATES_DISTANCE_PLAYER"),
        ["nameplateSimplifiedScale"] = Settings.GetValue("NPLATES_SIMPLE_SCALE"),
        ["nameplateShowOnlyNameForFriendlyPlayerUnits"] = Settings.GetValue("NPLATES_ONLYNAME"),
    }

    for cvar, value in pairs(settings) do
        if value ~= nil then
            SetCVar(cvar, value)
    end
end
end