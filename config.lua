local ADDON, nPlates = ...

local L = nPlates.L
local format = string.format
local tonumber = tonumber

local function ForceUpdate()
    for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end

local function showColorPicker(r,g,b,callback)
    ColorPickerFrame.previousValues = {r,g,b}
    ColorPickerFrame.func = callback
    ColorPickerFrame.opacityFunc = callback
    ColorPickerFrame.cancelFunc = callback
    ColorPickerFrame:SetColorRGB(r,g,b)
    ShowUIPanel(ColorPickerFrame)
end

local Options = CreateFrame("Frame", "nPlatesOptions", InterfaceOptionsFramePanelContainer)
Options.name = GetAddOnMetadata(ADDON, "Title")
Options.version = GetAddOnMetadata(ADDON, "Version")
InterfaceOptions_AddCategory(Options)

Options:Hide()
Options:SetScript("OnShow", function()

    local LeftSide = CreateFrame("Frame","LeftSide",Options)
    LeftSide:SetHeight(Options:GetHeight())
    LeftSide:SetWidth(Options:GetWidth()/2)
    LeftSide:SetPoint("TOPLEFT",Options,"TOPLEFT")

    local RightSide = CreateFrame("Frame","RightSide",Options)
    RightSide:SetHeight(Options:GetHeight())
    RightSide:SetWidth(Options:GetWidth()/2)
    RightSide:SetPoint("TOPRIGHT",Options,"TOPRIGHT")

    -- Left Side --

    local NameOptions = Options:CreateFontString("NameOptions", "ARTWORK", "GameFontNormalLarge")
    NameOptions:SetPoint("TOPLEFT", LeftSide, 16, -16)
    NameOptions:SetText(L.NameOptionsLabel)

    local name = "NameSize"
    local NameSize = CreateFrame("Slider", name, LeftSide, "OptionsSliderTemplate")
    NameSize:SetPoint("TOPLEFT", NameOptions, "BOTTOMLEFT", 0, -30)
    NameSize.textLow = _G[name.."Low"]
    NameSize.textHigh = _G[name.."High"]
    NameSize.text = _G[name.."Text"]
    NameSize:SetMinMaxValues(8, 35)
    NameSize.minValue, NameSize.maxValue = NameSize:GetMinMaxValues()
    NameSize.textLow:SetText(NameSize.minValue)
    NameSize.textHigh:SetText(NameSize.maxValue)
    NameSize:SetValue(nPlatesDB.NameSize or 11)
    NameSize:SetValueStep(1)
    NameSize:SetObeyStepOnDrag(true)
    NameSize.text:SetText(L.NameSizeLabel..": "..format("%.0f",NameSize:GetValue()))
    NameSize:SetScript("OnValueChanged", function(self,event,arg1)
        NameSize.text:SetText(L.NameSizeLabel..": "..format("%.0f",NameSize:GetValue()))
        nPlatesDB.NameSize = tonumber(format("%.0f",NameSize:GetValue()))
        ForceUpdate()
    end)

    local ShowLevel = CreateFrame("CheckButton", "ShowLevel", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    ShowLevel:SetPoint("TOPLEFT", NameSize, "BOTTOMLEFT", 0, -18)
    ShowLevel.Text:SetText(L.DisplayLevel)
    ShowLevel:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowLevel = checked
        ForceUpdate()
    end)

    local ShowServerName = CreateFrame("CheckButton", "ShowServerName", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    ShowServerName:SetPoint("TOPLEFT", ShowLevel, "BOTTOMLEFT", 0, -6)
    ShowServerName.Text:SetText(L.DisplayServerName)
    ShowServerName:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowServerName = checked
        ForceUpdate()
    end)

    local AbrrevLongNames = CreateFrame("CheckButton", "AbrrevLongNames", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    AbrrevLongNames:SetPoint("TOPLEFT", ShowServerName, "BOTTOMLEFT", 0, -6)
    AbrrevLongNames.Text:SetText(L.AbbrevName)
    AbrrevLongNames:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.AbrrevLongNames = checked
        ForceUpdate()
    end)

    local ShowPvP = CreateFrame("CheckButton", "ShowPvP", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    ShowPvP:SetPoint("TOPLEFT", AbrrevLongNames, "BOTTOMLEFT", 0, -6)
    ShowPvP.Text:SetText(L.ShowPvP)
    ShowPvP:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowPvP = checked
        ForceUpdate()
    end)

    local TankOptions = Options:CreateFontString("TankOptions", "ARTWORK", "GameFontNormalLarge")
    TankOptions:SetPoint("TOPLEFT", ShowPvP, "BOTTOMLEFT", 0, -24)
    TankOptions:SetText(L.TankOptionsLabel)

    local TankMode = CreateFrame("CheckButton", "TankMode", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    TankMode:SetPoint("TOPLEFT", TankOptions, "BOTTOMLEFT", 0, -12)
    TankMode.Text:SetText(L.TankMode)
    TankMode:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.TankMode = checked
        ForceUpdate()
    end)

    local ColorNameByThreat = CreateFrame("CheckButton", "ColorNameByThreat", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    ColorNameByThreat:SetPoint("TOPLEFT", TankMode, "BOTTOMLEFT", 0, -6)
    ColorNameByThreat.Text:SetText(L.NameThreat)
    ColorNameByThreat:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ColorNameByThreat = checked
        ForceUpdate()
    end)

    local UseOffTankColor = CreateFrame("CheckButton", "UseOffTankColor", LeftSide, "InterfaceOptionsCheckButtonTemplate")
    UseOffTankColor:SetPoint("TOPLEFT", ColorNameByThreat, "BOTTOMLEFT", 0, -6)
    UseOffTankColor.Text:SetText(L.OffTankColor)
    UseOffTankColor:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.UseOffTankColor = checked
        ForceUpdate()
    end)

    local OffTankColorPicker = CreateFrame("Frame", "OffTankColor", RightSide)
    OffTankColorPicker:SetSize(15,15)
    OffTankColorPicker:SetPoint("LEFT", UseOffTankColorText, "RIGHT", 10, 0)
    OffTankColorPicker.bg = OffTankColorPicker:CreateTexture(nil,"BACKGROUND",nil,-7)
    OffTankColorPicker.bg:SetAllPoints(OffTankColorPicker)
    OffTankColorPicker.bg:SetColorTexture(1,1,1,1)
    OffTankColorPicker.bg:SetVertexColor(nPlatesDB.OffTankColor.r,nPlatesDB.OffTankColor.g,nPlatesDB.OffTankColor.b)
    OffTankColorPicker.recolor = function(color)
        local r,g,b
        if (color) then
            r,g,b = unpack(color)
        else
            r,g,b = ColorPickerFrame:GetColorRGB()
        end
        nPlatesDB.OffTankColor.r = r
        nPlatesDB.OffTankColor.g = g
        nPlatesDB.OffTankColor.b = b
        OffTankColorPicker.bg:SetVertexColor(r,g,b)
    end
    OffTankColorPicker:EnableMouse(true)
    OffTankColorPicker:SetScript("OnMouseDown", function(self,button,...)
        if button == "LeftButton" then
            local r,g,b = OffTankColorPicker.bg:GetVertexColor()
            showColorPicker(r,g,b,OffTankColorPicker.recolor)
        end
    end)

    -- Right Side --

    local FrameOptions = Options:CreateFontString("NameOptions", "ARTWORK", "GameFontNormalLarge")
    FrameOptions:SetPoint("TOPLEFT", RightSide, 16, -16)
    FrameOptions:SetText(L.FrameOptionsLabel)

    local HealthTextMenuTable = {
        {
            text = L.EnableHealth,
            func = function()
                nPlatesDB.ShowHP = not nPlatesDB.ShowHP
                ForceUpdate()
            end,
            checked = function() return nPlatesDB.ShowHP end,
        },
        {
            text = L.ShowWhenFull,
            func = function()
                nPlatesDB.ShowFullHP = not nPlatesDB.ShowFullHP
                ForceUpdate()
            end,
            checked = function() return nPlatesDB.ShowFullHP end,
        },
        {
            text = L.ShowCurHP,
            func = function()
                nPlatesDB.ShowCurHP = not nPlatesDB.ShowCurHP
                ForceUpdate()
            end,
            checked = function() return nPlatesDB.ShowCurHP end,
        },
        {
            text = L.ShowPercHP,
            func = function()
                nPlatesDB.ShowPercHP = not nPlatesDB.ShowPercHP
                ForceUpdate()
            end,
            checked = function() return nPlatesDB.ShowPercHP end,
        },
        {
            text = CLOSE,
            func = function() CloseDropDownMenus() end,
            notCheckable = 1,
        },
    }

    local HealthTextDropDownMenu = CreateFrame("Frame", "HealthTextDropDownMenu", RightSide, "UIDropDownMenuTemplate")
    local HealthText = CreateFrame("Button", "HealthTextTitle", RightSide , "UIPanelButtonTemplate")
    HealthText:SetPoint("TOPLEFT", FrameOptions, "BOTTOMLEFT", 0, -18)
    HealthText:SetSize(140,25)
    HealthText:SetText(L.HealthOptions)
    HealthText:SetScript("OnClick", function(self, button, down)
        if ( not DropDownList1:IsVisible() ) then
            if button == "LeftButton" then
                EasyMenu(HealthTextMenuTable,HealthTextDropDownMenu, self:GetName(), 0, 0, "MENU")
            end
        else
            CloseDropDownMenus()
        end
    end)
    HealthText:RegisterForClicks("LeftButtonUp")

    local HideFriendly = CreateFrame("CheckButton", "HideFriendly", RightSide, "InterfaceOptionsCheckButtonTemplate")
    HideFriendly:SetPoint("TOPLEFT", HealthText, "BOTTOMLEFT", 0, -6)
    HideFriendly.Text:SetText(L.HideFriendly)
    HideFriendly:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.HideFriendly = checked
        ForceUpdate()
    end)

    local SmallStacking = CreateFrame("CheckButton", "SmallStacking", RightSide, "InterfaceOptionsCheckButtonTemplate")
    SmallStacking:SetPoint("TOPLEFT", HideFriendly, "BOTTOMLEFT", 0, -6)
    SmallStacking.Text:SetText(L.SmallStacking)
    SmallStacking.tooltipText = L.SmallStackingTooltip
    SmallStacking:SetScript("OnUpdate", function()
        if ( not InCombatLockdown() ) then
            SmallStacking:Enable()
        else
            SmallStacking:Disable()
        end
    end)
    SmallStacking:SetScript("OnClick", function(this)
        if ( not InCombatLockdown() ) then
        local checked = not not this:GetChecked()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            nPlatesDB.SmallStacking = checked
            if ( checked ) then
                SetCVar("nameplateOverlapH", 1.1) SetCVar("nameplateOverlapV", 0.9)
            else
                for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do SetCVar(v, GetCVarDefault(v),true) end
            end
        end
    end)

    local ShowFriendlyClassColors = CreateFrame("CheckButton", "ShowFriendlyClassColors", RightSide, "InterfaceOptionsCheckButtonTemplate")
    ShowFriendlyClassColors:SetPoint("TOPLEFT", SmallStacking, "BOTTOMLEFT", 0, -6)
    ShowFriendlyClassColors.Text:SetText(L.FriendlyClassColors)
    ShowFriendlyClassColors:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowFriendlyClassColors = checked
        ForceUpdate()
    end)

    local ShowEnemyClassColors = CreateFrame("CheckButton", "ShowEnemyClassColors", RightSide, "InterfaceOptionsCheckButtonTemplate")
    ShowEnemyClassColors:SetPoint("TOPLEFT", ShowFriendlyClassColors, "BOTTOMLEFT", 0, -6)
    ShowEnemyClassColors.Text:SetText(L.EnemyClassColors)
    ShowEnemyClassColors:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowEnemyClassColors = checked
        if ( not checked ) then
            DefaultCompactNamePlateEnemyFrameOptions.useClassColors = false
        else
            DefaultCompactNamePlateEnemyFrameOptions.useClassColors = true
        end
        ForceUpdate()
    end)

    local DontClamp = CreateFrame("CheckButton", "DontClamp", RightSide, "InterfaceOptionsCheckButtonTemplate")
    DontClamp:SetPoint("TOPLEFT", ShowEnemyClassColors, "BOTTOMLEFT", 0, -6)
    DontClamp.Text:SetText(L.StickyNameplates)
    DontClamp:SetScript("OnUpdate", function()
        if ( not InCombatLockdown() ) then
            DontClamp:Enable()
        else
            DontClamp:Disable()
        end
    end)
    DontClamp:SetScript("OnClick", function(this)
        if ( not InCombatLockdown() ) then
            local checked = not not this:GetChecked()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            nPlatesDB.DontClamp = checked
            if ( not checked ) then
                SetCVar("nameplateOtherTopInset", -1,true)
                SetCVar("nameplateOtherBottomInset", -1,true)
            else
                for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
            end
        end
    end)

    local FelExplosivesColor = CreateFrame("CheckButton", "FelExplosivesColor", RightSide, "InterfaceOptionsCheckButtonTemplate")
    FelExplosivesColor:SetPoint("TOPLEFT", DontClamp, "BOTTOMLEFT", 0, -6)
    FelExplosivesColor.Text:SetText(L.FelExplosivesColor)
    FelExplosivesColor:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.FelExplosives = checked
        ForceUpdate()
    end)

    local FelExplosivesColorPicker = CreateFrame("Frame", "FelExplosivesColorPicker", RightSide)
    FelExplosivesColorPicker:SetSize(15,15)
    FelExplosivesColorPicker:SetPoint("LEFT", FelExplosivesColorText, "RIGHT", 10, 0)
    FelExplosivesColorPicker.bg = FelExplosivesColorPicker:CreateTexture(nil,"BACKGROUND",nil,-7)
    FelExplosivesColorPicker.bg:SetAllPoints(FelExplosivesColorPicker)
    FelExplosivesColorPicker.bg:SetColorTexture(1,1,1,1)
    FelExplosivesColorPicker.bg:SetVertexColor(nPlatesDB.FelExplosivesColor.r,nPlatesDB.FelExplosivesColor.g,nPlatesDB.FelExplosivesColor.b)
    FelExplosivesColorPicker.recolor = function(color)
        local r,g,b
        if (color) then
            r,g,b = unpack(color)
        else
            r,g,b = ColorPickerFrame:GetColorRGB()
        end
        nPlatesDB.FelExplosivesColor.r = r
        nPlatesDB.FelExplosivesColor.g = g
        nPlatesDB.FelExplosivesColor.b = b
        FelExplosivesColorPicker.bg:SetVertexColor(r,g,b)
    end
    FelExplosivesColorPicker:EnableMouse(true)
    FelExplosivesColorPicker:SetScript("OnMouseDown", function(self,button,...)
        if button == "LeftButton" then
            local r,g,b = FelExplosivesColorPicker.bg:GetVertexColor()
            showColorPicker(r,g,b,FelExplosivesColorPicker.recolor)
        end
    end)

    local ShowExecuteRange = CreateFrame("CheckButton", "ShowExecuteRange", RightSide, "InterfaceOptionsCheckButtonTemplate")
    ShowExecuteRange:SetPoint("TOPLEFT", FelExplosivesColor, "BOTTOMLEFT", 0, -6)
    ShowExecuteRange.Text:SetText(L.ExecuteRange)
    ShowExecuteRange:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowExecuteRange = checked
        ForceUpdate()
    end)

    local ExecuteColorPicker = CreateFrame("Frame", "ExecuteColor", RightSide)
    ExecuteColorPicker:SetSize(15,15)
    ExecuteColorPicker:SetPoint("LEFT", ShowExecuteRangeText, "RIGHT", 10, 0)
    ExecuteColorPicker.bg = ExecuteColorPicker:CreateTexture(nil,"BACKGROUND",nil,-7)
    ExecuteColorPicker.bg:SetAllPoints(ExecuteColorPicker)
    ExecuteColorPicker.bg:SetColorTexture(1,1,1,1)
    ExecuteColorPicker.bg:SetVertexColor(nPlatesDB.ExecuteColor.r,nPlatesDB.ExecuteColor.g,nPlatesDB.ExecuteColor.b)
    ExecuteColorPicker.recolor = function(color)
        local r,g,b
        if (color) then
            r,g,b = unpack(color)
        else
            r,g,b = ColorPickerFrame:GetColorRGB()
        end
        nPlatesDB.ExecuteColor.r = r
        nPlatesDB.ExecuteColor.g = g
        nPlatesDB.ExecuteColor.b = b
        ExecuteColorPicker.bg:SetVertexColor(r,g,b)
    end
    ExecuteColorPicker:EnableMouse(true)
    ExecuteColorPicker:SetScript("OnMouseDown", function(self,button,...)
        if button == "LeftButton" then
            local r,g,b = ExecuteColorPicker.bg:GetVertexColor()
            showColorPicker(r,g,b,ExecuteColorPicker.recolor)
        end
    end)

    local name = "ExecuteSlider"
    local ExecuteSlider = CreateFrame("Slider", name, RightSide, "OptionsSliderTemplate")
    ExecuteSlider:SetPoint("TOPLEFT", ShowExecuteRange, "BOTTOMLEFT", 10, -18)
    ExecuteSlider.textLow = _G[name.."Low"]
    ExecuteSlider.textHigh = _G[name.."High"]
    ExecuteSlider.text = _G[name.."Text"]
    ExecuteSlider:SetMinMaxValues(0, 35)
    ExecuteSlider.minValue, ExecuteSlider.maxValue = ExecuteSlider:GetMinMaxValues()
    ExecuteSlider.textLow:SetText(ExecuteSlider.minValue)
    ExecuteSlider.textHigh:SetText(ExecuteSlider.maxValue)
    ExecuteSlider:SetValue(nPlatesDB.ExecuteValue or 35)
    ExecuteSlider:SetValueStep(1)
    ExecuteSlider:SetObeyStepOnDrag(true)
    ExecuteSlider.text:SetText(format("%.0f",ExecuteSlider:GetValue()))
    ExecuteSlider:SetScript("OnValueChanged", function(self,event,arg1)
        ExecuteSlider.text:SetText(format("%.0f",ExecuteSlider:GetValue()))
        nPlatesDB.ExecuteValue = tonumber(format("%.0f",ExecuteSlider:GetValue()))
    end)
    ExecuteSlider:SetScript("OnUpdate", function(self)
        if ( nPlatesDB.ShowExecuteRange ) then
            ExecuteSlider:Enable()
        else
            ExecuteSlider:Disable()
        end
    end)

    local name = "NameplateScale"
    local NameplateScale = CreateFrame("Slider", name, RightSide, "OptionsSliderTemplate")
    NameplateScale:SetPoint("TOPLEFT", ExecuteSlider, "BOTTOMLEFT", 0, -42)
    NameplateScale.textLow = _G[name.."Low"]
    NameplateScale.textHigh = _G[name.."High"]
    NameplateScale.text = _G[name.."Text"]
    NameplateScale:SetMinMaxValues(.75, 2)
    NameplateScale.minValue, NameplateScale.maxValue = NameplateScale:GetMinMaxValues()
    NameplateScale.textLow:SetText(NameplateScale.minValue)
    NameplateScale.textHigh:SetText(NameplateScale.maxValue)
    local scale = tonumber(format("%.2f",GetCVar("nameplateGlobalScale")))
    NameplateScale:SetValue(scale)
    NameplateScale:SetValueStep(.01)
    NameplateScale:SetObeyStepOnDrag(true)
    NameplateScale.text:SetText(L.NameplateScale..": "..format("%.2f",NameplateScale:GetValue()))
    NameplateScale:SetScript("OnValueChanged", function(self,event,arg1)
        NameplateScale.text:SetText(L.NameplateScale..": "..format("%.2f",NameplateScale:GetValue()))
        local value = tonumber(format("%.2f",NameplateScale:GetValue()))
        SetCVar("nameplateGlobalScale",value,true)
    end)
    NameplateScale:SetScript("OnUpdate", function(self)
        if ( InCombatLockdown() ) then
            NameplateScale:Disable()
        else
            NameplateScale:Enable()
        end
    end)

    local name = "NameplateAlpha"
    local NameplateAlpha = CreateFrame("Slider", name, RightSide, "OptionsSliderTemplate")
    NameplateAlpha:SetPoint("TOPLEFT", NameplateScale, "BOTTOMLEFT", 0, -42)
    NameplateAlpha.textLow = _G[name.."Low"]
    NameplateAlpha.textHigh = _G[name.."High"]
    NameplateAlpha.text = _G[name.."Text"]
    NameplateAlpha:SetMinMaxValues(.50, 1)
    NameplateAlpha.minValue, NameplateAlpha.maxValue = NameplateAlpha:GetMinMaxValues()
    NameplateAlpha.textLow:SetText(NameplateAlpha.minValue)
    NameplateAlpha.textHigh:SetText(NameplateAlpha.maxValue)
    local alpha = tonumber(format("%.2f",GetCVar("nameplateMinAlpha")))
    NameplateAlpha:SetValue(alpha)
    NameplateAlpha:SetValueStep(.01)
    NameplateAlpha:SetObeyStepOnDrag(true)
    NameplateAlpha.text:SetText(L.NameplateAlpha..": "..format("%.2f",NameplateAlpha:GetValue()))
    NameplateAlpha:SetScript("OnValueChanged", function(self,event,arg1)
        NameplateAlpha.text:SetText(L.NameplateAlpha..": "..format("%.2f",NameplateAlpha:GetValue()))
        local value = tonumber(format("%.2f",NameplateAlpha:GetValue()))
        SetCVar("nameplateMinAlpha",value,true)
    end)
    NameplateAlpha:SetScript("OnUpdate", function(self)
        if ( InCombatLockdown() ) then
            NameplateAlpha:Disable()
        else
            NameplateAlpha:Enable()
        end
    end)

    local name = "NameplateRange"
    local NameplateRange = CreateFrame("Slider", name, RightSide, "OptionsSliderTemplate")
    NameplateRange:SetPoint("TOPLEFT", NameplateAlpha, "BOTTOMLEFT", 0, -42)
    NameplateRange.textLow = _G[name.."Low"]
    NameplateRange.textHigh = _G[name.."High"]
    NameplateRange.text = _G[name.."Text"]
    NameplateRange:SetMinMaxValues(40, 60)
    NameplateRange.minValue, NameplateRange.maxValue = NameplateRange:GetMinMaxValues()
    NameplateRange.textLow:SetText(NameplateRange.minValue)
    NameplateRange.textHigh:SetText(NameplateRange.maxValue)
    local range = GetCVar("nameplateMaxDistance")
    NameplateRange:SetValue(range)
    NameplateRange:SetValueStep(1)
    NameplateRange:SetObeyStepOnDrag(true)
    NameplateRange.text:SetText(L.NameplateRange..": "..format("%.0f",NameplateRange:GetValue()))
    NameplateRange:SetScript("OnValueChanged", function(self,event,arg1)
        NameplateRange.text:SetText(L.NameplateRange..": "..format("%.0f",NameplateRange:GetValue()))
        local value = tonumber(format("%.0f",NameplateRange:GetValue()))
        SetCVar("nameplateMaxDistance",value,true)
    end)
    NameplateRange:SetScript("OnUpdate", function(self)
        if ( InCombatLockdown() ) then
            NameplateRange:Disable()
        else
            NameplateRange:Enable()
        end
    end)

    local AddonTitle = Options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
    AddonTitle:SetPoint("BOTTOMRIGHT", -16, 16)
    AddonTitle:SetText(Options.name.." "..Options.version)

    function Options:Refresh()
        TankMode:SetChecked(nPlatesDB.TankMode)
        ColorNameByThreat:SetChecked(nPlatesDB.ColorNameByThreat)
        ShowLevel:SetChecked(nPlatesDB.ShowLevel)
        ShowServerName:SetChecked(nPlatesDB.ShowServerName)
        AbrrevLongNames:SetChecked(nPlatesDB.AbrrevLongNames)
        HideFriendly:SetChecked(nPlatesDB.HideFriendly)
        SmallStacking:SetChecked(nPlatesDB.SmallStacking)
        ShowFriendlyClassColors:SetChecked(nPlatesDB.ShowFriendlyClassColors)
        ShowEnemyClassColors:SetChecked(nPlatesDB.ShowEnemyClassColors)
        DontClamp:SetChecked(nPlatesDB.DontClamp)
        ShowExecuteRange:SetChecked(nPlatesDB.ShowExecuteRange)
        UseOffTankColor:SetChecked(nPlatesDB.UseOffTankColor)
        ShowPvP:SetChecked(nPlatesDB.ShowPvP)
        FelExplosivesColor:SetChecked(nPlatesDB.FelExplosives)
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
