-- Kill Unused Options

for _, button in pairs({
    'AggroFlash',
}) do
    _G['InterfaceOptionsNamesPanelUnitNameplates'..button]:SetAlpha(0)
    _G['InterfaceOptionsNamesPanelUnitNameplates'..button]:SetScale(0.00001)
    _G['InterfaceOptionsNamesPanelUnitNameplates'..button]:EnableMouse(false)
end