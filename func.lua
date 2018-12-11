local addon, nPlates = ...
local L = nPlates.L

local len = string.len
local gsub = string.gsub
local match = string.match
local lower = string.lower
local format = string.format
local floor = math.floor
local ceil = math.ceil

local texturePath = "Interface\\AddOns\\nPlates\\media\\"

local pvpIcons = {
    ["Alliance"] = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
    ["Horde"] = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t",
}

nPlates.statusBar = texturePath.."UI-StatusBar"
nPlates.border = texturePath.."borderTexture"
nPlates.shadow = texturePath.."textureShadow"
nPlates.defaultBorderColor = CreateColor(0.40, 0.40, 0.40, 1)
nPlates.interruptibleColor = CreateColor(0.0, 0.75, 0.0, 1)
nPlates.nonInterruptibleColor = CreateColor(0.75, 0.0, 0.0, 1)

nPlates.markerColors = {
    ["1"] = { r = 1.0, g = 1.0, b = 0.0 },
    ["2"] = { r = 1.0, g = 127/255, b = 63/255 },
    ["3"] = { r = 163/255, g = 53/255, b = 238/255 },
    ["4"] = { r = 30/255, g = 1.0, b = 0.0 },
    ["5"] = { r = 170/255, g = 170/255, b = 221/255 },
    ["6"] = { r = 0.0, g = 112/255, b = 221/255 },
    ["7"] = { r = 1.0, g = 32/255, b = 32/255 },
    ["8"] = { r = 1.0, g = 1.0, b = 1.0 },
}

    -- RBG to Hex Colors

function nPlates:RGBHex(r, g, b)
    if ( type(r) == "table" ) then
        if ( r.r ) then
            r, g, b = r.r, r.g, r.b
        else
            r, g, b = unpack(r)
        end
    end

    return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

    -- Format Health

function nPlates:FormatValue(number)
    if ( number < 1e3 ) then
        return floor(number)
    elseif ( number >= 1e12 ) then
        return format("%.3ft", number/1e12)
    elseif ( number >= 1e9 ) then
        return format("%.3fb", number/1e9)
    elseif ( number >= 1e6 ) then
        return format("%.2fm", number/1e6)
    elseif ( number >= 1e3 ) then
        return format("%.1fk", number/1e3)
    end
end

    -- Format Time

function nPlates:FormatTime(seconds)
    if ( seconds > 86400 ) then
        -- Days
        return ceil(seconds/86400) .. "d", seconds%86400
    elseif ( seconds >= 3600 ) then
        -- Hours
        return ceil(seconds/3600) .. "h", seconds%3600
    elseif ( seconds >= 60 ) then
        -- Minutes
        return ceil(seconds/60) .. "m", seconds%60
    elseif ( seconds <= 10 ) then
        -- Seconds
        return format("%.1f", seconds)
    end

    return floor(seconds), seconds - floor(seconds)
end

    -- Set Defaults

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

function nPlates:RegisterDefaultSetting(key, value)
    if ( nPlatesDB == nil ) then
        nPlatesDB = {}
    end
    if ( nPlatesDB[key] == nil ) then
        nPlatesDB[key] = value
    end
end

function nPlates:SetDefaultOptions()
    for setting, value in pairs(nPlates.defaultOptions) do
        nPlates:RegisterDefaultSetting(setting, value)
    end
end

    -- Set Cvars

function nPlates:CVarCheck()
    if ( not nPlates:IsTaintable() ) then
        -- Combat Plates
        if ( nPlatesDB.CombatPlates ) then
            SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)
        else
            SetCVar("nameplateShowEnemies", 1)
        end

        -- Set min and max scale.
        SetCVar("namePlateMinScale", 1)
        SetCVar("namePlateMaxScale", 1)

        -- Set sticky nameplates.
        if ( not nPlatesDB.DontClamp ) then
            SetCVar("nameplateOtherTopInset", -1, true)
            SetCVar("nameplateOtherBottomInset", -1, true)
        else
            for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do
                SetCVar(v, GetCVarDefault(v), true)
            end
        end

        -- Set small stacking nameplates.
        if ( nPlatesDB.SmallStacking ) then
            SetCVar("nameplateOverlapH", 1.1) SetCVar("nameplateOverlapV", 0.9)
        else
            for _, v in pairs({"nameplateOverlapH", "nameplateOverlapV"}) do
                SetCVar(v, GetCVarDefault(v), true)
            end
        end
    end
end

    -- Force Nameplate Update

function nPlates:UpdateAllNameplates()
    for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end

    -- Check if the frame is a nameplate.

function nPlates:FrameIsNameplate(unit)
    if ( type(unit) ~= "string" ) then
        return false
    end

    unit = lower(unit)

    return match(unit, "nameplate") == "nameplate"
end

    -- Check for Combat

function nPlates:IsTaintable()
    return (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet")))
end

    -- Set Name Size

function nPlates:UpdateNameSize(frame)
    if ( not frame ) then
        return
    end
    local size = nPlatesDB.NameSize or 10
    frame.name:SetFontObject("nPlate_NameFont"..size)
    frame.name:SetShadowOffset(0.5, -0.5)
end

    -- Abbreviate Long Strings

function nPlates:Abbrev(str, length)
    if ( not str ) then
        return UNKNOWN
    end

    length = length or 20

    str = (len(str) > length) and gsub(str, "%s?(.[\128-\191]*)%S+%s", "%1. ") or str
    return str
end

    -- PvP Icon

function nPlates:PvPIcon(unit)
    if ( not nPlatesDB.ShowPvP or not UnitIsPlayer(unit) ) then
        return ""
    end

    local faction = UnitFactionGroup(unit)
    local icon = (UnitIsPVP(unit) and faction) and pvpIcons[faction] or ""

    return icon
end

    -- Raid Marker Coloring Update

function nPlates:UpdateRaidMarkerColoring()
    if ( not nPlatesDB.RaidMarkerColoring ) then return end

    for i, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
    end
end

    -- Check if class colors should be used.

function nPlates:UseClassColors(playerFaction, unit)
    local targetFaction, _ = UnitFactionGroup(unit)
    return ( playerFaction == targetFaction and nPlatesDB.ShowFriendlyClassColors) or ( playerFaction ~= targetFaction and nPlatesDB.ShowEnemyClassColors )
end

    -- Check for "Larger Nameplates"

function nPlates:IsUsingLargerNamePlateStyle()
    local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
    return namePlateVerticalScale > 1.0
end

    -- Check for threat.

function nPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

    -- Checks to see if unit has tank role.

local function PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

    -- Off Tank Color Checks

function nPlates:UseOffTankColor(unit)
    if ( nPlatesDB.UseOffTankColor and ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) ) then
        if ( not UnitIsUnit("player", unit) and PlayerIsTank("player") and PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

    -- Execute Range Check

function nPlates:IsInExecuteRange(unit)
    if ( not unit or not UnitCanAttack("player", unit) ) then
        return
    end

    local executeValue = nPlatesDB.ExecuteValue or 35
    local perc = floor(100*(UnitHealth(unit)/UnitHealthMax(unit)))

    return perc < executeValue
end

    -- Fel Explosive Check

local moblist = {
    [L.FelExplosivesMobName] = true,
    -- ["Training Dummy"] = true,
}

function nPlates:IsPriority(unit)
    if ( not unit or UnitIsPlayer(unit) or not UnitCanAttack("player", unit) ) then
        return false
    end

    return moblist[UnitName(unit)] == true
end

    -- Set Castbar Border Colors

function nPlates:SetCastbarBorderColor(frame, color)
    if ( not frame ) then
        return
    end

    if ( frame.castBar.beautyBorder ) then
        for i, texture in ipairs(frame.castBar.beautyBorder) do
            texture:SetVertexColor(color:GetRGB())
        end
     end
    if ( frame.castBar.Icon.beautyBorder ) then
        for i, texture in ipairs(frame.castBar.Icon.beautyBorder) do
            texture:SetVertexColor(color:GetRGB())
        end
     end
end

    -- Set Healthbar Border Color

function nPlates:SetHealthBorderColor(frame, r, g, b)
    if ( not frame ) then
        return
    end

    if ( frame.healthBar.beautyBorder ) then
        for i, texture in ipairs(frame.healthBar.beautyBorder) do
            if ( UnitIsUnit(frame.displayedUnit, "target") ) then
                if ( nPlatesDB.WhiteSelectionColor ) then
                    texture:SetVertexColor(1, 1, 1, 1)
                else
                    texture:SetVertexColor(r, g, b, 1)
                end
            else
                texture:SetVertexColor(nPlates.defaultBorderColor:GetRGB())
            end
        end
    end
end

    -- Update BuffFrame Anchors

function nPlates:UpdateAllBuffFrameAnchors()
    for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not frame.UnitFrame:IsForbidden() ) then
            local BuffFrame = frame.UnitFrame.BuffFrame

            if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
                BuffFrame.baseYOffset = frame.UnitFrame.name:GetHeight()+1
            elseif ( frame.UnitFrame.displayedUnit ) then
                BuffFrame.baseYOffset = 0
            end

            BuffFrame:UpdateAnchor()
        end
    end
end

function nPlates:UpdateBuffFrameAnchorsByUnit(unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if ( not frame ) then return end

    local BuffFrame = frame.UnitFrame.BuffFrame

    if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
        BuffFrame.baseYOffset = frame.UnitFrame.name:GetHeight()+1
    elseif ( frame.UnitFrame.displayedUnit ) then
        BuffFrame.baseYOffset = 0
    end

    BuffFrame:UpdateAnchor()
end

    -- Setup Healthbar Value Texture

function nPlates:AddHealthbarText(frame)
    if ( frame ) then
        local HealthBar = frame.UnitFrame.healthBar
        if ( not HealthBar.value ) then
            HealthBar.value = HealthBar:CreateFontString("$parentHeathValue", "OVERLAY")
            HealthBar.value:Hide()
            HealthBar.value:SetPoint("CENTER", HealthBar)
            HealthBar.value:SetFontObject("nPlate_NameFont10")
        end
    end
end

    -- Fixes the border when using the Personal Resource Display.

function nPlates:FixPlayerBorder(unit)
    local showSelf = GetCVar("nameplateShowSelf")
    if ( showSelf == "0" ) then
        return
    end

    if ( not UnitIsUnit(unit, "player") ) then return; end

    local frame = C_NamePlate.GetNamePlateForUnit("player", issecure())
    if ( frame ) then
        local HealthBar = frame.UnitFrame.healthBar

        if ( HealthBar.beautyBorder and HealthBar.beautyShadow ) then
            for i = 1, 8 do
                HealthBar.beautyBorder[i]:Hide()
                HealthBar.beautyShadow[i]:Hide()
            end
            HealthBar.border:Show()
            HealthBar.beautyBorder = nil
            HealthBar.beautyShadow = nil
        end
    end
end

    -- Set Border

function nPlates:SetBorder(frame)
    if ( frame.beautyBorder ) then
        return
    end

    local objectType = frame:GetObjectType()
    local padding = 2
    local size = 8
    local space = size/3.5

    frame.beautyShadow = {}
    for i = 1, 8 do
        if ( objectType == "Frame" or objectType == "StatusBar" ) then
            frame.beautyShadow[i] = frame:CreateTexture("$parentBeautyShadow"..i, "BORDER")
            frame.beautyShadow[i]:SetParent(frame)
        elseif ( objectType == "Texture" ) then
            local frameParent = frame:GetParent()
            frame.beautyShadow[i] = frameParent:CreateTexture("$parentBeautyShadow"..i, "BORDER")
            frame.beautyShadow[i]:SetParent(frameParent)
        end
        frame.beautyShadow[i]:SetTexture(nPlates.shadow)
        frame.beautyShadow[i]:SetSize(size, size)
        frame.beautyShadow[i]:SetVertexColor(0, 0, 0, 1)
        frame.beautyShadow[i]:Hide()
    end

    frame.beautyBorder = {}
    for i = 1, 8 do
        if ( objectType == "Frame" or objectType == "StatusBar" ) then
            frame.beautyBorder[i] = frame:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
            frame.beautyBorder[i]:SetParent(frame)
        elseif ( objectType == "Texture") then
            local frameParent = frame:GetParent()
            frame.beautyBorder[i] = frameParent:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
            frame.beautyBorder[i]:SetParent(frameParent)
        end
        frame.beautyBorder[i]:SetTexture(nPlates.border)
        frame.beautyBorder[i]:SetSize(size, size)
        frame.beautyBorder[i]:SetVertexColor(nPlates.defaultBorderColor:GetRGB())
        frame.beautyBorder[i]:Hide()
    end

    frame.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyBorder[1]:SetPoint("TOPLEFT", frame, -padding, padding)

    frame.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyBorder[2]:SetPoint("TOPRIGHT", frame, padding, padding)

    frame.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyBorder[3]:SetPoint("BOTTOMLEFT", frame, -padding, -padding)

    frame.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyBorder[4]:SetPoint("BOTTOMRIGHT", frame, padding, -padding)

    frame.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyBorder[5]:SetPoint("TOPLEFT", frame.beautyBorder[1], "TOPRIGHT")
    frame.beautyBorder[5]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "TOPLEFT")

    frame.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyBorder[6]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "BOTTOMRIGHT")
    frame.beautyBorder[6]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "BOTTOMLEFT")

    frame.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyBorder[7]:SetPoint("TOPLEFT", frame.beautyBorder[1], "BOTTOMLEFT")
    frame.beautyBorder[7]:SetPoint("BOTTOMLEFT", frame.beautyBorder[3], "TOPLEFT")

    frame.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyBorder[8]:SetPoint("TOPRIGHT", frame.beautyBorder[2], "BOTTOMRIGHT")
    frame.beautyBorder[8]:SetPoint("BOTTOMRIGHT", frame.beautyBorder[4], "TOPRIGHT")

    frame.beautyShadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.beautyShadow[1]:SetPoint("TOPLEFT", frame, -padding-space, padding+space)

    frame.beautyShadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.beautyShadow[2]:SetPoint("TOPRIGHT", frame, padding+space, padding+space)

    frame.beautyShadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.beautyShadow[3]:SetPoint("BOTTOMLEFT", frame, -padding-space, -padding-space)

    frame.beautyShadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.beautyShadow[4]:SetPoint("BOTTOMRIGHT", frame, padding+space, -padding-space)

    frame.beautyShadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.beautyShadow[5]:SetPoint("TOPLEFT", frame.beautyShadow[1], "TOPRIGHT")
    frame.beautyShadow[5]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "TOPLEFT")

    frame.beautyShadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.beautyShadow[6]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "BOTTOMRIGHT")
    frame.beautyShadow[6]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "BOTTOMLEFT")

    frame.beautyShadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.beautyShadow[7]:SetPoint("TOPLEFT", frame.beautyShadow[1], "BOTTOMLEFT")
    frame.beautyShadow[7]:SetPoint("BOTTOMLEFT", frame.beautyShadow[3], "TOPLEFT")

    frame.beautyShadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.beautyShadow[8]:SetPoint("TOPRIGHT", frame.beautyShadow[2], "BOTTOMRIGHT")
    frame.beautyShadow[8]:SetPoint("BOTTOMRIGHT", frame.beautyShadow[4], "TOPRIGHT")


    for i = 1, 8 do
        frame.beautyBorder[i]:Show()
        frame.beautyShadow[i]:Show()
    end
end

    -- Config Functions

local prevControl

function nPlates:pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function ()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end


function nPlates:LockInCombat(frame)
    frame:SetScript("OnUpdate", function(self)
        if ( not InCombatLockdown() ) then
            self:Enable()
        else
            self:Disable()
        end
    end)
end

function nPlates:RegisterControl(control, parentFrame)
    if ( ( not parentFrame ) or ( not control ) ) then
        return;
    end

    parentFrame.controls = parentFrame.controls or {}

    tinsert(parentFrame.controls, control);
end

function nPlates:CreateLabel(cfg)
    --[[
        {
            type = "Label",
            name = "LabelName",
            parent = Options,
            label = L.LabelText,
            fontObject = "GameFontNormalLarge",
            relativeTo = LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
    --]]
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -16
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.fontObject = cfg.fontObject or "GameFontNormalLarge"

    local label = cfg.parent:CreateFontString(cfg.name, "ARTWORK", cfg.fontObject)
    label:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    label:SetText(cfg.label)

    prevControl = label
    return label
end

function nPlates:CreateCheckBox(cfg)
    --[[
        {
            type = "CheckBox",
            name = "Test",
            parent = parent,
            label = L.TestLabel,
            tooltip = L.TestTooltip,
            isCvar = nil or True,
            var = "TestVar",
            needsRestart = nil or True,
            disableInCombat = nil or True,
            updateAll = nil or True,
            func = function(self)
                -- Do stuff here.
            end,
            colorPicker = {
                name = "ColorPicker",
                parent = Options,
                var = "TestVarColor",
            },
            initialPoint = "TOPLEFT",
            relativeTo = frame,
            relativePoint, "BOTTOMLEFT",
            offsetX = 0,
            offsetY = -6,
        },
    --]]
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl

    local checkBox = CreateFrame("CheckButton", cfg.name, cfg.parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    checkBox.Text:SetText(cfg.label)
    checkBox.GetValue = function(self) return checkBox:GetChecked() end
    checkBox.SetControl = function(self) checkBox:SetChecked(nPlatesDB[cfg.var]) end
    checkBox.var = cfg.var
    checkBox.isCvar = cfg.isCvar

    if cfg.tooltip then
        checkBox.tooltipText = cfg.tooltip
    end

    if cfg.disableInCombat then
        nPlates:LockInCombat(checkBox)
    end

    if cfg.colorPicker then
        nPlates:CreateColorPicker(cfg.colorPicker, checkBox.Text)
    end

    checkBox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        checkBox.value = checked
        nPlatesDB[cfg.var] = checked

        if cfg.func then
            cfg.func(self)
        end
        if cfg.updateAll then
            nPlates:UpdateAllNameplates()
        end
    end)

    nPlates:RegisterControl(checkBox, cfg.parent)
    prevControl = checkBox
    return checkBox
end

function nPlates:CreateSlider(cfg)
        --[[
        {
            type = "Slider",
            name = "Test",
            parent = parent,
            label = L.TestLabel,
            isCvar = True,
            var = "DBVariableGoesHere",
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
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -26
    cfg.relativeTo = cfg.relativeTo or prevControl

    local value
    if cfg.isCvar then
        value = BlizzardOptionsPanel_GetCVarSafe(cfg.var)
    else
        value = nPlatesDB[cfg.var]
    end

    local slider = CreateFrame("Slider", cfg.name, cfg.parent, "OptionsSliderTemplate")
    slider:SetWidth(180)
    slider:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    slider.GetValue = function(self) return slider.value end
    slider.SetControl = function(self) slider:SetValue(value) end
    slider.value = value
    slider.var = cfg.var
    slider.textLow = _G[cfg.name.."Low"]
    slider.textHigh = _G[cfg.name.."High"]
    slider.text = _G[cfg.name.."Text"]

    slider:SetMinMaxValues(cfg.minValue, cfg.maxValue)
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
    slider:SetValue(value)
    slider:SetValueStep(cfg.step)
    slider:SetObeyStepOnDrag(true)

    if cfg.multiplier then
        slider.text:SetFormattedText(cfg.fromatString, floor(value*cfg.multiplier))
    else
        slider.text:SetFormattedText(cfg.fromatString, value)
    end

    slider.text:ClearAllPoints()
    slider.text:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT")

    slider.textHigh:Hide()

    slider.textLow:ClearAllPoints()
    slider.textLow:SetPoint("BOTTOMLEFT", slider, "TOPLEFT")
    slider.textLow:SetPoint("BOTTOMRIGHT", slider.text, "BOTTOMLEFT", -4, 0)
    slider.textLow:SetText(cfg.label)
    slider.textLow:SetJustifyH("LEFT")

    if cfg.disableInCombat then
        nPlates:LockInCombat(slider)
    end

    slider:SetScript("OnValueChanged", function(self, value)
        slider.value = value

        if cfg.multiplier then
            slider.text:SetFormattedText(cfg.fromatString, floor(value*cfg.multiplier))
        else
            slider.text:SetFormattedText(cfg.fromatString, value)
        end

        if cfg.isCvar then
            SetCVar(cfg.var, value)
        else
            nPlatesDB[cfg.var] = value
        end

        if cfg.func then
            cfg.func(self)
        end

        if cfg.updateAll then
            nPlates:UpdateAllNameplates()
        end
    end)

    if cfg.OnUpdate then
        slider:SetScript("OnUpdate", function(self)
            cfg.OnUpdate(self)
        end)
    end

    nPlates:RegisterControl(slider, cfg.parent)
    prevControl = slider
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
    colorPicker.bg:SetVertexColor(nPlatesDB[cfg.var].r,nPlatesDB[cfg.var].g, nPlatesDB[cfg.var].b)
    colorPicker.recolor = function(color)
        local r, g, b
        if ( color ) then
            r, g, b = unpack(color)
        else
            r, g, b = ColorPickerFrame:GetColorRGB()
        end
        nPlatesDB[cfg.var].r = r
        nPlatesDB[cfg.var].g = g
        nPlatesDB[cfg.var].b = b
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
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -26
    cfg.relativeTo = cfg.relativeTo or prevControl
    --[[
        {
            type = "Dropdown",
            name = "TestDropdown",
            parent = Options,
            label = L.LocalizedName,
            var = "DBVariableGoesHere",
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

    local dropdown = CreateFrame("Button", cfg.name, cfg.parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    dropdown:EnableMouse(true)
    dropdown.GetValue = function(self) return UIDropDownMenu_GetSelectedValue(self) end
    dropdown.SetControl = function(self)
        self.value = nPlatesDB[cfg.var]
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        UIDropDownMenu_SetText(dropdown, cfg.optionsTable[self.value].text)
    end
    dropdown.var = cfg.var
    dropdown.value = nPlatesDB[cfg.var]

    dropdown.title = dropdown:CreateFontString("$parentTitle", "BACKGROUND", "GameFontNormalSmall")
    dropdown.title:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 5)
    dropdown.title:SetText(cfg.label)

    local function Dropdown_OnClick(self)
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        nPlatesDB[cfg.var] = cfg.optionsTable[self.value].value

        if cfg.func then
            cfg.func(dropdown)
        end

        if cfg.updateAll then
            nPlates:UpdateAllNameplates()
        end
    end

    local function Initialize(self, level)
        local selectedValue = UIDropDownMenu_GetSelectedValue(dropdown)
        local info = UIDropDownMenu_CreateInfo()

        for i, filter in ipairs(cfg.optionsTable) do
            info.text = filter.text
            info.value = i
            info.value2 = filter.value
            info.func = Dropdown_OnClick
            if info.value2 == selectedValue then
                info.checked = 1
                UIDropDownMenu_SetText(self, filter.text)
            else
                info.checked = nil
            end
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_SetWidth(dropdown, 180)
    UIDropDownMenu_SetSelectedValue(dropdown, nPlatesDB[cfg.var])
    UIDropDownMenu_SetText(dropdown, cfg.optionsTable[nPlatesDB[cfg.var]].text)
    UIDropDownMenu_Initialize(dropdown, Initialize)

    nPlates:RegisterControl(dropdown, cfg.parent)
    prevControl = dropdown
    return dropdown
end
