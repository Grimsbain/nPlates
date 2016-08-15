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
L.DisplayServerName = "Display Server Name"
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

L.AbbrevName = "Lange Namen abkürzen"
L.ClassColors = "Klassenfarben anzeigen"
L.DisplayLevel = "Stufe anzeigen"
L.EnableHealth = "Gesundheitstext aktivieren"
L.HealthOptions = "Gesundheitsoptionen"
L.HideFriendly = "Freundliche Namensplaketten ausblenden"
L.NameplateScale = "Namensplakettenskalierung"
L.NameThreat = "Name nach Bedrohung färben"
L.ShowCurHP = "Momentanen Wert anzeigen"
L.ShowPercHP = "Prozent anzeigen"
L.ShowWhenFull = "Anzeigen, wenn voll"
L.TankMode = "Tankmodus"
L.TotemIcons = "Totemsymbol anzeigen"

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

L.AbbrevName = "縮短長名稱"
L.ClassColors = "顯示職業顏色"
L.DisplayLevel = "顯示等級"
L.DisplayServerName = "顯示伺服器名稱"
L.EnableHealth = "啟用血量文字"
L.HealthOptions = "血量選項"
L.HideFriendly = "隱藏友方血條"
L.LargeNames = "使用大名稱文字"
L.NameplateAlpha = "血條最小透明度"
L.NameplateScale = "血條縮放"
L.NameThreat = "名稱依據威脅著色"
L.ShowCurHP = "顯示當前數值"
L.ShowPercHP = "顯示百分比"
L.ShowWhenFull = "當血滿時顯示"
L.StickyNameplates = "黏附血條"
L.TankMode = "坦克模式"
L.TotemIcons = "顯示圖騰圖示"

return end
