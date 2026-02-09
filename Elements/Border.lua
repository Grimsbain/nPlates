local _, nPlates = ...

function nPlates:SetCastbarBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    self:SetBeautyBorderColor(frame, color)
    self:SetBeautyBorderColor(frame.Icon, color)
end

function nPlates:HasBeautyBorder(frame)
    if ( not frame ) then
        return
    end

    return frame.Border ~= nil
end

function nPlates:SetBeautyBorderColor(frame, color)
    if ( not frame or not color ) then
        return
    end

    if ( self:HasBeautyBorder(frame) ) then
        for _, texture in ipairs(frame.Border) do
            texture:SetVertexColor(color:GetRGB())
        end
    end
end

function nPlates:SetBeautyBorderColorByRGB(frame, r, g, b)
    if ( not frame or not r or not g or not b ) then
        return
    end

    if ( self:HasBeautyBorder(frame) ) then
        for _, texture in ipairs(frame.Border) do
            texture:SetVertexColor(r, g, b)
        end
    end
end

function nPlates:SetBorder(frame)
    if ( self:HasBeautyBorder(frame) ) then
        return
    end

    local padding = 3
    local size = 12
    local space = size/3.5
    local objectType = frame:GetObjectType()
    local textureParent = (objectType == "Frame" or objectType == "StatusBar") and frame or frame:GetParent()

    frame.Border = {}
    frame.Shadow = {}

    for i = 1, 8 do
        frame.Border[i] = textureParent:CreateTexture("$parentBeautyBorder"..i, "OVERLAY")
        frame.Border[i]:SetTexture([[Interface\AddOns\nPlates\Media\borderTexture]])
        frame.Border[i]:SetSize(size, size)
        frame.Border[i]:SetVertexColor(self.Media.DefaultBorderColor:GetRGB())
        frame.Border[i]:ClearAllPoints()

        frame.Shadow[i] = textureParent:CreateTexture("$parentBeautyShadow"..i, "BORDER")
        frame.Shadow[i]:SetTexture([[Interface\AddOns\nPlates\Media\textureShadow]])
        frame.Shadow[i]:SetSize(size, size)
        frame.Shadow[i]:SetVertexColor(0, 0, 0, 1)
        frame.Shadow[i]:ClearAllPoints()
    end

    -- TOPLEFT
    frame.Border[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.Border[1]:SetPoint("TOPLEFT", frame, -padding, padding)
    -- TOPRIGHT
    frame.Border[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.Border[2]:SetPoint("TOPRIGHT", frame, padding, padding)
    -- BOTTOMLEFT
    frame.Border[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.Border[3]:SetPoint("BOTTOMLEFT", frame, -padding, -padding)
    -- BOTTOMRIGHT
    frame.Border[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.Border[4]:SetPoint("BOTTOMRIGHT", frame, padding, -padding)
    -- TOP
    frame.Border[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.Border[5]:SetPoint("TOPLEFT", frame.Border[1], "TOPRIGHT")
    frame.Border[5]:SetPoint("TOPRIGHT", frame.Border[2], "TOPLEFT")
    -- BOTTOM
    frame.Border[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.Border[6]:SetPoint("BOTTOMLEFT", frame.Border[3], "BOTTOMRIGHT")
    frame.Border[6]:SetPoint("BOTTOMRIGHT", frame.Border[4], "BOTTOMLEFT")
    -- LEFT
    frame.Border[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.Border[7]:SetPoint("TOPLEFT", frame.Border[1], "BOTTOMLEFT")
    frame.Border[7]:SetPoint("BOTTOMLEFT", frame.Border[3], "TOPLEFT")
    -- RIGHT
    frame.Border[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.Border[8]:SetPoint("TOPRIGHT", frame.Border[2], "BOTTOMRIGHT")
    frame.Border[8]:SetPoint("BOTTOMRIGHT", frame.Border[4], "TOPRIGHT")

    -- TOPLEFT
    frame.Shadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
    frame.Shadow[1]:SetPoint("TOPLEFT", frame, -padding-space, padding+space)
    -- TOPRIGHT
    frame.Shadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
    frame.Shadow[2]:SetPoint("TOPRIGHT", frame, padding+space, padding+space)
    -- BOTTOMLEFT
    frame.Shadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
    frame.Shadow[3]:SetPoint("BOTTOMLEFT", frame, -padding-space, -padding-space)
    -- BOTTOMRIGHT
    frame.Shadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
    frame.Shadow[4]:SetPoint("BOTTOMRIGHT", frame, padding+space, -padding-space)
    -- TOP
    frame.Shadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
    frame.Shadow[5]:SetPoint("TOPLEFT", frame.Shadow[1], "TOPRIGHT")
    frame.Shadow[5]:SetPoint("TOPRIGHT", frame.Shadow[2], "TOPLEFT")
    -- BOTTOM
    frame.Shadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    frame.Shadow[6]:SetPoint("BOTTOMLEFT", frame.Shadow[3], "BOTTOMRIGHT")
    frame.Shadow[6]:SetPoint("BOTTOMRIGHT", frame.Shadow[4], "BOTTOMLEFT")
    -- LEFT
    frame.Shadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    frame.Shadow[7]:SetPoint("TOPLEFT", frame.Shadow[1], "BOTTOMLEFT")
    frame.Shadow[7]:SetPoint("BOTTOMLEFT", frame.Shadow[3], "TOPLEFT")
    -- RIGHT
    frame.Shadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    frame.Shadow[8]:SetPoint("TOPRIGHT", frame.Shadow[2], "BOTTOMRIGHT")
    frame.Shadow[8]:SetPoint("BOTTOMRIGHT", frame.Shadow[4], "TOPRIGHT")
end
