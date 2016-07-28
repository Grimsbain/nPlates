
local _, nPlates = ...

nPlates.Config = {
    -- Colors by threat. Green = Tanking, Orange = Loosing Threat, Red = Lost Threat
    enableTankMode = false,
    colorNameWithThreat = false,

    -- Use class colors on all player nameplates.
    alwaysUseClassColors = true,
    displaySelectionHighlight = false,
    showClassificationIndicator = true,
    
    -- 0 to 1. Default is .5.
    nameplateMinAlpha = .8,
    dontClampToBorder = true,
    dontZoom = false,
        
    showFullHP = true,
    showLevel = true,
    showServerName = false,
    abbrevLongNames = false,

    showTotemIcon = false,
}