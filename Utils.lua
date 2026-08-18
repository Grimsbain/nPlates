local _, nPlates = ...
local oUF = nPlates.oUF

nPlates.Colors = {
    DefaultBorderColor = CreateColor(0.4, 0.4, 0.4),
    ImportantCastColor = CreateColor(1, 0, 0.5),
    FocusColor = CreateColor(1.0, 0.49, 0.039),
    SelectionColor = CreateColor(1.0, 1.0, 1.0),
}

nPlates.MobColors = {
    Boss = CreateColor(1, 215/255, 0),
    MiniBoss = CreateColor(188/255, 198/255, 204/255),
    Other = BATTLENET_FONT_COLOR,
    Trivial = RED_THREAT_COLOR,
}

function nPlates:IsTaintable()
    return (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet")))
end

    -- Threat Functions

function nPlates.IsOnThreatListWithPlayer(unit)
    local threatStatus = UnitThreatSituation("player", unit)
    return threatStatus ~= nil
end

local threatColors = {
    [1] = {r = 1, g = 0, b = 0 },
    [2] = {r = 1, g = 0.6, b = 0 },
    [3] = {r = 0, g = 1, b = 0 },
}

nPlates.GetThreatColor = function(unit)
    local r, g, b
    local threatStatus = UnitThreatSituation("player", unit)
    local threatColor = threatColors[threatStatus]

    if ( threatStatus and threatColor ) then
        r, g, b = threatColor.r, threatColor.g, threatColor.b
    else
        r, g, b = 1, 0, 0
    end

    return r, g, b
end

    -- Color Functions

local function ConvertRGBtoColorString(color)
	local colorString = "|cff"
	local r = color.r * 255
	local g = color.g * 255
	local b = color.b * 255
	colorString = colorString..string.format("%2x%2x%2x", r, g, b)
	return colorString
end

nPlates.DifficultyColor = function(unit)
    if ( not unit ) then
        return ConvertRGBtoColorString(WHITE_FONT_COLOR)
    end

    local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
    local color = (difficulty and GetDifficultyColor(difficulty)) or WHITE_FONT_COLOR
    return ConvertRGBtoColorString(color)
end

-- oUF Functions

local function IsNameplate(frame)
    return frame and frame.isNamePlate and frame.__unit
end

function nPlates:UpdateAllNameplates()
    for _, frame in ipairs(oUF.objects) do
        if ( IsNameplate(frame) ) then
            frame:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateNameplatesWithFunction(func, ...)
    for _, frame in ipairs(oUF.objects) do
        if ( IsNameplate(frame) ) then
            if ( func ) then
                func(frame, frame.unit, ...)
            end
        end
    end
end

function nPlates:UpdateElement(name)
    for _, frame in ipairs(oUF.objects) do
        if ( IsNameplate(frame) ) then
            local element = frame[name]
            if ( element and element.ForceUpdate ) then
                element:ForceUpdate()
            end
        end
    end
end
