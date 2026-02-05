local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit, isFullUpdate, updatedAuraInfos)
    if  not unit or unit ~= self.unit then
        return
    end

    local element = self.CCIcon
    element.data = {}

    --[[ Callback: CCIcon:PreUpdate()
    Called before the element has been updated.

    * self - the CCIcon element
    --]]
    if element.PreUpdate then
        element:PreUpdate()
    end

    if not element:IsVisible() then
        return
    end

    local foundCC = false

    for i = 1, 40 do
        element.data = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")

        if not element.data then
            break
        end

        local isCrowdControl = C_Spell.IsSpellCrowdControl(element.data.spellId)
        element:SetAlphaFromBoolean(isCrowdControl, 1, 0)

        if element:IsVisible() then
            local duration = C_UnitAuras.GetAuraDuration(unit, element.data.auraInstanceID)

            if duration then
                element.Cooldown:SetCooldownFromDurationObject(duration)
                element.Cooldown:Show()
            else
                element.Cooldown:Hide()
            end

            element.Icon:SetTexture(element.data.icon)
            element:Show()
            foundCC = true
            break
        end
    end

    if not foundCC then
        element:Hide()
    end

    if event == "PLAYER_ENTERING_WORLD" then
        CooldownFrame_Set(element.Cooldown, 1, 1, 1)
    end

    --[[ Callback: CCIcon:PostUpdate()
    Called after the element has been updated.

    * self - the CCIcon element
    --]]
    if element.PostUpdate then
        return element:PostUpdate()
    end
end

local function Path(self, ...)
    --[[ Override: CCIcon.Override(self, event, ...)
    Used to completely override the internal update function.

    * self  - the parent object
    * event - the event triggering the update (string)
    * ...   - the arguments accompanying the event
    --]]
    return (self.CCIcon.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    local element = self.CCIcon

    if ( element ) then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        self:RegisterEvent("UNIT_AURA", Path)
        self:RegisterEvent("PLAYER_ENTERING_WORLD", Path, true)

        if ( not element.Cooldown ) then
            element.Cooldown = CreateFrame("Cooldown", nil, element, "CooldownFrameTemplate")
            element.Cooldown:SetAllPoints(element)
            element.Cooldown:SetHideCountdownNumbers(false)
        end

        if ( not element.Icon ) then
            element.Icon = element:CreateTexture("$parentIcon", "BORDER")
            element.Icon:SetAllPoints(element)
            element.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            element.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
        end

        return true
    end
end

local function Disable(self)
    local element = self.CCIcon
    if ( element ) then
        self:UnregisterEvent("UNIT_AURA", Path)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
        element:Hide()
    end
end

oUF:AddElement("CCIcon", Path, Enable, Disable)
