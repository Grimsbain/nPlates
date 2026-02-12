local _, ns = ...
local oUF = ns.oUF

local function UpdateTooltip(self)
	if ( nPlatesTooltip:IsForbidden() ) then return end

    -- print(self:GetParent():GetDebugName())
	nPlatesTooltip:SetUnitAuraByAuraInstanceID(self.__owner.unit, self.auraInstanceID)
end

local function onEnter(self)
	if( nPlatesTooltip:IsForbidden() or not self:IsVisible() ) then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	nPlatesTooltip:SetOwner(self, "ANCHOR_CURSOR")
    self:UpdateTooltip()
    end

local function onLeave()
	if ( nPlatesTooltip:IsForbidden() ) then return end

	nPlatesTooltip:Hide()
end

local function Update(self, event, unit, isFullUpdate, updatedAuraInfos)
    if ( not unit or unit ~= self.unit ) then return end

    local element = self.CCIcon
    element.data = {}

    --[[ Callback: CCIcon:PreUpdate()
    Called before the element has been updated.

    * self - the CCIcon element
    --]]
    if element.PreUpdate then
        element:PreUpdate()
    end

    local foundCC = false

    for _, auraData in ipairs(C_UnitAuras.GetUnitAuras(unit, "HARMFUL|CROWD_CONTROL", 1, Enum.UnitAuraSortRule.ExpirationOnly, Enum.UnitAuraSortDirection.Reverse)) do
        local duration = C_UnitAuras.GetAuraDuration(unit, auraData.auraInstanceID)

            if duration then
                element.Cooldown:SetCooldownFromDurationObject(duration)
                element.Cooldown:Show()
            else
                element.Cooldown:Hide()
            end

        element.Icon:SetTexture(auraData.icon)
        element.auraInstanceID = auraData.auraInstanceID
            element:Show()
            foundCC = true
            break
        end

    if ( not foundCC ) then
        element:Hide()
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
        element.UpdateTooltip = UpdateTooltip
        element:SetScript("OnEnter", onEnter)
        element:SetScript("OnLeave", onLeave)

        self:RegisterEvent("UNIT_AURA", Path)

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
        element:Hide()
    end
end

oUF:AddElement("CCIcon", Path, Enable, Disable)
