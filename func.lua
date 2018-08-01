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

function nPlates:RegisterDefaultSetting(key, value)
    if ( nPlatesDB == nil ) then
        nPlatesDB = {}
    end
    if ( nPlatesDB[key] == nil ) then
        nPlatesDB[key] = value
    end
end

	-- Set Defaults

function nPlates:SetDefaultOptions()
	nPlates:RegisterDefaultSetting("NameSize", 10)
	nPlates:RegisterDefaultSetting("ShowLevel", true)
	nPlates:RegisterDefaultSetting("ShowServerName", false)
	nPlates:RegisterDefaultSetting("AbrrevLongNames", true)
	nPlates:RegisterDefaultSetting("ShowPvP", false)
	nPlates:RegisterDefaultSetting("ShowFriendlyClassColors", true)
	nPlates:RegisterDefaultSetting("ShowEnemyClassColors", true)
	nPlates:RegisterDefaultSetting("WhiteSelectionColor", false)
	nPlates:RegisterDefaultSetting("RaidMarkerColoring", false)
	nPlates:RegisterDefaultSetting("FelExplosives", true)
	nPlates:RegisterDefaultSetting("FelExplosivesColor", { r = 197/255, g = 1, b = 0})
	nPlates:RegisterDefaultSetting("ShowExecuteRange", false)
	nPlates:RegisterDefaultSetting("ExecuteValue", 35)
	nPlates:RegisterDefaultSetting("ExecuteColor", { r = 0, g = 71/255, b = 126/255})
	nPlates:RegisterDefaultSetting("CurrentHealthOption", 2)
	nPlates:RegisterDefaultSetting("HideFriendly", false)
	nPlates:RegisterDefaultSetting("SmallStacking", false)
	nPlates:RegisterDefaultSetting("DontClamp", false)
	nPlates:RegisterDefaultSetting("CombatPlates", false)
	nPlates:RegisterDefaultSetting("TankMode", false)
	nPlates:RegisterDefaultSetting("ColorNameByThreat", false)
	nPlates:RegisterDefaultSetting("UseOffTankColor", false)
	nPlates:RegisterDefaultSetting("OffTankColor", { r = 0.60, g = 0.20, b = 1.0})
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
			frame.beautyShadow[i] = frame:CreateTexture("$parentBeautyShadow"..i, 'BORDER')
			frame.beautyShadow[i]:SetParent(frame)
		elseif ( objectType == "Texture" ) then
			local frameParent = frame:GetParent()
			frame.beautyShadow[i] = frameParent:CreateTexture("$parentBeautyShadow"..i, 'BORDER')
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
			frame.beautyBorder[i] = frame:CreateTexture("$parentBeautyBorder"..i, 'OVERLAY')
			frame.beautyBorder[i]:SetParent(frame)
		elseif ( objectType == "Texture") then
			local frameParent = frame:GetParent()
			frame.beautyBorder[i] = frameParent:CreateTexture("$parentBeautyBorder"..i, 'OVERLAY')
			frame.beautyBorder[i]:SetParent(frameParent)
		end
		frame.beautyBorder[i]:SetTexture(nPlates.border)
		frame.beautyBorder[i]:SetSize(size, size)
		frame.beautyBorder[i]:SetVertexColor(nPlates.defaultBorderColor:GetRGB())
		frame.beautyBorder[i]:Hide()
	end

	frame.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
	frame.beautyBorder[1]:SetPoint('TOPLEFT', frame, -padding, padding)

	frame.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
	frame.beautyBorder[2]:SetPoint('TOPRIGHT', frame, padding, padding)

	frame.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
	frame.beautyBorder[3]:SetPoint('BOTTOMLEFT', frame, -padding, -padding)

	frame.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
	frame.beautyBorder[4]:SetPoint('BOTTOMRIGHT', frame, padding, -padding)

	frame.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
	frame.beautyBorder[5]:SetPoint('TOPLEFT', frame.beautyBorder[1], 'TOPRIGHT')
	frame.beautyBorder[5]:SetPoint('TOPRIGHT', frame.beautyBorder[2], 'TOPLEFT')

	frame.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
	frame.beautyBorder[6]:SetPoint('BOTTOMLEFT', frame.beautyBorder[3], 'BOTTOMRIGHT')
	frame.beautyBorder[6]:SetPoint('BOTTOMRIGHT', frame.beautyBorder[4], 'BOTTOMLEFT')

	frame.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
	frame.beautyBorder[7]:SetPoint('TOPLEFT', frame.beautyBorder[1], 'BOTTOMLEFT')
	frame.beautyBorder[7]:SetPoint('BOTTOMLEFT', frame.beautyBorder[3], 'TOPLEFT')

	frame.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
	frame.beautyBorder[8]:SetPoint('TOPRIGHT', frame.beautyBorder[2], 'BOTTOMRIGHT')
	frame.beautyBorder[8]:SetPoint('BOTTOMRIGHT', frame.beautyBorder[4], 'TOPRIGHT')

	frame.beautyShadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
	frame.beautyShadow[1]:SetPoint('TOPLEFT', frame, -padding-space, padding+space)

	frame.beautyShadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
	frame.beautyShadow[2]:SetPoint('TOPRIGHT', frame, padding+space, padding+space)

	frame.beautyShadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
	frame.beautyShadow[3]:SetPoint('BOTTOMLEFT', frame, -padding-space, -padding-space)

	frame.beautyShadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
	frame.beautyShadow[4]:SetPoint('BOTTOMRIGHT', frame, padding+space, -padding-space)

	frame.beautyShadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
	frame.beautyShadow[5]:SetPoint('TOPLEFT', frame.beautyShadow[1], 'TOPRIGHT')
	frame.beautyShadow[5]:SetPoint('TOPRIGHT', frame.beautyShadow[2], 'TOPLEFT')

	frame.beautyShadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
	frame.beautyShadow[6]:SetPoint('BOTTOMLEFT', frame.beautyShadow[3], 'BOTTOMRIGHT')
	frame.beautyShadow[6]:SetPoint('BOTTOMRIGHT', frame.beautyShadow[4], 'BOTTOMLEFT')

	frame.beautyShadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
	frame.beautyShadow[7]:SetPoint('TOPLEFT', frame.beautyShadow[1], 'BOTTOMLEFT')
	frame.beautyShadow[7]:SetPoint('BOTTOMLEFT', frame.beautyShadow[3], 'TOPLEFT')

	frame.beautyShadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
	frame.beautyShadow[8]:SetPoint('TOPRIGHT', frame.beautyShadow[2], 'BOTTOMRIGHT')
	frame.beautyShadow[8]:SetPoint('BOTTOMRIGHT', frame.beautyShadow[4], 'TOPRIGHT')


    for i = 1, 8 do
        frame.beautyBorder[i]:Show()
        frame.beautyShadow[i]:Show()
    end
end

	-- Config Functions

function nPlates:LockInCombat(frame)
    frame:SetScript("OnUpdate", function(self)
        if ( not InCombatLockdown() ) then
            self:Enable()
        else
            self:Disable()
        end
    end)
end

function nPlates:CreateCheckBox(name, parent, label, tooltip, relativeTo, x, y, disableInCombat)
	local checkBox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y)
    checkBox.Text:SetText(label)

	if ( tooltip ) then
		checkBox.tooltipText = tooltip
	end

	if ( disableInCombat ) then
		nPlates:LockInCombat(checkBox)
	end

	return checkBox
end

function nPlates:CreateSlider(name, parent, label, relativeTo, x, y, cvar, nDB, fromatString, defaultValue, minValue, maxValue, step, disableInCombat)
	local value
	if ( cvar ) then
		value = BlizzardOptionsPanel_GetCVarSafe(cvar)
	else
		value = nDB
	end

    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetWidth(180)
    slider:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y)
    slider.textLow = _G[name.."Low"]
    slider.textHigh = _G[name.."High"]
    slider.text = _G[name.."Text"]

	slider:SetMinMaxValues(minValue, maxValue)
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
	slider:SetValue(value)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

	slider.text:SetFormattedText(fromatString, defaultValue)
	slider.text:ClearAllPoints()
	slider.text:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT")

	slider.textHigh:Hide()

	slider.textLow:ClearAllPoints()
	slider.textLow:SetPoint("BOTTOMLEFT", slider, "TOPLEFT")
	slider.textLow:SetPoint("BOTTOMRIGHT", slider.text, "BOTTOMLEFT", -4, 0)
	slider.textLow:SetText(label)
	slider.textLow:SetJustifyH("LEFT")

	if ( disableInCombat ) then
		nPlates:LockInCombat(slider)
	end

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

function nPlates:CreateColorPicker(name, parent, relativeTo, x, y, nDB)
    local colorPicker = CreateFrame("Frame", name, parent)
    colorPicker:SetSize(15, 15)
    colorPicker:SetPoint("LEFT", relativeTo, "RIGHT", x, y)
    colorPicker.bg = colorPicker:CreateTexture(nil, "BACKGROUND", nil, -7)
    colorPicker.bg:SetAllPoints(colorPicker)
    colorPicker.bg:SetColorTexture(1, 1, 1, 1)
    colorPicker.bg:SetVertexColor(nDB.r, nDB.g, nDB.b)
    colorPicker.recolor = function(color)
        local r, g, b
        if ( color ) then
            r, g, b = unpack(color)
        else
            r, g, b = ColorPickerFrame:GetColorRGB()
        end
        nDB.r = r
        nDB.g = g
        nDB.b = b
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

-- HonorFrame Taint Workaround
-- Credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint

if ( UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0 ) < 2 then
	UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i=1, UIDROPDOWNMENU_MAXLEVELS do
			for j=1, UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G["DropDownList" .. i .. "Button" .. j]
				if ( not (issecurevariable(b, "value") or b:IsShown()) ) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1
					until issecurevariable(b, "value")
				end
			end
		end
	end)
end