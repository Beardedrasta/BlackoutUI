--------------------------------------------------
-- BLACKOUT UI
-- Modules/TargetOfTarget.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local WIDTH = 200
local HEIGHT = 42

local HEALTH_HEIGHT = 14

--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------

local ToTFrame = CreateFrame(
    "Button",
    "BlackoutUI_TargetOfTarget",
    UIParent,
    "SecureUnitButtonTemplate"
)

ToTFrame:SetSize(
    WIDTH,
    HEIGHT
)

ToTFrame:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    0,
    -112
)

ToTFrame:SetFrameStrata(
    "MEDIUM"
)

--------------------------------------------------
-- UNIT BEHAVIOR
--------------------------------------------------

ToTFrame:SetAttribute(
    "unit",
    "targettarget"
)

ToTFrame:RegisterForClicks(
    "AnyUp"
)

ToTFrame:SetAttribute(
    "*type1",
    "target"
)

--------------------------------------------------
-- MAIN BACKGROUND
--------------------------------------------------

local Background =
    ToTFrame:CreateTexture(
        nil,
        "BACKGROUND"
    )

Background:SetAllPoints()

Background:SetColorTexture(
    0.018,
    0.018,
    0.018,
    0.97
)

--------------------------------------------------
-- OUTER BORDER
--------------------------------------------------

BlackoutUI:CreateBorder(
    ToTFrame,
    1,
    "borderBright"
)

--------------------------------------------------
-- INNER FRAME
--------------------------------------------------

local InnerFrame =
    CreateFrame(
        "Frame",
        nil,
        ToTFrame
    )

InnerFrame:SetPoint(
    "TOPLEFT",
    2,
    -2
)

InnerFrame:SetPoint(
    "BOTTOMRIGHT",
    -2,
    2
)

BlackoutUI:CreateBorder(
    InnerFrame,
    1,
    "border"
)

--------------------------------------------------
-- NAME
--------------------------------------------------

local NameText =
    BlackoutUI:CreateFont(
        InnerFrame,
        10
    )

NameText:SetPoint(
    "TOPLEFT",
    InnerFrame,
    "TOPLEFT",
    6,
    -5
)

NameText:SetPoint(
    "TOPRIGHT",
    InnerFrame,
    "TOPRIGHT",
    -45,
    -5
)

NameText:SetJustifyH(
    "LEFT"
)

--------------------------------------------------
-- HEALTH PERCENT
--------------------------------------------------

local PercentText =
    BlackoutUI:CreateFont(
        InnerFrame,
        10
    )

PercentText:SetPoint(
    "TOPRIGHT",
    InnerFrame,
    "TOPRIGHT",
    -6,
    -5
)

PercentText:SetJustifyH(
    "RIGHT"
)

--------------------------------------------------
-- HEALTH BACKGROUND
--------------------------------------------------

local HealthBackground =
    CreateFrame(
        "Frame",
        nil,
        InnerFrame
    )

HealthBackground:SetPoint(
    "BOTTOMLEFT",
    InnerFrame,
    "BOTTOMLEFT",
    5,
    5
)

HealthBackground:SetPoint(
    "BOTTOMRIGHT",
    InnerFrame,
    "BOTTOMRIGHT",
    -5,
    5
)

HealthBackground:SetHeight(
    HEALTH_HEIGHT
)

local HealthBackgroundTexture =
    HealthBackground:CreateTexture(
        nil,
        "BACKGROUND"
    )

HealthBackgroundTexture:SetAllPoints()

HealthBackgroundTexture:SetColorTexture(
    0.055,
    0.055,
    0.055,
    1
)

--------------------------------------------------
-- HEALTH BAR
--------------------------------------------------

local HealthBar =
    CreateFrame(
        "StatusBar",
        nil,
        HealthBackground
    )

HealthBar:SetPoint(
    "TOPLEFT",
    1,
    -1
)

HealthBar:SetPoint(
    "BOTTOMRIGHT",
    -1,
    1
)

HealthBar:SetStatusBarTexture(
    "Interface\\Buttons\\WHITE8X8"
)

HealthBar:SetMinMaxValues(
    0,
    100
)

HealthBar:SetValue(
    100
)

--------------------------------------------------
-- HEALTH BAR SHADE
--------------------------------------------------

local Shade =
    HealthBar:CreateTexture(
        nil,
        "ARTWORK"
    )

Shade:SetPoint(
    "BOTTOMLEFT"
)

Shade:SetPoint(
    "BOTTOMRIGHT"
)

Shade:SetHeight(
    HEALTH_HEIGHT / 2
)

Shade:SetColorTexture(
    0,
    0,
    0,
    0.12
)

--------------------------------------------------
-- REACTION / CLASS COLOR
--------------------------------------------------

local function GetUnitColor()
    --------------------------------------------------
    -- PLAYER CLASS COLOR
    --------------------------------------------------

    if UnitIsPlayer("targettarget") then
        local _, classFile =
            UnitClass("targettarget")

        local classColor =
            classFile
            and RAID_CLASS_COLORS[classFile]

        if classColor then
            return
                classColor.r,
                classColor.g,
                classColor.b
        end
    end

    --------------------------------------------------
    -- NPC REACTION COLOR
    --------------------------------------------------

    local reaction =
        UnitReaction(
            "targettarget",
            "player"
        )

    if reaction then
        -- Hostile
        if reaction <= 3 then
            return
                0.78,
                0.14,
                0.14

            -- Neutral
        elseif reaction == 4 then
            return
                0.82,
                0.68,
                0.08

            -- Friendly
        elseif reaction >= 5 then
            return
                0.18,
                0.68,
                0.28
        end
    end

    return
        0.50,
        0.50,
        0.50
end

--------------------------------------------------
-- UPDATE NAME
--------------------------------------------------

local function UpdateName()
    local name =
        UnitName(
            "targettarget"
        )

    if not name then
        return
    end

    NameText:SetText(
        string.upper(name)
    )

    local r, g, b =
        GetUnitColor()

    NameText:SetTextColor(
        r,
        g,
        b
    )
end

--------------------------------------------------
-- UPDATE HEALTH
--------------------------------------------------

local function UpdateHealth()
    if not UnitExists(
            "targettarget"
        ) then
        return
    end

    local health =
        UnitHealth(
            "targettarget"
        )

    local maxHealth =
        UnitHealthMax(
            "targettarget"
        )

    if maxHealth <= 0 then
        maxHealth = 1
    end

    HealthBar:SetMinMaxValues(
        0,
        maxHealth
    )

    HealthBar:SetValue(
        health
    )

    --------------------------------------------------
    -- DEAD
    --------------------------------------------------

    if UnitIsDeadOrGhost(
            "targettarget"
        ) then
        HealthBar:SetStatusBarColor(
            0.24,
            0.24,
            0.24,
            1
        )

        PercentText:SetText(
            "DEAD"
        )

        return
    end

    --------------------------------------------------
    -- HEALTH %
    --------------------------------------------------

    local percentage =
        health / maxHealth

    PercentText:SetText(
        string.format(
            "%d%%",
            percentage * 100
        )
    )

    --------------------------------------------------
    -- HEALTH COLOR
    --------------------------------------------------

    local r
    local g
    local b

    if percentage > 0.50 then
        r = 0.16
        g = 0.62
        b = 0.25
    elseif percentage > 0.25 then
        r = 0.80
        g = 0.55
        b = 0.10
    else
        r = 0.78
        g = 0.12
        b = 0.12
    end

    HealthBar:SetStatusBarColor(
        r,
        g,
        b,
        1
    )
end

--------------------------------------------------
-- UPDATE EVERYTHING
--------------------------------------------------

local function UpdateAll()
    if not UnitExists(
            "targettarget"
        ) then
        ToTFrame:Hide()

        return
    end

    ToTFrame:Show()

    UpdateName()
    UpdateHealth()
end

--------------------------------------------------
-- EVENTS
--------------------------------------------------

ToTFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

ToTFrame:RegisterEvent(
    "PLAYER_TARGET_CHANGED"
)

ToTFrame:RegisterEvent(
    "UNIT_TARGET"
)

ToTFrame:RegisterEvent(
    "UNIT_HEALTH"
)

ToTFrame:RegisterEvent(
    "UNIT_MAXHEALTH"
)

ToTFrame:RegisterEvent(
    "UNIT_FACTION"
)

--------------------------------------------------
-- EVENT HANDLER
--------------------------------------------------

ToTFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        --------------------------------------------------
        -- PLAYER TARGET CHANGED
        --------------------------------------------------

        if event ==
            "PLAYER_TARGET_CHANGED" then
            UpdateAll()

            return
        end

        --------------------------------------------------
        -- ENTERING WORLD
        --------------------------------------------------

        if event ==
            "PLAYER_ENTERING_WORLD" then
            UpdateAll()

            return
        end

        --------------------------------------------------
        -- TARGET CHANGED ITS TARGET
        --------------------------------------------------

        if event ==
            "UNIT_TARGET" then
            if unit == "target" then
                UpdateAll()
            end

            return
        end

        --------------------------------------------------
        -- TARGET OF TARGET DATA
        --------------------------------------------------

        if unit ==
            "targettarget" then
            if event ==
                "UNIT_HEALTH"
                or event ==
                "UNIT_MAXHEALTH" then
                UpdateHealth()
            elseif event ==
                "UNIT_FACTION" then
                UpdateName()
            end
        end
    end
)


--------------------------------------------------
-- CONFIG API
--------------------------------------------------

BlackoutUI.TargetOfTarget = BlackoutUI.TargetOfTarget or {}

local function GetToTConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.UnitFrames = BlackoutUIDB.Config.UnitFrames or {}
    BlackoutUIDB.Config.UnitFrames.targettarget = BlackoutUIDB.Config.UnitFrames.targettarget or {}

    local c = BlackoutUIDB.Config.UnitFrames.targettarget
    if c.enabled == nil then c.enabled = true end
    if c.width == nil then c.width = 200 end
    if c.height == nil then c.height = 42 end
    if c.scale == nil then c.scale = 1.00 end
    if c.healthHeight == nil then c.healthHeight = 14 end
    if c.nameSize == nil then c.nameSize = 10 end
    if c.healthPercentSize == nil then c.healthPercentSize = 10 end
    if c.showName == nil then c.showName = true end
    if c.showHealthPercent == nil then c.showHealthPercent = true end
    return c
end

local function SetFontSize(fontString, size)
    local font, _, flags = fontString:GetFont()
    if font then fontString:SetFont(font, size, flags) end
end

function BlackoutUI.TargetOfTarget:ApplyConfig()
    if InCombatLockdown() then return end

    local c = GetToTConfig()

    ToTFrame:SetSize(c.width, c.height)
    ToTFrame:SetScale(c.scale)
    HealthBackground:SetHeight(c.healthHeight)
    Shade:SetHeight(c.healthHeight / 2)

    SetFontSize(NameText, c.nameSize)
    SetFontSize(PercentText, c.healthPercentSize)

    NameText:SetShown(c.showName)
    PercentText:SetShown(c.showHealthPercent)

    if not c.enabled then
        ToTFrame:Hide()
    else
        UpdateAll()
    end
end

function BlackoutUI.TargetOfTarget:ResetConfig()
    if InCombatLockdown() then return end
    BlackoutUIDB.Config.UnitFrames.targettarget = nil
    GetToTConfig()
    self:ApplyConfig()
end

--------------------------------------------------
-- BLACKOUT MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    ToTFrame,
    "TargetOfTarget",
    "TARGET OF TARGET"
)

--------------------------------------------------
-- START HIDDEN
--------------------------------------------------

ToTFrame:Hide()

BlackoutUI.TargetOfTarget:ApplyConfig()
