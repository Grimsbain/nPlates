local addon, nPlates = ...
local L = nPlates.L

-- Default Options

nPlates.defaultOptions = {
    ["NameSize"] =  10,
    ["ShowLevel"] =  true,
    ["ShowServerName"] =  false,
    ["AbrrevLongNames"] =  true,
    ["ShowPvP"] =  false,
    ["ShowFriendlyClassColors"] =  true,
    ["ShowEnemyClassColors"] =  true,
    ["WhiteSelectionColor"] =  false,
    ["RaidMarkerColoring"] =  false,
    ["FelExplosives"] =  true,
    ["FelExplosivesColor"] =  { r = 197/255, g = 1, b = 0},
    ["ShowExecuteRange"] =  false,
    ["ExecuteValue"] =  35,
    ["ExecuteColor"] =  { r = 0, g = 71/255, b = 126/255},
    ["CurrentHealthOption"] =  2,
    ["HideFriendly"] =  false,
    ["SmallStacking"] =  false,
    ["DontClamp"] =  false,
    ["CombatPlates"] =  false,
    ["TankMode"] =  false,
    ["ColorNameByThreat"] =  false,
    ["UseOffTankColor"] =  false,
    ["OffTankColor"] =  { r = 0.60, g = 0.20, b = 1.0},
}


nPlatesConfigMixin = {}

function nPlatesConfigMixin:OnLoad()
    self:RegisterEvent("VARIABLES_LOADED")

    self.prevControl = nil
    self.controls = {}
    self.profileBackup = {}

    self.name = GetAddOnMetadata(addon, "Title")
    self.version = GetAddOnMetadata(addon, "Version")
    self.okay = self.SaveChanges
    self.cancel = self.CancelChanges
    self.default = self.RestoreDefaults
    self.refresh = self.UpdatePanel
    InterfaceOptions_AddCategory(self)
end

function nPlatesConfigMixin:OnEvent(event, ...)
    if ( event == "VARIABLES_LOADED") then
        self:Init()
        self:SaveProfileBackup()
        self:UnregisterEvent(event)
    end
end

function nPlatesConfigMixin:SaveProfileBackup()
    self.profileBackup = CopyTable(nPlatesDB)
end

function nPlatesConfigMixin:SaveChanges()
    for _, control in pairs(self.controls) do
        if ( self:ShouldUpdate(control) ) then
            self.profileBackup[control.optionName] = control:GetValue()
        end
    end
end

function nPlatesConfigMixin:ShouldUpdate(control)
    local oldValue = self.profileBackup[control.optionName]
    local value = control:GetValue()

    return oldValue ~= value
end

function nPlatesConfigMixin:CancelChanges()
    for _, control in pairs(self.controls) do
        if ( self:ShouldUpdate(control) ) then
            nPlatesDB[control.optionName] = self.profileBackup[control.optionName]
            control:Update()
        end
    end
end

function nPlatesConfigMixin:RestoreDefaults()
    for _, control in pairs(self.controls) do
        nPlatesDB[control.optionName] = nPlates.defaultOptions[control.optionName]
        control:Update()
    end
    ReloadUI()
end

function nPlatesConfigMixin:UpdatePanel()
    for _, control in pairs(self.controls) do
        if ( control.SetControl ) then
            control:SetControl()
        end
    end
end

function nPlatesConfigMixin:Init()

    local UIControls = {
        {
            type = "Label",
            name = "NameOptions",
            parent = self,
            text = L.NameOptionsLabel,
            relativeTo = self.LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
        {
            type = "Slider",
            name = "currentNameSize",
            parent = self,
            label = L.NameSizeLabel,
            optionName = "NameSize",
            fromatString = "%.0f",
            minValue = 8,
            maxValue = 35,
            step = 1,
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowLevel",
            parent = self,
            text = L.DisplayLevel,
            optionName = "ShowLevel",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowServerName",
            parent = self,
            text = L.DisplayServerName,
            optionName = "ShowServerName",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "AbrrevLongNames",
            parent = self,
            text = L.AbbrevName,
            optionName = "AbrrevLongNames",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowPvP",
            parent = self,
            text = L.ShowPvP,
            optionName = "ShowPvP",
            updateAll = true,
        },
        {
            type = "Label",
            name = "ColoringOptions",
            parent = self,
            text = L.ColoringOptionsLabel,
            offsetY = -18,
        },
        {
            type = "CheckBox",
            name = "ShowFriendlyClassColors",
            parent = self,
            text = L.FriendlyClassColors,
            optionName = "ShowFriendlyClassColors",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "ShowEnemyClassColors",
            parent = self,
            text = L.EnemyClassColors,
            optionName = "ShowEnemyClassColors",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "WhiteSelectionColor",
            parent = self,
            text = L.WhiteSelectionColor,
            optionName = "WhiteSelectionColor",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "RaidMarkerColoring",
            parent = self,
            text = L.RaidMarkerColoring,
            optionName = "RaidMarkerColoring",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "FelExplosives",
            parent = self,
            text = L.FelExplosivesColor,
            optionName = "FelExplosives",
            updateAll = true,
            colorPicker = {
                name = "FelExplosivesColorPicker",
                parent = self,
                optionName = "FelExplosivesColor",
            }
        },
        {
            type = "CheckBox",
            name = "ShowExecuteRange",
            parent = self,
            text = L.ExecuteRange,
            optionName = "ShowExecuteRange",
            updateAll = true,
            colorPicker = {
                name = "ExecuteColorPicker",
                parent = self,
                optionName = "ExecuteColor",
            }
        },
        {
            type = "Slider",
            name = "ExecuteSlider",
            parent = self,
            label = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            optionName = "ExecuteValue",
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
            parent = self,
            text = L.FrameOptionsLabel,
            relativeTo = self.RightSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
        {
            type = "Dropdown",
            name = "HealthText",
            parent = self,
            label = L.HealthOptions,
            optionName = "CurrentHealthOption",
            offsetX = -20,
            updateAll = true,
            optionsTable = {
                ["HealthBoth"] = L.HealthBoth,
                ["HealthDisabled"] = L.HealthDisabled,
                ["HealthPercOnly"] = L.HealthPercOnly,
                ["HealthValueOnly"] = L.HealthValueOnly,
                ["PercentHealth"] = L.PercentHealth,
            },
        },
        {
            type = "CheckBox",
            name = "SmallStacking",
            parent = self,
            text = L.SmallStacking,
            tooltipText = L.SmallStackingTooltip,
            optionName = "SmallStacking",
            disableInCombat = true,
            offsetX = 20,
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
            parent = self,
            text = L.CombatPlates,
            tooltipText = L.CombatPlatesTooltip,
            optionName = "CombatPlates",
            disableInCombat = true,
            func = function(self)
                C_CVar.SetCVar("nameplateShowEnemies", not self:GetChecked() and 1 or 0)
                ReloadUI()
            end
        },
        {
            type = "CheckBox",
            name = "DontClamp",
            parent = self,
            text = L.StickyNameplates,
            optionName = "DontClamp",
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
            parent = self,
            label = L.NameplateScale,
            disableInCombat = true,
            isCvar = true,
            multiplier = 100,
            optionName = "nameplateGlobalScale",
            fromatString = PERCENTAGE_STRING,
            minValue = .75,
            maxValue = 1.5,
            step = 0.01,
        },
        {
            type = "Slider",
            name = "NameplateAlpha",
            parent = self,
            label = L.NameplateAlpha,
            disableInCombat = true,
            isCvar = true,
            multiplier = 100,
            optionName = "nameplateMinAlpha",
            fromatString = PERCENTAGE_STRING,
            minValue = .50,
            maxValue = 1.0,
            step = 0.01,
        },
        {
            type = "Slider",
            name = "NameplateOccludedAlpha",
            parent = self,
            label = L.NameplateOccludedAlpha,
            disableInCombat = true,
            isCvar = true,
            multiplier = 100,
            optionName = "nameplateOccludedAlphaMult",
            fromatString = PERCENTAGE_STRING,
            minValue = 0,
            maxValue = 1.0,
            step = 0.01,
        },
        {
            type = "Label",
            name = "TankOptions",
            parent = self,
            text = L.TankOptionsLabel,
            offsetX = -10,
            offsetY = -16,
        },
        {
            type = "CheckBox",
            name = "TankMode",
            parent = self,
            text = L.TankMode,
            optionName = "TankMode",
            updateAll = true,
            offsetX = 10,
        },
        {
            type = "CheckBox",
            name = "ColorNameByThreat",
            parent = self,
            text = L.NameThreat,
            optionName = "ColorNameByThreat",
            updateAll = true,
        },
        {
            type = "CheckBox",
            name = "UseOffTankColor",
            parent = self,
            text = L.OffTankColor,
            optionName = "UseOffTankColor",
            updateAll = true,
            colorPicker = {
                name = "OffTankColorPicker",
                parent = self,
                optionName = "OffTankColor",
            }
        },
        {
            type = "Label",
            name = "AddonTitle",
            parent = self,
            text = self.name.." "..self.version,
            relativeTo = self.RightSide,
            initialPoint = "BOTTOMRIGHT",
            relativePoint = "BOTTOMRIGHT",
            offsetX = -16,
            offsetY = 16,
        },
    }

    for _, control in pairs(UIControls) do
        if ( control.type == "Label" ) then
            nPlates:CreateLabel(control)
        elseif ( control.type == "CheckBox" ) then
            nPlates:CreateCheckBox(control)
        elseif ( control.type == "Slider" ) then
            nPlates:CreateSlider(control)
        elseif ( control.type == "Dropdown" ) then
            nPlates:CreateDropdown(control)
        end
    end

    self:UpdatePanel()
end
