
local _, nPlates = ...

nPlates.Config = {
    -- Colors by threat. Green = Tanking, Orange = Loosing Threat, Red = Lost Threat
    enableTankMode = false,
    colorNameWithThreat = false,

    showHP = true, -- Disable if you are having fps issues.
    showFullHP = true,
    showLevel = true,
    showServerName = false,
    abbrevLongNames = true,

    -- Use class colors on all player nameplates.
    alwaysUseClassColors = true,
    -- Turns on/off selection highlight.
    displaySelectionHighlight = true,
    -- Turns on/off elite icon.
    showClassificationIndicator = true,
    
    -- Shows the totems icon above their nameplates. Only works for other players totems.
    showTotemIcon = false,

    -- CVar Settings (False will set them back to default or use /nplatereset ingame to rest all of them.)
    -- Default is 1. 1-1.2 Recommened.
    nameplateScale = false,
    -- 0 to 1. Default is .5.
    nameplateMinAlpha = .8,
    -- Prevents nameplates from sticking to the edge of the screen.
    dontClampToBorder = true,
    -- Makes all nameplates the same size. False may cause fps issues.
    dontZoom = true,
}