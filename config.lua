local addon, nPlates = ...
local L = nPlates.L

local Options = CreateFrame("Frame", "nPlatesOptions", InterfaceOptionsFramePanelContainer)
Options.name = GetAddOnMetadata(addon, "Title")
Options.version = GetAddOnMetadata(addon, "Version")
Options.default = function(self)
    for setting, value in pairs(nPlates.defaultOptions) do
        nPlatesDB[setting] = value
    end
    ReloadUI()
end
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

    local UIControls = {
        {
            type = "Label",
            name = "NameOptions",
            parent = Options,
            label = L.NameOptionsLabel,
            relativeTo = LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
        {
            type = "Slider",
            name = "currentNameSize",
            parent = Options,
            label = L.NameSizeLabel,
            var = "NameSize",
            fromatString = "%.0f",
            minValue = 8,
            maxValue = 35,
            step = 1,
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowLevel",
            parent = Options,
            label = L.DisplayLevel,
            var = "ShowLevel",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowServerName",
            parent = Options,
            label = L.DisplayServerName,
            var = "ShowServerName",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "AbrrevLongNames",
            parent = Options,
            label = L.AbbrevName,
            var = "AbrrevLongNames",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowPvP",
            parent = Options,
            label = L.ShowPvP,
            var = "ShowPvP",
            updateAll = true,
        },
        {
            type = "Label",
            name = "ColoringOptions",
            parent = Options,
            label = L.ColoringOptionsLabel,
            offsetY = -18,
        },
        {
            type = "CheckBox",
            name = "ShowFriendlyClassColors",
            parent = Options,
            label = L.FriendlyClassColors,
            var = "ShowFriendlyClassColors",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowEnemyClassColors",
            parent = Options,
            label = L.EnemyClassColors,
            var = "ShowEnemyClassColors",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "WhiteSelectionColor",
            parent = Options,
            label = L.WhiteSelectionColor,
            var = "WhiteSelectionColor",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "RaidMarkerColoring",
            parent = Options,
            label = L.RaidMarkerColoring,
            var = "RaidMarkerColoring",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "FelExplosives",
            parent = Options,
            label = L.FelExplosivesColor,
            var = "FelExplosives",
            updateAll = true,
            colorPicker = {
                name = "FelExplosivesColorPicker",
                parent = Options,
                var = "FelExplosivesColor",
            }
        },
        {
            type = "CheckBox",
            name = "ShowExecuteRange",
            parent = Options,
            label = L.ExecuteRange,
            var = "ShowExecuteRange",
            updateAll = true,
            colorPicker = {
                name = "ExecuteColorPicker",
                parent = Options,
                var = "ExecuteColor",
            }
        },
        {
            type = "Slider",
            name = "ExecuteSlider",
            parent = Options,
            label = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            var = "ExecuteValue",
            fromatString = PERCENTAGE_STRING,
            minValue = 0,
            maxValue = 35,
            step = 1,
            offsetX = 10,
            updateAll = true,
            onUpdate = function(self)
                if ( nPlatesDB.ShowExecuteRange ) then
                    self:Enable()
                else
                    self:Disable()
                end
            end
        },
        {
            type = "Label",
            name = "FrameOptions",
            parent = Options,
            label = L.FrameOptionsLabel,
            relativeTo = RightSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
        {
            type = "Dropdown",
            name = "HealthText",
            parent = Options,
            label = "",
            var = "CurrentHealthOption",
            updateAll = true,
            optionsTable = {
                ["HealthDisabled"] = L.HealthDisabled,
                ["HealthBoth"] = L.HealthBoth,
                ["HealthValueOnly"] = L.HealthValueOnly,
                ["HealthPercOnly"] = L.HealthPercOnly,
            },
        },
        {
            type = "CheckBox",
            name = "HideFriendly",
            parent = Options,
            label = L.HideFriendly,
            var = "HideFriendly",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "SmallStacking",
            parent = Options,
            label = L.SmallStacking,
            tooltip = L.SmallStackingTooltip,
            var = "SmallStacking",
            disableInCombat = true,
            func = function(self)
                if ( self:GetChecked() ) then
                    C_CVar.SetCVar("nameplateOverlapH", 0.8)
                    C_CVar.SetCVar("nameplateOverlapV", 0.8)
                else
                    for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do
                        C_CVar.SetCVar(v, GetCVarDefault(v))
                    end
                end
            end
        },
        {
            type = "CheckBox",
            name = "CombatPlates",
            parent = Options,
            label = L.CombatPlates,
            tooltip = L.CombatPlatesTooltip,
            var = "CombatPlates",
            disableInCombat = true,
            func = function(self)
                C_CVar.SetCVar("nameplateShowEnemies", not self:GetChecked() and 1 or 0)
                ReloadUI()
            end
        },
        {
            type = "CheckBox",
            name = "DontClamp",
            parent = Options,
            label = L.StickyNameplates,
            var = "DontClamp",
            disableInCombat = true,
            func = function(self)
                if ( not self:GetChecked() ) then
                    C_CVar.SetCVar("nameplateOtherTopInset", -1)
                    C_CVar.SetCVar("nameplateOtherBottomInset", -1)
                else
                    for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do
                        C_CVar.SetCVar(v, GetCVarDefault(v))
                    end
                end
            end
        },
        {
            type = "Slider",
            name = "NameplateScale",
            parent = Options,
            label = L.NameplateScale,
            disableInCombat = true,
            isCvar = true,
            multiplier = 100,
            var = "nameplateGlobalScale",
            fromatString = PERCENTAGE_STRING,
            minValue = .75,
            maxValue = 1.5,
            step = 0.01,
        },
        {
            type = "Slider",
            name = "NameplateAlpha",
            parent = Options,
            label = L.NameplateAlpha,
            disableInCombat = true,
            isCvar = true,
            multiplier = 100,
            var = "nameplateMinAlpha",
            fromatString = PERCENTAGE_STRING,
            minValue = .50,
            maxValue = 1.0,
            step = 0.01,
        },
        {
            type = "Slider",
            name = "NameplateRange",
            parent = Options,
            label = L.NameplateRange,
            disableInCombat = true,
            isCvar = true,
            var = "nameplateMaxDistance",
            fromatString = "%.0f",
            minValue = 40,
            maxValue = 60,
            step = 1,
        },
        {
            type = "Label",
            name = "TankOptions",
            parent = Options,
            label = L.TankOptionsLabel,
            offsetX = -10,
            offsetY = -16,
        },
        {
            type = "CheckBox",
            name = "TankMode",
            parent = Options,
            label = L.TankMode,
            var = "TankMode",
            updateAll = true,
            offsetX = 10,
        },
        {
            type = "CheckBox",
            name = "ColorNameByThreat",
            parent = Options,
            label = L.NameThreat,
            var = "ColorNameByThreat",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "UseOffTankColor",
            parent = Options,
            label = L.OffTankColor,
            var = "UseOffTankColor",
            updateAll = true,
            colorPicker = {
                name = "OffTankColorPicker",
                parent = Options,
                var = "OffTankColor",
            }
        },
        {
            type = "Label",
            name = "AddonTitle",
            parent = Options,
            label = Options.name.." "..Options.version,
            relativeTo = RightSide,
            initialPoint = "BOTTOMRIGHT",
            relativePoint = "BOTTOMRIGHT",
            offsetX = -16,
            offsetY = 16,
        },
    }

    for i, control in pairs(UIControls) do
        if control.type == "Label" then
            nPlates:CreateLabel(control)
        elseif control.type == "CheckBox" then
            nPlates:CreateCheckBox(control)
        elseif control.type == "Slider" then
            nPlates:CreateSlider(control)
        elseif control.type == "Dropdown" then
            nPlates:CreateDropdown(control)
        end
    end

    function Options:Refresh()
        for _, control in pairs(self.controls) do
            if control.SetControl then
                control:SetControl()
            end
        end
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
