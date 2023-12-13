local _, nPlates = ...

local englishFaction, _ = UnitFactionGroup("player")

nPlatesMixin = {}

function nPlatesMixin:OnLoad()
    local events = {
        "ADDON_LOADED",
        "NAME_PLATE_UNIT_ADDED",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
        "RAID_TARGET_UPDATE",
        "UNIT_AURA",
        "PLAYER_TARGET_CHANGED",
    }

    FrameUtil.RegisterFrameForEvents(self, events)
end

function nPlatesMixin:OnEvent(event, ...)
    if ( event == "ADDON_LOADED" ) then
        local name = ...

        if ( name == "nPlates" ) then
            nPlates:SetDefaultOptions()
            nPlates:CVarCheck()

            self:UnregisterEvent(event)
        end
    elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then
        self:OnNamePlateAdded(...)
    elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
        self:UpdateCombatPlates(event)
    elseif ( event == "RAID_TARGET_UPDATE" ) then
        nPlates:UpdateRaidMarkerColoring()
    elseif ( event == "PLAYER_TARGET_CHANGED" ) then
        self:OnTargetChanged()
    elseif ( event == "UNIT_AURA" ) then
        self:OnUnitAuraUpdate(...)
    end
end

function nPlatesMixin:OnNamePlateAdded(unit)
    local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    local unitFrame = namePlateFrameBase.UnitFrame
    unitFrame.isNameplate = true

    nPlates:UpdateClassification(unitFrame)
    nPlates:UpdateStatusText(unitFrame)
    nPlates:UpdateHealthColor(unitFrame)
    nPlates:UpdateName(unitFrame)

    self:SetupBuffFrame(unitFrame)
    self:OnUnitAuraUpdate(unit)
end

function nPlatesMixin:SetupBuffFrame(unitFrame)
    if ( not unitFrame.BuffFrame ) then
        unitFrame.BuffFrame = CreateFrame("Frame", "$parentBuffFrame", unitFrame, "nPlatesBuffFrame")
    end
end

function nPlatesMixin:OnTargetChanged()
	self:OnUnitAuraUpdate("target")
end

function nPlatesMixin:OnUnitAuraUpdate(unit)
	-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile.
	local reaction = UnitReaction("player", unit)
	local hostileUnit = reaction and reaction <= 4
    local filter = hostileUnit and "HARMFUL|INCLUDE_NAME_PLATE_ONLY" or "NONE"

	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(unit, issecure())
	if ( namePlateFrameBase ) then
        namePlateFrameBase.UnitFrame.BuffFrame:UpdateBuffs(namePlateFrameBase.namePlateUnitToken, filter)
	end
end

function nPlatesMixin:UpdateCombatPlates(event)
    if ( not nPlates:GetOption("CombatPlates") ) then
        return
    end

    SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
end

local function CUF_OnEvents(self, event, ...)
    if ( nPlates:IsFrameBlocked(self) ) then
        return
    end

    if ( event == "UNIT_THREAT_LIST_UPDATE" ) then
        nPlates:UpdateHealthColor(self)
        nPlates:UpdateNameColor(self)
    elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
        nPlates:UpdateClassification(self)
    end
end

function nPlates:UpdateCastbarTimer(castBar)
    if ( castBar:IsForbidden() ) then return end

    if ( castBar.unit ) then
        if ( castBar.casting ) then
            local current = castBar.maxValue - castBar.value
            if ( current > 0 ) then
                castBar.CastTime:SetText(self:FormatTime(current))
            end
        else
            if ( castBar.value > 0 ) then
                castBar.CastTime:SetText(self:FormatTime(castBar.value))
            end
        end
    end
end

function nPlates:UpdateCastbar(castBar)
    if ( castBar:IsForbidden() ) then return end

    castBar.Border:SetTexture(nil)
    castBar.BorderShield:ClearAllPoints()

    castBar.Icon:SetSize(26, 26)
    castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    castBar.Icon:ClearAllPoints()
    castBar.Icon:SetIgnoreParentAlpha(false)
    castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", 4.9, 0)

    castBar.Text:Show()

    local color = castBar.notInterruptible and self.nonInterruptibleColor or self.defaultBorderColor
    self:SetCastbarBorderColor(castBar, color)
end

function nPlates:UpdateStatusText(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    local healthBar = frame.healthBar

    if ( not healthBar.value ) then
        healthBar.value = healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
        healthBar.value:SetPoint("CENTER", healthBar)
        healthBar.value:SetFontObject("nPlate_NameFont10")
    end

    local option = self:GetOption("CurrentHealthOption")

    if ( option == "HealthDisabled" ) then
        healthBar.value:Hide()
    else
        local health, maxHealth = UnitHealth(frame.displayedUnit), UnitHealthMax(frame.displayedUnit)

        if ( option == "HealthBoth" ) then
            local healthPercent = math.floor((health/maxHealth) * 100)
            if ( healthPercent >= 100 ) then
                healthBar.value:SetFormattedText("%s", self:FormatValue(health))
                healthBar.value:Show()
            else
                healthBar.value:SetFormattedText("%s - %s%%", self:FormatValue(health), healthPercent)
                healthBar.value:Show()
            end
        elseif ( option == "PercentHealth" ) then
            local healthPercent = math.floor((health/maxHealth) * 100)
            if ( healthPercent >= 100 ) then
                healthBar.value:SetFormattedText("%s", self:FormatValue(health))
                healthBar.value:Show()
            else
                healthBar.value:SetFormattedText("%s%% - %s", healthPercent, self:FormatValue(health))
                healthBar.value:Show()
            end
        elseif ( option == "HealthValueOnly" ) then
            healthBar.value:SetFormattedText("%s", self:FormatValue(health))
            healthBar.value:Show()
        elseif ( option == "HealthPercOnly" ) then
            local healthPercent = math.floor((health/maxHealth) * 100)
            healthBar.value:SetFormattedText("%s%%", healthPercent)
            healthBar.value:Show()
        else
            healthBar.value:Hide()
        end
    end
end

function nPlates:UpdateHealthColor(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    local r, g, b

    if ( not UnitIsConnected(frame.unit) or UnitIsDead(frame.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local color = frame.optionTable.healthBarColorOverride
            r, g, b = color.r, color.g, color.b
        else
            local _, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            local raidMarker = GetRaidTargetIndex(frame.displayedUnit)

            if ( frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) and classColor and self:UseClassColors(englishFaction, frame.unit) ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
            elseif ( self:GetOption("RaidMarkerColoring") and raidMarker ) then
                local color = self.markerColors[raidMarker]
                r, g, b = color.r, color.g, color.b
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( self:IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    if ( self:GetOption("TankMode") ) then
                        local target = frame.displayedUnit.."target"
                        local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                        if ( isTanking and threatStatus ) then
                            if ( threatStatus >= 3 ) then
                                r, g, b = 0.0, 1.0, 0.0
                            else
                                r, g, b = GetThreatStatusColor(threatStatus)
                            end
                        elseif ( self:UseOffTankColor(target) ) then
                            local color = self:GetOption("OffTankColor")
                            r, g, b = color.r, color.g, color.b
                        else
                            r, g, b = 1.0, 0.0, 0.0
                        end
                    else
                        r, g, b = 1.0, 0.0, 0.0
                    end
                else
                    r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors)
                end
            elseif ( UnitIsFriend("player", frame.unit) ) then
                r, g, b = 0.0, 1.0, 0.0
            else
                r, g, b = 1.0, 0.0, 0.0
            end
        end
    end

    if ( self:GetOption("ShowExecuteRange") and self:IsInExecuteRange(frame.displayedUnit) ) then
        local color = self:GetOption("ExecuteColor")
        r, g, b = color.r, color.g, color.b
    end

    local currentR, currentG, currentB = frame.healthBar:GetStatusBarColor()

    if ( r ~= currentR or g ~= currentG or b ~= currentB ) then
        frame.healthBar:SetStatusBarColor(r, g, b)

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1.0, 1.0, 1.0)
        end

    end

    self:SetSelectionColor(frame)
end

function nPlates:UpdateSelectionHighlight(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    if ( not frame.optionTable.displaySelectionHighlight ) then
		frame.selectionHighlight:Hide()
		return
	end

	if ( UnitIsUnit(frame.displayedUnit, "target") ) then
		frame.selectionHighlight:Show()
	else
		frame.selectionHighlight:Hide()
	end

    self:SetSelectionColor(frame)
end

function nPlates:UpdateName(frame)
    if ( self:IsFrameBlocked(frame) ) then
        return
    end

    if ( not ShouldShowName(frame) ) then
        frame.name:Hide()
        return
    else
        self:UpdateNameSize(frame)
        self:UpdateNameColor(frame)

        local pvpIcon = self:PvPIcon(frame.displayedUnit)
        local name, server = UnitName(frame.displayedUnit) or UNKOWN

        if ( self:GetOption("AbrrevLongNames") ) then
            name = self:Abbreviate(name)
        end

        if ( self:GetOption("ShowServerName") ) then
            if ( server ) then
                name = name.." - "..server
            end
        end

        if ( self:GetOption("ShowLevel") ) then
            local targetLevel = UnitLevel(frame.displayedUnit)

            if ( targetLevel == -1 ) then
                frame.name:SetFormattedText("%s%s", pvpIcon, name)
            else
                local difficultyColor = GetCreatureDifficultyColor(targetLevel)
                local levelColor = self:RGBToHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

                frame.name:SetFormattedText("%s%s%d|r %s", pvpIcon, levelColor, targetLevel, name)
            end
        else
            frame.name:SetFormattedText("%s%s", pvpIcon, name)
        end
    end
end

function nPlates:FrameSetup(frame)
    if ( frame:IsForbidden() ) then return end

    local healthBar = frame.healthBar
    local castBar = frame.CastBar

    self:SetBorder(healthBar)
    self:SetBorder(castBar)
    self:SetBorder(castBar.Icon)

    frame.name:ClearAllPoints()
    frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 5)

    healthBar:SetStatusBarTexture(self.statusBar)
    healthBar.barTexture:SetTexture(self.statusBar)
    healthBar.border:Hide()

    healthBar:SetPoint("BOTTOMLEFT", frame, 4, 4)
    healthBar:SetPoint("BOTTOMRIGHT", frame, -4, 4)

    castBar:SetHeight(10)
    castBar:SetStatusBarTexture(self.statusBar)

    castBar.Border:SetTexture(nil)

    castBar.Text:ClearAllPoints()
    castBar.Text:SetFontObject("nPlate_CastbarFont")
    castBar.Text:SetPoint("LEFT", castBar, 2, 0)

    if ( not castBar.CastTime ) then
        castBar.CastTime = castBar:CreateFontString(nil, "OVERLAY")
        castBar.CastTime:SetFontObject("nPlate_CastbarTimerFont")
        castBar.CastTime:SetPoint("BOTTOMRIGHT", castBar.Icon)
    end

    if ( not castBar.IconBackground ) then
        castBar.IconBackground = castBar:CreateTexture("$parent_Background", "BACKGROUND")
        castBar.IconBackground:SetAllPoints(castBar.Icon)
        castBar.IconBackground:SetTexture([[Interface\Icons\Ability_DualWield]])
        castBar.IconBackground:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    castBar:SetScript("OnValueChanged", function(castBar)
        self:UpdateCastbarTimer(castBar)
    end)

    frame.LevelFrame:Hide()
    frame.LevelFrame:ClearAllPoints()
end

function nPlates:SetupAnchors(frame, setupOptions)
    if ( frame:IsForbidden() ) then return end

    local healthBar = frame.healthBar
    local castBar = frame.CastBar

    healthBar:SetHeight(11)

    castBar.Icon:SetSize(26, 26)
    castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    castBar.Icon:ClearAllPoints()
    castBar.Icon:SetIgnoreParentAlpha(false)
    castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", 4.9, 0)

    castBar:ClearAllPoints()
    castBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -5)
    castBar:SetPoint("TOPRIGHT", healthBar,"BOTTOMRIGHT", 0, -5 )

    castBar.BorderShield:ClearAllPoints()
end

hooksecurefunc("CompactUnitFrame_OnEvent", CUF_OnEvents)
hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(self) nPlates:UpdateStatusText(self)  end)
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(self) nPlates:UpdateHealthColor(self)  end)
hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(self) nPlates:UpdateSelectionHighlight(self)  end)
hooksecurefunc("CompactUnitFrame_UpdateName", function(self) nPlates:UpdateName(self)  end)
hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(self) nPlates:FrameSetup(self)  end)
hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", function(self) nPlates:SetupAnchors(self)  end)
hooksecurefunc("Nameplate_CastBar_AdjustPosition", function(self)  nPlates:UpdateCastbar(self)  end)
