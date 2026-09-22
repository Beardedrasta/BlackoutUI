------------------------------------------------------------
-- BlackoutUI
-- Tooltips.lua
-- Tooltip styling - Step 1
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.Tooltips = BlackoutUI.Tooltips or {}
local Tooltips = BlackoutUI.Tooltips

------------------------------------------------------------
-- DEFAULTS
------------------------------------------------------------

local DEFAULTS = {
    enabled = true,
    scale = 1.00,
    opacity = 0.96,
    classColorBorder = true,
    itemQualityBorder = true,
}

local BASE_BORDER = {
    0.22,
    0.66,
    0.92,
    1,
}

------------------------------------------------------------
-- DATABASE
------------------------------------------------------------

local function GetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.Tooltips =
        BlackoutUIDB.Config.Tooltips or {}

    local db = BlackoutUIDB.Config.Tooltips

    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

------------------------------------------------------------
-- TOOLTIP LIST
------------------------------------------------------------

local TooltipFrames = {
    GameTooltip,
    ItemRefTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2,
    ShoppingTooltip3,
}

------------------------------------------------------------
-- BACKDROP
------------------------------------------------------------

local function EnsureBackdrop(tooltip)
    if not tooltip
        or tooltip.BlackoutBackdrop then
        return
    end

    local backdrop =
        CreateFrame(
            "Frame",
            nil,
            tooltip,
            "BackdropTemplate"
        )

    backdrop:SetPoint(
        "TOPLEFT",
        tooltip,
        "TOPLEFT",
        -3,
        3
    )

    backdrop:SetPoint(
        "BOTTOMRIGHT",
        tooltip,
        "BOTTOMRIGHT",
        3,
        -3
    )

    backdrop:SetFrameLevel(
        math.max(
            0,
            tooltip:GetFrameLevel() - 1
        )
    )

    backdrop:SetBackdrop({
        bgFile =
        "Interface\\Buttons\\WHITE8x8",

        edgeFile =
        "Interface\\Buttons\\WHITE8x8",

        edgeSize = 1,
    })

    tooltip.BlackoutBackdrop = backdrop
end

local function SetBorder(
    tooltip,
    r,
    g,
    b,
    a
)
    EnsureBackdrop(tooltip)

    if tooltip.BlackoutBackdrop then
        tooltip.BlackoutBackdrop:SetBackdropBorderColor(
            r or BASE_BORDER[1],
            g or BASE_BORDER[2],
            b or BASE_BORDER[3],
            a or 1
        )
    end
end

local function ApplyBaseStyle(tooltip)
    local db = GetConfig()

    if db.enabled == false
        or not tooltip then
        return
    end

    EnsureBackdrop(tooltip)

    tooltip:SetScale(
        db.scale or 1
    )

    if tooltip.BlackoutBackdrop then
        tooltip.BlackoutBackdrop:SetBackdropColor(
            0.008,
            0.008,
            0.008,
            db.opacity or 0.96
        )

        tooltip.BlackoutBackdrop:SetBackdropBorderColor(
            unpack(BASE_BORDER)
        )

        tooltip.BlackoutBackdrop:Show()
    end

    -- Make Blizzard's own tooltip background transparent so the
    -- Blackout backdrop is the visible presentation.
    if tooltip.SetBackdropColor then
        tooltip:SetBackdropColor(
            0,
            0,
            0,
            0
        )
    end

    if tooltip.SetBackdropBorderColor then
        tooltip:SetBackdropBorderColor(
            0,
            0,
            0,
            0
        )
    end
end

------------------------------------------------------------
-- ITEM QUALITY
------------------------------------------------------------

local function ApplyItemBorder(tooltip)
    local db = GetConfig()

    if db.enabled == false
        or db.itemQualityBorder == false then
        return
    end

    local _, itemLink =
        tooltip:GetItem()

    if not itemLink then
        return
    end

    local quality =
        select(
            3,
            GetItemInfo(itemLink)
        )

    if quality == nil then
        return
    end

    local r, g, b =
        GetItemQualityColor(quality)

    if r then
        SetBorder(
            tooltip,
            r,
            g,
            b,
            1
        )
    end
end

------------------------------------------------------------
-- UNIT / CLASS BORDER
------------------------------------------------------------

local function ApplyUnitBorder(tooltip)
    local db = GetConfig()

    if db.enabled == false
        or db.classColorBorder == false then
        return
    end

    local _, unit =
        tooltip:GetUnit()

    if not unit
        or not UnitExists(unit) then
        return
    end

    if UnitIsPlayer(unit) then
        local _, class =
            UnitClass(unit)

        local color =
            class
            and RAID_CLASS_COLORS
            and RAID_CLASS_COLORS[class]

        if color then
            SetBorder(
                tooltip,
                color.r,
                color.g,
                color.b,
                1
            )

            return
        end
    end

    -- Non-player units retain the BUI accent.
    SetBorder(
        tooltip,
        unpack(BASE_BORDER)
    )
end

------------------------------------------------------------
-- HOOKS
------------------------------------------------------------

local function StyleTooltip(tooltip)
    if not tooltip
        or tooltip.BlackoutHooked then
        return
    end

    tooltip.BlackoutHooked = true

    tooltip:HookScript(
        "OnShow",
        function(self)
            ApplyBaseStyle(self)

            C_Timer.After(
                0,
                function()
                    if not self:IsShown() then
                        return
                    end

                    ApplyItemBorder(self)
                    ApplyUnitBorder(self)
                end
            )
        end
    )

    tooltip:HookScript(
        "OnTooltipCleared",
        function(self)
            if GetConfig().enabled ~= false then
                SetBorder(
                    self,
                    unpack(BASE_BORDER)
                )
            end
        end
    )

    ApplyBaseStyle(tooltip)
end

for _, tooltip in ipairs(TooltipFrames) do
    if tooltip then
        StyleTooltip(tooltip)
    end
end

------------------------------------------------------------
-- TOOLTIP DATA HOOKS
------------------------------------------------------------

if TooltipDataProcessor
    and TooltipDataProcessor.AddTooltipPostCall
    and Enum
    and Enum.TooltipDataType then
    if Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(
            Enum.TooltipDataType.Item,
            function(tooltip)
                ApplyBaseStyle(tooltip)
                ApplyItemBorder(tooltip)
            end
        )
    end

    if Enum.TooltipDataType.Unit then
        TooltipDataProcessor.AddTooltipPostCall(
            Enum.TooltipDataType.Unit,
            function(tooltip)
                ApplyBaseStyle(tooltip)
                ApplyUnitBorder(tooltip)
            end
        )
    end
end

------------------------------------------------------------
-- APPLY CONFIG
------------------------------------------------------------

function Tooltips:ApplyConfig()
    local db = GetConfig()

    for _, tooltip in ipairs(TooltipFrames) do
        if tooltip then
            if db.enabled == false then
                if tooltip.BlackoutBackdrop then
                    tooltip.BlackoutBackdrop:Hide()
                end

                tooltip:SetScale(1)
            else
                ApplyBaseStyle(tooltip)

                if tooltip:IsShown() then
                    SetBorder(
                        tooltip,
                        unpack(BASE_BORDER)
                    )
                    ApplyItemBorder(tooltip)
                    ApplyUnitBorder(tooltip)
                end
            end
        end
    end
end

------------------------------------------------------------
-- LOGIN
------------------------------------------------------------

local Events =
    CreateFrame("Frame")

Events:RegisterEvent("PLAYER_LOGIN")

Events:SetScript(
    "OnEvent",
    function()
        GetConfig()

        for _, tooltip in ipairs(TooltipFrames) do
            if tooltip then
                StyleTooltip(tooltip)
            end
        end
    end
)

------------------------------------------------------------
-- EXPORT
------------------------------------------------------------

BlackoutUI.Tooltips = Tooltips
