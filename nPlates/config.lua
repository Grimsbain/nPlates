local ADDON, nPlates = ...
local L = nPlates.L

local Options = CreateFrame("Frame", "nPlatesOptions", InterfaceOptionsFramePanelContainer)
local ShowFullHP

local function ForceUpdate()
    for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
        nPlates.NameSize(frame.UnitFrame)
        nPlates.UpdateTotemIcon(frame.UnitFrame)
    end
end

Options.name = GetAddOnMetadata(ADDON, "Title")
InterfaceOptions_AddCategory(Options)

Options:Hide()
Options:SetScript("OnShow", function()

    local Title = Options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
    Title:SetPoint("TOPLEFT", 16, -16)
    Title:SetText(Options.name)

    local SubText = Options:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
    SubText:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
    SubText:SetPoint("RIGHT", -32, 0)
    SubText:SetHeight(32)
    SubText:SetJustifyH("LEFT")
    SubText:SetJustifyV("TOP")
    SubText:SetText(GetAddOnMetadata(ADDON, "Notes"))

    local TankMode = CreateFrame("CheckButton", "$parentTankMode", Options, "InterfaceOptionsCheckButtonTemplate")
    TankMode:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -12)
    TankMode.Text:SetText(L.TankMode)
    TankMode:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.TankMode = checked
        ForceUpdate()
    end)

    local ColorNameByThreat = CreateFrame("CheckButton", "$parentColorNameByThreat", Options, "InterfaceOptionsCheckButtonTemplate")
    ColorNameByThreat:SetPoint("TOPLEFT", TankMode, "BOTTOMLEFT", 0, -6)
    ColorNameByThreat.Text:SetText(L.NameThreat)
    ColorNameByThreat:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ColorNameByThreat = checked
        ForceUpdate()
    end)

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

    local HealthTextDropDownMenu = CreateFrame("Frame", "HealthTextDropDownMenu", Options, "UIDropDownMenuTemplate")
    local HealthText = CreateFrame("Button", "HealthTextTitle", Options , "UIPanelButtonTemplate")
    HealthText:SetPoint("TOPLEFT", ColorNameByThreat, "BOTTOMLEFT", 0, -6)
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

    local ShowLevel = CreateFrame("CheckButton", "$parentShowLevel", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowLevel:SetPoint("TOPLEFT", HealthText, "BOTTOMLEFT", 0, -6)
    ShowLevel.Text:SetText(L.DisplayLevel)
    ShowLevel:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowLevel = checked
        ForceUpdate()
    end)

    local ShowServerName = CreateFrame("CheckButton", "$parentShowServerName", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowServerName:SetPoint("TOPLEFT", ShowLevel, "BOTTOMLEFT", 0, -6)
    ShowServerName.Text:SetText("Display Server Name")
    ShowServerName:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowServerName = checked
        ForceUpdate()
    end)

    local AbrrevLongNames = CreateFrame("CheckButton", "$parentAbrrevLongNames", Options, "InterfaceOptionsCheckButtonTemplate")
    AbrrevLongNames:SetPoint("TOPLEFT", ShowServerName, "BOTTOMLEFT", 0, -6)
    AbrrevLongNames.Text:SetText(L.AbbrevName)
    AbrrevLongNames:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.AbrrevLongNames = checked
        ForceUpdate()
    end)

    local UseLargeNameFont = CreateFrame("CheckButton", "$parentUseBigNames", Options, "InterfaceOptionsCheckButtonTemplate")
    UseLargeNameFont:SetPoint("TOPLEFT", AbrrevLongNames, "BOTTOMLEFT", 0, -6)
    UseLargeNameFont.Text:SetText(L.LargeNames)
    UseLargeNameFont:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.UseLargeNameFont = checked
        ForceUpdate()
    end)

    local HideFriendly = CreateFrame("CheckButton", "$parentHideFriendly", Options, "InterfaceOptionsCheckButtonTemplate")
    HideFriendly:SetPoint("TOPLEFT", UseLargeNameFont, "BOTTOMLEFT", 0, -6)
    HideFriendly.Text:SetText(L.HideFriendly)
    HideFriendly:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.HideFriendly = checked
        ForceUpdate()
    end)

    local ShowClassColors = CreateFrame("CheckButton", "$parentShowClassColors", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowClassColors:SetPoint("TOPLEFT", HideFriendly, "BOTTOMLEFT", 0, -6)
    ShowClassColors.Text:SetText(L.ClassColors)
    ShowClassColors:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowClassColors = checked
        if ( not checked ) then
            DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = false
            DefaultCompactNamePlateEnemyFrameOptions.useClassColors = false
        else
            DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = true
            DefaultCompactNamePlateEnemyFrameOptions.useClassColors = true
        end
        ForceUpdate()
    end)

    local DontClamp = CreateFrame("CheckButton", "$parentDontClamp", Options, "InterfaceOptionsCheckButtonTemplate")
    DontClamp:SetPoint("TOPLEFT", ShowClassColors, "BOTTOMLEFT", 0, -6)
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
            PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
            nPlatesDB.DontClamp = checked
            if ( not checked ) then
                SetCVar("nameplateOtherTopInset", -1,true)
                SetCVar("nameplateOtherBottomInset", -1,true)
            else
                for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
            end
        end
    end)

    local ShowTotemIcon = CreateFrame("CheckButton", "$parentShowTotemIcon", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowTotemIcon:SetPoint("TOPLEFT", DontClamp, "BOTTOMLEFT", 0, -6)
    ShowTotemIcon.Text:SetText(L.TotemIcons)
    ShowTotemIcon:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowTotemIcon = checked
        ForceUpdate()
    end)

    local NameplateScale = CreateFrame("EditBox", "$parentNameplateScale", Options, "InputBoxTemplate")
    NameplateScale:SetPoint("LEFT", TankMode, "RIGHT", 375, 0)
    NameplateScale:SetSize(60,15)
    NameplateScale:EnableMouse(true)
    local scale = string.format("%.2f",GetCVar("nameplateGlobalScale"))
    NameplateScale:SetText(scale)
    NameplateScale:SetAutoFocus(false)
    NameplateScale:SetCursorPosition(0)
    NameplateScale:SetMaxLetters(4)
    NameplateScale:SetJustifyH("CENTER")

    local NameplateScaleLabel = Options:CreateFontString("NameplateScaleLabel", "ARTWORK", "GameFontHighlightSmall")
    NameplateScaleLabel:SetPoint("RIGHT", NameplateScale, "LEFT", -10, 0)
    NameplateScaleLabel:SetText(L.NameplateScale..":")

    local NameplateScaleButton = CreateFrame("Button", "$parentButton", NameplateScale, "UIPanelButtonTemplate")
    NameplateScaleButton:SetPoint("LEFT", NameplateScale, "RIGHT", 10, 0)
    NameplateScaleButton:SetText(APPLY)
    NameplateScaleButton:SetWidth(100)
    NameplateScaleButton:SetScript("OnUpdate", function()
        if ( not InCombatLockdown() ) then
            NameplateScaleButton:Enable()
        else
            NameplateScaleButton:Disable()
        end
    end)
    NameplateScaleButton:SetScript("OnClick", function(this)
        local value = NameplateScale:GetNumber()
        if ( value >= 0 and value <= 2 and value ~= nil and tonumber(NameplateScale:GetText()) ~= nil ) then
            SetCVar("nameplateGlobalScale",value,true)
        else
            message("Please enter a number between 0 and 2.\n1 is default.")
        end
    end)

    local NameplateAlpha = CreateFrame("EditBox", "$parentNameplateAlpha", Options, "InputBoxTemplate")
    NameplateAlpha:SetPoint("LEFT", ColorNameByThreat, "RIGHT", 375, 0)
    NameplateAlpha:SetSize(60,15)
    NameplateAlpha:EnableMouse(true)
    local alpha = string.format("%.2f",GetCVar("nameplateMinAlpha"))
    NameplateAlpha:SetText(alpha)
    NameplateAlpha:SetAutoFocus(false)
    NameplateAlpha:SetCursorPosition(0)
    NameplateAlpha:SetMaxLetters(4)
    NameplateAlpha:SetJustifyH("CENTER")

    local NameplateAlphaLabel = Options:CreateFontString("NameplateAlphaLabel", "ARTWORK", "GameFontHighlightSmall")
    NameplateAlphaLabel:SetPoint("RIGHT", NameplateAlpha, "LEFT", -10, 0)
    NameplateAlphaLabel:SetText(L.NameplateAlpha..":")

    local NameplateAlphaButton = CreateFrame("Button", "$parentButton", NameplateAlpha, "UIPanelButtonTemplate")
    NameplateAlphaButton:SetPoint("LEFT", NameplateAlpha, "RIGHT", 10, 0)
    NameplateAlphaButton:SetText(APPLY)
    NameplateAlphaButton:SetWidth(100)
    NameplateAlphaButton:SetScript("OnUpdate", function()
        if ( not InCombatLockdown() ) then
            NameplateAlphaButton:Enable()
        else
            NameplateAlphaButton:Disable()
        end
    end)
    NameplateAlphaButton:SetScript("OnClick", function(this)
        local value = NameplateAlpha:GetNumber()
        if ( value >= 0.50 and value <= 1 and value ~= nil and tonumber(NameplateAlpha:GetText()) ~= nil ) then
            SetCVar("nameplateMinAlpha",value,true)
        else
            message("Please enter a number between 0.50 and 1.\n0.80 is default.")
        end
    end)

    function Options:Refresh()
        TankMode:SetChecked(nPlatesDB.TankMode)
        ColorNameByThreat:SetChecked(nPlatesDB.ColorNameByThreat)
        ShowLevel:SetChecked(nPlatesDB.ShowLevel)
        ShowServerName:SetChecked(nPlatesDB.ShowServerName)
        AbrrevLongNames:SetChecked(nPlatesDB.AbrrevLongNames)
        UseLargeNameFont:SetChecked(nPlatesDB.UseLargeNameFont)
        HideFriendly:SetChecked(nPlatesDB.HideFriendly)
        ShowClassColors:SetChecked(nPlatesDB.ShowClassColors)
        DontClamp:SetChecked(nPlatesDB.DontClamp)
        ShowTotemIcon:SetChecked(nPlatesDB.ShowTotemIcon)
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
