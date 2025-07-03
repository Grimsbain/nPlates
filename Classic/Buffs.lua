local _, nPlates = ...

nPlatesBuffContainerMixin = {}

function nPlatesBuffContainerMixin:OnLoad()
	self.buffList = {}
	self.targetYOffset = 0
	self.baseYOffset = 0
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function nPlatesBuffContainerMixin:OnEvent(event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self:UpdateAnchor()
	end
end

function nPlatesBuffContainerMixin:SetTargetYOffset(targetYOffset)
	self.targetYOffset = targetYOffset
end

function nPlatesBuffContainerMixin:GetTargetYOffset()
	return self.targetYOffset
end

function nPlatesBuffContainerMixin:SetBaseYOffset(baseYOffset)
	self.baseYOffset = baseYOffset
end

function nPlatesBuffContainerMixin:GetBaseYOffset()
	return self.baseYOffset
end

function nPlatesBuffContainerMixin:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target")
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0.0)
	if ( self:GetParent().unit and ShouldShowName(self:GetParent()) ) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset)
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset)
	end
end

function nPlatesBuffContainerMixin:ShouldShowBuff(name, caster, nameplateShowAll)
    if ( not name ) then
		return false
	end

	return nameplateShowAll or (caster == "player" or caster == "pet" or caster == "vehicle")
end

function nPlatesBuffContainerMixin:UpdateBuffs(unit, filter)
	self.unit = unit
	self.filter = filter
	self:UpdateAnchor()

	if filter == "NONE" then
		for _, buff in ipairs(self.buffList) do
			buff:Hide()
		end
	else
		-- Some buffs may be filtered out, use this to create the buff frames.
		local buffIndex = 1

        for i = 1, BUFF_MAX_DISPLAY do
            local name, texture, count, debuffType, duration, expirationTime, caster, _, _, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter)

			if ( self:ShouldShowBuff(name, caster, nameplateShowAll) ) then
				if ( not self.buffList[buffIndex] ) then
					self.buffList[buffIndex] = CreateFrame("Frame", "$parentBuff"..buffIndex, self, "nPlatesBuffButtonTemplate")
					self.buffList[buffIndex]:SetMouseClickEnabled(false)
					self.buffList[buffIndex].layoutIndex = buffIndex
				end

				local buff = self.buffList[buffIndex]
				buff:SetID(i)
				buff.Icon:SetTexture(texture)

				if ( count > 1 ) then
					buff.CountFrame.Count:SetText(count)
					buff.CountFrame.Count:Show()
				else
					buff.CountFrame.Count:Hide()
				end

				CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, true)

				buff:Show()
				buffIndex = buffIndex + 1
			end
		end

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if ( self.buffList[i] ) then
				self.buffList[i]:Hide()
			else
				break
			end
		end
	end
	self:Layout()
end

nPlatesBuffButtonTemplateMixin = {}

function nPlatesBuffButtonTemplateMixin:OnEnter()
	NamePlateTooltip:SetOwner(self, "ANCHOR_LEFT")
	NamePlateTooltip:SetUnitAura(self:GetParent().unit, self:GetID(), self:GetParent().filter)

	self.UpdateTooltip = self.OnEnter
end

function nPlatesBuffButtonTemplateMixin:OnLeave()
	NamePlateTooltip:Hide()
end
