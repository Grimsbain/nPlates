
local _, nPlates = ...
local cfg = nPlates.Config

local iconOverlay = 'Interface\\AddOns\\nPlates\\media\\textureIconOverlay'
DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(0, 0, 0, .55)

local function RGBHex(r, g, b)
    if (type(r) == 'table') then
        if (r.r) then
            r, g, b = r.r, r.g, r.b
        else
            r, g, b = unpack(r)
        end
    end

    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local function FormatValue(number)
    if (number >= 1e6) then
        return tonumber(format('%.1f', number/1e6))..'m'
    elseif (number >= 1e3) then
        return tonumber(format('%.1f', number/1e3))..'k'
    else
        return number
    end
end

    -- Updated Health Text

local function UpdateHealthText(frame)
    local health = UnitHealth(frame.displayedUnit)
    local maxHealth = UnitHealthMax(frame.displayedUnit)
    local perc = (health/maxHealth)*100
    frame.healthBar.healthString:SetText('')

    if (perc >= 100 and health > 5 and cfg.showFullHP) then
        frame.healthBar.healthString:SetFormattedText('%s', FormatValue(health))
    elseif (perc < 100 and health > 5) then
        frame.healthBar.healthString:SetFormattedText('%s - %.0f%%', FormatValue(health), perc-0.5)
    else
        frame.healthBar.healthString:SetText('')
    end
end

    -- Tank Role/Spec Check

local function IsTank()
    local assignedRole = UnitGroupRolesAssigned("player")
    if assignedRole == "TANK" then return true end
    local role = GetSpecializationRole(GetSpecialization())
    if role == "TANK" then return true end
    return false
end

    -- Setup Frames

local function SetupNamePlate(frame, setupOptions, frameOptions)

    frame.name:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')

    frame.healthBar:SetHeight(12)
    frame.healthBar:CreateBeautyBorder(7)
    frame.healthBar:SetBeautyBorderPadding(1)
    frame.healthBar:SetBeautyShadowColor(0,0,0)

    if (not frame.healthBar.healthString) then
        frame.healthBar.healthString = frame.healthBar:CreateFontString('$parentHeathValue', 'OVERLAY')
        frame.healthBar.healthString:SetPoint('CENTER', frame.healthBar, 0, 0)
        frame.healthBar.healthString:SetFont('Fonts\\ARIALN.ttf', 10, 'OUTLINE')
    end

    frame.healthBar:SetScript('OnValueChanged', function()
        UpdateHealthText(frame)
    end)

    frame.castBar:CreateBeautyBorder(4)
    frame.castBar:SetBeautyBorderPadding(1)
    frame.castBar:SetBeautyShadowColor(0,0,0)

    frame.castBar.Icon:SetSize(20,20)
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMRIGHT", 4, 0)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    frame.castBar.Icon.Overlay = frame.castBar:CreateTexture('$parentIconGlow', 'OVERLAY', nil, 7)
    frame.castBar.Icon.Overlay:SetTexCoord(0, 1, 0, 1)
    frame.castBar.Icon.Overlay:ClearAllPoints()
    frame.castBar.Icon.Overlay:SetPoint('TOPRIGHT', frame.castBar.Icon, 1.85, 1.85)
    frame.castBar.Icon.Overlay:SetPoint('BOTTOMLEFT', frame.castBar.Icon, -1.85, -1.85)
    frame.castBar.Icon.Overlay:SetTexture(iconOverlay)
    frame.castBar.Icon.Overlay:SetVertexColor(.8,.8,.8)

    ClassNameplateManaBarFrame:CreateBeautyBorder(4)
    ClassNameplateManaBarFrame:SetBeautyBorderPadding(0)
    ClassNameplateManaBarFrame:SetBeautyShadowColor(0,0,0)

end
hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", SetupNamePlate)

    -- Update Name

local function UpdateName(frame)

    local playerLevel = UnitLevel ("player")
    local targetLevel = UnitLevel(frame.displayedUnit)
    local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
    local levelColor = RGBHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

    if (targetLevel == -1) then
        frame.name:SetText(GetUnitName(frame.unit, true));
    else
        frame.name:SetText('|cffffff00|r'..levelColor..targetLevel..'|r '..GetUnitName(frame.unit, true));
    end

    if not cfg.enableTankMode and not IsTank() then return end
    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
    if isTanking and threatStatus then
        if threatStatus >= 3 then
            frame.name:SetTextColor(0,1,0)
        elseif threatStatus == 2 then
            frame.name:SetTextColor(1,0.6,0.2)
        end
    end

end
hooksecurefunc("CompactUnitFrame_UpdateName", UpdateName)