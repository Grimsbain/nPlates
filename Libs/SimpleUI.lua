local _, ns = ...
ns.SimpleUI = {}

local SimpleUI = ns.SimpleUI

local function Percentage(percentage)
    local value = Round(percentage * 100)
	return _G.PERCENTAGE_STRING:format(value)
end

function SimpleUI:CreateLabel(layout, data)
    assert(type(data) == "table", "SimpleUI:CreateLabel(layout, data). Data needs to be a table.");

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(data.label))
end

function SimpleUI:CreateCheckbox(category, data)
    assert(type(data) == "table", "SimpleUI:CreateCheckbox(category, data). Data needs to be a table.");

    local setting = Settings.RegisterAddOnSetting(category, data.name, data.variable, SimpleUI.DB, data.varType, data.label, data.default)
    if (data.callback) then setting:SetValueChangedCallback(data.callback) end
    Settings.CreateCheckbox(category, setting, data.tooltip)
end

function SimpleUI:CreateCheckBoxWithDropdown(category, layout, data)
    assert(type(data) == "table", "SimpleUI:CreateCheckBoxWithDropdown(category, layout, data). Data needs to be a table.");

    local cbData = data.checkbox;
    local ddData = data.dropdown;

    local ddSetting = Settings.RegisterAddOnSetting(category, ddData.name, ddData.variable, SimpleUI.DB, ddData.varType, ddData.label, ddData.default);
    if ddCallback then ddSetting:SetValueChangedCallback(ddCallback); end

	local setting = Settings.RegisterAddOnSetting(category, cbData.name, cbData.variable, SimpleUI.DB, cbData.varType, cbData.label, cbData.default);
    if callback then setting:SetValueChangedCallback(callback); end

    local initializer = CreateSettingsCheckboxDropdownInitializer(setting, cbData.label, cbData.tooltip, ddSetting, ddData.Options, ddData.label, ddData.tooltip);
    layout:AddInitializer(initializer);
end

function SimpleUI:CreateDropdown(category, data)
    assert(type(data) == "table", "SimpleUI:CreateDropdown(category, data). Data needs to be a table.");

    local setting = Settings.RegisterAddOnSetting(category, data.name, data.variable, SimpleUI.DB, data.varType, data.label, data.default)
    if (data.callback) then setting:SetValueChangedCallback(data.callback) end
    Settings.CreateDropdown(category, setting, data.options, data.tooltip)
end

function SimpleUI:CreateSlider(category, data)
    assert(type(data) == "table", "SimpleUI:CreateSlider(category, data). Data needs to be a table.");

    local options = Settings.CreateSliderOptions(data.min, data.max, data.step)

    if data.percentage then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, Percentage)
    else
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, data.format)
    end

    local setting = Settings.RegisterAddOnSetting(category, data.name, data.variable, SimpleUI.DB, data.varType, data.label, data.default)
    if (data.callback) then setting:SetValueChangedCallback(data.callback) end
    Settings.CreateSlider(category, setting, options, data.tooltip)
end

function SimpleUI:CreateColorSwatch(category, layout, data)
    assert(type(data) == "table", "SimpleUI:CreateColorSwatch(category, data). Data needs to be a table.");

    local hex = Settings.RegisterAddOnSetting(category, data.name.."_HEX", data.variable.."Hex", SimpleUI.DB, Settings.VarType.String, nil, data.color)
    if (data.hexCallback) then hex:SetValueChangedCallback(data.hexCallback) end

    local setting = Settings.RegisterAddOnSetting(category, data.name, data.variable, SimpleUI.DB, data.varType, data.label, data.default)
    if (data.callback) then setting:SetValueChangedCallback(data.callback) end

    local function GetColor()
        local healthColorString = Settings.GetValue(data.name.."_HEX")
        local color = CreateColorFromHexString(healthColorString)
        return color or WHITE_FONT_COLOR
    end

    local function OpenColorPicker(swatch, button, isDown)
        local info = {}
        info.swatch = swatch

        local color = GetColor()
        info.r, info.g, info.b = color:GetRGB()

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
        data.tooltip,
        OpenColorPicker,
        clickRequiresSet,
        invertClickRequiresSet,
        GetColor,
        data.label,
        data.swatchTooltip
    )

    if ( data.indent ) then
        initializer:Indent()
    end

    layout:AddInitializer(initializer)
end

function SimpleUI:ProcessSettings(category, layout, controls)
    for index, control in ipairs(controls) do
        if control.type == "Label" then
            SimpleUI:CreateLabel(layout, control)
        elseif control.type == "CheckBox" then
            SimpleUI:CreateCheckbox(category, control)
        elseif control.type == "CheckBoxWithDropdown" then
            SimpleUI:CreateCheckBoxWithDropdown(category, layout, control)
        elseif control.type == "Dropdown" then
            SimpleUI:CreateDropdown(category, control)
        elseif control.type == "Slider" then
            SimpleUI:CreateSlider(category, control)
        elseif control.type == "Swatch" then
            SimpleUI:CreateColorSwatch(category, layout, control)
        end
    end
end