local _, nPlates = ...

local function UpdateStatusText(self)
    local element = self.Health
    local text = element.Text
    local style = Settings.GetValue("NPLATES_HEALTH_STYLE")

    if ( style == "disabled" ) then
        text:Hide()
        return
    else
        local health = AbbreviateNumbers(element.values:GetCurrentHealth())
        local percent = UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)

        if ( style == "cur_perc" ) then
            text:SetFormattedText("%s - %.0f%%", health, percent)
        elseif ( style == "perc_cur" ) then
            text:SetFormattedText("%.0f%% - %s", percent, health)
        elseif ( style  == "cur" ) then
            text:SetFormattedText("%s", health)
        elseif ( style == "perc" ) then
            text:SetFormattedText("%.0f%%", percent)
        end

        text:Show()
    end
end

local function UpdateColor(self, event, unit)
	local element = self.Health

    if ( UnitIsDeadOrGhost(self.unit) or UnitIsTapDenied(self.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( UnitIsPlayer(self.unit) or UnitInPartyIsAI(self.unit) ) then
            r, g, b = self.classColor:GetRGB()
        else
            local healthStyle = Settings.GetValue("NPLATES_HEALTH_COLOR")

            if ( self:ShouldShowMobType() and (healthStyle == "mobType" or healthStyle == "mobTypeOrThreat") ) then
                r, g, b = nPlates.MobColors[self.mobType]:GetRGB()
            elseif ( nPlates.IsOnThreatListWithPlayer(self.unit) ) then
                if ( healthStyle == "threat" or healthStyle == "mobTypeOrThreat" ) then
                    r, g, b = nPlates.GetThreatColor(self.unit):GetRGB()
                else
                    r, g, b = 1, 0, 0
                end
            else
                r, g, b = UnitSelectionColor(self.unit, true)
            end
        end
    end

    element:GetStatusBarTexture():SetVertexColor(r, g, b)

    self:SetSelectionColor()
    UpdateStatusText(self)
end

function nPlates.CreateHealth(self)
    self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
    self.Health:SetPoint("TOP")
    self.Health:SetWidth(175)
    self.Health:SetHeight(18)
    self.Health:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    self.Health.UpdateColor = UpdateColor
    self.Health.incomingHealOverflow = 1.2
    nPlates:SetBorder(self.Health)

    self.Health.Background = self.Health:CreateTexture("$parentBackground", "BACKGROUND")
    self.Health.Background:SetAllPoints(self.Health)
    self.Health.Background:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    self.Health.Text = self.Health:CreateFontString("$parentHealthText", "OVERLAY", "nPlate_HealthFont")
    self.Health.Text:SetShadowOffset(1, -1)
    self.Health.Text:SetPoint("TOPLEFT", self.Health, 0, 0)
    self.Health.Text:SetPoint("BOTTOMRIGHT", self.Health, 0, 0)
    self.Health.Text:SetJustifyH("CENTER")
    self.Health.Text:SetJustifyV("MIDDLE")
    self.Health.Text:SetTextColor(1, 1, 1)

    -- local healingAll = CreateFrame("StatusBar", "$parentHealing", self.Health)
    -- healingAll:SetPoint("TOP")
    -- healingAll:SetPoint("BOTTOM")
    -- healingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    -- healingAll:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    -- healingAll:GetStatusBarTexture():SetVertexColor(HEALTHBAR_MY_HEAL_PREDICTION_COLOR:GetRGB())
    -- healingAll:SetUsingParentLevel(true)
    -- self.Health.HealingAll = healingAll

    -- local damageAbsorb = CreateFrame("StatusBar", "$parentObsorb", self.Health)
    -- damageAbsorb:SetPoint("TOP")
    -- damageAbsorb:SetPoint("BOTTOM")
    -- damageAbsorb:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    -- damageAbsorb:SetStatusBarTexture([[Interface\RaidFrame\Shield-Fill]])
    -- damageAbsorb:SetStatusBarColor(HEALTHBAR_TOTAL_ABSORB_COLOR:GetRGB())
    -- damageAbsorb:SetUsingParentLevel(true)
    -- -- Overlay
    -- damageAbsorb.overlay = damageAbsorb:CreateTexture("$parentOverlay", "OVERLAY")
    -- damageAbsorb.overlay:SetTexture([[Interface\RaidFrame\Shield-Overlay]], true, true)
    -- damageAbsorb.overlay:SetAllPoints(damageAbsorb:GetStatusBarTexture())
    -- damageAbsorb.overlay:SetVertexColor(HEALTHBAR_TOTAL_ABSORB_COLOR:GetRGB())
    -- damageAbsorb.overlay:SetHorizTile(true)
    -- self.Health.DamageAbsorb = damageAbsorb

    -- local healAbsorb = CreateFrame("StatusBar", "$parentHealObsorb", self.Health)
    -- healAbsorb:SetStatusBarTexture([[Interface\RaidFrame\Absorb-Fill]], true, true)
    -- healAbsorb:GetStatusBarTexture():SetVertexColor(HEALTHBAR_HEAL_ABSORB_COLOR:GetRGB())
    -- healAbsorb:SetPoint("TOP")
    -- healAbsorb:SetPoint("BOTTOM")
    -- healAbsorb:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
    -- healAbsorb:SetWidth(200)
    -- healAbsorb:SetReverseFill(true)
    -- healAbsorb:SetUsingParentLevel(true)
    -- self.Health.HealAbsorb = healAbsorb

    -- local overDamageAbsorbIndicator = self.Health:CreateTexture("$parentOverObsorb", "OVERLAY")
    -- overDamageAbsorbIndicator:SetPoint("TOP")
    -- overDamageAbsorbIndicator:SetPoint("BOTTOM")
    -- overDamageAbsorbIndicator:SetPoint("LEFT", self.Health, "RIGHT")
    -- overDamageAbsorbIndicator:SetWidth(10)
    -- self.Health.OverDamageAbsorbIndicator = overDamageAbsorbIndicator

    -- local overHealAbsorbIndicator = self.Health:CreateTexture("$parentOverHealObsorb", "OVERLAY")
    -- overHealAbsorbIndicator:SetPoint("TOP")
    -- overHealAbsorbIndicator:SetPoint("BOTTOM")
    -- overHealAbsorbIndicator:SetPoint("RIGHT", self.Health, "LEFT")
    -- overHealAbsorbIndicator:SetWidth(10)
    -- self.Health.OverHealAbsorbIndicator = overHealAbsorbIndicator
end
