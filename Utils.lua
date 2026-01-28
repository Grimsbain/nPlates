local _, nPlates = ...
local oUF = nPlates.oUF

nPlates.Media = {
    StatusBarTexture = [[Interface\AddOns\nPlates\Media\UI-StatusBar]],
    StatusBarColor = CreateColor(1, 0.7, 0),
    ImportantCastColor = CreateColor(1, 0, 0.5),
    BorderColor = CreateColor(1.0, 1.0, 1.0),
    DefaultBorderColor = CreateColor(0.4, 0.4, 0.4),
    InteruptibleColor = CreateColor(0.75, 0.0, 0.0),
    OffTankColor =  CreateColor(174/255, 0.0, 1.0),
    SelectionColor = CreateColor(1.0, 1.0, 1.0),
    FocusColor = CreateColor(1.0, 0.49, 0.039),
}

-- Threat Functions

function nPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

function nPlates:UseOffTankColor(unit)
    if ( not Settings.GetValue("NPLATES_OFF_TANK_COLOR") or not PlayerUtil.IsPlayerEffectivelyTank() ) then
        return false
    end

    return IsInRaid() and UnitGroupRolesAssignedEnum(unit.."target") == Enum.LFGRole.Tank
end

    -- Health Functions

function nPlates:UpdateStatusText(self, currentHealth)
    local text = self.Health.Value
    local style = Settings.GetValue("NPLATES_HEALTH_STYLE")

    if ( style == "disabled" ) then
        text:Hide()
        return
    else
        local health = AbbreviateNumbers(currentHealth)
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

function nPlates.UpdateHealth(self, event, unit)
    if ( not unit or self.unit ~= unit ) then return end

	local element = self.Health
    if not element:IsShown() then return end

    local r, g, b
    local currentHealth, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)

    if ( UnitIsDeadOrGhost(self.unit) or UnitIsTapDenied(self.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( UnitIsPlayer(self.unit) or UnitInPartyIsAI(self.unit) ) then
            local _, class = UnitClass(self.unit)
            local color = RAID_CLASS_COLORS[class]
            r, g, b = color:GetRGB()
        else
            if ( nPlates:IsOnThreatListWithPlayer(self.unit) ) then
                if ( Settings.GetValue("NPLATES_TANKMODE") ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.unit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.0, 1.0, 0.0
                        else
                            r, g, b = GetThreatStatusColor(threatStatus)
                        end
                    elseif ( nPlates:UseOffTankColor(self.unit) ) then
                        r, g, b = nPlates.Media.OffTankColor:GetRGB()
                    else
                        r, g, b = 1, 0, 0
                    end
                else
                    r, g, b = 1, 0, 0
                end
            else
                r, g, b = UnitSelectionColor(self.unit, true)
            end
        end
    end

	element:SetMinMaxValues(0, maxHealth)
    element:SetValue(currentHealth)
    element:SetStatusBarColor(r, g, b)
    nPlates:SetSelectionColor(self)
    nPlates:UpdateStatusText(self, currentHealth, maxHealth)
end

-- Name Functions

function nPlates:ShouldShowName(unit)
    if ( self.isWidget ) then
        self.Name:Hide()
        return
    end

    if ( Settings.GetValue("NPLATES_FORCE_NAME") ) then
        return true
    end

    if ( UnitIsPlayer(unit) ) then
        return true
    end

    if ( UnitIsEnemy("player", unit) or UnitIsUnit("target", unit) ) then
        return true
    end

    return false
end

function nPlates:UpdateName(self, event, unit)
    if ( not unit or self.unit ~= unit ) then return end

    if ( self.isWidget ) then
        self.Name:Hide()
        return
    end

    if ( self.Name ) then
        if ( not nPlates:ShouldShowName(self.unit) ) then
            self.Name:Hide()
            return
        else
            local isPlayer = UnitIsPlayer(self.unit)
            local unitName = UnitName(self.unit) or UNKOWN

            if ( Settings.GetValue("NPLATES_SHOWLEVEL") and not isPlayer ) then
                local targetLevel = UnitLevel(self.unit)

                if ( targetLevel == -1 ) then
                    self.Name:SetText(unitName)
                else
                    local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
                    local color = GetDifficultyColor(difficulty)
                    self.Name:SetFormattedText("%s%d|r %s", ConvertRGBtoColorString(color), targetLevel, unitName)
                end
            else
                if ( isPlayer ) then
                    self.Name:SetText(GetClassColoredTextForUnit(self.unit, unitName))
                else
                    self.Name:SetText(unitName)
                end
            end

            self.Name:Show()
        end
    end
end

function nPlates:UpdateNameLocation(self, event, unit)
    if ( self.isWidget ) then
        self.Name:Hide()
        return
    end

    self.Name:ClearAllPoints()

    if ( Settings.GetValue("NPLATES_ONLYNAME") and nPlates:IsFriendlyPlayer(unit) ) then
        self.Name:SetPoint("BOTTOM", self, "TOP", 0, 5)
        self.Health:ClearAllPoints()
    else
        self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)

        self.Health:ClearAllPoints()
        self.Health:SetPoint("TOP")
    end
end

    -- Debuff Functions

function nPlates:UpdateDebuffAnchors(self)
    local offset = nPlates:ShouldShowName(self.unit) and 17 or 5
    PixelUtil.SetPoint(self.Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, offset)
end

    -- Castbar Functions

nPlates.PostCastStart = function(castbar, unit)
    local isImportant = C_Spell.IsSpellImportant(castbar.spellID)
    local statusBarColor = C_CurveUtil.EvaluateColorFromBoolean(isImportant, nPlates.Media.ImportantCastColor, nPlates.Media.StatusBarColor)
    castbar:GetStatusBarTexture():SetVertexColor(statusBarColor:GetRGB())

    local borderColor = C_CurveUtil.EvaluateColorFromBoolean(castbar.notInterruptible, nPlates.Media.InteruptibleColor, nPlates.Media.DefaultBorderColor)
    nPlates:SetCastbarBorderColor(castbar, borderColor)
end

    -- Classification Functions

function nPlates:UpdateClassification(self, event, unit)
    if ( not unit or self.unit ~= unit or not self.Health:IsShown() ) then return end

    local classification = UnitClassification(unit)

    if ( classification == "elite" or classification == "worldboss" ) then
        self.classificationIndicator:SetAtlas("nameplates-icon-elite-gold")
        self.classificationIndicator:Show()
    elseif ( classification == "rareelite" or classification == "rare" ) then
        self.classificationIndicator:SetAtlas("nameplates-icon-elite-silver")
        self.classificationIndicator:Show()
    else
        self.classificationIndicator:Hide()
    end
end

-- Aura Functions

nPlates.PostCreateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetCountdownFont("nPlate_CooldownFont")

    button.Overlay:ClearAllPoints()

    button.Background = button:CreateTexture("$parentBackground", "BACKGROUND")
    button.Background:SetAllPoints(button)
    button.Background:SetColorTexture(0, 0, 0)

    button.Count:SetFontObject("nPlate_CountFont")
    button.Count:ClearAllPoints()
    button.Count:SetPoint("CENTER", button.Icon, "TOPLEFT", 1, 1)
    button.Count:SetJustifyH("RIGHT")

    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("CENTER")
    button.Icon:SetSize(18, 12)
    button.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
end

nPlates.PostUpdateButton = function(auras, button)
    button.Cooldown:SetHideCountdownNumbers(not Settings.GetValue("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(Settings.GetValue("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(Settings.GetValue("NPLATES_COOLDOWN_SWIPE"))
end

nPlates.DebuffPostUpdate = function(auras, unit)
    local parent = auras:GetParent()
    parent.ComboPoints:ClearAllPoints()

    if auras.visibleButtons > 0 then
        parent.ComboPoints:SetPoint("BOTTOM", parent.Debuffs, "TOP", 0, 4)
        parent.ComboPoints:SetPoint("CENTER", parent)
    else
        parent.ComboPoints:SetPoint("BOTTOM", parent.Name, "TOP", 0, 4)
        parent.ComboPoints:SetPoint("CENTER", parent)
    end
end

-- oUF Functions

function nPlates:UpdateAllNameplates()
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            obj:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateNameplatesWithFunction(func, ...)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            if func then
                func(obj, obj.unit, ...)
            end
        end
    end
end

function nPlates:UpdateElement(name)
    for _, obj in ipairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj:IsShown() and obj.unit ) then
            local element = obj[name]
            if element and element.ForceUpdate then
                element:ForceUpdate()
            end
        end
    end
end
