local _, nPlates = ...

local englishFaction, localizedFaction = UnitFactionGroup("player")
local _, playerClass = UnitClass("player")

nPlatesMixin = {}

function nPlatesMixin:OnLoad()
    local events = {
        "ADDON_LOADED",
        "NAME_PLATE_CREATED",
        "NAME_PLATE_UNIT_ADDED",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
        "RAID_TARGET_UPDATE",
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
    elseif ( event == "NAME_PLATE_CREATED" ) then
        local namePlateFrameBase = ...
        nPlates:SetupNameplate(namePlateFrameBase)
    elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then
        local unit = ...
        nPlates:FixPlayerBorder(unit)

        local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        nPlates:UpdateNameplate(namePlateFrameBase)
    elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
        if ( not nPlatesDB.CombatPlates ) then
            return
        end
        C_CVar.SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
    elseif ( event == "RAID_TARGET_UPDATE" ) then
        nPlates:UpdateRaidMarkerColoring()
    end
end

    -- Hook CompactUnitFrame OnEvent function.

local function CUF_OnEvents(self, event, ...)
    if ( self:IsForbidden() ) then return end
    if ( not self.isNameplate ) then return end

    local unit = ...

    if ( event == "PLAYER_TARGET_CHANGED" ) then
        nPlates:UpdateBuffFrameAnchorsByFrame(self)
    else
        -- local unitMatches = unit == self.unit or unit == self.displayedUnit
		-- if ( unitMatches ) then
            -- if ( event == "UNIT_AURA") then
            -- end
        -- end
    end
end

    -- Update Castbar Time

local function UpdateCastbarTimer(self)
    if ( self.unit ) then
        if ( self.castBar.casting ) then
            local current = self.castBar.maxValue - self.castBar.value
            if ( current > 0 ) then
                self.castBar.CastTime:SetText(nPlates:FormatTime(current))
            end
        else
            if ( self.castBar.value > 0 ) then
                self.castBar.CastTime:SetText(nPlates:FormatTime(self.castBar.value))
            end
        end
    end
end

    --- Skin Castbar

local function UpdateCastbar(self)

        -- Castbar Overlay Coloring

    local name, texture, isTradeSkill, notInterruptible

    if ( self.unit ) then
        if ( self.castBar.casting ) then
            name, _, texture, _, _, isTradeSkill, _, notInterruptible = UnitCastingInfo(self.unit)
        else
            name, _, texture, _, _, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit)
        end

        if ( isTradeSkill or not UnitCanAttack("player", self.unit) ) then
            nPlates:SetCastbarBorderColor(self, nPlates.defaultBorderColor)
        else
            nPlates:UpdateInterruptibleState(self.castBar, notInterruptible)
        end
    end

    if ( self.castBar.Background ) then
        self.castBar.Background:SetShown(not self.castBar.Icon:IsVisible())
    end

        -- Abbreviate Long Spell Names

    if ( not nPlates:IsUsingLargerNamePlateStyle() ) then
        local name = self.castBar.Text:GetText()
        if ( name ) then
            name = nPlates:Abbrev(name, 20)
            self.castBar.Text:SetText(name)
        end
    end
end

    -- Updated Health Text

local function UpdateStatusText(self)
    if ( self:IsForbidden() ) then return end
    if ( self.statusText ) then return end

    if ( not self.healthBar.value ) then
        self.healthBar.value = self.healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
        self.healthBar.value:SetPoint("CENTER", self.healthBar)
        self.healthBar.value:SetFontObject("nPlate_NameFont10")
    end

    local option = nPlatesDB.CurrentHealthOption

    if ( option ~= "HealthDisabled" ) then
        local health = UnitHealth(self.displayedUnit)
        local maxHealth = UnitHealthMax(self.displayedUnit)
        local perc = math.floor(100 * (health/maxHealth))

        if ( health > 0 ) then
            if ( option == "HealthBoth" and perc >= 100 ) then
                self.healthBar.value:SetFormattedText("%s", nPlates:FormatValue(health))
            elseif ( option == "HealthBoth" ) then
                self.healthBar.value:SetFormattedText("%s - %s%%", nPlates:FormatValue(health), perc)
            elseif ( option == "HealthValueOnly" ) then
                self.healthBar.value:SetFormattedText("%s", nPlates:FormatValue(health))
            elseif ( option == "HealthPercOnly" ) then
                self.healthBar.value:SetFormattedText("%s%%", perc)
            else
                self.healthBar.value:SetText("")
            end
        else
            self.healthBar.value:SetText("")
        end

        self.healthBar.value:Show()
    else
        self.healthBar.value:Hide()
    end
end

    -- Update Health Color

local function UpdateHealthColor(self)
    if ( self:IsForbidden() ) then return end
    if ( not self.isNameplate ) then return end

    local r, g, b
    if ( not UnitIsConnected(self.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( self.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = self.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            local localizedClass, englishClass = UnitClass(self.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            local raidMarker = GetRaidTargetIndex(self.displayedUnit)

            if ( (self.optionTable.allowClassColorsForNPCs or UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay(self.unit)) and classColor and nPlates:UseClassColors(englishFaction, self.unit) ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(self) ) then
                r, g, b = 0.1, 0.1, 0.1
            elseif ( nPlatesDB.RaidMarkerColoring and raidMarker ) then
                local markerColor = nPlates.markerColors[tostring(raidMarker)]
                r, g, b = markerColor.r, markerColor.g, markerColor.b
            elseif ( nPlatesDB.FelExplosives and nPlates:IsPriority(self.displayedUnit) ) then
                r, g, b = nPlatesDB.FelExplosivesColor.r, nPlatesDB.FelExplosivesColor.g, nPlatesDB.FelExplosivesColor.b
            elseif ( self.optionTable.colorHealthBySelection ) then
                if ( self.optionTable.considerSelectionInCombatAsHostile and nPlates:IsOnThreatListWithPlayer(self.displayedUnit) ) then
                    if ( nPlatesDB.TankMode ) then
                        local target = self.displayedUnit.."target"
                        local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.displayedUnit)
                        if ( isTanking and threatStatus ) then
                            if ( threatStatus >= 3 ) then
                                r, g, b = 0.0, 1.0, 0.0
                            elseif ( threatStatus == 2 ) then
                                r, g, b = 1.0, 0.6, 0.2
                            end
                        elseif ( nPlates:UseOffTankColor(target) ) then
                            r, g, b = nPlatesDB.OffTankColor.r, nPlatesDB.OffTankColor.g, nPlatesDB.OffTankColor.b
                        else
                            r, g, b = 1.0, 0.0, 0.0
                        end
                    else
                        r, g, b = 1.0, 0.0, 0.0
                    end
                else
                    r, g, b = UnitSelectionColor(self.unit, self.optionTable.colorHealthWithExtendedColors)
                end
            elseif ( UnitIsFriend("player", self.unit) ) then
                r, g, b = 0.0, 1.0, 0.0
            else
                r, g, b = 1.0, 0.0, 0.0
            end
        end
    end

    -- Execute Range Coloring

    if ( nPlatesDB.ShowExecuteRange and nPlates:IsInExecuteRange(self.displayedUnit) ) then
        r, g, b = nPlatesDB.ExecuteColor.r, nPlatesDB.ExecuteColor.g, nPlatesDB.ExecuteColor.b
    end

    -- Update Healthbar Color

    local currentR, currentG, currentB = self.healthBar:GetStatusBarColor()

    if ( r ~= currentR or g ~= currentG or b ~= currentB ) then
        self.healthBar:SetStatusBarColor(r, g, b)

        if ( self.optionTable.colorHealthWithExtendedColors ) then
            self.selectionHighlight:SetVertexColor(r, g, b)
        else
            self.selectionHighlight:SetVertexColor(1.0, 1.0, 1.0)
        end

        -- Update Border Color
        nPlates:SetHealthBorderColor(self, r, g, b)
    end
end

-- Update Border Color

local function UpdateSelectionHighlight(self)
    if ( self:IsForbidden() ) then return end
    if ( not self.isNameplate ) then return end

    nPlates:SetHealthBorderColor(self)
end

    -- Update Name

function nPlates.UpdateName(self)
    if ( self:IsForbidden() ) then return end
    if ( not self.isNameplate ) then return end

    if ( not ShouldShowName(self) ) then
        self.name:Hide()
    else
            -- Update Name Size

        nPlates:UpdateNameSize(self)

            -- PvP Icon

        local pvpIcon = nPlates:PvPIcon(self.displayedUnit)

            -- Class Color Names

        if ( UnitIsPlayer(self.displayedUnit) ) then
            local r, g, b = self.healthBar:GetStatusBarColor()
            self.name:SetTextColor(r, g, b)
        end

        local name, server = UnitName(self.displayedUnit)

            -- Shorten Long Names

        if ( nPlatesDB.AbrrevLongNames ) then
            name = nPlates:Abbrev(name, 20)
        end

            -- Server Name

        if ( nPlatesDB.ShowServerName ) then
            if ( server ) then
                name = name.." - "..server
            end
        end

            -- Level

        if ( nPlatesDB.ShowLevel ) then
            local targetLevel = UnitLevel(self.displayedUnit)
            local difficultyColor = GetCreatureDifficultyColor(targetLevel)
            local levelColor = nPlates:RGBToHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

            if ( targetLevel == -1 ) then
                self.name:SetFormattedText("%s%s", pvpIcon, name)
            else
                self.name:SetFormattedText("%s%s%d|r %s", pvpIcon, levelColor, targetLevel, name)
            end
        else
            self.name:SetFormattedText("%s%s", pvpIcon, name)
        end

            -- Color Name To Threat Status

        if ( nPlatesDB.ColorNameByThreat ) then
            local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.displayedUnit)
            if ( isTanking and threatStatus ) then
                if ( threatStatus >= 3 ) then
                    self.name:SetTextColor(0.0, 1.0, 0.0)
                elseif ( threatStatus == 2 ) then
                    self.name:SetTextColor(1.0, 0.6, 0.2)
                end
            else
                local target = self.displayedUnit.."target"
                if ( nPlates:UseOffTankColor(target) ) then
                    self.name:SetTextColor(nPlatesDB.OffTankColor.r, nPlatesDB.OffTankColor.g, nPlatesDB.OffTankColor.b)
                end
            end
        end
    end
end

    -- Skin Nameplate

local function FrameSetup(self, options)
    if ( self:IsForbidden() ) then return end

        -- Healthbar

    self.healthBar:SetStatusBarTexture(nPlates.statusBar)
    self.healthBar.barTexture:SetTexture(nPlates.statusBar)

        -- Healthbar Border

    self.healthBar.border:Hide()

    if ( not self.healthBar.beautyBorder ) then
        nPlates:SetBorder(self.healthBar)
    end

        -- Castbar

    self.castBar:SetHeight(10)
    self.castBar:SetStatusBarTexture(nPlates.statusBar)

        -- Castbar Border

    if ( not self.castBar.beautyBorder ) then
        nPlates:SetBorder(self.castBar)
    end

        -- Spell Name

    self.castBar.Text:ClearAllPoints()
    self.castBar.Text:SetFontObject("nPlate_CastbarFont")
    self.castBar.Text:SetPoint("LEFT", self.castBar, 2, 0)

        -- Set Castbar Timer

    if ( not self.castBar.CastTime ) then
        self.castBar.CastTime = self.castBar:CreateFontString(nil, "OVERLAY")
        self.castBar.CastTime:SetFontObject("nPlate_CastbarTimerFont")
        self.castBar.CastTime:SetPoint("BOTTOMRIGHT", self.castBar.Icon)
    end

        -- Castbar Icon Border

    if ( not self.castBar.Icon.beautyBorder ) then
        nPlates:SetBorder(self.castBar.Icon)
    end

        -- Castbar Icon Background

    if ( not self.castBar.Background ) then
        self.castBar.Background = self.castBar:CreateTexture("$parent_Background", "BACKGROUND")
        self.castBar.Background:SetAllPoints(self.castBar.Icon)
        self.castBar.Background:SetTexture([[Interface\Icons\Ability_DualWield]])
        self.castBar.Background:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

        -- Update Castbar

    self.castBar:SetScript("OnValueChanged", function()
        UpdateCastbarTimer(self)
    end)

    self.castBar:SetScript("OnShow", function()
        UpdateCastbar(self)
    end)
end

local function SetupAnchors(self, setupOptions)
    if ( self:IsForbidden() ) then return end

        -- Healthbar

    self.healthBar:SetHeight(11)

    if ( setupOptions.healthBarAlpha ~= 1 ) then
        self.healthBar:SetPoint("BOTTOMLEFT", self.castBar, "TOPLEFT", 0, 5)
        self.healthBar:SetPoint("BOTTOMRIGHT", self.castBar, "TOPRIGHT", 0, 5)
    end

        -- Castbar

    self.castBar.Icon:SetSize(26, 26)
    self.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.castBar.Icon:ClearAllPoints()
    self.castBar.Icon:SetPoint("BOTTOMLEFT", self.castBar, "BOTTOMRIGHT", 4.9, 0)

        -- Hide Border Shield

    self.castBar.BorderShield:ClearAllPoints()
end

    -- Setup Hooks

hooksecurefunc("CompactUnitFrame_OnEvent", CUF_OnEvents)
hooksecurefunc("CompactUnitFrame_UpdateStatusText", UpdateStatusText)
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", UpdateHealthColor)
hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", UpdateSelectionHighlight)
hooksecurefunc("CompactUnitFrame_UpdateName", nPlates.UpdateName)
hooksecurefunc("DefaultCompactNamePlateFrameSetup", FrameSetup)
hooksecurefunc("DefaultCompactNamePlateFrameAnchorInternal", SetupAnchors)
