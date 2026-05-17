local _, nPlates = ...

local function PostCastStart(castbar, unit)
    local castColor = C_CurveUtil.EvaluateColorFromBoolean(castbar.notInterruptible, RED_FONT_COLOR, GREEN_FONT_COLOR)
    castbar:GetStatusBarTexture():SetVertexColor(castColor:GetRGB())
    nPlates:SetCastbarBorderColor(castbar, castColor)

    if ( castbar.useImportantCast ) then
        local isImportant = C_Spell.IsSpellImportant(castbar.spellID)
        local castColor = C_CurveUtil.EvaluateColorFromBoolean(isImportant, nPlates.Media.ImportantCastColor, castColor)
        castbar:GetStatusBarTexture():SetVertexColor(castColor:GetRGB())
        nPlates:SetCastbarBorderColor(castbar, castColor)
    end

    if ( castbar.showTarget ) then
        castbar.Target:SetText(UnitSpellTargetName(unit))
        castbar.Target:Show()
    else
        castbar.Target:Hide()
    end
end

local function PostCastInterrupted(castbar, unit, interruptedBy)
    castbar:GetStatusBarTexture():SetVertexColor(ORANGE_FONT_COLOR:GetRGB())
    nPlates:SetCastbarBorderColor(castbar, ORANGE_FONT_COLOR)

    local name = select(6, GetPlayerInfoByGUID(interruptedBy))

    if ( name ) then
        castbar.Target:SetText(name)
        castbar.Target:Show()
    else
        castbar.Target:Hide()
    end
end

function nPlates.CreateCastbar(self)
    self.Castbar = CreateFrame("StatusBar", "$parentCastbar", self)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
    self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -5)
    self.Castbar:SetHeight(18)
    self.Castbar:SetStatusBarTexture(nPlates.Media.StatusBarTexture)
    self.Castbar:GetStatusBarTexture():SetVertexColor(nPlates.Media.StatusBarColor:GetRGB())
    self.Castbar.PostCastStart = PostCastStart
    self.Castbar.PostCastInterrupted = PostCastInterrupted
    self.Castbar.timeToHold = 0.8
    nPlates:SetBorder(self.Castbar)

    self.Castbar.Background = self.Castbar:CreateTexture("$parentBackground", "BACKGROUND")
    self.Castbar.Background:SetAllPoints(self.Castbar)
    self.Castbar.Background:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    self.Castbar.Text = self.Castbar:CreateFontString("$parentText", "OVERLAY", "nPlate_CastbarFont")
    self.Castbar.Text:SetPoint("LEFT", self.Castbar, 2, 1)
    self.Castbar.Text:SetJustifyH("LEFT")
    self.Castbar.Text:SetJustifyV("MIDDLE")
    self.Castbar.Text:SetTextColor(1, 1, 1)

    self.Castbar.Target = self.Castbar:CreateFontString("$parentTarget", "OVERLAY", "nPlate_CountFont")
    self.Castbar.Target:SetPoint("RIGHT", self.Castbar, -2, 1)
    self.Castbar.Target:SetPoint("LEFT", self.Castbar.Text, "RIGHT", 5, 0)
    self.Castbar.Target:SetJustifyH("RIGHT")
    self.Castbar.Target:SetJustifyV("MIDDLE")
    self.Castbar.Target:SetTextColor(1, 1, 1)
    self.Castbar.Target:SetWordWrap(false)

    self.Castbar.Icon = self.Castbar:CreateTexture("$parentIcon", "OVERLAY")
    self.Castbar.Icon:SetSize(33, 33)
    self.Castbar.Icon:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMRIGHT", 4.9, 0)
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    nPlates:SetBorder(self.Castbar.Icon)

    -- Waiting on Blizzard timer formatting function.
    -- self.Castbar.Time = self.Castbar:CreateFontString("$parentTime", "OVERLAY", "nPlate_CastbarTimerFont")
    -- self.Castbar.Time:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, -1, 1)
    -- self.Castbar.Time:SetJustifyH("RIGHT")
    -- self.Castbar.Time:SetTextColor(1, 1, 1)
end


