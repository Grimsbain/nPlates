--[[
# Element: BetterDebuffs

Handles creation and updating of aura buttons.

## Widget

Debuffs - A Frame to hold `Button`s representing debuffs.

## Notes

At least one of the above widgets must be present for the element to work.

## Options

.disableMouse             - Disables mouse events (boolean)
.disableCooldown          - Disables the cooldown spiral (boolean)
.size                     - Aura button size. Defaults to 16 (number)
.width                    - Aura button width. Takes priority over `size` (number)
.height                   - Aura button height. Takes priority over `size` (number)
.spacing                  - Spacing between each button. Defaults to 0 (number)
.spacingX                 - Horizontal spacing between each button. Takes priority over `spacing` (number)
.spacingY                 - Vertical spacing between each button. Takes priority over `spacing` (number)
.growthX                  - Horizontal growth direction. Defaults to "RIGHT" (string)
.growthY                  - Vertical growth direction. Defaults to "UP" (string)
.initialAnchor            - Anchor point for the aura buttons. Defaults to "BOTTOMLEFT" (string)
.filter                   - Custom filter list for auras to display. Defaults to "HELPFUL" for buffs and "HARMFUL" for
                            debuffs (string)
.tooltipAnchor            - Anchor point for the tooltip. Defaults to "ANCHOR_BOTTOMRIGHT", however, if a frame has
                            anchoring restrictions it will be set to "ANCHOR_CURSOR" (string)
.reanchorIfVisibleChanged - Reanchors aura buttons when the number of visible auras has changed (boolean)
.showType                 - Show Overlay texture colored by oUF.colors.dispel (boolean)
.minCount                 - Minimum number of aura applications for the Count text to be visible. Defaults to 2 (number)
.maxCount                 - Maximum number of aura applications for the Count text, anything above renders "*". Defaults to 999 (number)
.maxCols                  - Maximum number of aura button columns before wrapping to a new row. Defaults to element width divided by aura button size (number)
.numTotal                 - Number of debuffs to display. Defaults to 40 (number)

## Button Attributes

button.auraInstanceID - unique ID for the current aura being tracked by the button (number)

## Examples

    -- Position and size
    local Debuffs = CreateFrame("Frame", nil, self)
    Debuffs:SetPoint("RIGHT", self, "LEFT")
    Debuffs:SetSize(16 * 2, 16 * 16)

    -- Register with oUF
    self.BetterDebuffs = Debuffs
--]]

local _, ns = ...
local oUF = ns.oUF

local dispelColorCurve = C_CurveUtil.CreateColorCurve()
dispelColorCurve:SetType(Enum.LuaCurveType.Step)

for _, dispelIndex in next, oUF.Enum.DispelType do
    if ( oUF.colors.dispel[dispelIndex] ) then
        dispelColorCurve:AddPoint(dispelIndex, oUF.colors.dispel[dispelIndex])
    end
end

local function UpdateTooltip(self)
	if ( nPlatesTooltip:IsForbidden() ) then return end

	nPlatesTooltip:SetUnitAuraByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
end

local function onEnter(self)
	if( nPlatesTooltip:IsForbidden() or not self:IsVisible() ) then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	nPlatesTooltip:SetOwner(self, self:GetParent().__restricted and "ANCHOR_CURSOR" or self:GetParent().tooltipAnchor)
    self:UpdateTooltip()
end

local function onLeave()
	if ( nPlatesTooltip:IsForbidden() ) then return end

	nPlatesTooltip:Hide()
end

local function CreateButton(element, index)
    local name = string.format("%sButton%d", element:GetDebugName(), index)
	local button = CreateFrame("Button", name, element)

	local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cd:SetAllPoints()
	button.Cooldown = cd

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetAllPoints()
	button.Icon = icon

	local countFrame = CreateFrame("Frame", nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	count:SetPoint("BOTTOMRIGHT", countFrame, "BOTTOMRIGHT", -1, 0)
	button.Count = count

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
	overlay:SetAllPoints()
	overlay:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
	button.Overlay = overlay

	button.UpdateTooltip = UpdateTooltip
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)

	--[[ Callback: Auras:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if ( element.PostCreateButton ) then element:PostCreateButton(button) end

	return button
end

local function SetPosition(element, from, to)
	local width = element.width or element.size or 16
	local height = element.height or element.size or 16
	local sizeX = width + (element.spacingX or element.spacing or 0)
	local sizeY = height + (element.spacingY or element.spacing or 0)
	local anchor = element.initialAnchor or "BOTTOMLEFT"
	local growthX = (element.growthX == "LEFT" and -1) or 1
	local growthY = (element.growthY == "DOWN" and -1) or 1
	local cols = element.maxCols or math.floor(element:GetWidth() / sizeX + 0.5)

	for i = from, to do
		local button = element[i]
		if ( not button ) then break end

		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)

		button:ClearAllPoints()
		button:SetPoint(anchor, element, anchor, col * sizeX * growthX, row * sizeY * growthY)
	end
end

local function UpdateButton(element, unit, data, position)
	if ( not data ) then return end

	local button = element[position]
	if ( not button ) then
		--[[ Override: Auras:CreateButton(position)
		Used to create an aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		button = (element.CreateButton or CreateButton) (element, position)

		table.insert(element, button)
		element.createdButtons = element.createdButtons + 1
	end

	-- for tooltips
	button.auraInstanceID = data.auraInstanceID

	if ( button.Cooldown and not element.disableCooldown ) then
		local duration = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
		if duration then
			button.Cooldown:SetCooldownFromDurationObject(duration)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end
	end

	if ( button.Overlay ) then
		if ( element.showType ) then
			local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, dispelColorCurve)
            if color == nil then
                -- BUG: this shouldn't happen but color can be nil, so default to None color
                color = dispelColorCurve:Evaluate(0)
            end

			button.Overlay:SetVertexColor(color:GetRGBA())
			button.Overlay:Show()
		else
			button.Overlay:Hide()
		end
	end

	if ( button.Icon ) then button.Icon:SetTexture(data.icon) end

	if ( button.Count ) then
		button.Count:SetText(C_UnitAuras.GetAuraApplicationDisplayCount(unit, data.auraInstanceID, element.minCount or 2, element.maxCount or 999))
	end

	local width = element.width or element.size or 16
	local height = element.height or element.size or 16
	button:SetSize(width, height)
	button:EnableMouse(not element.disableMouse)
	button:Show()

	--[[ Callback: Auras:PostUpdateButton(unit, button, data, position)
	Called after the aura button has been updated.

	* self     - the widget holding the aura buttons
	* button   - the updated aura button (Button)
	* unit     - the unit for which the update has been triggered (string)
	* data     - the [AuraData](https://warcraft.wiki.gg/wiki/Struct_AuraData) object (table)
	* position - the actual position of the aura button (number)
	--]]
	if ( element.PostUpdateButton ) then
		element:PostUpdateButton(button, unit, data, position)
	end
end

local function AddAura(self, aura, checkFilters, filter)
    if ( checkFilters and C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, aura.auraInstanceID, filter) ) then
        return false
    end

    local element = self.BetterDebuffs
    element.debuffList[aura.auraInstanceID] = aura
    return true
end

local function UpdateAura(self, auraInstanceID)
    local element = self.BetterDebuffs
    if ( element.debuffList[auraInstanceID] ~= nil ) then
    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID)
        element.debuffList[auraInstanceID] = newAura
        return true
    end

    return false
end

local function RemoveAura(self, auraInstanceID)
    local element = self.BetterDebuffs

    if ( element.debuffList[auraInstanceID] ~= nil ) then
        element.debuffList[auraInstanceID] = nil
        return true
    end

    return false
end

local function UpdateAuras(self, event, unit, updateInfo)
	if ( self.unit ~= unit ) then return end

	local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

	local element = self.BetterDebuffs
	if ( element ) then
        isFullUpdate = element.needFullUpdate or isFullUpdate
		element.needFullUpdate = false

		if ( element.PreUpdate ) then element:PreUpdate(unit, isFullUpdate) end

		local aurasChanged = false
		local maxAuras = element.numTotal or 40
		local filter = element.filter or "PLAYER|HARMFUL|INCLUDE_NAME_PLATE_ONLY"
        local sortRule = element.sortRule or Enum.UnitAuraSortRule.Default
        local sortDirection = element.sortDirection or Enum.UnitAuraSortDirection.Normal

		if ( isFullUpdate ) then
			table.wipe(element.debuffList)
			aurasChanged = true

            for _, auraData in ipairs(C_UnitAuras.GetUnitAuras(unit, filter, maxAuras, sortRule, sortDirection)) do
                element.debuffList[auraData.auraInstanceID] = auraData
            end
		else
			if ( updateInfo.addedAuras ~= nil ) then
				for _, auraData in ipairs(updateInfo.addedAuras) do
                    aurasChanged = AddAura(self, auraData, true, filter) or aurasChanged
				end
			end

			if ( updateInfo.updatedAuraInstanceIDs ~= nil ) then
				for _, auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
                    aurasChanged = UpdateAura(self, auraInstanceID) or aurasChanged
				end
			end

			if ( updateInfo.removedAuraInstanceIDs ~= nil ) then
				for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                    aurasChanged = RemoveAura(self, auraInstanceID) or aurasChanged
				end
			end
		end

		if ( element.PostUpdateInfo ) then
			element:PostUpdateInfo(unit, aurasChanged)
		end

		if ( aurasChanged ) then
            local numVisible = 0

            for index, auraInstanceID in ipairs(C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, maxAuras, sortRule, sortDirection)) do
                UpdateButton(element, unit, element.debuffList[auraInstanceID], index)
                numVisible = index
            end

            numVisible = math.min(maxAuras, numVisible)

			local visibleChanged = false

			if ( numVisible ~= element.visibleButtons ) then
				element.visibleButtons = numVisible
				visibleChanged = element.reanchorIfVisibleChanged
			end

			for i = numVisible + 1, #element do
				element[i]:Hide()
			end

			if ( visibleChanged or element.createdButtons > element.anchoredButtons ) then
				if ( visibleChanged ) then
					(element.SetPosition or SetPosition) (element, 1, numVisible)
				else
					(element.SetPosition or SetPosition) (element, element.anchoredButtons + 1, element.createdButtons)
					element.anchoredButtons = element.createdButtons
				end
			end

			if ( element.PostUpdate ) then element:PostUpdate(unit) end
		end
	end
end

local function Update(self, event, unit, updateInfo)
	if ( self.unit ~= unit ) then return end

	UpdateAuras(self, event, unit, updateInfo)

	-- Assume no event means someone wants to re-anchor things. This is usually
	-- done by UpdateAllElements and :ForceUpdate.
	if ( event == "ForceUpdate" or not event ) then
		local element = self.BetterDebuffs
		if ( element ) then
			(element.SetPosition or SetPosition) (element, 1, element.createdButtons)
		end
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	if ( self.BetterDebuffs ) then
		self:RegisterEvent("UNIT_AURA", UpdateAuras)

		local element = self.BetterDebuffs
        element.__owner = self
        -- check if there's any anchoring restrictions
        element.__restricted = not pcall(self.GetCenter, self)
        element.ForceUpdate = ForceUpdate

        element.needFullUpdate = true
        element.createdButtons = element.createdButtons or 0
        element.anchoredButtons = 0
        element.visibleButtons = 0
        element.tooltipAnchor = element.tooltipAnchor or "ANCHOR_BOTTOMRIGHT"
        element.debuffList = {}

        element:Show()

		return true
	end
end

local function Disable(self)
	if ( self.BetterDebuffs ) then
		self:UnregisterEvent("UNIT_AURA", UpdateAuras)
        self.BetterDebuffs:Hide()
	end
end

oUF:AddElement("BetterDebuffs", Update, Enable, Disable)
