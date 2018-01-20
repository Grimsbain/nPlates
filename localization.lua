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

L.AbbrevName = "Abbreviate Long Names"
L.DisplayLevel = "Display Level"
L.DisplayServerName = "Display Server Name"
L.EnableHealth = "Enable Health Text"
L.EnemyClassColors = "Display Enemy Class Colors"
L.ExecuteRange = "Show Execute Color"
L.FelExplosivesColor = "Fel Explosive Color"
L.FrameOptionsLabel = "Frame Options"
L.FriendlyClassColors = "Display Friendly Class Colors"
L.HealthOptions = "Health Options"
L.HideFriendly = "Hide Friendly Nameplates"
L.NameOptionsLabel = "Name Options"
L.NameplateAlpha = "Nameplate Min Alpha"
L.NameplateScale = "Nameplate Scale"
L.NameplateRange = "Nameplate Range"
L.NameSizeLabel = "Name Size"
L.NameThreat = "Color Name By Threat"
L.OffTankColor = "Off Tank Color"
L.ShowCurHP = "Show Current Value"
L.ShowPercHP = "Show Percent"
L.ShowPvP = "Show PvP Icon"
L.ShowWhenFull = "Show When Full"
L.SmallStacking = "Small Stacking Nameplates"
L.SmallStackingTooltip = "Only used if the stacking nameplates motion type is enabled."
L.StickyNameplates = "Sticky Nameplates"
L.TankMode = "Tank Mode"
L.TankOptionsLabel = "Tank Options"

local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE == "enUS" then return end

------------------------------------------------------------------------
-- German
------------------------------------------------------------------------

if CURRENT_LOCALE == "deDE" then

L.AbbrevName = "Lange Namen abkürzen"
L.DisplayLevel = "Stufe anzeigen"
L.DisplayServerName = "Realmname anzeigen"
L.EnableHealth = "Gesundheitstext aktivieren"
L.EnemyClassColors = "Gegner nach Klasse färben"
L.ExecuteRange = "Einfärben wenn Hinrichten nutzbar"
L.FrameOptionsLabel = "Plakettenoptionen"
L.FriendlyClassColors = "Verbündete nach Klasse färben"
L.HealthOptions = "Gesundheitsoptionen"
L.HideFriendly = "Freundliche Namensplaketten ausblenden"
L.NameOptionsLabel = "Namensoptionen"
L.NameplateAlpha = "Namensplakettendurchsichtigkeit"
L.NameplateRange = "Namensplakettenreichweite"
L.NameplateScale = "Namensplakettenskalierung"
L.NameSizeLabel = "Namensgröße"
L.NameThreat = "Name nach Bedrohung färben"
L.OffTankColor = "Off-Tank Farbe"
L.ShowCurHP = "Momentanen Wert anzeigen"
L.ShowPercHP = "Prozent anzeigen"
L.ShowPvP = "PvP-Symbol anzeigen"
L.ShowWhenFull = "Anzeigen, wenn voll"
L.StickyNameplates = "Beharrliche Namensplaketten"
L.TankMode = "Tankmodus"
L.TankOptionsLabel = "Tankoptionen"

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

L.AbbrevName = "Сокращать длинные имена"
L.DisplayLevel = "Дисплей Уровень"
L.DisplayServerName = "Имя сервера"
L.EnableHealth = "Включить текст здоровья."
L.ExecuteRange = "Цвет дистанции"
L.FrameOptionsLabel = "Варианты структуры этикетки"
L.HealthOptions = "Опции для здоровья"
L.HideFriendly = "Скрыть дружественных"
L.NameOptionsLabel = "Параметры имени"
L.NameplateAlpha = "Минимальная прозрачнось"
L.NameplateRange = "Серия Боя"
L.NameplateScale = "Масштаб"
L.NameSizeLabel = "Масштаб имени"
L.NameThreat = "Цвет имени для здоровья"
L.OffTankColor = "Отключить цвет танка"
L.ShowCurHP = "Показать текущее значение"
L.ShowPercHP = "Показать процент"
L.ShowWhenFull = "Показать когда здоровье полноя"
L.TankMode = "Режим танка"
L.TankOptionsLabel = "Варианты танка этикетки"

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

L.AbbrevName = "简化过长名字"
L.DisplayLevel = "显示等级"
L.DisplayServerName = "显示服务器"
L.EnableHealth = "显示生命值"
L.EnemyClassColors = "敌方职业染色"
L.ExecuteRange = "斩杀阶段染色"
L.FrameOptionsLabel = "框体选项"
L.FriendlyClassColors = "友方职业染色"
L.HealthOptions = "血量选项"
L.HideFriendly = "隐藏友方血条"
L.NameOptionsLabel = "名字选项"
L.NameplateAlpha = "最小透明度"
L.NameplateRange = "显示距离"
L.NameplateScale = "框体缩放"
L.NameSizeLabel = "名字大小"
L.NameThreat = "名字仇恨染色"
L.OffTankColor = "副坦颜色"
L.ShowCurHP = "显示当前数值"
L.ShowPercHP = "显示百分比"
L.ShowPvP = "显示 PvP 图标"
L.ShowWhenFull = "满血时显示"
L.StickyNameplates = "保持在屏幕內"
L.TankMode = "坦克模式"
L.TankOptionsLabel = "坦克选项"

return end

------------------------------------------------------------------------
-- Traditional Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhTW" then

L.AbbrevName = "縮短過長名稱"
L.DisplayLevel = "顯示等級"
L.DisplayServerName = "顯示伺服器名稱"
L.EnableHealth = "顯示生命值"
L.EnemyClassColors = "敵方職業著色"
L.ExecuteRange = "顯示斬殺顏色"
L.FrameOptionsLabel = "框架選項"
L.FriendlyClassColors = "友方職業著色"
L.HealthOptions = "血量選項"
L.HideFriendly = "隱藏友方血條"
L.NameOptionsLabel = "名稱選項"
L.NameplateAlpha = "名條最小透明度"
L.NameplateRange = "名條顯示距離"
L.NameplateScale = "名條縮放"
L.NameSizeLabel = "名稱大小"
L.NameThreat = "名稱依據威脅著色"
L.OffTankColor = "副坦顏色"
L.ShowCurHP = "顯示當前數值"
L.ShowPercHP = "顯示百分比"
L.ShowPvP = "顯示 PvP 圖示"
L.ShowWhenFull = "滿血時顯示"
L.StickyNameplates = "使名條保持在畫面內"
L.TankMode = "坦克模式"
L.TankOptionsLabel = "坦克選項"

return end
