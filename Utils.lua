local _, nPlates = ...
local oUF = nPlates.oUF

nPlates.Media = {
    StatusBarTexture = [[Interface\AddOns\nPlates\Media\UI-StatusBar]],
    StatusBarColor = CreateColor(1, 0.7, 0),
    ImportantCastColor = CreateColor(1, 0, 0.5),
    BorderColor = CreateColor(1.0, 1.0, 1.0),
    DefaultBorderColor = CreateColor(0.4, 0.4, 0.4),
    InteruptibleColor = CreateColor(0.75, 0.0, 0.0),
    OffTankColorHex =  CreateColor(174/255, 0.0, 1.0),
    SelectionColorHex = CreateColor(1.0, 1.0, 1.0),
    FocusColorHex = CreateColor(1.0, 0.49, 0.039),
}

-- Threat Functions

local function PlayerIsTank()
    return UnitGroupRolesAssignedEnum("player") == Enum.LFGRole.Tank
end

function nPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

function nPlates:UseOffTankColor(unit)
    if ( not self:GetSetting("NPLATES_OFF_TANK_COLOR") or not PlayerIsTank() ) then
        return false
    end

    return IsInRaid() and UnitGroupRolesAssignedEnum(unit.."target") == Enum.LFGRole.Tank
end

    -- Health Functions

function nPlates:UpdateStatusText(self, currentHealth)
    local text = self.Health.Value
    local style = nPlates:GetSetting("NPLATES_HEALTH_STYLE")

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
                if ( nPlates:GetSetting("NPLATES_TANKMODE") ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.unit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.0, 1.0, 0.0
                        else
                            r, g, b = GetThreatStatusColor(threatStatus)
                        end
                    elseif ( nPlates:UseOffTankColor(self.unit) ) then
                        local color = nPlates.Media.OffTankColorHex
                        r, g, b = color:GetRGB()
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
    if ( nPlates:GetSetting("NPLATES_FORCE_NAME") ) then
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

            if ( nPlates:GetSetting("NPLATES_SHOWLEVEL") and not isPlayer ) then
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

    if ( nPlates:GetSetting("NPLATES_ONLYNAME") and UnitIsPlayer(unit) ) then
        self.Name:SetPoint("BOTTOM", self, "TOP", 0, 5)
        self.Health:ClearAllPoints()
    else
        self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)

        self.Health:ClearAllPoints()
        self.Health:SetPoint("TOP")
    end
end

function nPlates:UpdateDebuffAnchors(self)
    local offset = nPlates:ShouldShowName(self.unit) and 17 or 5
    PixelUtil.SetPoint(self.Debuffs, "BOTTOMLEFT", self.Health, "TOPLEFT", 0, offset)
end

-- Beauty Border Functions

nPlates.PostCastStart = function(castbar, unit)
    local isImportant = C_Spell.IsSpellImportant(castbar.spellID)
    local statusBarColor = C_CurveUtil.EvaluateColorFromBoolean(isImportant, nPlates.Media.ImportantCastColor, nPlates.Media.StatusBarColor)
    castbar:GetStatusBarTexture():SetVertexColor(statusBarColor:GetRGB())

    local borderColor = C_CurveUtil.EvaluateColorFromBoolean(castbar.notInterruptible, nPlates.Media.InteruptibleColor, nPlates.Media.DefaultBorderColor)
    nPlates:SetCastbarBorderColor(castbar, borderColor)
end

function nPlates:SetCastbarBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    self:SetBeautyBorderColor(frame, color)
    self:SetBeautyBorderColor(frame.Icon, color)
end

function nPlates:HasBeautyBorder(frame)
    if ( not frame ) then
        return
    end

    return frame.Border ~= nil
end

function nPlates:SetBeautyBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    if ( self:HasBeautyBorder(frame) ) then
        for _, texture in ipairs(frame.Border) do
            texture:SetVertexColor(color:GetRGB())
        end
    end
end

function nPlates:SetSelectionColor(frame)
    if ( not frame) then
        return
    end

    local healthBar = frame.Health
    local unit = frame.unit

    if ( not unit ) then
        self:SetBeautyBorderColor(healthBar, self.Media.DefaultBorderColor)
        return
    end

    if ( nPlates:GetSetting("NPLATES_FOCUS_COLOR") ) then
        if ( UnitIsUnit(unit, "focus") ) then
            self:SetBeautyBorderColor(healthBar, self.Media.FocusColorHex)
            return
        end
    end

    if ( UnitIsUnit(unit, "target") ) then
        if ( nPlates:GetSetting("NPLATES_SELECTION_COLOR") ) then
            self:SetBeautyBorderColor(healthBar, self.Media.SelectionColorHex)
        else
            local r, g, b = healthBar:GetStatusBarColor()
            self.Media.BorderColor:SetRGB(r, g, b)
            self:SetBeautyBorderColor(healthBar, self.Media.BorderColor)
        end
    else
        self:SetBeautyBorderColor(healthBar, self.Media.DefaultBorderColor)
    end
end

function nPlates:SetBorder(frame)
    if ( self:HasBeautyBorder(frame) ) then
        return
    end

    local padding = 3
    local size = 12
    local space = size/3.5
    local objectType = frame:GetObjectType()
    local textureParent = (objectType == "Frame" or objectType == "StatusBar") and frame or frame:GetParent()

    frame.Border = {}
    frame.Shadow = {}

    for i = 1, 8 do
        frame.Border[i] = textureParent:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
        frame.Border[i]:SetTexture([[Interface\AddOns\nPlates\Media\borderTexture]])
        frame.Border[i]:SetSize(size, size)
        frame.Border[i]:SetVertexColor(self.Media.DefaultBorderColor:GetRGB())
        frame.Border[i]:ClearAllPoints()

        frame.Shadow[i] = textureParent:CreateTexture("$parentBeautyShadow"..i, "BORDER")
        frame.Shadow[i]:SetTexture([[Interface\AddOns\nPlates\Media\textureShadow]])
        frame.Shadow[i]:SetSize(size, size)
        frame.Shadow[i]:SetVertexColor(0, 0, 0, 1)
        frame.Shadow[i]:ClearAllPoints()
    end

    -- TOPLEFT
    frame.Border[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.Border[1]:SetPoint("TOPLEFT", frame, -padding, padding)
    -- TOPRIGHT
    frame.Border[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.Border[2]:SetPoint("TOPRIGHT", frame, padding, padding)
    -- BOTTOMLEFT
    frame.Border[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.Border[3]:SetPoint("BOTTOMLEFT", frame, -padding, -padding)
    -- BOTTOMRIGHT
    frame.Border[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.Border[4]:SetPoint("BOTTOMRIGHT", frame, padding, -padding)
    -- TOP
    frame.Border[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.Border[5]:SetPoint("TOPLEFT", frame.Border[1], "TOPRIGHT")
    frame.Border[5]:SetPoint("TOPRIGHT", frame.Border[2], "TOPLEFT")
    -- BOTTOM
    frame.Border[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.Border[6]:SetPoint("BOTTOMLEFT", frame.Border[3], "BOTTOMRIGHT")
    frame.Border[6]:SetPoint("BOTTOMRIGHT", frame.Border[4], "BOTTOMLEFT")
    -- LEFT
    frame.Border[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.Border[7]:SetPoint("TOPLEFT", frame.Border[1], "BOTTOMLEFT")
    frame.Border[7]:SetPoint("BOTTOMLEFT", frame.Border[3], "TOPLEFT")
    -- RIGHT
    frame.Border[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.Border[8]:SetPoint("TOPRIGHT", frame.Border[2], "BOTTOMRIGHT")
    frame.Border[8]:SetPoint("BOTTOMRIGHT", frame.Border[4], "TOPRIGHT")

    -- TOPLEFT
    frame.Shadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.Shadow[1]:SetPoint("TOPLEFT", frame, -padding-space, padding+space)
    -- TOPRIGHT
    frame.Shadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.Shadow[2]:SetPoint("TOPRIGHT", frame, padding+space, padding+space)
    -- BOTTOMLEFT
    frame.Shadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.Shadow[3]:SetPoint("BOTTOMLEFT", frame, -padding-space, -padding-space)
    -- BOTTOMRIGHT
    frame.Shadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.Shadow[4]:SetPoint("BOTTOMRIGHT", frame, padding+space, -padding-space)
    -- TOP
    frame.Shadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.Shadow[5]:SetPoint("TOPLEFT", frame.Shadow[1], "TOPRIGHT")
    frame.Shadow[5]:SetPoint("TOPRIGHT", frame.Shadow[2], "TOPLEFT")
    -- BOTTOM
    frame.Shadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.Shadow[6]:SetPoint("BOTTOMLEFT", frame.Shadow[3], "BOTTOMRIGHT")
    frame.Shadow[6]:SetPoint("BOTTOMRIGHT", frame.Shadow[4], "BOTTOMLEFT")
    -- LEFT
    frame.Shadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.Shadow[7]:SetPoint("TOPLEFT", frame.Shadow[1], "BOTTOMLEFT")
    frame.Shadow[7]:SetPoint("BOTTOMLEFT", frame.Shadow[3], "TOPLEFT")
    -- RIGHT
    frame.Shadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.Shadow[8]:SetPoint("TOPRIGHT", frame.Shadow[2], "BOTTOMRIGHT")
    frame.Shadow[8]:SetPoint("BOTTOMRIGHT", frame.Shadow[4], "TOPRIGHT")
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
    button.Cooldown:SetHideCountdownNumbers(not nPlates:GetSetting("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(nPlates:GetSetting("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(nPlates:GetSetting("NPLATES_COOLDOWN_SWIPE"))
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
    button.Cooldown:SetHideCountdownNumbers(not nPlates:GetSetting("NPLATES_COOLDOWN"))
    button.Cooldown:SetDrawEdge(nPlates:GetSetting("NPLATES_COOLDOWN_EDGE"))
    button.Cooldown:SetDrawSwipe(nPlates:GetSetting("NPLATES_COOLDOWN_SWIPE"))
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
    for _, obj in pairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            obj:UpdateAllElements("RefreshUnit")
        end
    end
end

function nPlates:UpdateAllNameplatesWithFunction(func, ...)
    for _, obj in pairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj.unit ) then
            if func then
                func(obj, obj.unit, ...)
            end
        end
    end
end

function nPlates:UpdateNameplateElement(name)
    for _, obj in pairs(oUF.objects) do
        if ( obj and obj.isNamePlate and obj:IsShown() and obj.unit ) then
            local element = obj[name]
            if element and element.ForceUpdate then
                element:ForceUpdate()
            end
        end
    end
end
