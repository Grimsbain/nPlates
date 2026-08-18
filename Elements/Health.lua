local _, nPlates = ...

local function UpdateStatusText(element, unit, cur, max, lossPerc)
    local text = element.Text
    local tag = element.__owner.healthTag

    if ( tag == "disabled" ) then
        text:Hide()
        return
    else
        local health = AbbreviateNumbers(cur)

        if ( tag  == "cur" ) then
            text:SetFormattedText("%s", health)
            text:Show()
            return
        end

        local percent = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)

        if ( tag == "perc" ) then
            text:SetFormattedText("%.0f%%", percent)
        elseif ( tag == "cur_perc" ) then
            text:SetFormattedText("%s - %.0f%%", health, percent)
        elseif ( tag == "perc_cur" ) then
            text:SetFormattedText("%.0f%% - %s", percent, health)
        end

        text:Show()
    end
end

local function UpdateColor(self, event, unit)
	local element = self.Health
    local r, g, b

    if ( UnitIsDeadOrGhost(self.__unit) or UnitIsTapDenied(self.__unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( self.useClassColor ) then
            r, g, b = self.classColor:GetRGB()
        else
            if ( self:UseMobColoring("healthStyle") ) then
                r, g, b = nPlates.MobColors[self.mobType]:GetRGB()
            elseif ( nPlates.IsOnThreatListWithPlayer(self.__unit) ) then
                if ( self:UseThreatColoring("healthStyle") ) then
                    r, g, b = nPlates.GetThreatColor(self.__unit)
                else
                    r, g, b = 1, 0, 0
                end
            else
                r, g, b = UnitSelectionColor(self.__unit, true)
            end
        end
    end

    element:SetStatusBarColor(r, g, b)
    self:SetSelectionColor()
end

function nPlates.CreateHealth(self)
    self.Health = CreateFrame("StatusBar", "$parentHealthBar", self, "nPlatesStatusBar")
    self.Health:SetPoint("TOP")
    self.Health:SetWidth(175)
    self.Health:SetHeight(18)
    self.Health.colorThreat = true
    self.Health.colorTapping = true
    self.Health.colorReaction = true
    self.Health.colorSelection = true
    self.Health.UpdateColor = UpdateColor
    self.Health.PostUpdate = UpdateStatusText
    nPlates:SetBorder(self.Health)

    self.Health.Text = self.Health:CreateFontString("$parentHealthText", "OVERLAY", "nPlate_HealthFont")
    self.Health.Text:SetPoint("CENTER")
    self.Health.Text:SetJustifyH("CENTER")
    self.Health.Text:SetJustifyV("MIDDLE")
    self.Health.Text:SetTextColor(1, 1, 1)

    local DamageAbsorb = CreateFrame("StatusBar", "$parentObsorb", self.Health)
    DamageAbsorb:SetPoint("TOP")
    DamageAbsorb:SetPoint("BOTTOM")
    DamageAbsorb:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    DamageAbsorb:SetStatusBarTexture([[Interface\RaidFrame\Shield-Fill]])
    DamageAbsorb:SetStatusBarColor(HEALTHBAR_TOTAL_ABSORB_COLOR:GetRGB())
    DamageAbsorb:SetUsingParentLevel(true)
    -- Overlay
    DamageAbsorb.Overlay = DamageAbsorb:CreateTexture("$parentOverlay", "OVERLAY")
    DamageAbsorb.Overlay:SetTexture([[Interface\RaidFrame\Shield-Overlay]], true, true)
    DamageAbsorb.Overlay:SetAllPoints(DamageAbsorb:GetStatusBarTexture())
    DamageAbsorb.Overlay:SetVertexColor(HEALTHBAR_TOTAL_ABSORB_COLOR:GetRGB())
    DamageAbsorb.Overlay:SetHorizTile(true)
    self.Health.DamageAbsorb = DamageAbsorb
end
