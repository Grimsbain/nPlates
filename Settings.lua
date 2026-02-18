local _, nPlates = ...
local L = nPlates.L
local SimpleUI = nPlates.SimpleUI

local function Percentage(percentage)
    local value = Round(percentage * 100)
	return _G.PERCENTAGE_STRING:format(value)
end

function nPlates:RegisterSettings()
    nPlatesDB = nPlatesDB or {}
    SimpleUI.DB = nPlatesDB

    local category, layout = Settings.RegisterVerticalLayoutCategory(L.AddonTitle)
    Settings.RegisterAddOnCategory(category)
    nPlates.categoryID = category.ID

    local options = {
        {
            type = "Label",
            label = L.NameOptionsLabel,
        },
        {
            type = "CheckBox",
            name = "NPLATES_SHOWLEVEL",
            variable = "ShowLevel",
            label = L.ShowLevel,
            tooltip = L.ShowLevelToolitp,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:UpdateName()
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_FORCE_NAME",
            variable = "AlwaysShowName",
            label = L.AlwaysShowName,
            tooltip = L.AlwaysShowNameTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:UpdateName()
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_PLAYER_THREAT",
            variable = "PlayerThreat",
            label = L.PlayerThreatLevel,
            tooltip = L.PlayerThreatLevelTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:UpdateName()
                end)
            end,
        },
        {
            type = "Label",
            label = L.CastbarOptions,
        },
        {
            type = "CheckBox",
            name = "NPLATES_CAST_TARGET",
            variable = "CastTarget",
            label = L.CastTarget,
            tooltip = L.CastTargetTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateElement("Castbar")
            end,
        },
        {
            type = "Label",
            label = L.ColoringOptionsLabel,
        },
        {
            type = "Dropdown",
            name = "NPLATES_HEALTH_COLOR",
            variable = "HealthColor",
            label = L.ColorHealthBy,
            tooltip = L.ColorHealthByTooltip,
            default = "default",
            varType = Settings.VarType.String,
            options = function()
                local container = Settings.CreateControlTextContainer()
                container:Add("default", L.Default)
                container:Add("threat", L.ThreatColoring)
                container:Add("mobType", L.MobType)
                container:Add("mobTypeOrThreat", L.MobTypeOrHealth)
                return container:GetData()
            end,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.healthStyle = value
                    plate.Health:ForceUpdate()
                end)
            end,
        },
        {
            type = "Dropdown",
            name = "NPLATES_BORDER_COLOR",
            variable = "BorderColor",
            label = L.ColorBorderBy,
            tooltip = L.ColorBorderByTooltip,
            default = "default",
            varType = Settings.VarType.String,
            options = function()
                local container = Settings.CreateControlTextContainer()
                container:Add("default", L.Default)
                container:Add("threat", L.ThreatColoring)
                container:Add("mobType", L.MobType)
                container:Add("mobTypeOrThreat", L.MobTypeOrHealth)
                return container:GetData()
            end,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.borderStyle = value
                    plate:SetSelectionColor()
                end)
            end,
        },
        {
            type = "Swatch",
            name = "NPLATES_OFF_TANK_COLOR",
            variable = "OffTankColor",
            default = Settings.Default.False,
            label = L.OffTankColor,
            tooltip = L.OffTankColorTooltip,
            varType = Settings.VarType.Boolean,
            color = "ff7328ff",
            callback = function(setting, value)
                nPlates:UpdateElement("Health")
            end,
            hexCallback = function(setting, value)
                nPlates.Media.OffTankColor = CreateColorFromHexString(value)
                nPlates:UpdateElement("Health")
            end,
        },
        {
            type = "Swatch",
            name = "NPLATES_SELECTION_COLOR",
            variable = "SelectionColor",
            label = L.SelectionColor,
            tooltip = L.SelectionColorTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            color = "ffffffff",
            callback = function(control, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.useSelectionColor = value
                    plate:SetSelectionColor()
                end)
            end,
            hexCallback = function(setting, value)
                nPlates.Media.SelectionColor = CreateColorFromHexString(value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:SetSelectionColor()
                end)
            end,
        },
        {
            type = "Swatch",
            name = "NPLATES_FOCUS_COLOR",
            variable = "FocusColor",
            default = Settings.Default.False,
            label = L.FocusColor,
            tooltip = L.FocusColorTooltip,
            varType = Settings.VarType.Boolean,
            color = "FFFF7B00",
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.useFocusColor = value
                    plate:SetSelectionColor()
                end)
            end,
            hexCallback = function(setting, value)
                nPlates.Media.FocusColor = CreateColorFromHexString(value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:SetSelectionColor()
                end)
            end,
        },
        {
            type = "Label",
            label = L.AuraOptions,
        },
        {
            type = "CheckBox",
            name = "NPLATES_SHOW_BUFFS",
            variable = "ShowBuffs",
            label = L.ShowBuffs,
            tooltip = L.ShowBuffsTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(control, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.showBuffs = value
                    nPlates:ToggleElement("BetterBuffs", plate, value)
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_CROWD_CONTROL",
            variable = "ShowCrowdControl",
            label = L.CrowdControl,
            tooltip = L.CrowdControlTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(control, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.showCrowdControl = value
                    nPlates:ToggleElement("CCIcon", plate, value)
                end)
            end,
        },
        {
            type = "Dropdown",
            name = "NPLATES_SORT_BY",
            variable = "SortBy",
            label = L.SortBy,
            tooltip = L.SortByTooltip,
            default = Enum.UnitAuraSortRule.Default,
            varType = Settings.VarType.Number,
            options = function()
                local container = Settings.CreateControlTextContainer()
                container:Add(Enum.UnitAuraSortRule.Default, L.Default)
                container:Add(Enum.UnitAuraSortRule.NameOnly, L.Name)
                container:Add(Enum.UnitAuraSortRule.ExpirationOnly, L.Time)
                return container:GetData()
            end,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.BetterDebuffs.sortRule = value
                    plate.BetterDebuffs:ForceUpdate()
                end)
            end,
        },
        {
            type = "Dropdown",
            name = "NPLATES_SORT_DIRECTION",
            variable = "SortDirection",
            label = L.SortDirection,
            tooltip = L.SortDirectionTooltip,
            default = Enum.UnitAuraSortDirection.Normal,
            varType = Settings.VarType.Number,
            options = function()
                local container = Settings.CreateControlTextContainer()
                container:Add(Enum.UnitAuraSortDirection.Normal, L.Default)
                container:Add(Enum.UnitAuraSortDirection.Reverse, L.Reverse)
                return container:GetData()
            end,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.BetterDebuffs.sortDirection = value
                    plate.BetterDebuffs:ForceUpdate()
                end)
            end,
        },
        {
            type = "Slider",
            name = "NPLATES_AURA_SCALE",
            variable = "AuraScale",
            label = L.AuraScale,
            tooltip = L.AuraScaleTooltip,
            default = 1,
            varType = Settings.VarType.Number,
            percentage = true,
            min = 0.85,
            max = 1.5,
            step = 0.05,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.BetterDebuffs:SetScale(value)
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_DEBUFF_TYPE",
            variable = "ShowDebuffType",
            label = L.ShowDebuffType,
            tooltip = L.ShowDebuffTypeTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.BetterDebuffs.showType = value
                    plate.BetterDebuffs:ForceUpdate()
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_COOLDOWN",
            variable = "ShowCooldownNumbers",
            label = L.CooldownNumbers,
            tooltip = L.CooldownNumbersTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateAllNameplates()
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_COOLDOWN_EDGE",
            variable = "ShowCooldowndownEdge",
            label = L.CooldownEdge,
            tooltip = L.CooldownEdgeTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(control, value)
                nPlates:UpdateAllNameplates()
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_COOLDOWN_SWIPE",
            variable = "ShowCooldownSwipe",
            label = L.CooldownSwipe,
            tooltip = L.CooldownSwipeTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateAllNameplates()
            end,
        },
        {
            type = "Label",
            label = L.FrameOptionsLabel,
        },
        {
            type = "CheckBox",
            name = "NPLATES_SHOW_RESOURCE",
            variable = "ShowResource",
            label = L.ClassResource,
            tooltip = L.ClassResourceTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                local _, value = ...
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    if plate.ComboPoints then plate.ComboPoints:Toggle(value) end
                    if plate.Chi then plate.Chi:Toggle(value) end
                    if plate.Essence then plate.Essence:Toggle(value) end
                end)
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_SHOWQUEST",
            variable = "ShowQuest",
            label = L.ShowQuest,
            tooltip = L.ShowQuestTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateElement("QuestIndicator")
            end,
        },
        {
            type = "CheckBox",
            name = "NPLATES_ONLYNAME",
            variable = "OnlyName",
            label = L.OnlyName,
            tooltip = L.OnlyNameToolitp,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:UpdateNameLocation()
                end)

                SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", value and 1 or 0)
            end,
        },
        {
            type = "Dropdown",
            name = "NPLATES_HEALTH_STYLE",
            variable = "HealthStyle",
            label = L.HealthOptions,
            tooltip = L.HealthOptionsTooltip,
            default = "cur",
            varType = Settings.VarType.String,
            options = function()
                local container = Settings.CreateControlTextContainer()
                container:Add("disabled", L.HealthDisabled)
                container:Add("cur", L.HealthValueOnly)
                container:Add("perc", L.HealthPercOnly)
                container:Add("cur_perc", L.HealthBoth)
                container:Add("perc_cur", L.PercentHealth)
                return container:GetData()
            end,
            callback = function(setting, value)
                nPlates:UpdateElement("Health")
            end,
        },
        {
            type = "Slider",
            name = "NPLATES_ALPHA",
            variable = "nameplateOccludedAlphaMult",
            label = L.NameplateOccludedAlpha,
            tooltip = L.NameplateOccludedAlphaTooltip,
            default = 0.4,
            varType = Settings.VarType.Number,
            percentage = true,
            min = 0,
            max = 1,
            step = 0.01,
            callback = function(setting, value)
                if ( nPlates:IsTaintable() ) then
                    return
                end

                SetCVar("nameplateOccludedAlphaMult", value)
            end,
        },
        {
            type = "Label",
            label = L.NameplateDistance,
        },
        {
            type = "Slider",
            name = "NPLATES_DISTANCE_NPC",
            variable = "nameplateMaxDistance",
            label = L.NpcRange,
            tooltip = L.NpcRangeTooltip,
            default = 60,
            varType = Settings.VarType.Number,
            min = 20,
            max = 60,
            step = 1,
            callback = function(setting, value)
                if ( nPlates:IsTaintable() ) then
                    return
                end

                SetCVar("nameplateMaxDistance", value)
            end,
        },
        {
            type = "Slider",
            name = "NPLATES_DISTANCE_PLAYER",
            variable = "nameplatePlayerMaxDistance",
            label = L.PlayerRange,
            tooltip = L.PlayerRangeTooltip,
            default = 60,
            varType = Settings.VarType.Number,
            min = 20,
            max = 60,
            step = 1,
            callback = function(setting, value)
                if ( nPlates:IsTaintable() ) then
                    return
                end

                SetCVar("nameplatePlayerMaxDistance", value)
            end,
        },
        {
            type = "Label",
            label = MISCELLANEOUS,
        },
        {
            type = "Slider",
            name = "NPLATES_SIMPLE_SCALE",
            variable = "nameplateSimplifiedScale",
            label = L.SimplifiedScale,
            tooltip = L.SimplifiedScaleTooltip,
            varType = Settings.VarType.Number,
            min = .15,
            max = 1,
            step = 0.01,
            default = 0.30,
            percentage = true,
            callback = function(control, value)
                if ( nPlates:IsTaintable() ) then
                    return
                end

                SetCVar("nameplateSimplifiedScale", value)
            end,
        },
    }

    SimpleUI:ProcessSettings(category, layout, options)

    -- Register cvar callbacks so settings are updated if the cvar is changed outside of the addon.

    CVarCallbackRegistry:RegisterCallback("nameplateOccludedAlphaMult", function(arg1, value)
        Settings.SetValue("NPLATES_ALPHA", tonumber(value))
    end)

    CVarCallbackRegistry:RegisterCallback("nameplateMaxDistance", function(arg1, value)
        Settings.SetValue("NPLATES_DISTANCE_NPC", tonumber(value))
    end)

    CVarCallbackRegistry:RegisterCallback("nameplatePlayerMaxDistance", function(arg1, value)
        Settings.SetValue("NPLATES_DISTANCE_PLAYER", tonumber(value))
    end)

    CVarCallbackRegistry:RegisterCallback("nameplateSimplifiedScale", function(arg1, value)
        Settings.SetValue("NPLATES_SIMPLE_SCALE", tonumber(value))
    end)
end

-- Addon Comparment and Slash Command code.

local function ToggleSettings()
    if ( SettingsPanel:IsShown() ) then
        HideUIPanel(SettingsPanel)
		HideUIPanel(GameMenuFrame)
    else
        Settings.OpenToCategory(nPlates.categoryID)
    end
end

nPlates_OnAddonCompartmentClick = ToggleSettings
nPlates_OnAddonCompartmentOnLeave = function() GameTooltip:Hide() end
nPlates_OnAddonCompartmentOnEnter = function(name, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:AddLine(name, 1, 1, 1)
    GameTooltip:AddLine(L.CompartmentTooltip)
    GameTooltip:Show()
end

local function nPlatesSlash(msg)
    if ( msg == "config") then
        ToggleSettings()
    elseif ( msg == "reset" ) then
        nPlates:RestoreCVars()
        ReloadUI()
    else
        print(L.SlashCommand)
    end
end

RegisterNewSlashCommand(nPlatesSlash, "nplates", "np3")
