local ADDON, nPlates = ...

local Options = CreateFrame("Frame", "nPlatesOptions", InterfaceOptionsFramePanelContainer)
local ShowFullHP

local function ForceUpdate()
    for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
        nPlates.NameSize(frame.UnitFrame)
        -- nPlates.UpdateTotemIcon(frame.UnitFrame)
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
    TankMode.Text:SetText("Tank Mode")
    TankMode:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.TankMode = checked
        ForceUpdate()
    end)

    local ColorNameByThreat = CreateFrame("CheckButton", "$parentColorNameByThreat", Options, "InterfaceOptionsCheckButtonTemplate")
    ColorNameByThreat:SetPoint("TOPLEFT", TankMode, "BOTTOMLEFT", 0, -12)
    ColorNameByThreat.Text:SetText("Color Name By Threat")
    ColorNameByThreat:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ColorNameByThreat = checked
        ForceUpdate()
    end)

    local ShowHP = CreateFrame("CheckButton", "$parentShowHP", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowHP:SetPoint("TOPLEFT", ColorNameByThreat, "BOTTOMLEFT", 0, -24)
    ShowHP.Text:SetText("Display Health Text")
    ShowHP:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowHP = checked
        if nPlatesDB.ShowHP then
            ShowFullHP:Enable()
            ForceUpdate()
        else
            ShowFullHP:Disable()
            ForceUpdate()
        end
    end)

    ShowFullHP = CreateFrame("CheckButton", "$parentShowFullHP", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowFullHP:SetPoint("TOPLEFT", ShowHP, "BOTTOMLEFT", 10, 0)
    ShowFullHP.Text:SetText("Display When Full")
    ShowFullHP:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowFullHP = checked
        ForceUpdate()
    end)

    local ShowLevel = CreateFrame("CheckButton", "$parentShowLevel", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowLevel:SetPoint("TOPLEFT", ShowHP, "BOTTOMLEFT", 0, -48)
    ShowLevel.Text:SetText("Display Level")
    ShowLevel:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowLevel = checked
        ForceUpdate()
    end)

    local ShowServerName = CreateFrame("CheckButton", "$parentShowServerName", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowServerName:SetPoint("TOPLEFT", ShowLevel, "BOTTOMLEFT", 0, -12)
    ShowServerName.Text:SetText("Display Server Name")
    ShowServerName:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.ShowServerName = checked
        ForceUpdate()
    end)

    local AbrrevLongNames = CreateFrame("CheckButton", "$parentAbrrevLongNames", Options, "InterfaceOptionsCheckButtonTemplate")
    AbrrevLongNames:SetPoint("TOPLEFT", ShowServerName, "BOTTOMLEFT", 0, -12)
    AbrrevLongNames.Text:SetText("Abbreviate Long Names")
    AbrrevLongNames:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.AbrrevLongNames = checked
        ForceUpdate()
    end)

    local UseLargeNameFont = CreateFrame("CheckButton", "$parentUseBigNames", Options, "InterfaceOptionsCheckButtonTemplate")
    UseLargeNameFont:SetPoint("TOPLEFT", AbrrevLongNames, "BOTTOMLEFT", 0, -12)
    UseLargeNameFont.Text:SetText("Use Large Names")
    UseLargeNameFont:SetScript("OnClick", function(this)
        local checked = not not this:GetChecked()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        nPlatesDB.UseLargeNameFont = checked
        ForceUpdate()
    end)

    local ShowClassColors = CreateFrame("CheckButton", "$parentShowClassColors", Options, "InterfaceOptionsCheckButtonTemplate")
    ShowClassColors:SetPoint("TOPLEFT", UseLargeNameFont, "BOTTOMLEFT", 0, -12)
    ShowClassColors.Text:SetText("Display Class Colors")
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
    DontClamp:SetPoint("TOPLEFT", ShowClassColors, "BOTTOMLEFT", 0, -12)
    DontClamp.Text:SetText("Sticky Nameplates")
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

    -- local ShowTotemIcon = CreateFrame("CheckButton", "$parentShowTotemIcon", Options, "InterfaceOptionsCheckButtonTemplate")
    -- ShowTotemIcon:SetPoint("TOPLEFT", DontClamp, "BOTTOMLEFT", 0, -12)
    -- ShowTotemIcon.Text:SetText("Display Totem Icon")
    -- ShowTotemIcon:SetScript("OnClick", function(this)
        -- local checked = not not this:GetChecked()
        -- PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
        -- nPlatesDB.ShowTotemIcon = checked
        -- ForceUpdate()
    -- end)

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
    NameplateScaleLabel:SetText("Nameplate Scale:")

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
    NameplateAlphaLabel:SetText("Nameplate Min Alpha:")

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
        ShowHP:SetChecked(nPlatesDB.ShowHP)
        ShowFullHP:SetChecked(nPlatesDB.ShowFullHP)
        ShowLevel:SetChecked(nPlatesDB.ShowLevel)
        ShowServerName:SetChecked(nPlatesDB.ShowServerName)
        AbrrevLongNames:SetChecked(nPlatesDB.AbrrevLongNames)
        UseLargeNameFont:SetChecked(nPlatesDB.UseLargeNameFont)
        ShowClassColors:SetChecked(nPlatesDB.ShowClassColors)
        DontClamp:SetChecked(nPlatesDB.DontClamp)
        --ShowTotemIcon:SetChecked(nPlatesDB.ShowTotemIcon)
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
