local _, nPlates = ...
local oUF = nPlates.oUF

nPlates.Media = {
    -- Status Bar
    StatusBarTexture = [[Interface\AddOns\nPlates\Media\UI-StatusBar]],
    StatusBarColor = CreateColor(1, 0.7, 0),

    -- Border
    BorderColor = CreateColor(1.0, 1.0, 1.0),
    DefaultBorderColor = CreateColor(0.4, 0.4, 0.4),
    ImportantCastColor = CreateColor(1, 0, 0.5),
    FocusColor = CreateColor(1.0, 0.49, 0.039),
    SelectionColor = CreateColor(1.0, 1.0, 1.0),

    -- Castbar
    InteruptibleColor = CreateColor(0.75, 0.0, 0.0),

    -- Health
    HealthColor = CreateColor(1, 0, 0),
    ThreatColor = CreateColor(1, 0, 0),
    OffTankColor =  CreateColor(174/255, 0.0, 1.0),
}

nPlates.MobColors = {
    Boss = CreateColor(1, 215/255, 0),
    MiniBoss = CreateColor(188/255, 198/255, 204/255),
    Caster = C_ClassColor.GetClassColor("MAGE"),
    Melee = C_ClassColor.GetClassColor("WARRIOR"),
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

-- local function UseOffTankColor(unit)
--     if ( not PlayerUtil.IsPlayerEffectivelyTank() ) then
--         return false
--     end

--     return IsInRaid() and UnitGroupRolesAssignedEnum(unit.."target") == Enum.LFGRole.Tank
-- end

    -- Color

local function ConvertRGBtoColorString(color)
	local colorString = "|cff";
	local r = color.r * 255;
	local g = color.g * 255;
	local b = color.b * 255;
	colorString = colorString..string.format("%2x%2x%2x", r, g, b);
	return colorString;
end

nPlates.DifficultyColor = function(unit)
    if ( not unit ) then
        return ConvertRGBtoColorString(WHITE_FONT_COLOR)
    end

    local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
    local color = (difficulty and GetDifficultyColor(difficulty)) or WHITE_FONT_COLOR
    return ConvertRGBtoColorString(color)
end

-- Aura Functions

nPlates.PostCreateButton = function(element, button, options)
    button.Cooldown:SetHideCountdownNumbers(false)
    button.Cooldown:SetDrawEdge(true)
    button.Cooldown:SetDrawSwipe(false)
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")
    button.Cooldown:SetUseAuraDisplayTime(true)

    button.Background = button:CreateTexture("$parentBackground", "BACKGROUND")
    button.Background:SetAllPoints(button)
    button.Background:SetColorTexture(0, 0, 0)

    button.Count:SetFontObject("nPlate_CountFont")
    button.Count:ClearAllPoints()
    button.Count:SetPoint("CENTER", button.Icon, "TOPLEFT", 1, 1)
    button.Count:SetJustifyH("RIGHT")

    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("CENTER")
    button.Icon:SetSize(18, 12)
    button.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
end

local threatColors = {
    [1] = {r = 1, g = 0, b = 0 },
    [2] = {r = 1, g = 0.6, b = 0 },
    [3] = {r = 0, g = 1, b = 0 },
}

nPlates.GetThreatColor = function(self)
    local r, g, b
    local threatStatus = UnitThreatSituation("player", self.__unit)
    local threatColor = threatColors[threatStatus]

    if ( threatStatus and threatColor ) then
        r, g, b = threatColor.r, threatColor.g, threatColor.b
    -- elseif ( self.useOffTankColor and UseOffTankColor(self.__unit) ) then
    --     r, g, b = nPlates.Media.OffTankColor:GetRGB()
    else
        r, g, b = 1, 0, 0
    end

    nPlates.Media.ThreatColor:SetRGB(r, g, b)

    return nPlates.Media.ThreatColor
end

-- oUF Functions

function nPlates:UpdateAllNameplates()
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.__unit ) then
            obj:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateNameplatesWithFunction(func, ...)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.__unit ) then
            if func then
                func(obj, obj.unit, ...)
            end
        end
    end
end

function nPlates:UpdateElement(name)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj:IsShown() and obj.__unit ) then
            local element = obj[name]
            if element and element.ForceUpdate then
                element:ForceUpdate()
            end
        end
    end
end

function nPlates:ToggleElement(name, nameplate, shouldShow)
    local element = nameplate[name]
    if element then
        if shouldShow then
            nameplate:EnableElement(name)
        else
            nameplate:DisableElement(name)
        end

        if element.ForceUpdate then
        element:ForceUpdate()
        end
    end
end
