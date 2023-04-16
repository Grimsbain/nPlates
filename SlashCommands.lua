local _, nPlates = ...

local function ShowConfig()
    if ( SettingsPanel:IsShown() ) then
        HideUIPanel(SettingsPanel)
		HideUIPanel(GameMenuFrame)
    else
        Settings.OpenToCategory(nPlatesOptions.name)
    end
end

local function nPlatesSlash(msg)
    if ( msg == "config") then
        ShowConfig()
    elseif ( msg == "reset" ) then
        for _, setting in pairs({
            "nameplateGlobalScale",
            "nameplateMinAlpha",
            "nameplateMinScale",
            "nameplateMaxScale",
            "nameplateOccludedAlphaMult",
            "nameplateOtherTopInset",
            "nameplateOtherBottomInset",
            "nameplateShowEnemies",
        })
        do
            C_CVar.SetCVar(setting, GetCVarDefault(setting))
        end

        nPlatesDB.SmallStacking = false
        nPlatesDB.CombatPlates = false
        nPlatesDB.DontClamp = false
        ReloadUI()
    else
        print("|cffCC3333n|rPlates Options\nConfig - Open ingame gui options.\nReset: Reset all cvar options to Blizzard defaults. "..REQUIRES_RELOAD)
    end
end

RegisterNewSlashCommand(nPlatesSlash, "nplates", "np2")