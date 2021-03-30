local _, nPlates = ...

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
L.ColoringOptionsLabel = "Coloring Options"
L.CombatPlates = "Combat Plates"
L.CombatPlatesTooltip = "Auto hide enemy nameplates when out of combat.\n\n"..REQUIRES_RELOAD
L.DisplayLevel = "Display Level"
L.DisplayServerName = "Display Server Name"
L.EnemyClassColors = "Display Enemy Class Colors"
L.ExecuteRange = "Show Execute Color"
L.FelExplosivesColor = "Explosive Color"
L.FelExplosivesMobName = "Explosives"
L.FrameOptionsLabel = "Frame Options"
L.FriendlyClassColors = "Display Friendly Class Colors"
L.HealthOptions = "Health Options"
L.HealthBoth = "Health - Percent"
L.PercentHealth = "Precent - Health"
L.HealthDisabled = "Disabled"
L.HealthPercOnly = "Percent Only"
L.HealthValueOnly = "Health Only"
L.HideFriendly = "Hide Friendly Nameplates"
L.NameOptionsLabel = "Name Options"
L.NameplateAlpha = "Min Alpha"
L.NameplateScale = "Scale"
L.NameplateRange = "Range"
L.NameSizeLabel = "Size"
L.NameThreat = "Color Name By Threat"
L.OffTankColor = "Off Tank Color"
L.RaidMarkerColoring = "Raid Marker Coloring"
L.ShowPvP = "Show PvP Icon"
L.SmallStacking = "Small Stacking Nameplates"
L.SmallStackingTooltip = "Only used if the stacking nameplates motion type is enabled."
L.StickyNameplates = "Sticky Nameplates"
L.TankMode = "Tank Mode"
L.TankOptionsLabel = "Tank Options"
L.WhiteSelectionColor = "White Selection Color"

local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE == "enUS" then return end

------------------------------------------------------------------------
-- German
------------------------------------------------------------------------

if CURRENT_LOCALE == "deDE" then

L.AbbrevName = "Lange Namen abkürzen"
L.DisplayLevel = "Stufe anzeigen"
L.DisplayServerName = "Realmname anzeigen"
L.EnemyClassColors = "Gegner nach Klasse färben"
L.ExecuteRange = "Einfärben wenn Hinrichten nutzbar"
L.FrameOptionsLabel = "Plakettenoptionen"
L.FriendlyClassColors = "Verbündete nach Klasse färben"
L.HealthBoth = "Gesundheit - Prozent"
L.HealthDisabled = "Deaktiviert"
L.HealthPercOnly = "Nur Prozent"
L.HealthValueOnly = "Nur Gesundheit"
L.HideFriendly = "Freundliche Namensplaketten ausblenden"
L.NameOptionsLabel = "Namensoptionen"
L.NameplateAlpha = "Namensplakettendurchsichtigkeit"
L.NameplateRange = "Namensplakettenreichweite"
L.NameplateScale = "Namensplakettenskalierung"
L.NameSizeLabel = "Namensgröße"
L.NameThreat = "Name nach Bedrohung färben"
L.OffTankColor = "Off-Tank Farbe"
L.ShowPvP = "PvP-Symbol anzeigen"
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

L.AbbrevName = "Raccourcir les longs noms"
L.ColoringOptionsLabel = "Options des couleurs"
L.CombatPlates = "Barres d'info. en mode combat"
L.CombatPlatesTooltip = "Cacher automatiquement les barres d'info. en dehors du combat."
L.DisplayLevel = "Afficher le niveau"
L.DisplayServerName = "Afficher le nom du serveur"
L.EnemyClassColors = "Afficher la couleur des classes de la faction opposée"
L.ExecuteRange = "Changer la couleur en phase d'exécution"
L.FelExplosivesColor = "Changer la couleur lors d'explosion gangrenée (donjons mythiques)"
L.FelExplosivesMobName = "Explosifs gangrenés"
L.FrameOptionsLabel = "Options de la barre"
L.FriendlyClassColors = "Afficher la couleur des classes de la faction alliée"
L.HealthBoth = "Vie - Pourcentage"
L.HealthDisabled = "Désactivé"
L.HealthPercOnly = "Pourcentage seulement"
L.HealthValueOnly = "Points de vie seulement"
L.HideFriendly = "Cacher les barres d'info. alliées"
L.NameOptionsLabel = "Options des noms"
L.NameplateAlpha = "Transparence minimale"
L.NameplateRange = "Portée"
L.NameplateScale = "Echelle"
L.NameSizeLabel = "Taille du texte"
L.NameThreat = "Colorer les noms en fonction de la menace"
L.OffTankColor = "Couleur des off tanks (tanks alliés)"
L.RaidMarkerColoring = "Colorer en fonction des marqueurs de raid"
L.ShowPvP = "Afficher l'icône JcJ"
L.SmallStacking = "Empilement proche des barres d'info."
L.SmallStackingTooltip = "Seulement activée si vous avez choisi les barres d'info. empilées"
L.StickyNameplates = "Barres d'info. collantes"
L.TankMode = "Mode tank"
L.TankOptionsLabel = "Options de menace"
L.WhiteSelectionColor = "Couleur blanche pour la cible sélectionnée"

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

L.AbbrevName = "긴 이름 줄임"
L.ColoringOptionsLabel = "색상 옵션"
L.CombatPlates = "전투 시 이름표"
L.CombatPlatesTooltip = "전투에서 벗어난 경우 자동으로 적 이름표를 숨깁니다."
L.DisplayLevel = "레벨 표시"
L.DisplayServerName = "서버명 표시"
L.EnemyClassColors = "적 직업 색상 표시"
L.ExecuteRange = "사거리 색상 표시"
L.FelExplosivesColor = "지옥 폭발물 색상"
L.FelExplosivesMobName = "지옥 폭발물"
L.FrameOptionsLabel = "창 옵션"
L.FriendlyClassColors = "아군 직업 색상 표시"
L.HealthBoth = "생명력 - 백분율"
L.HealthDisabled = "표시 안 함"
L.HealthPercOnly = "백분율만"
L.HealthValueOnly = "생명력만"
L.HideFriendly = "아군 이름표 숨김"
L.NameOptionsLabel = "이름 옵션"
L.NameplateAlpha = "이름표 최소 투명도"
L.NameplateRange = "이름표 최대 거리"
L.NameplateScale = "이름표 크기 비율"
L.NameSizeLabel = "이름 길이"
L.NameThreat = "위협 수준별 이름 색칠"
L.OffTankColor = "오프탱 색상"
L.RaidMarkerColoring = "공격대 표시기 대상 색칠"
L.ShowPvP = "PvP 아이콘 표시"
L.SmallStacking = "작게 겹치는 이름표"
L.SmallStackingTooltip = "이름표 배열 방식이 이름표 겹침 허용인 경우에만 사용됩니다."
L.StickyNameplates = "대상 이름표 화면 안으로 고정"
L.TankMode = "방어 전담 모드"
L.TankOptionsLabel = "방어 전담 옵션"
L.WhiteSelectionColor = "선택된 대상 흰색 테두리"

return end

------------------------------------------------------------------------
-- Simplified Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhCN" then

L.AbbrevName = "简化过长名字"
L.ColoringOptionsLabel = "着色选项"
L.CombatPlates = "非战斗时隐藏"
L.CombatPlatesTooltip = "进入战斗时显示敌方姓名板，脱离战斗后自动隐藏。"
L.DisplayLevel = "显示等级"
L.DisplayServerName = "显示服务器"
L.EnemyClassColors = "敌方职业染色"
L.ExecuteRange = "斩杀阶段染色"
L.FelExplosivesColor = "易爆小球染色"
L.FelExplosivesMobName = "爆炸物"
L.FrameOptionsLabel = "框体选项"
L.FriendlyClassColors = "友方职业染色"
L.HealthBoth = "血量 - 百分比"
L.HealthDisabled = "无"
L.HealthPercOnly = "百分比"
L.HealthValueOnly = "血量"
L.HideFriendly = "隐藏友方姓名板"
L.NameOptionsLabel = "名字选项"
L.NameplateAlpha = "最小透明度"
L.NameplateRange = "显示距离"
L.NameplateScale = "框体缩放"
L.NameSizeLabel = "字体大小"
L.NameThreat = "名字按威胁值着色"
L.OffTankColor = "副坦颜色"
L.RaidMarkerColoring = "团队标记着色"
L.ShowPvP = "显示 PvP 图标"
L.SmallStacking = "紧凑堆叠姓名板"
L.SmallStackingTooltip = "使姓名板堆叠的间距缩小，只在姓名板排列类型为堆叠时生效。"
L.StickyNameplates = "保持在屏幕內"
L.TankMode = "坦克模式"
L.TankOptionsLabel = "坦克选项"
L.WhiteSelectionColor = "高亮当前目标"


return end

------------------------------------------------------------------------
-- Traditional Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhTW" then

L.AbbrevName = "縮短過長名稱"
L.ColoringOptionsLabel = "著色選項"
L.CombatPlates = "非戰鬥時隱藏"
L.CombatPlatesTooltip = "進入戰鬥時顯示敵方名條，脫離戰鬥後自動隱藏。"
L.DisplayLevel = "顯示等級"
L.DisplayServerName = "顯示伺服器名稱"
L.EnemyClassColors = "敵方職業著色"
L.ExecuteRange = "顯示斬殺顏色"
L.FelExplosivesColor = "魔化炸彈顏色"
L.FelExplosivesMobName = "炸藥"
L.FrameOptionsLabel = "框架選項"
L.FriendlyClassColors = "友方職業著色"
L.HealthBoth = "血量 - 百分比"
L.HealthDisabled = "無"
L.HealthPercOnly = "只有百分比"
L.HealthValueOnly = "只有血量"
L.HideFriendly = "隱藏友方血條"
L.NameOptionsLabel = "名稱選項"
L.NameplateAlpha = "名條最小透明度"
L.NameplateRange = "名條顯示距離"
L.NameplateScale = "名條縮放"
L.NameSizeLabel = "字型大小"
L.NameThreat = "名稱依據威脅值著色"
L.OffTankColor = "副坦顏色"
L.RaidMarkerColoring = "團隊標記著色"
L.ShowPvP = "顯示 PvP 圖示"
L.SmallStacking = "緊湊名條堆疊"
L.SmallStackingTooltip = "使名條堆疊的間距縮小，只在名條排列類型為堆疊時生效。"
L.StickyNameplates = "使名條保持在畫面內"
L.TankMode = "坦克模式"
L.TankOptionsLabel = "坦克選項"
L.WhiteSelectionColor = "高亮當前目標"


return end
