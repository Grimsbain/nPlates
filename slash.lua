local addon, nPlates = ...

local function ShowConfig()
    if InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Hide()
    else
        InterfaceOptionsFrame_OpenToCategory(nPlatesOptions)
        InterfaceOptionsFrame_OpenToCategory(nPlatesOptions)
    end
end

SlashCmdList["nplates"] = function(msg)
    if ( msg == "config") then
        ShowConfig()
    elseif ( msg == "reset" ) then
        for _, v in pairs({
            "nameplateGlobalScale",
            "nameplateMinAlpha",
            "namePlateMinScale",
            "namePlateMaxScale",
            "nameplateMaxDistance",
            "nameplateOtherTopInset",
            "nameplateOtherBottomInset",
            "nameplateShowEnemies"
        })
        do
            SetCVar(v, GetCVarDefault(v))
        end
        nPlatesDB.SmallStacking = false
        nPlatesDB.CombatPlates = false
        nPlatesDB.DontClamp = false
        ReloadUI()
    else
        print("|cffCC3333n|rPlates Options\nConfig - Open ingame gui options.\nReset: Reset all cvar options to Blizzard defaults. "..REQUIRES_RELOAD)
    end
end
SLASH_nplates1 = "/nplates"
