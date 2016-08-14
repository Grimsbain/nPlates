local ADDON, nPlates = ...

local L = {}
nPlates.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

------------------------------------------------------------------------
-- English
------------------------------------------------------------------------

L.TankMode = "Tank Mode"
L.NameThreat = "Color Name By Threat"
L.HealthOptions = "Health Options"
L.EnableHealth = "Enable Health Text"
L.ShowWhenFull = "Show When Full"
L.ShowCurHP = "Show Current Value"
L.ShowPercHP = "Show Percent"
L.DisplayLevel = "Display Level"
L.AbbrevName = "Abbreviate Long Names"
L.LargeNames = "Use Large Names"
L.HideFriendly = "Hide Friendly Nameplates"
L.ClassColors = "Display Class Colors"
L.StickyNameplates = "Sticky Nameplates"
L.TotemIcons = "Display Totem Icon"
L.NameplateScale = "Nameplate Scale"
L.NameplateAlpha = "Nameplate Min Alpha"

local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE == "enUS" then return end

------------------------------------------------------------------------
-- German
------------------------------------------------------------------------

if CURRENT_LOCALE == "deDE" then

return end

------------------------------------------------------------------------
-- Spanish
------------------------------------------------------------------------

if CURRENT_LOCALE == "esES" then

return end

------------------------------------------------------------------------
-- Latin American Spanish
------------------------------------------------------------------------

if CURRENT_LOCALE == "esMX" then

return end

------------------------------------------------------------------------
-- French
------------------------------------------------------------------------

if CURRENT_LOCALE == "frFR" then

return end

------------------------------------------------------------------------
-- Italian
------------------------------------------------------------------------

if CURRENT_LOCALE == "itIT" then

return end

------------------------------------------------------------------------
-- Brazilian Portuguese
------------------------------------------------------------------------

if CURRENT_LOCALE == "ptBR" then

return end

------------------------------------------------------------------------
-- Russian
------------------------------------------------------------------------

if CURRENT_LOCALE == "ruRU" then

return end

------------------------------------------------------------------------
-- Korean
------------------------------------------------------------------------

if CURRENT_LOCALE == "koKR" then

return end

------------------------------------------------------------------------
-- Simplified Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhCN" then

return end

------------------------------------------------------------------------
-- Traditional Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhTW" then

return end
