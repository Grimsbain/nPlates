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
    Trivial = CreateColor(0.4, 0.4, 0.4),
}

    -- Threat Functions

function nPlates.IsOnThreatListWithPlayer(unit)
    local threatStatus = UnitThreatSituation("player", unit)
    return threatStatus ~= nil
end

local function UseOffTankColor(unit)
    if ( not PlayerUtil.IsPlayerEffectivelyTank() ) then
        return false
    end

    return IsInRaid() and UnitGroupRolesAssignedEnum(unit.."target") == Enum.LFGRole.Tank
end

    -- Color

nPlates.DifficultyColor = function(unit)
    local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
    local color = GetDifficultyColor(difficulty)
    return ConvertRGBtoColorString(color)
end

-- Aura Functions

nPlates.PostCreateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")
    button.Cooldown:SetUseAuraDisplayTime(true)

    button.Background = button:CreateTexture("$parentBackground", "BACKGROUND")
    button.Background:SetAllPoints(button)
    button.Background:SetColorTexture(0, 0, 0)

    if button.Overlay then
        button.Overlay:ClearAllPoints()
        button.Overlay:SetAllPoints(button.Background)
        button.Overlay:SetTexture([[Interface\AddOns\nPlates\Media\borderTexture]])
    end

    button.Count:SetFontObject("nPlate_CountFont")
    button.Count:ClearAllPoints()
    button.Count:SetPoint("CENTER", button.Icon, "TOPLEFT", 1, 1)
    button.Count:SetJustifyH("RIGHT")

    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("CENTER")
    button.Icon:SetSize(18, 12)
    button.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
end

nPlates.PostUpdateButton = function(element, button, unit, data, position)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
end

local threatColors = {
    [0] = CreateColor(1, 0, 0),
    [1] = CreateColor(1, 0, 0),
    [2] = CreateColor(1, 0.6, 0),
    [3] = CreateColor(0, 1, 0),
}

nPlates.GetThreatColor = function(self)
    local r, g, b

    local threatStatus = UnitThreatSituation("player", self.unit)
    if ( threatStatus ) then
        local color = threatColors[threatStatus] or RED_FONT_COLOR
        r, g, b = color:GetRGB()
    elseif ( self.useOffTankColor and UseOffTankColor(self.unit) ) then
        r, g, b = nPlates.Media.OffTankColor:GetRGB()
    else
        r, g, b = 1, 0, 0
    end

    nPlates.Media.ThreatColor:SetRGB(r, g, b)

    return nPlates.Media.ThreatColor
end

-- oUF Functions

function nPlates:UpdateAllNameplates()
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            obj:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateNameplatesWithFunction(func, ...)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            if func then
                func(obj, obj.unit, ...)
            end
        end
    end
end

function nPlates:UpdateElement(name)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj:IsShown() and obj.unit ) then
            local element = obj[name]
            if element and element.ForceUpdate then
                element:ForceUpdate()
            end
        end
    end
end

function nPlates:ToggleElement(name, nameplate, shouldShow)
    local element = nameplate[name]
    if element and element.ForceUpdate then
        if shouldShow then
            nameplate:EnableElement("BetterBuffs")
        else
            nameplate:DisableElement("BetterBuffs")
        end

        element:ForceUpdate()
    end
end
