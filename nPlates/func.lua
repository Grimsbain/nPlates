
local ADDON, nPlates = ...

local len = string.len
local gsub = string.gsub

    -- RBG to Hex Colors

nPlates.RGBHex = function(r, g, b)
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

nPlates.FormatValue = function(number)
    if number < 1e3 then
        return floor(number)
    elseif number >= 1e12 then
        return string.format("%.3ft", number/1e12)
    elseif number >= 1e9 then
        return string.format("%.3fb", number/1e9)
    elseif number >= 1e6 then
        return string.format("%.2fm", number/1e6)
    elseif number >= 1e3 then
        return string.format("%.1fk", number/1e3)
    end
end

    -- Format Time

nPlates.FormatTime = function(s)
    if s > 86400 then
        -- Days
        return ceil(s/86400) .. "d", s%86400
    elseif s >= 3600 then
        -- Hours
        return ceil(s/3600) .. "h", s%3600
    elseif s >= 60 then
        -- Minutes
        return ceil(s/60) .. "m", s%60
    elseif s <= 10 then
        -- Seconds
        return format("%.1f", s)
    end

    return floor(s), s - floor(s)
end

    -- Set Name Size

nPlates.NameSize = function(frame)
    if ( nPlatesDB.UseLargeNameFont or InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:GetValue() == "1" ) then
        frame.name:SetFontObject(SystemFont_LargeNamePlate)
    else
        frame.name:SetFontObject(SystemFont_NamePlate)
    end
end

    -- Check for "Larger Nameplates"

nPlates.IsUsingLargerNamePlateStyle = function()
    local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
    return namePlateVerticalScale > 1.0
end

    -- Check if the frame is a nameplate.

nPlates.FrameIsNameplate = function(frame)
    if ( string.match(frame.displayedUnit,"nameplate") ~= "nameplate") then
        return false
    else
        return true
    end
end

    -- Totem Data and Functions

local function TotemName(SpellID)
    local name = GetSpellInfo(SpellID)
    return name
end

local totemData = {
    [TotemName(192058)] = "Interface\\Icons\\spell_nature_brilliance",          -- Lightning Surge Totem
    [TotemName(98008)]  = "Interface\\Icons\\spell_shaman_spiritlink",          -- Spirit Link Totem
    [TotemName(192077)] = "Interface\\Icons\\ability_shaman_windwalktotem",     -- Wind Rush Totem
    [TotemName(204331)] = "Interface\\Icons\\spell_nature_wrathofair_totem",    -- Counterstrike Totem
    [TotemName(204332)] = "Interface\\Icons\\spell_nature_windfury",            -- Windfury Totem
    [TotemName(204336)] = "Interface\\Icons\\spell_nature_groundingtotem",      -- Grounding Totem
    -- Water
    [TotemName(157153)] = "Interface\\Icons\\ability_shaman_condensationtotem", -- Cloudburst Totem
    [TotemName(5394)]   = "Interface\\Icons\\INV_Spear_04",                     -- Healing Stream Totem
    [TotemName(108280)] = "Interface\\Icons\\ability_shaman_healingtide",       -- Healing Tide Totem
    -- Earth
    [TotemName(207399)] = "Interface\\Icons\\spell_nature_reincarnation",       -- Ancestral Protection Totem
    [TotemName(198838)] = "Interface\\Icons\\spell_nature_stoneskintotem",      -- Earthen Shield Totem
    [TotemName(51485)]  = "Interface\\Icons\\spell_nature_stranglevines",       -- Earthgrab Totem
    [TotemName(61882)]  = "Interface\\Icons\\spell_shaman_earthquake",          -- Earthquake Totem
    [TotemName(196932)] = "Interface\\Icons\\spell_totem_wardofdraining",       -- Voodoo Totem
    -- Fire
    [TotemName(192222)] = "Interface\\Icons\\spell_shaman_spewlava",            -- Liquid Magma Totem
    [TotemName(204330)] = "Interface\\Icons\\spell_fire_totemofwrath",          -- Skyfury Totem
    -- Totem Mastery
    [TotemName(202188)] = "Interface\\Icons\\spell_nature_stoneskintotem",      -- Resonance Totem
    [TotemName(210651)] = "Interface\\Icons\\spell_shaman_stormtotem",          -- Storm Totem
    [TotemName(210657)] = "Interface\\Icons\\spell_fire_searingtotem",          -- Ember Totem
    [TotemName(210660)] = "Interface\\Icons\\spell_nature_invisibilitytotem",   -- Tailwind Totem
}

nPlates.UpdateTotemIcon = function(frame)
    if ( not nPlates.FrameIsNameplate(frame) ) then return end

    local name = UnitName(frame.displayedUnit)

    if name == nil then return end
    if (totemData[name]) then
        if (not frame.TotemIcon) then
            frame.TotemIcon = CreateFrame("Frame", "$parentTotem", frame)
            frame.TotemIcon:EnableMouse(false)
            frame.TotemIcon:SetSize(24, 24)
            frame.TotemIcon:Hide()
            frame.TotemIcon:SetPoint("BOTTOM", frame.BuffFrame, "TOP", 0, 10)
            frame.TotemIcon:Show()
        end

        if (not frame.TotemIcon.Icon) then
            frame.TotemIcon.Icon = frame.TotemIcon:CreateTexture("$parentIcon","BACKGROUND")
            frame.TotemIcon.Icon:SetSize(24,24)
            frame.TotemIcon.Icon:Hide()
            frame.TotemIcon.Icon:SetAllPoints(frame.TotemIcon)
            frame.TotemIcon.Icon:SetTexture(totemData[name])
            frame.TotemIcon.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.TotemIcon.Icon:Show()
        end

        if (not frame.TotemIcon.Icon.Overlay) then
            frame.TotemIcon.Icon.Overlay = frame.TotemIcon:CreateTexture("$parentOverlay", "OVERLAY")
            frame.TotemIcon.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
            frame.TotemIcon.Icon.Overlay:Hide()
            frame.TotemIcon.Icon.Overlay:ClearAllPoints()
            frame.TotemIcon.Icon.Overlay:SetPoint("TOPRIGHT", frame.TotemIcon.Icon, 2.5, 2.5)
            frame.TotemIcon.Icon.Overlay:SetPoint("BOTTOMLEFT", frame.TotemIcon.Icon, -2.5, -2.5)
            frame.TotemIcon.Icon.Overlay:SetTexture(iconOverlay)
            frame.TotemIcon.Icon.Overlay:SetVertexColor(unpack(borderColor))
            frame.TotemIcon.Icon.Overlay:Show()
        end
    else
        if (frame.TotemIcon) then
            frame.TotemIcon:Hide()
        end
    end
end