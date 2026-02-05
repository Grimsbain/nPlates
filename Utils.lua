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
    OffTankColor =  CreateColor(174/255, 0.0, 1.0),
}

-- Aura Functions

nPlates.PostCreateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")

    button.Overlay:ClearAllPoints()

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

nPlates.PostUpdateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
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
