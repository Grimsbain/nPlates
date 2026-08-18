local _, nPlates = ...

local function PostCastStart(castbar, unit, spellID, notInterruptible, displayName, texture, isTradeSkill)
    local castColor = C_CurveUtil.EvaluateColorFromBoolean(notInterruptible, RED_FONT_COLOR, GREEN_FONT_COLOR)
    castbar:SetStatusBarColor(castColor:GetRGB())
    nPlates:SetCastbarBorderColor(castbar, castColor)

    if ( castbar.useImportantCast ) then
        local color = C_CurveUtil.EvaluateColorFromBoolean(C_Spell.IsSpellImportant(spellID), nPlates.Colors.ImportantCastColor, castColor)
        castbar:SetStatusBarColor(color:GetRGB())
    end

    local name = UnitSpellTargetName(unit)

    if ( name and castbar.showTarget ) then
        local classToken = UnitSpellTargetClass(unit)
        local color = classToken and C_ClassColor.GetClassColor(classToken) or WHITE_FONT_COLOR

        castbar.Target:SetFormattedText(color:WrapTextInColorCode(name))
        castbar.Target:Show()
    else
        castbar.Target:Hide()
    end
end

local function PostCastInterrupted(castbar, unit, spellID, interruptedBy)
    castbar:SetStatusBarColor(ORANGE_FONT_COLOR:GetRGB())
    nPlates:SetCastbarBorderColor(castbar, ORANGE_FONT_COLOR)

    if ( interruptedBy ~= nil ) then
        local name = UnitNameFromGUID(interruptedBy)
        local _, classToken = UnitClassFromGUID(interruptedBy)

        if classToken ~= nil then
            local color = C_ClassColor.GetClassColor(classToken)
            name = color:WrapTextInColorCode(name)
        end

        castbar.Target:SetText(name)
        castbar.Target:Show()
    else
        castbar.Target:Hide()
    end
end

function nPlates.CreateCastbar(self)
    self.Castbar = CreateFrame("StatusBar", "$parentCastbar", self, "nPlatesStatusBar")
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
    self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -5)
    self.Castbar:SetHeight(18)
    self.Castbar:SetStatusBarColor(1, 0.7, 0)
    self.Castbar.PostCastStart = PostCastStart
    self.Castbar.PostCastInterruptible = PostCastStart
    self.Castbar.PostCastInterrupted = PostCastInterrupted
    self.Castbar.PostCastFail = PostCastInterrupted
    self.Castbar.timeToHold = 1
    nPlates:SetBorder(self.Castbar)

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

    self.Castbar.Time = self.Castbar:CreateFontString("$parentTime", "OVERLAY", "nPlate_CastbarTimerFont")
    self.Castbar.Time:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, -1, 1)
    self.Castbar.Time:SetJustifyH("RIGHT")
    self.Castbar.Time:SetTextColor(1, 1, 1)

    self.Castbar:HookScript("OnShow", function()
        self.ClassFrameContainer:ClearAllPoints()
        self.ClassFrameContainer:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
        self.ClassFrameContainer:SetPoint("CENTER", self.Castbar)
    end)

    self.Castbar:HookScript("OnHide", function()
        self.ClassFrameContainer:ClearAllPoints()
        self.ClassFrameContainer:SetPoint("TOP", self.Health, "BOTTOM", 0, -5)
        self.ClassFrameContainer:SetPoint("CENTER", self.Health)
    end)
end
