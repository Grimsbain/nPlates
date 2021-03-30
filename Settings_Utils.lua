
local _, nPlates = ...
local L = nPlates.L

nPlatesCheckboxMixin = {}

function nPlatesCheckboxMixin:OnLoad()
end

function nPlatesCheckboxMixin:OnClick(button, down)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    local checked = self:GetChecked()
    self.value = checked
    self:SetOption(checked)
end

function nPlatesCheckboxMixin:Update()
    local currentValue = nPlatesDB[self.optionName]
    self:SetChecked(currentValue)
    self:SetOption()
end

function nPlatesCheckboxMixin:GetValue()
    return self:GetChecked()
end

function nPlatesCheckboxMixin:SetControl(checked)
    if ( checked ) then
        self:SetChecked(checked)
    else
        self:SetChecked(nPlatesDB[self.optionName])
    end
end

function nPlatesCheckboxMixin:SetOption()
    nPlatesDB[self.optionName] = self:GetChecked()

    if ( self.config.needsRestart ) then
        self.restart = not self.restart
    end

    local customFunc = self.config.func
    if ( customFunc ) then
        customFunc(self)
    end

    if ( self.config.updateAll ) then
        nPlates:UpdateAllNameplates()
    end
end

function nPlatesCheckboxMixin:OnEvent(event, ...)
    if ( event == "PLAYER_REGEN_ENABLED" ) then
        self:Enable()
    elseif ( event == "PLAYER_REGEN_DISABLED" ) then
        self:Disable()
    end
end

function nPlatesCheckboxMixin:OnEnter()
    if ( self.tooltipText ) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end

function nPlatesCheckboxMixin:OnLeave()
    if ( GameTooltip:GetOwner() == self ) then
        GameTooltip:Hide();
    end
end

function nPlatesCheckboxMixin:OnEnable()
    self.label:SetFontObject(GameFontHighlightLeft)
end

function nPlatesCheckboxMixin:OnDisable()
    self.label:SetFontObject(GameFontDisableLeft)
end

---------------------------------------------------------

nPlatesSliderMixin = {}

function nPlatesSliderMixin:OnLoad()
    BackdropTemplateMixin.OnBackdropLoaded(self)
end

function nPlatesSliderMixin:OnEvent(event, ...)
    if ( event == "PLAYER_REGEN_ENABLED" ) then
        self:Enable()
    elseif ( event == "PLAYER_REGEN_DISABLED" ) then
        self:Disable()
    end
end

function nPlatesSliderMixin:GetValue()
    return self.value
end

function nPlatesSliderMixin:SetControl()
    self:SetValue(self.value)
end

function nPlatesSliderMixin:SetText(value)
    if ( self.config.multiplier ) then
        self.Text:SetFormattedText(self.config.fromatString, floor(value * self.config.multiplier))
    else
        self.Text:SetFormattedText(self.config.fromatString, value)
    end
end

function nPlatesSliderMixin:GetCurrentValue()
    local value

    if ( self.config.isCvar ) then
        value = BlizzardOptionsPanel_GetCVarSafe(self.optionName)
    else
        value = nPlatesDB[self.optionName]
    end

    return value
end

function nPlatesSliderMixin:OnValueChanged(value)
    self.value = value
    self:SetText(value)

    if ( self.config.isCvar ) then
        BlizzardOptionsPanel_SetCVarSafe(self.optionName, value)
    else
        nPlatesDB[self.optionName] = value
    end

    local customFunc = self.config.func
    if ( customFunc ) then
        customFunc(self)
    end

    if ( self.config.needsRestart ) then
        self.restart = self.value ~= self.oldValue
    end

    if ( self.config.updateAll ) then
        nPlates:UpdateAllNameplates()
    end
end

function nPlatesSliderMixin:Update()
    local currentValue = self:GetCurrentValue()
    self:SetValue(currentValue)
    self:SetText(currentValue)
end

    -- Sorts a table by key.

local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        tinsert(a, n)
    end
    sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local function RegisterControl(parent, control)
    if ( not parent or not control ) then
        return
    end

    if ( not parent.controls ) then
        parent.controls = {}
    end

    parent.prevControl = control

    tinsert(parent.controls, control)
end

function nPlates:CreateLabel(config)
    --[[
        {
            type = "Label",
            name = "LabelName",
            parent = self,
            label = L.LabelText,
            fontObject = "GameFontNormalLarge",
            relativeTo = self.LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
    --]]

    local name = config.name
    local parent = config.parent
    local text = config.text
    local fontObject = config.fontObject or "GameFontNormalLarge"
    local initialPoint = config.initialPoint or "TOPLEFT"
    local relativeTo = config.relativeTo or parent.prevControl or parent
    local relativePoint = config.relativePoint or "BOTTOMLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or -16

    local label = parent:CreateFontString(name, "ARTWORK", fontObject)
    label:SetPoint(initialPoint, relativeTo, relativePoint, offsetX, offsetY)
    label:SetText(text)

    parent.prevControl = label
    return label
end

function nPlates:CreateCheckBox(config)
    --[[
        {
            type = "CheckBox",
            name = "Test",
            parent = parent,
            text = L.TestLabel,
            tooltipText = L.TestTooltip,
            isCvar = nil or True,
            optionName = "TestVar",
            needsRestart = nil or True,
            disableInCombat = nil or True,
            updateAll = nil or True,
            func = function(self)
                -- Do stuff here.
            end,
            colorPicker = {
                name = "ColorPicker",
                parent = Options,
                optionName = "TestVarColor",
            },
            initialPoint = "TOPLEFT",
            relativeTo = frame,
            relativePoint, "BOTTOMLEFT",
            offsetX = 0,
            offsetY = -6,
        },
    --]]

    local name = config.name
    local parent = config.parent
    local text = config.text
    local tooltipText = config.tooltipText
    local optionName = config.optionName
    local initialPoint = config.initialPoint or "TOPLEFT"
    local relativeTo = config.relativeTo or parent.prevControl
    local relativePoint = config.relativePoint or "BOTTOMLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or -6
    local disableInCombat = config.disableInCombat
    local needsRestart = config.needsRestart
    local colorPicker = config.colorPicker

    local checkBox = CreateFrame("CheckButton", name, parent, "nPlatesCheckButtonTemplate")
    checkBox:SetPoint(initialPoint, relativeTo, relativePoint, offsetX, offsetY)
    checkBox.label:SetText(text)
    checkBox.optionName = optionName
    checkBox.config = config

    if ( needsRestart ) then
        checkBox.restart = false
    end

    if ( tooltipText ) then
        checkBox.tooltipText = tooltipText
    end

    if ( disableInCombat ) then
        checkBox:RegisterEvent("PLAYER_REGEN_ENABLED")
        checkBox:RegisterEvent("PLAYER_REGEN_DISABLED")
    end

    if ( colorPicker ) then
        nPlates:CreateColorPicker(colorPicker, checkBox.label)
    end

    RegisterControl(parent, checkBox)
    return checkBox
end

function nPlates:CreateSlider(config)
        --[[
        {
            type = "Slider",
            name = "Test",
            parent = parent,
            label = L.TestLabel,
            isCvar = True,
            optionName = "DBVariableGoesHere",
            fromatString = "%.2f",
            minValue = 0,
            maxValue = 1,
            step = .10,
            needsRestart = True,
            disableInCombat = True,
            func = function(self)
                -- Do stuff here.
            end,
            OnUpdate = function(self)
                -- Do stuff here.
            end
            initialPoint = "TOPLEFT",
            relativeTo = frame,
            relativePoint, "BOTTOMLEFT",
            offsetX = 0,
            offsetY = -6,
        },
    --]]

    local name = config.name
    local parent = config.parent
    local optionName = config.optionName
    local initialPoint = config.initialPoint or "TOPLEFT"
    local relativeTo = config.relativeTo or parent.prevControl or parent
    local relativePoint = config.relativePoint or "BOTTOMLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or -26
    local minValue = config.minValue
    local maxValue = config.maxValue
    local step = config.step
    local label = config.label
    local onUpdate = config.OnUpdate
    local isCvar = config.isCvar
    local disableInCombat = config.disableInCombat

    local value

    if ( isCvar ) then
        value = BlizzardOptionsPanel_GetCVarSafe(optionName)
    else
        value = nPlatesDB[optionName]
    end

    local slider = CreateFrame("Slider", name, parent, "nPlatesSliderTemplate")
    slider:SetWidth(180)
    slider:SetPoint(initialPoint, relativeTo, relativePoint, offsetX, offsetY)
    slider.config = config
    slider.value = value
    slider.optionName = optionName
    slider.OnUpdate = config.OnUpdate

    slider:SetMinMaxValues(minValue, maxValue)
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
    slider:SetValue(value)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    slider:SetText(value)
    slider.Text:ClearAllPoints()
    slider.Text:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT")

    slider.Low:ClearAllPoints()
    slider.Low:SetPoint("BOTTOMLEFT", slider, "TOPLEFT")
    slider.Low:SetPoint("BOTTOMRIGHT", slider.Text, "BOTTOMLEFT", -4, 0)
    slider.Low:SetText(label)
    slider.Low:SetJustifyH("LEFT")
    slider.High:Hide()

    if ( disableInCombat ) then
        slider:RegisterEvent("PLAYER_REGEN_ENABLED")
        slider:RegisterEvent("PLAYER_REGEN_DISABLED")
    end

    if ( slider.OnUpdate ) then
        slider:SetScript("OnUpdate", slider.OnUpdate)
    end

    RegisterControl(parent, slider)
    return slider
end

function nPlates:showColorPicker(r, g, b, callback)
    ColorPickerFrame.previousValues = {r, g, b}
    ColorPickerFrame.func = callback
    ColorPickerFrame.opacityFunc = callback
    ColorPickerFrame.cancelFunc = callback
    ColorPickerFrame:SetColorRGB(r, g, b)
    ShowUIPanel(ColorPickerFrame)
end

function nPlates:CreateColorPicker(cfg, relativeTo)
    cfg.initialPoint = cfg.initialPoint or "LEFT"
    cfg.relativePoint = cfg.relativePoint or "RIGHT"
    cfg.offsetX = cfg.offsetX or 10
    cfg.offsetY = cfg.offsetY or 0

    local colorPicker = CreateFrame("Frame", cfg.name, cfg.parent)
    colorPicker:SetSize(15, 15)
    colorPicker:SetPoint(cfg.initialPoint, relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    colorPicker.bg = colorPicker:CreateTexture(nil, "BACKGROUND", nil, -7)
    colorPicker.bg:SetAllPoints(colorPicker)
    colorPicker.bg:SetColorTexture(1, 1, 1, 1)
    colorPicker.bg:SetVertexColor(nPlatesDB[cfg.optionName].r,nPlatesDB[cfg.optionName].g, nPlatesDB[cfg.optionName].b)
    colorPicker.recolor = function(color)
        local r, g, b
        if ( color ) then
            r, g, b = unpack(color)
        else
            r, g, b = ColorPickerFrame:GetColorRGB()
        end
        nPlatesDB[cfg.optionName].r = r
        nPlatesDB[cfg.optionName].g = g
        nPlatesDB[cfg.optionName].b = b
        colorPicker.bg:SetVertexColor(r, g, b)
        nPlates:UpdateAllNameplates()
    end
    colorPicker:EnableMouse(true)
    colorPicker:SetScript("OnMouseDown", function(self, button, ...)
        if ( not relativeTo:GetParent():GetChecked() ) then return end
        if button == "LeftButton" then
            local r, g, b = colorPicker.bg:GetVertexColor()
            nPlates:showColorPicker(r, g, b, colorPicker.recolor)
        end
    end)

    return colorPicker
end

function nPlates:CreateDropdown(cfg)
        --[[
        {
            type = "Dropdown",
            name = "TestDropdown",
            parent = Options,
            label = L.LocalizedName,
            optionName = "DBVariableGoesHere",
            needsRestart = true,
            func = function(self)
                -- Do stuff here. Only ran on click.
            end,
            optionsTable = {
                { text = L.TopLeft, value = 1, },
                { text = L.BottomLeft, value = 2, },
                { text = L.TopRight, value = 3, },
                { text = L.BottomRight, value = 4, },
            },
        },
    ]]

    local name = cfg.name
    local label = cfg.label
    local optionName = cfg.optionName
    local parent = cfg.parent
    local initialPoint = cfg.initialPoint or "TOPLEFT"
    local relativeTo = cfg.relativeTo or parent.prevControl
    local relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    local offsetX = cfg.offsetX or 0
    local offsetY = cfg.offsetY or -26
    local func = cfg.func
    local needsRestart = cfg.needsRestart
    local updateAll = cfg.updateAll
    local optionsTable = cfg.optionsTable

    local dropdown = L_Create_UIDropDownMenu(cfg.name, cfg.parent)
    dropdown:SetPoint(initialPoint, relativeTo, relativePoint, offsetX, offsetY)

    dropdown.Label = dropdown:CreateFontString("$parentLabel", "BACKGROUND", "OptionsFontSmall")
    dropdown.Label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 5)
    dropdown.Label:SetText(label)

    local function Dropdown_OnClick(self)
        L_UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        nPlatesDB[optionName] = self.value

        if ( func ) then
            func(dropdown)
        end

        if ( needsRestart ) then
            if self.value ~= dropdown.oldValue then
                dropdown.restart = true
            else
                dropdown.restart = false
            end
        end

        if ( updateAll ) then
            nPlates:UpdateAllNameplates()
        end
    end

    local function Initialize()
        local selectedValue = L_UIDropDownMenu_GetSelectedValue(dropdown)
        local info = L_UIDropDownMenu_CreateInfo()
        info.func = Dropdown_OnClick

        for value, text in pairs(optionsTable) do
            info.text = text
            info.value = value
            info.checked = value == selectedValue
            L_UIDropDownMenu_AddButton(info)
        end
    end

    dropdown:RegisterEvent("PLAYER_ENTERING_WORLD")
    dropdown:SetScript("OnEvent", function(self, event, ...)
        if ( event == "PLAYER_ENTERING_WORLD" ) then
            self.optionName = optionName
            self.value = nPlatesDB[optionName]
            self.oldValue = value

            L_UIDropDownMenu_SetWidth(self, 180)
            L_UIDropDownMenu_Initialize(self, Initialize, "DROPDOWN")
            L_UIDropDownMenu_SetSelectedValue(self, self.value)

            self.GetValue = GenerateClosure(L_UIDropDownMenu_GetSelectedValue, self)

            self.SetControl = function(self, value)
                self.value = nPlatesDB[optionName]

                L_UIDropDownMenu_SetSelectedValue(self, self.value)
                L_UIDropDownMenu_SetText(self, optionsTable[self.value])
            end

            self.Update = function(self)
                self:SetControl()

                if ( updateAll ) then
                    nPlates:UpdateAllNameplates()
                end
            end
        end
    end)

    RegisterControl(parent, dropdown)
    return dropdown
end
