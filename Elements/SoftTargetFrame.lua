local _, nPlates = ...

function nPlates.UpdateSoftTarget(self)
    self.SoftTargetFrame = self:GetUnitFrame().SoftTargetFrame
    self.SoftTargetFrame:ClearAllPoints()
    self.SoftTargetFrame:SetPoint("RIGHT", self.RaidTargetIndicator, "LEFT", -5, 0)
    self.SoftTargetFrame:SetCollapsesLayout(true)
    self.SoftTargetFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    self.SoftTargetFrame.Overlay = self.SoftTargetFrame:CreateTexture("$parentOverlay", "OVERLAY")
    self.SoftTargetFrame.Overlay:SetTexture([[Interface\AddOns\nPlates\Media\borderTexture]])
    self.SoftTargetFrame.Overlay:SetTexCoord(0, 1, 0, 1)
    self.SoftTargetFrame.Overlay:SetPoint("TOPRIGHT", self.SoftTargetFrame.Icon, 1.35, 1.35)
    self.SoftTargetFrame.Overlay:SetPoint("BOTTOMLEFT", self.SoftTargetFrame.Icon, -1.35, -1.35)
    self.SoftTargetFrame.Overlay:SetVertexColor(0.40, 0.40, 0.40)
    self.SoftTargetFrame.Overlay:SetIgnoreParentAlpha(false)
    self.SoftTargetFrame.Overlay:Hide()

    -- Have to hook the Icon because Blizzard doesn't hide the entire frame just the icon.
    self.SoftTargetFrame.Icon:HookScript("OnShow", function() self.SoftTargetFrame.Overlay:Show()  end)
    self.SoftTargetFrame.Icon:HookScript("OnHide", function() self.SoftTargetFrame.Overlay:Hide()  end)
end
