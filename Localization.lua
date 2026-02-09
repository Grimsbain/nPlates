local addon, nPlates = ...

local L = {}
nPlates.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

L.AddonTitle = C_AddOns.GetAddOnMetadata(addon, "Title")

------------------------------------------------------------------------
-- English
------------------------------------------------------------------------
L.CompartmentTooltip = "Shows configuration options for nPlates nameplates."
L.SlashCommand = "|cffCC3333n|rPlates Options\nconfig - Shows configuration options.\nreset - Reset all cvar options to Blizzard defaults. |cffCC3333"..REQUIRES_RELOAD

-- Name Options
L.NameOptionsLabel = "Name Options"
L.ShowLevel = "Display Unit Level"
L.ShowLevelToolitp = "Displays the unit's level next to its name. Always hidden on player nameplates."
L.AlwaysShowName = "Always Show Names"
L.AlwaysShowNameTooltip = "Always display unit names, ignoring automatic visibility rules."
L.PlayerThreatLevel = "Player Threat Level"
L.PlayerThreatLevelTooltip = "Colors the name of enemy players depending on their relative level to the player."
-- Castbar Options
L.CastbarOptions = "Castbar Options"
L.CastTarget = "Show Cast Target"
L.CastTargetTooltip = "Shows the name of the spells current target."
-- Coloring Options
L.ColoringOptionsLabel = "Coloring Options"
L.ColorHealthBy = "Color Health By"
L.ColorHealthByTooltip = "Colors the health bar. Options are default coloring, by threat, or by mob type."
L.ColorBorderBy  = "Color Border By"
L.ColorBorderByTooltip = "Colors the border. Options are default coloring, by threat, or by mob type."
L.Default = "Default"
L.ThreatColoring = "Threat Coloring"
L.MobType = "Mob Type"
L.OffTankColor = "Off Tank Color"
L.OffTankColorTooltip = "Color shown if another tank is being targeted."
L.SelectionColor = "Target Selection Color"
L.SelectionColorTooltip = "Displays a custom selection border."
-- Buff Options
L.BuffOptions = "Buff Options"
L.ShowBuffs = "Show Buffs"
L.ShowBuffsTooltip = "Display important buffs to the left of the nameplate."
-- Aura Options
L.DebuffOptions = "Debuff Options"
L.CrowdControl = "Show Crowd Control Icon"
L.CrowdControlTooltip = "Displays icon for crowd control spells to the right of the health bar."
L.CooldownNumbers = "Show Cooldown Numbers"
L.CooldownNumbersTooltip = "Shows or hides cooldown text."
L.CooldownEdge = "Show Cooldown Edge"
L.CooldownEdgeTooltip = "Shows or hides the edge animation."
L.CooldownSwipe = "Show Cooldown Swipe"
L.CooldownSwipeTooltip = "Shows or hides the cooldown swipe animation."
L.AuraScale = "Debuff Scale"
L.AuraScaleTooltip = "Adjusts the size of debuff icons."
-- Frame Options
L.FrameOptionsLabel = "Frame Options"
L.ClassResource = "Show Class Resource"
L.ClassResourceTooltip = "Displays your class resource above the nameplate. Currently supports combo points, chi, and essence. More coming in the future."
L.ShowQuest = "Show Quest Marker"
L.ShowQuestTooltip = "Displays a quest marker next to the nameplate of quest mobs."
L.OnlyName = "Hide Friendly Nameplates"
L.OnlyNameToolitp = "Friendly player nameplates display names only. Not available in raids or dungeons."
L.HealthOptions = "Health Options"
L.HealthOptionsTooltip = "Adjusts how health is displayed on the nameplate."
L.HealthBoth = "Health - Percent"
L.PercentHealth = "Precent - Health"
L.HealthDisabled = "Disabled"
L.HealthPercOnly = "Percent Only"
L.HealthValueOnly = "Health Only"
L.NameplateOccludedAlpha = "Behind Object Alpha"
L.NameplateOccludedAlphaTooltip = "Adjusts the transparency of nameplates that are behind other objects."
-- Nameplate Distance
L.NameplateDistance = "Nameplate Distance"
L.NpcRange = "NPC Range"
L.NpcRangeTooltip = "Adjusts the distance at which NPC nameplates are shown."
L.PlayerRange = "Player Range"
L.PlayerRangeTooltip = "Adjusts the distance at which player nameplates are shown."

local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE == "enUS" then return end

-- German

if CURRENT_LOCALE == "deDE" then

return end

-- Spanish

if CURRENT_LOCALE == "esES" then

return end

-- Latin American Spanish

if CURRENT_LOCALE == "esMX" then

return end

-- French

if CURRENT_LOCALE == "frFR" then

return end

-- Italian

if CURRENT_LOCALE == "itIT" then

return end

-- Brazilian Portuguese

if CURRENT_LOCALE == "ptBR" then

return end

-- Russian

if CURRENT_LOCALE == "ruRU" then

return end

-- Korean

if CURRENT_LOCALE == "koKR" then

return end

-- Simplified Chinese

if CURRENT_LOCALE == "zhCN" then

return end

-- Traditional Chinese

if CURRENT_LOCALE == "zhTW" then

return end
