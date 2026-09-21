--------------------------------------------------
-- BLACKOUT UI
-- Modules/PetFrame.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local WIDTH = 280
local HEIGHT = 82

local HEADER_HEIGHT = 19
local HEALTH_HEIGHT = 34
local POWER_HEIGHT = 15

--------------------------------------------------
-- MAIN PET FRAME
--------------------------------------------------

local PetFrame = CreateFrame(
    "Button",
    "BlackoutUI_PetFrame",
    UIParent,
    "SecureUnitButtonTemplate"
)

PetFrame:SetSize(WIDTH, HEIGHT)

PetFrame:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    -300,
    -275
)

PetFrame:SetFrameStrata("MEDIUM")

--------------------------------------------------
-- UNIT BEHAVIOR
--------------------------------------------------

PetFrame:SetAttribute("unit", "pet")

PetFrame:RegisterForClicks(
    "AnyUp"
)

PetFrame:SetAttribute(
    "*type1",
    "target"
)

PetFrame:SetAttribute(
    "*type2",
    "togglemenu"
)

--------------------------------------------------
-- MAIN BACKGROUND
--------------------------------------------------

local MainBackground =
    PetFrame:CreateTexture(
        nil,
        "BACKGROUND"
    )

MainBackground:SetAllPoints()

MainBackground:SetColorTexture(
    0.018,
    0.018,
    0.018,
    0.97
)

--------------------------------------------------
-- OUTER BORDER
--------------------------------------------------

BlackoutUI:CreateBorder(
    PetFrame,
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
        PetFrame
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
-- HEADER
--------------------------------------------------

local Header =
    CreateFrame(
        "Frame",
        nil,
        InnerFrame
    )

Header:SetPoint(
    "TOPLEFT",
    3,
    -3
)

Header:SetPoint(
    "TOPRIGHT",
    -3,
    -3
)

Header:SetHeight(
    HEADER_HEIGHT
)

--------------------------------------------------
-- HEADER BACKGROUND
--------------------------------------------------

local HeaderBackground =
    Header:CreateTexture(
        nil,
        "BACKGROUND"
    )

HeaderBackground:SetAllPoints()

HeaderBackground:SetColorTexture(
    0.045,
    0.045,
    0.045,
    1
)

--------------------------------------------------
-- CLASS ACCENT
--------------------------------------------------

local ClassAccent =
    Header:CreateTexture(
        nil,
        "ARTWORK"
    )

ClassAccent:SetPoint(
    "TOPLEFT",
    Header,
    "TOPLEFT",
    0,
    0
)

ClassAccent:SetPoint(
    "BOTTOMLEFT",
    Header,
    "BOTTOMLEFT",
    0,
    0
)

ClassAccent:SetWidth(3)

ClassAccent:SetColorTexture(
    1,
    1,
    1,
    1
)

--------------------------------------------------
-- PET NAME
--------------------------------------------------

local NameText =
    BlackoutUI:CreateFont(
        Header,
        12
    )

NameText:SetPoint(
    "LEFT",
    ClassAccent,
    "RIGHT",
    7,
    0
)

NameText:SetJustifyH("LEFT")

--------------------------------------------------
-- LEVEL
--------------------------------------------------

local LevelText =
    BlackoutUI:CreateFont(
        Header,
        10
    )

LevelText:SetPoint(
    "RIGHT",
    Header,
    "RIGHT",
    -6,
    0
)

LevelText:SetTextColor(
    0.60,
    0.60,
    0.60
)

--------------------------------------------------
-- HEALTH CONTAINER
--------------------------------------------------

local HealthContainer =
    CreateFrame(
        "Frame",
        nil,
        InnerFrame
    )

HealthContainer:SetPoint(
    "TOPLEFT",
    Header,
    "BOTTOMLEFT",
    0,
    -3
)

HealthContainer:SetPoint(
    "TOPRIGHT",
    Header,
    "BOTTOMRIGHT",
    0,
    -3
)

HealthContainer:SetHeight(
    HEALTH_HEIGHT
)

--------------------------------------------------
-- HEALTH BACKGROUND
--------------------------------------------------

local HealthBackground =
    HealthContainer:CreateTexture(
        nil,
        "BACKGROUND"
    )

HealthBackground:SetAllPoints()

HealthBackground:SetColorTexture(
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
        HealthContainer
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
-- HEALTH DARK OVERLAY
--------------------------------------------------

local HealthOverlay =
    HealthBar:CreateTexture(
        nil,
        "ARTWORK"
    )

HealthOverlay:SetPoint(
    "BOTTOMLEFT",
    HealthBar,
    "BOTTOMLEFT"
)

HealthOverlay:SetPoint(
    "BOTTOMRIGHT",
    HealthBar,
    "BOTTOMRIGHT"
)

HealthOverlay:SetHeight(
    HEALTH_HEIGHT * 0.45
)

HealthOverlay:SetColorTexture(
    0,
    0,
    0,
    0.12
)

--------------------------------------------------
-- HEALTH TOP HIGHLIGHT
--------------------------------------------------

local HealthHighlight =
    HealthBar:CreateTexture(
        nil,
        "ARTWORK"
    )

HealthHighlight:SetPoint(
    "TOPLEFT",
    HealthBar,
    "TOPLEFT"
)

HealthHighlight:SetPoint(
    "TOPRIGHT",
    HealthBar,
    "TOPRIGHT"
)

HealthHighlight:SetHeight(1)

HealthHighlight:SetColorTexture(
    1,
    1,
    1,
    0.10
)

--------------------------------------------------
-- HEALTH VALUE
--------------------------------------------------

local HealthValue =
    BlackoutUI:CreateFont(
        HealthBar,
        12
    )

HealthValue:SetPoint(
    "LEFT",
    HealthBar,
    "LEFT",
    8,
    0
)

--------------------------------------------------
-- HEALTH PERCENT
--------------------------------------------------

local HealthPercent =
    BlackoutUI:CreateFont(
        HealthBar,
        14
    )

HealthPercent:SetPoint(
    "RIGHT",
    HealthBar,
    "RIGHT",
    -8,
    0
)

--------------------------------------------------
-- POWER CONTAINER
--------------------------------------------------

local PowerContainer =
    CreateFrame(
        "Frame",
        nil,
        InnerFrame
    )

PowerContainer:SetPoint(
    "TOPLEFT",
    HealthContainer,
    "BOTTOMLEFT",
    0,
    -3
)

PowerContainer:SetPoint(
    "TOPRIGHT",
    HealthContainer,
    "BOTTOMRIGHT",
    0,
    -3
)

PowerContainer:SetHeight(
    POWER_HEIGHT
)

--------------------------------------------------
-- POWER BACKGROUND
--------------------------------------------------

local PowerBackground =
    PowerContainer:CreateTexture(
        nil,
        "BACKGROUND"
    )

PowerBackground:SetAllPoints()

PowerBackground:SetColorTexture(
    0.04,
    0.04,
    0.04,
    1
)

--------------------------------------------------
-- POWER BAR
--------------------------------------------------

local PowerBar =
    CreateFrame(
        "StatusBar",
        nil,
        PowerContainer
    )

PowerBar:SetPoint(
    "TOPLEFT",
    1,
    -1
)

PowerBar:SetPoint(
    "BOTTOMRIGHT",
    -1,
    1
)

PowerBar:SetStatusBarTexture(
    "Interface\\Buttons\\WHITE8X8"
)

PowerBar:SetMinMaxValues(
    0,
    100
)

PowerBar:SetValue(
    100
)

--------------------------------------------------
-- POWER LABEL
--------------------------------------------------

local PowerLabel =
    BlackoutUI:CreateFont(
        PowerBar,
        9
    )

PowerLabel:SetPoint(
    "LEFT",
    PowerBar,
    "LEFT",
    6,
    0
)

PowerLabel:SetTextColor(
    0.90,
    0.90,
    0.90
)

--------------------------------------------------
-- POWER VALUE
--------------------------------------------------

local PowerValue =
    BlackoutUI:CreateFont(
        PowerBar,
        10
    )

PowerValue:SetPoint(
    "RIGHT",
    PowerBar,
    "RIGHT",
    -6,
    0
)

--------------------------------------------------
-- CLASS COLOR
--------------------------------------------------

local function UpdateClassColor()
    ClassAccent:SetColorTexture(
        0.30,
        0.72,
        0.38,
        1
    )

    NameText:SetTextColor(
        0.30,
        0.72,
        0.38
    )
end

--------------------------------------------------
-- NAME
--------------------------------------------------

local function UpdateName()
    local name =
        UnitName("pet")
        or "Unknown"

    NameText:SetText(
        string.upper(name)
    )
end

--------------------------------------------------
-- LEVEL
--------------------------------------------------

local function UpdateLevel()
    local level =
        UnitLevel("pet")
        or 0

    LevelText:SetText(
        "LVL " .. level
    )
end

--------------------------------------------------
-- HEALTH
--------------------------------------------------

local function UpdateHealth()
    local health =
        UnitHealth("pet")

    local maxHealth =
        UnitHealthMax("pet")

    if maxHealth <= 0 then
        maxHealth = 1
    end

    --------------------------------------------------
    -- BAR VALUES
    --------------------------------------------------

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

    if UnitIsDeadOrGhost("pet") then
        HealthValue:SetText("DEAD")

        HealthPercent:SetText("")

        HealthBar:SetStatusBarColor(
            0.25,
            0.25,
            0.25,
            1
        )

        return
    end

    --------------------------------------------------
    -- HEALTH COLOR
    --------------------------------------------------

    local percentage =
        health / maxHealth

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

    --------------------------------------------------
    -- VALUES
    --------------------------------------------------

    HealthValue:SetText(
        BlackoutUI:FormatNumber(health)
        ..
        "  /  "
        ..
        BlackoutUI:FormatNumber(maxHealth)
    )

    HealthPercent:SetText(
        string.format(
            "%d%%",
            percentage * 100
        )
    )
end

--------------------------------------------------
-- POWER
--------------------------------------------------

local function UpdatePower()
    local powerType,
    powerToken =
        UnitPowerType("pet")

    local power =
        UnitPower(
            "pet",
            powerType
        )

    local maxPower =
        UnitPowerMax(
            "pet",
            powerType
        )

    if maxPower <= 0 then
        maxPower = 1
    end

    --------------------------------------------------
    -- VALUES
    --------------------------------------------------

    PowerBar:SetMinMaxValues(
        0,
        maxPower
    )

    PowerBar:SetValue(
        power
    )

    --------------------------------------------------
    -- MANA
    --------------------------------------------------

    if powerType == 0 then
        PowerBar:SetStatusBarColor(
            0.10,
            0.35,
            0.82,
            1
        )

        PowerLabel:SetText(
            "MANA"
        )

        --------------------------------------------------
        -- RAGE
        --------------------------------------------------
    elseif powerType == 1 then
        PowerBar:SetStatusBarColor(
            0.75,
            0.10,
            0.10,
            1
        )

        PowerLabel:SetText(
            "RAGE"
        )

        --------------------------------------------------
        -- ENERGY
        --------------------------------------------------
    elseif powerType == 3 then
        PowerBar:SetStatusBarColor(
            0.82,
            0.68,
            0.08,
            1
        )

        PowerLabel:SetText(
            "ENERGY"
        )

        --------------------------------------------------
        -- OTHER
        --------------------------------------------------
    else
        PowerBar:SetStatusBarColor(
            0.40,
            0.40,
            0.40,
            1
        )

        PowerLabel:SetText(
            powerToken or "POWER"
        )
    end

    PowerValue:SetText(
        BlackoutUI:FormatNumber(power)
        ..
        " / "
        ..
        BlackoutUI:FormatNumber(maxPower)
    )
end

--------------------------------------------------
-- UPDATE EVERYTHING
--------------------------------------------------

local function UpdateAll()
    if not UnitExists("pet") then
        PetFrame:Hide()
        return
    end

    local config =
        BlackoutUIDB
        and BlackoutUIDB.Config
        and BlackoutUIDB.Config.UnitFrames
        and BlackoutUIDB.Config.UnitFrames.pet

    if config and config.enabled == false then
        PetFrame:Hide()
        return
    end

    PetFrame:Show()

    UpdateName()
    UpdateLevel()
    UpdateClassColor()
    UpdateHealth()
    UpdatePower()
end

--------------------------------------------------
-- EVENTS
--------------------------------------------------

PetFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

PetFrame:RegisterEvent(
    "UNIT_PET"
)

PetFrame:RegisterEvent(
    "PET_UI_UPDATE"
)

PetFrame:RegisterEvent(
    "UNIT_HEALTH"
)

PetFrame:RegisterEvent(
    "UNIT_MAXHEALTH"
)

PetFrame:RegisterEvent(
    "UNIT_POWER_UPDATE"
)

PetFrame:RegisterEvent(
    "UNIT_MAXPOWER"
)

PetFrame:RegisterEvent(
    "UNIT_DISPLAYPOWER"
)

PetFrame:RegisterEvent(
    "UNIT_LEVEL"
)

--------------------------------------------------
-- EVENT HANDLER
--------------------------------------------------

PetFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        if event == "PLAYER_ENTERING_WORLD"
            or event == "PET_UI_UPDATE" then
            UpdateAll()
            return
        end

        if event == "UNIT_PET" then
            -- UNIT_PET normally reports "player" because the
            -- player's pet changed, not because unit == "pet".
            if unit == "player" then
                UpdateAll()
            end
            return
        end

        if event ==
            "UNIT_LEVEL" then
            UpdateLevel()
            return
        end

        if unit
            and unit ~= "pet" then
            return
        end

        if event == "UNIT_HEALTH"
            or event == "UNIT_MAXHEALTH" then
            UpdateHealth()
        elseif event ==
            "UNIT_POWER_UPDATE"
            or event ==
            "UNIT_MAXPOWER"
            or event ==
            "UNIT_DISPLAYPOWER" then
            UpdatePower()
        end
    end
)


--------------------------------------------------
-- CONFIG API
--------------------------------------------------

BlackoutUI.PetFrame = BlackoutUI.PetFrame or {}

local function GetPetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.UnitFrames = BlackoutUIDB.Config.UnitFrames or {}
    BlackoutUIDB.Config.UnitFrames.pet = BlackoutUIDB.Config.UnitFrames.pet or {}

    local c = BlackoutUIDB.Config.UnitFrames.pet
    if c.enabled == nil then c.enabled = true end
    if c.width == nil then c.width = 280 end
    if c.height == nil then c.height = 82 end
    if c.scale == nil then c.scale = 1.00 end
    if c.headerHeight == nil then c.headerHeight = 19 end
    if c.healthHeight == nil then c.healthHeight = 34 end
    if c.powerHeight == nil then c.powerHeight = 15 end
    if c.nameSize == nil then c.nameSize = 12 end
    if c.levelSize == nil then c.levelSize = 10 end
    if c.healthTextSize == nil then c.healthTextSize = 12 end
    if c.healthPercentSize == nil then c.healthPercentSize = 14 end
    if c.powerTextSize == nil then c.powerTextSize = 10 end

    if c.showName == nil then c.showName = true end
    if c.showLevel == nil then c.showLevel = true end
    if c.showHealthValue == nil then c.showHealthValue = true end
    if c.showHealthPercent == nil then c.showHealthPercent = true end
    if c.showPowerValue == nil then c.showPowerValue = true end
    if c.showPowerBar == nil then c.showPowerBar = true end
    if c.healthValueSize == nil then c.healthValueSize = 12 end
    if c.healthPercentSize == nil then c.healthPercentSize = 14 end
    if c.powerLabelSize == nil then c.powerLabelSize = 9 end
    if c.powerValueSize == nil then c.powerValueSize = 10 end
    if c.showName == nil then c.showName = true end
    if c.showLevel == nil then c.showLevel = true end
    if c.showHealthValue == nil then c.showHealthValue = true end
    if c.showHealthPercent == nil then c.showHealthPercent = true end
    if c.showPowerLabel == nil then c.showPowerLabel = true end
    if c.showPowerValue == nil then c.showPowerValue = true end
    return c
end

local function SetFontSize(fontString, size)
    local font, _, flags = fontString:GetFont()
    if font then fontString:SetFont(font, size, flags) end
end

function BlackoutUI.PetFrame:ApplyConfig()
    if InCombatLockdown() then return end

    local c = GetPetConfig()

    PetFrame:SetSize(c.width, c.height)
    PetFrame:SetScale(c.scale)

    Header:SetHeight(c.headerHeight)
    HealthContainer:SetHeight(c.healthHeight)
    PowerContainer:SetHeight(c.powerHeight)
    HealthOverlay:SetHeight(c.healthHeight * 0.45)

    SetFontSize(NameText, c.nameSize)
    SetFontSize(LevelText, c.levelSize)
    SetFontSize(HealthValue, c.healthValueSize)
    SetFontSize(HealthPercent, c.healthPercentSize)
    SetFontSize(PowerLabel, c.powerLabelSize)
    SetFontSize(PowerValue, c.powerValueSize)

    NameText:SetShown(c.showName)
    LevelText:SetShown(c.showLevel)
    HealthValue:SetShown(c.showHealthValue)
    HealthPercent:SetShown(c.showHealthPercent)
    PowerLabel:SetShown(c.showPowerLabel)
    PowerValue:SetShown(c.showPowerValue)
    PowerContainer:SetShown(c.showPowerBar)

    PetFrame:SetShown(
        c.enabled and UnitExists("pet")
    )
end

function BlackoutUI.PetFrame:ResetConfig()
    if InCombatLockdown() then return end
    BlackoutUIDB.Config.UnitFrames.pet = nil
    GetPetConfig()
    self:ApplyConfig()
end

--------------------------------------------------
-- BLACKOUT MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    PetFrame,
    "PetFrame",
    "PET FRAME"
)

--------------------------------------------------
-- INITIAL UPDATE
--------------------------------------------------

UpdateAll()

BlackoutUI.PetFrame:ApplyConfig()
