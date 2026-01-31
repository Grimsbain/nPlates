local _, nPlates = ...
local L = nPlates.L

local function Percentage(percentage)
    local value = Round(percentage * 100)
	return _G.PERCENTAGE_STRING:format(value)
end

function nPlates:RegisterSettings()
    nPlatesDB = nPlatesDB or {}

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
            type = "Label",
            label = L.ColoringOptionsLabel,
        },
        {
            type = "CheckBox",
            name = "NPLATES_TANKMODE",
            variable = "ThreatColoring",
            label = L.TankMode,
            tooltip = L.TankModeTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateElement("Health")
            end,
        },
        {
            type = "Swatch",
            name = "NPLATES_OFF_TANK_COLOR",
            variable = "OffTankColor",
            default = Settings.Default.False,
            label = L.OffTankColor,
            varType = Settings.VarType.Boolean,
            color = "ff7328ff",
            indent = true,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    nPlates:UpdateElement("Health")
                end)
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
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    nPlates:SetSelectionColor(plate)
                end)
            end,
        },
        {
            type = "Swatch",
            name = "NPLATES_FOCUS_COLOR",
            variable = "FocusColor",
            default = Settings.Default.False,
            label = "Focus Color",
            varType = Settings.VarType.Boolean,
            color = "FFFF7B00",
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    nPlates:UpdateElement("Health")
                end)
            end,
        },
        {
            type = "Label",
            label = L.BuffOptions,
        },
        {
            type = "CheckBox",
            name = "NPLATES_SHOW_BUFFS",
            variable = "ShowBuffs",
            label = L.ShowBuffs,
            tooltip = L.ShowBuffsTooltip,
            default = Settings.Default.True,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate:UpdateBuffs()
                end)
            end,
        },
        {
            type = "Label",
            label = L.DebuffOptions,
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
                nPlates:UpdateElement("Debuffs")
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
            callback = function(...)
                nPlates:UpdateElement("Debuffs")
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
                nPlates:UpdateElement("Debuffs")
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
            format = Percentage,
            min = 0.85,
            max = 1.5,
            step = 0.05,
            callback = function(setting, value)
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.Debuffs:SetScale(value)
                end)
            end,
        },
        {
            type = "Label",
            label = L.FrameOptionsLabel,
        },
        {
            type = "CheckBox",
            name = "NPLATES_COMBO_POINTS",
            variable = "ShowComboPoints",
            label = L.ComboPoints,
            tooltip = L.ComboPointsTooltip,
            default = Settings.Default.False,
            varType = Settings.VarType.Boolean,
            callback = function(...)
                local _, value = ...
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    plate.ComboPoints:Toggle(value)
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
                nPlates:UpdateNameplatesWithFunction(function(plate, unitToken)
                    nPlates:UpdateElement("Health")
                end)
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
            format = Percentage,
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

    }

    for index, control in ipairs(options) do
        if control.type == "Label" then
            layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(control.label))
        elseif control.type == "CheckBox" then
            local setting = Settings.RegisterAddOnSetting(category, control.name, control.variable, nPlatesDB, control.varType, control.label, control.default)
            setting:SetValueChangedCallback(control.callback)
            Settings.CreateCheckbox(category, setting, control.tooltip)
        elseif control.type == "Dropdown" then
            local setting = Settings.RegisterAddOnSetting(category, control.name, control.variable, nPlatesDB, control.varType, control.label, control.default)
            setting:SetValueChangedCallback(control.callback)
            Settings.CreateDropdown(category, setting, control.options, control.tooltip)
        elseif control.type == "Slider" then
            local options = Settings.CreateSliderOptions(control.min, control.max, control.step)
            options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, control.format)
            local setting = Settings.RegisterAddOnSetting(category, control.name, control.variable, nPlatesDB, control.varType, control.label, control.default)
            setting:SetValueChangedCallback(control.callback)
            Settings.CreateSlider(category, setting, options, control.tooltip)
        elseif control.type == "Swatch" then
            local hex = Settings.RegisterAddOnSetting(category, control.name.."_HEX", control.variable.."Hex", nPlatesDB, Settings.VarType.String, nil, control.color)
            hex:SetValueChangedCallback(function(s, value)
                nPlates.Media[control.variable] = CreateColorFromHexString(value)
                if control.callback then
                    control.callback(s, value)
                end
            end)

            local setting = Settings.RegisterAddOnSetting(category, control.name, control.variable, nPlatesDB, control.varType, control.label, control.default)
            setting:SetValueChangedCallback(control.callback)

            local function GetColor()
                local healthColorString = Settings.GetValue(control.name.."_HEX")
                local color = CreateColorFromHexString(healthColorString)
                return color or COMPACT_UNIT_FRAME_FRIENDLY_HEALTH_COLOR
            end

            local function OpenColorPicker(swatch, button, isDown)
                local info = {}
                info.swatch = swatch

                local healthColor = GetColor()
                info.r, info.g, info.b = healthColor:GetRGB()

                local currentColor = CreateColor(0, 0, 0, 0)
                info.swatchFunc = function()
                    local r,g,b = ColorPickerFrame:GetColorRGB()
                    currentColor:SetRGB(r, g, b)
                    hex:SetValue(currentColor:GenerateHexColor())
                end

                info.cancelFunc = function()
                    local r,g,b = ColorPickerFrame:GetPreviousValues()
                    currentColor:SetRGB(r, g, b)
                    hex:SetValue(currentColor:GenerateHexColor())
                end

                ColorPickerFrame:SetupColorPickerAndShow(info)
            end

            local clickRequiresSet = true
            local invertClickRequiresSet = false
            local initializer = CreateSettingsCheckboxWithColorSwatchInitializer(
                setting,
                OpenColorPicker,
                clickRequiresSet,
                invertClickRequiresSet,
                control.label,
                GetColor
            )

            if control.indent then
                initializer:Indent()
            end

            layout:AddInitializer(initializer)
        end
    end

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
    GameTooltip:AddLine(L.AddonTitle, 1, 1, 1)
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
