--------------------------------------------------
-- BLACKOUT UI
-- Core/Core.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- ADDON INFORMATION
--------------------------------------------------

BlackoutUI.name = addonName
BlackoutUI.version = "0.2.0"

--------------------------------------------------
-- COLORS
--------------------------------------------------

BlackoutUI.colors = {

    background = {
        0.025,
        0.025,
        0.025,
        0.96
    },

    backgroundLight = {
        0.055,
        0.055,
        0.055,
        1
    },

    border = {
        0.15,
        0.15,
        0.15,
        1
    },

    borderBright = {
        0.30,
        0.30,
        0.30,
        1
    },

    health = {
        0.18,
        0.72,
        0.30,
        1
    },

    mana = {
        0.12,
        0.42,
        0.90,
        1
    },

    rage = {
        0.85,
        0.15,
        0.15,
        1
    },

    energy = {
        0.90,
        0.75,
        0.15,
        1
    },

    text = {
        0.95,
        0.95,
        0.95,
        1
    },

    textDim = {
        0.60,
        0.60,
        0.60,
        1
    }
}

--------------------------------------------------
-- HELPER: APPLY COLOR
--------------------------------------------------

function BlackoutUI:GetColor(name)
    local color = self.colors[name]

    if not color then
        return 1, 1, 1, 1
    end

    return unpack(color)
end

--------------------------------------------------
-- HELPER: CREATE SOLID TEXTURE
--------------------------------------------------

function BlackoutUI:CreateBackground(parent, colorName)
    local texture = parent:CreateTexture(nil, "BACKGROUND")

    texture:SetAllPoints(parent)

    texture:SetColorTexture(
        self:GetColor(colorName or "background")
    )

    return texture
end

--------------------------------------------------
-- HELPER: CREATE SQUARE BORDER
--------------------------------------------------

function BlackoutUI:CreateBorder(frame, size, colorName)
    size = size or 1
    colorName = colorName or "border"

    local r, g, b, a = self:GetColor(colorName)

    local top = frame:CreateTexture(nil, "OVERLAY")
    top:SetColorTexture(r, g, b, a)
    top:SetPoint("TOPLEFT", frame, "TOPLEFT", -size, size)
    top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", size, size)
    top:SetHeight(size)

    local bottom = frame:CreateTexture(nil, "OVERLAY")
    bottom:SetColorTexture(r, g, b, a)
    bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -size, -size)
    bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", size, -size)
    bottom:SetHeight(size)

    local left = frame:CreateTexture(nil, "OVERLAY")
    left:SetColorTexture(r, g, b, a)
    left:SetPoint("TOPLEFT", frame, "TOPLEFT", -size, size)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -size, -size)
    left:SetWidth(size)

    local right = frame:CreateTexture(nil, "OVERLAY")
    right:SetColorTexture(r, g, b, a)
    right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", size, size)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", size, -size)
    right:SetWidth(size)

    frame.BlackoutBorder = {
        top = top,
        bottom = bottom,
        left = left,
        right = right
    }
end

--------------------------------------------------
-- HELPER: FORMAT LARGE NUMBERS
--------------------------------------------------

function BlackoutUI:FormatNumber(value)
    value = tonumber(value) or 0

    if value >= 1000000 then
        return string.format(
            "%.1fm",
            value / 1000000
        )
    elseif value >= 1000 then
        return string.format(
            "%.1fk",
            value / 1000
        )
    end

    return tostring(value)
end

--------------------------------------------------
-- HELPER: CREATE FONT
--------------------------------------------------

function BlackoutUI:CreateFont(parent, size)
    local text = parent:CreateFontString(nil, "OVERLAY")

    text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        size or 11,
        "OUTLINE"
    )

    text:SetTextColor(
        self:GetColor("text")
    )

    return text
end

--------------------------------------------------
-- ADDON LOADING
--------------------------------------------------

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript(
    "OnEvent",
    function(self, event, loadedAddon)
        if loadedAddon ~= addonName then
            return
        end

        print(
            "|cff666666[|r" ..
            "|cffffffffBlackoutUI|r" ..
            "|cff666666]|r " ..
            "Version " ..
            BlackoutUI.version ..
            " loaded."
        )

        self:UnregisterEvent("ADDON_LOADED")
    end
)
