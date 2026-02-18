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
        if ( self.useClassColors ) then
            r, g, b = self.classColor:GetRGB()
        else
            if ( (self.healthStyle == "mobType" or self.healthStyle == "mobTypeOrThreat") and self:ShouldShowMobType() ) then
                r, g, b = nPlates.MobColors[self.mobType]:GetRGB()
            elseif ( nPlates.IsOnThreatListWithPlayer(self.unit) ) then
                if ( self.healthStyle == "threat" or self.healthStyle == "mobTypeOrThreat" ) then
                    r, g, b = nPlates.GetThreatColor(self.unit):GetRGB()
                else
                    r, g, b = 1, 0, 0
                end
            else
                r, g, b = UnitSelectionColor(self.unit, true)
            end
        end
    end

    element:SetStatusBarColor(r, g, b)

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

    local HealingAll = CreateFrame("StatusBar", "$parentHealing", self.Health)
    HealingAll:SetPoint("TOP")
    HealingAll:SetPoint("BOTTOM")
    HealingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    HealingAll:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    HealingAll:GetStatusBarTexture():SetVertexColor(HEALTHBAR_MY_HEAL_PREDICTION_COLOR:GetRGB())
    HealingAll:SetUsingParentLevel(true)
    self.Health.HealingAll = HealingAll

    local DamageAbsorb = CreateFrame("StatusBar", "$parentObsorb", self.Health)
    DamageAbsorb:SetPoint("TOP")
    DamageAbsorb:SetPoint("BOTTOM")
    DamageAbsorb:SetPoint("LEFT", HealingAll:GetStatusBarTexture(), "RIGHT")
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

    local HealAbsorb = CreateFrame("StatusBar", "$parentHealObsorb", self.Health)
    HealAbsorb:SetStatusBarTexture([[Interface\RaidFrame\Absorb-Fill]], true, true)
    HealAbsorb:GetStatusBarTexture():SetVertexColor(HEALTHBAR_HEAL_ABSORB_COLOR:GetRGB())
    HealAbsorb:SetPoint("TOP")
    HealAbsorb:SetPoint("BOTTOM")
    HealAbsorb:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
    HealAbsorb:SetWidth(200)
    HealAbsorb:SetReverseFill(true)
    HealAbsorb:SetUsingParentLevel(true)
    self.Health.HealAbsorb = HealAbsorb

    local OverDamageAbsorbIndicator = self.Health:CreateTexture("$parentOverObsorb", "OVERLAY")
    OverDamageAbsorbIndicator:SetPoint("TOP")
    OverDamageAbsorbIndicator:SetPoint("BOTTOM")
    OverDamageAbsorbIndicator:SetPoint("LEFT", self.Health, "RIGHT")
    OverDamageAbsorbIndicator:SetWidth(10)
    self.Health.OverDamageAbsorbIndicator = OverDamageAbsorbIndicator

    local OverHealAbsorbIndicator = self.Health:CreateTexture("$parentOverHealObsorb", "OVERLAY")
    OverHealAbsorbIndicator:SetPoint("TOP")
    OverHealAbsorbIndicator:SetPoint("BOTTOM")
    OverHealAbsorbIndicator:SetPoint("RIGHT", self.Health, "LEFT")
    OverHealAbsorbIndicator:SetWidth(10)
    self.Health.OverHealAbsorbIndicator = OverHealAbsorbIndicator
end
