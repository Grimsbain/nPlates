local addon, nPlates = ...
local L = nPlates.L

local floor = math.floor

local Options = CreateFrame("Frame", "nPlatesOptions", InterfaceOptionsFramePanelContainer)
Options.name = GetAddOnMetadata(addon, "Title")
Options.version = GetAddOnMetadata(addon, "Version")
InterfaceOptions_AddCategory(Options)

Options:Hide()
Options:SetScript("OnShow", function()
	local panelWidth = Options:GetWidth()/2

    local LeftSide = CreateFrame("Frame", "LeftSide", Options)
    LeftSide:SetHeight(Options:GetHeight())
    LeftSide:SetWidth(panelWidth)
    LeftSide:SetPoint("TOPLEFT", Options)

    local RightSide = CreateFrame("Frame", "RightSide", Options)
    RightSide:SetHeight(Options:GetHeight())
    RightSide:SetWidth(panelWidth)
    RightSide:SetPoint("TOPRIGHT", Options)

    -- Left Side --

    local NameOptions = Options:CreateFontString("NameOptions", "ARTWORK", "GameFontNormalLarge")
    NameOptions:SetPoint("TOPLEFT", LeftSide, 16, -16)
    NameOptions:SetText(L.NameOptionsLabel)

	local currentNameSize = nPlatesDB.NameSize or 10
	local nameSize = nPlates:CreateSlider("NameSize", LeftSide, L.NameSizeLabel, NameOptions, 0, -30, nil, nPlatesDB.NameSize, "%.0f", currentNameSize, 8, 35, 1, false)
    nameSize:SetScript("OnValueChanged", function(self, value)
		value = floor(value)
		nameSize.text:SetFormattedText("%.0f", value)
        nPlatesDB.NameSize = value
        nPlates:UpdateAllNameplates()
    end)

	local ShowLevel = nPlates:CreateCheckBox("ShowLevel", LeftSide, L.DisplayLevel, nil, NameSize, 0, -6, false)
    ShowLevel:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowLevel = checked
        nPlates:UpdateAllNameplates()
    end)

	local ShowServerName = nPlates:CreateCheckBox("ShowServerName", LeftSide, L.DisplayServerName, nil, ShowLevel, 0, -6, false)
    ShowServerName:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowServerName = checked
        nPlates:UpdateAllNameplates()
    end)

	local AbrrevLongNames = nPlates:CreateCheckBox("AbrrevLongNames", LeftSide, L.AbbrevName, nil, ShowServerName, 0, -6, false)
    AbrrevLongNames:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.AbrrevLongNames = checked
        nPlates:UpdateAllNameplates()
    end)

	local ShowPvP = nPlates:CreateCheckBox("ShowPvP", LeftSide, L.ShowPvP, nil, AbrrevLongNames, 0, -6, false)
    ShowPvP:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowPvP = checked
        nPlates:UpdateAllNameplates()
    end)

	local ColoringOptions = Options:CreateFontString("ColoringOptions", "ARTWORK", "GameFontNormalLarge")
    ColoringOptions:SetPoint("TOPLEFT", ShowPvP, "BOTTOMLEFT", 0, -18) -- -24
    ColoringOptions:SetText(L.ColoringOptionsLabel)

	local ShowFriendlyClassColors = nPlates:CreateCheckBox("ShowFriendlyClassColors", LeftSide, L.FriendlyClassColors, nil, ColoringOptions, 0, -12, false)
    ShowFriendlyClassColors:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowFriendlyClassColors = checked
        nPlates:UpdateAllNameplates()
    end)

	local ShowEnemyClassColors = nPlates:CreateCheckBox("ShowEnemyClassColors", LeftSide, L.EnemyClassColors, nil, ShowFriendlyClassColors, 0, -6, false)
    ShowEnemyClassColors:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowEnemyClassColors = checked
		nPlates:UpdateAllNameplates()
    end)

	local WhiteSelectionColor = nPlates:CreateCheckBox("WhiteSelectionColor", LeftSide, L.WhiteSelectionColor, nil, ShowEnemyClassColors, 0, -6, false)
    WhiteSelectionColor:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.WhiteSelectionColor = checked
		nPlates:UpdateAllNameplates()
    end)

	local RaidMarkerColoring = nPlates:CreateCheckBox("RaidMarkerColoring", LeftSide, L.RaidMarkerColoring, nil, WhiteSelectionColor, 0, -6, false)
    RaidMarkerColoring:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.RaidMarkerColoring = checked
        nPlates:UpdateAllNameplates()
    end)

	local FelExplosivesColor = nPlates:CreateCheckBox("FelExplosivesColor", LeftSide, L.FelExplosivesColor, nil, RaidMarkerColoring, 0, -6, false)
    FelExplosivesColor:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.FelExplosives = checked
        nPlates:UpdateAllNameplates()
    end)

	local FelExplosivesColorPicker = nPlates:CreateColorPicker("FelExplosivesColorPicker", LeftSide, FelExplosivesColorText, 10, 0, nPlatesDB.FelExplosivesColor)

	local ShowExecuteRange = nPlates:CreateCheckBox("ShowExecuteRange", LeftSide, L.ExecuteRange, nil, FelExplosivesColor, 0, -6, false)
    ShowExecuteRange:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ShowExecuteRange = checked
        nPlates:UpdateAllNameplates()
    end)

	local ExecuteColorPicker = nPlates:CreateColorPicker("ExecuteColorPicker", LeftSide, ShowExecuteRangeText, 10, 0, nPlatesDB.ExecuteColor)

	local currentExecutePercent = floor(nPlatesDB.ExecuteValue) or 35
	local ExecuteSlider = nPlates:CreateSlider("ExecuteSlider", LeftSide, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, ShowExecuteRange, 10, -18, nil, nPlatesDB.ExecuteValue, PERCENTAGE_STRING, currentExecutePercent, 0, 35, 1, false)
    ExecuteSlider:SetScript("OnValueChanged", function(self, value)
		value = floor(value)
        executeSlider.text:SetFormattedText(PERCENTAGE_STRING, value)
		nPlatesDB.ExecuteValue = value
		nPlates:UpdateAllNameplates()
    end)
    ExecuteSlider:SetScript("OnUpdate", function(self)
        if ( nPlatesDB.ShowExecuteRange ) then
            ExecuteSlider:Enable()
        else
            ExecuteSlider:Disable()
        end
    end)

    -- Right Side --

    local FrameOptions = Options:CreateFontString("NameOptions", "ARTWORK", "GameFontNormalLarge")
    FrameOptions:SetPoint("TOPLEFT", RightSide, 16, -16)
    FrameOptions:SetText(L.FrameOptionsLabel)

	HealthOptions = {
		{ text = L.HealthDisabled, },
		{ text = L.HealthBoth, },
		{ text = L.HealthValeuOnly, },
		{ text = L.HealthPercOnly, }
	}

	local HealthText = CreateFrame("Button", "HealthTextTitle", RightSide , "UIDropDownMenuTemplate")
    HealthText:SetPoint("TOPLEFT", FrameOptions, "BOTTOMLEFT", 0, -18)
	HealthText:EnableMouse(true)

	local function HealthOption_OnClick(self)
		nPlatesDB.CurrentHealthOption = self.value
		UIDropDownMenu_SetText(HealthText, HealthOptions[self.value].text)
		nPlates:UpdateAllNameplates()
	end

	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()

		for i, filter in ipairs(HealthOptions) do
			info.text = filter.text
			info.value = i
			info.func = HealthOption_OnClick
			if ( info.value == nPlatesDB.CurrentHealthOption ) then
				info.checked = 1
				UIDropDownMenu_SetText(self, filter.text)
			else
				info.checked = nil
			end
			UIDropDownMenu_AddButton(info)
		end
	end

	UIDropDownMenu_SetWidth(HealthText, 180)
	UIDropDownMenu_Initialize(HealthText, Initialize)


	local HideFriendly = nPlates:CreateCheckBox("HideFriendly", RightSide, L.HideFriendly, nil, HealthText, 0, -6, false)
    HideFriendly:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.HideFriendly = checked
		nPlates:UpdateAllNameplates()
    end)

	local SmallStacking = nPlates:CreateCheckBox("SmallStacking", RightSide, L.SmallStacking, L.SmallStackingTooltip, HideFriendly, 0, -6, true)
    SmallStacking:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		nPlatesDB.SmallStacking = checked
		if ( checked ) then
			SetCVar("nameplateOverlapH", 1.1)
			SetCVar("nameplateOverlapV", 0.9)
		else
			for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do SetCVar(v, GetCVarDefault(v)) end
		end
    end)

	local CombatPlates = nPlates:CreateCheckBox("CombatPlates", RightSide, L.CombatPlates, L.CombatPlatesTooltip, SmallStacking, 0, -6, true)
    CombatPlates:SetScript("OnClick", function(self)
		local checked = not not self:GetChecked()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		nPlatesDB.CombatPlates = checked
		SetCVar("nameplateShowEnemies", not checked and 1 or 0)
		ReloadUI()
    end)

	local DontClamp = nPlates:CreateCheckBox("DontClamp", RightSide, L.StickyNameplates, nil, CombatPlates, 0, -6, true)
    DontClamp:SetScript("OnClick", function(self)
		local checked = not not self:GetChecked()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		nPlatesDB.DontClamp = checked
		if ( not checked ) then
			SetCVar("nameplateOtherTopInset", -1)
			SetCVar("nameplateOtherBottomInset", -1)
		else
			for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v)) end
		end
    end)

	local globalScale = floor(BlizzardOptionsPanel_GetCVarSafe("nameplateGlobalScale") * 100)
	local NameplateScale = nPlates:CreateSlider("NameplateScale", RightSide, L.NameplateScale, DontClamp, 10, -24, "nameplateGlobalScale", nil, PERCENTAGE_STRING, globalScale, .75, 1.5, 0.01, true)
    NameplateScale:SetScript("OnValueChanged", function(self, value)
		NameplateScale.text:SetFormattedText(PERCENTAGE_STRING, floor(value * 100))
        SetCVar("nameplateGlobalScale", value)
    end)

	local currentAlpha = floor(BlizzardOptionsPanel_GetCVarSafe("nameplateMinAlpha") * 100)
	local NameplateAlpha = nPlates:CreateSlider("NameplateAlpha", RightSide, L.NameplateAlpha, NameplateScale, 0, -24, "nameplateMinAlpha", nil, PERCENTAGE_STRING, currentAlpha, .50, 1.0, 0.01, true)
    NameplateAlpha:SetScript("OnValueChanged", function(self, value)
        NameplateAlpha.text:SetFormattedText(PERCENTAGE_STRING, floor(value * 100))
        SetCVar("nameplateMinAlpha", value)
    end)

	local currentRange = floor(BlizzardOptionsPanel_GetCVarSafe("nameplateMaxDistance"))
	local NameplateRange = nPlates:CreateSlider("NameplateRange", RightSide, L.NameplateRange, NameplateAlpha, 0, -24, "nameplateMaxDistance", nil, "%.0f", currentRange, 40, 60, 1, true)
    NameplateRange:SetScript("OnValueChanged", function(self, value)
		value = floor(value)
		NameplateRange.text:SetFormattedText("%.0f", value)
        SetCVar("nameplateMaxDistance", value)
    end)

	local TankOptions = Options:CreateFontString("TankOptions", "ARTWORK", "GameFontNormalLarge")
    TankOptions:SetPoint("TOPLEFT", NameplateRange, "BOTTOMLEFT", -10, -18)
    TankOptions:SetText(L.TankOptionsLabel)

	local TankMode = nPlates:CreateCheckBox("TankMode", RightSide, L.TankMode, nil, TankOptions, 0, -12, false)
    TankMode:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.TankMode = checked
        nPlates:UpdateAllNameplates()
    end)

	local ColorNameByThreat = nPlates:CreateCheckBox("ColorNameByThreat", RightSide, L.NameThreat, nil, TankMode, 0, -6, false)
    ColorNameByThreat:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.ColorNameByThreat = checked
        nPlates:UpdateAllNameplates()
    end)

	local UseOffTankColor = nPlates:CreateCheckBox("UseOffTankColor", RightSide, L.OffTankColor, nil, ColorNameByThreat, 0, -6, false)
    UseOffTankColor:SetScript("OnClick", function(self)
        local checked = not not self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        nPlatesDB.UseOffTankColor = checked
        nPlates:UpdateAllNameplates()
    end)

	local OffTankColorPicker = nPlates:CreateColorPicker("OffTankColor", RightSide, UseOffTankColorText, 10, 0, nPlatesDB.OffTankColor)

    local AddonTitle = Options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
    AddonTitle:SetPoint("BOTTOMRIGHT", -16, 16)
    AddonTitle:SetText(Options.name.." "..Options.version)

    function Options:Refresh()
        ShowLevel:SetChecked(nPlatesDB.ShowLevel)
        ShowServerName:SetChecked(nPlatesDB.ShowServerName)
        AbrrevLongNames:SetChecked(nPlatesDB.AbrrevLongNames)
        ShowPvP:SetChecked(nPlatesDB.ShowPvP)
        ShowFriendlyClassColors:SetChecked(nPlatesDB.ShowFriendlyClassColors)
        ShowEnemyClassColors:SetChecked(nPlatesDB.ShowEnemyClassColors)
        WhiteSelectionColor:SetChecked(nPlatesDB.WhiteSelectionColor)
		RaidMarkerColoring:SetChecked(nPlatesDB.RaidMarkerColoring)
		FelExplosivesColor:SetChecked(nPlatesDB.FelExplosives)
		ShowExecuteRange:SetChecked(nPlatesDB.ShowExecuteRange)
		HideFriendly:SetChecked(nPlatesDB.HideFriendly)
        SmallStacking:SetChecked(nPlatesDB.SmallStacking)
        CombatPlates:SetChecked(nPlatesDB.CombatPlates)
		DontClamp:SetChecked(nPlatesDB.DontClamp)
		TankMode:SetChecked(nPlatesDB.TankMode)
        ColorNameByThreat:SetChecked(nPlatesDB.ColorNameByThreat)
		UseOffTankColor:SetChecked(nPlatesDB.UseOffTankColor)
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
