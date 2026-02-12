local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
    local element = self.ClassificationIndicator

    if ( not unit or self.unit ~= unit or self:IsWidgetMode() ) then
        element:Hide()
        return
    end

    --[[ Callback: ClassificationIndicator:PreUpdate()
    Called before the element has been updated.

    * self - the ClassificationIndicator element
    --]]
    if element.PreUpdate then
        element:PreUpdate()
    end

    local classification = UnitClassification(self.unit)

    if ( classification == "elite" or classification == "worldboss" ) then
        element:SetAtlas("nameplates-icon-elite-gold")
        element:Show()
    elseif ( classification == "rareelite" or classification == "rare" ) then
        element:SetAtlas("nameplates-icon-elite-silver")
        element:Show()
    else
        element:Hide()
    end

    --[[ Callback: ClassificationIndicator:PostUpdate()
    Called after the element has been updated.

    * self - the ClassificationIndicator element
    --]]
    if element.PostUpdate then
        return element:PostUpdate()
    end
end

local function Path(self, ...)
    --[[ Override: ClassificationIndicator.Override(self, event, ...)
    Used to completely override the internal update function.

    * self  - the parent object
    * event - the event triggering the update (string)
    * ...   - the arguments accompanying the event
    --]]
    return (self.ClassificationIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    local element = self.ClassificationIndicator

    if ( element ) then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)

        return true
    end
end

local function Disable(self)
    local element = self.ClassificationIndicator
    if ( element ) then
        self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED", Path)
        element:Hide()
    end
end

oUF:AddElement("ClassificationIndicator", Path, Enable, Disable)
