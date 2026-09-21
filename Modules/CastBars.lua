--------------------------------------------------
-- BLACKOUT UI
-- Modules/CastBars.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local WIDTH = 310
local HEIGHT = 30
local ICON_SIZE = 30

local DEFAULTS = {
    player = {
        enabled = true,
        width = WIDTH,
        height = HEIGHT,
        scale = 1.00,
        showIcon = true,
        showSpellName = true,
        spellNameSize = 11,
        showCastTime = true,
        castTimeSize = 11,
    },

    target = {
        enabled = true,
        width = WIDTH,
        height = HEIGHT,
        scale = 1.00,
        showIcon = true,
        showSpellName = true,
        spellNameSize = 11,
        showCastTime = true,
        castTimeSize = 11,
    },
}

local function CopyDefaults(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function EnsureCastBarConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.CastBars = BlackoutUIDB.Config.CastBars or {}

    for key, defaults in pairs(DEFAULTS) do
        BlackoutUIDB.Config.CastBars[key] =
            BlackoutUIDB.Config.CastBars[key] or {}

        local saved = BlackoutUIDB.Config.CastBars[key]

        -- Icon size is intentionally tied to bar height.
        -- Remove the old independent setting from earlier builds.
        saved.iconSize = nil

        for option, value in pairs(defaults) do
            if saved[option] == nil then
                saved[option] = value
            end
        end
    end

    return BlackoutUIDB.Config.CastBars
end

local function SetFontSize(fontString, size)
    if not fontString then return end
    local font, _, flags = fontString:GetFont()
    if font then
        fontString:SetFont(font, size, flags)
    end
end

--------------------------------------------------
-- CREATE CAST BAR
--------------------------------------------------

local function CreateCastBar(name, unit, x, y)
    --------------------------------------------------
    -- MAIN FRAME
    --------------------------------------------------

    local frame = CreateFrame(
        "Frame",
        name,
        UIParent
    )

    frame:SetSize(
        WIDTH + ICON_SIZE + 5,
        HEIGHT
    )

    frame:SetPoint(
        "CENTER",
        UIParent,
        "CENTER",
        x,
        y
    )

    frame:SetFrameStrata("MEDIUM")

    frame.unit = unit

    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local background =
        frame:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    background:SetColorTexture(
        0.018,
        0.018,
        0.018,
        0.97
    )

    frame.Background = background

    BlackoutUI:CreateBorder(
        frame,
        1,
        "borderBright"
    )

    --------------------------------------------------
    -- SPELL ICON
    --------------------------------------------------

    local iconFrame =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    iconFrame:SetSize(
        ICON_SIZE,
        ICON_SIZE
    )

    iconFrame:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        0,
        0
    )

    local icon =
        iconFrame:CreateTexture(
            nil,
            "ARTWORK"
        )

    icon:SetPoint(
        "TOPLEFT",
        2,
        -2
    )

    icon:SetPoint(
        "BOTTOMRIGHT",
        -2,
        2
    )

    icon:SetTexCoord(
        0.08,
        0.92,
        0.08,
        0.92
    )

    BlackoutUI:CreateBorder(
        iconFrame,
        1,
        "border"
    )

    frame.Icon = icon
    frame.IconFrame = iconFrame

    --------------------------------------------------
    -- STATUS BAR
    --------------------------------------------------

    local bar =
        CreateFrame(
            "StatusBar",
            nil,
            frame
        )

    bar:SetPoint(
        "TOPLEFT",
        iconFrame,
        "TOPRIGHT",
        5,
        0
    )

    bar:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        0,
        0
    )

    bar:SetStatusBarTexture(
        "Interface\\Buttons\\WHITE8X8"
    )

    bar:SetStatusBarColor(
        0.22,
        0.48,
        0.78,
        1
    )

    --------------------------------------------------
    -- EMPTY BAR BACKGROUND
    --------------------------------------------------

    local barBackground =
        bar:CreateTexture(
            nil,
            "BACKGROUND"
        )

    barBackground:SetAllPoints()

    barBackground:SetColorTexture(
        0.045,
        0.045,
        0.045,
        1
    )

    --------------------------------------------------
    -- LOWER SHADE
    --------------------------------------------------

    local shade =
        bar:CreateTexture(
            nil,
            "ARTWORK"
        )

    shade:SetPoint(
        "BOTTOMLEFT"
    )

    shade:SetPoint(
        "BOTTOMRIGHT"
    )

    shade:SetHeight(
        HEIGHT * 0.45
    )

    shade:SetColorTexture(
        0,
        0,
        0,
        0.15
    )

    --------------------------------------------------
    -- TOP HIGHLIGHT
    --------------------------------------------------

    local highlight =
        bar:CreateTexture(
            nil,
            "ARTWORK"
        )

    highlight:SetPoint(
        "TOPLEFT"
    )

    highlight:SetPoint(
        "TOPRIGHT"
    )

    highlight:SetHeight(1)

    highlight:SetColorTexture(
        1,
        1,
        1,
        0.10
    )

    frame.Bar = bar
    frame.Shade = shade

    --------------------------------------------------
    -- SPELL NAME
    --------------------------------------------------

    local spellName =
        BlackoutUI:CreateFont(
            bar,
            11
        )

    spellName:SetPoint(
        "LEFT",
        bar,
        "LEFT",
        8,
        0
    )

    spellName:SetPoint(
        "RIGHT",
        bar,
        "RIGHT",
        -55,
        0
    )

    spellName:SetJustifyH(
        "LEFT"
    )

    frame.SpellName =
        spellName

    --------------------------------------------------
    -- TIME
    --------------------------------------------------

    local timeText =
        BlackoutUI:CreateFont(
            bar,
            11
        )

    timeText:SetPoint(
        "RIGHT",
        bar,
        "RIGHT",
        -7,
        0
    )

    timeText:SetJustifyH(
        "RIGHT"
    )

    frame.TimeText =
        timeText

    --------------------------------------------------
    -- INTERRUPT ACCENT
    --------------------------------------------------

    local accent =
        bar:CreateTexture(
            nil,
            "OVERLAY"
        )

    accent:SetPoint(
        "TOPLEFT",
        bar,
        "TOPLEFT",
        0,
        0
    )

    accent:SetPoint(
        "BOTTOMLEFT",
        bar,
        "BOTTOMLEFT",
        0,
        0
    )

    accent:SetWidth(3)

    frame.Accent =
        accent

    --------------------------------------------------
    -- VARIABLES
    --------------------------------------------------

    frame.casting = false
    frame.channeling = false

    frame.startTime = 0
    frame.endTime = 0

    frame:Hide()

    return frame
end

--------------------------------------------------
-- CREATE PLAYER CAST BAR
--------------------------------------------------

local PlayerCast =
    CreateCastBar(
        "BlackoutUI_PlayerCastBar",
        "player",
        0,
        -250
    )

--------------------------------------------------
-- CREATE TARGET CAST BAR
--------------------------------------------------

local TargetCast =
    CreateCastBar(
        "BlackoutUI_TargetCastBar",
        "target",
        0,
        -70
    )

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local CastBars = {}
BlackoutUI.CastBars = CastBars

local function GetFrameForKey(key)
    if key == "player" then
        return PlayerCast
    end

    return TargetCast
end

local function ApplyFrameConfig(key)
    local settings = EnsureCastBarConfig()[key]
    local frame = GetFrameForKey(key)

    local iconSpace =
        settings.showIcon
        and (settings.height + 5)
        or 0

    local totalWidth =
        settings.width + iconSpace

    --------------------------------------------------
    -- MAIN FRAME
    --------------------------------------------------

    frame:SetScale(settings.scale)

    frame:SetSize(
        totalWidth,
        settings.height
    )

    --------------------------------------------------
    -- ICON
    --------------------------------------------------

    frame.IconFrame:ClearAllPoints()

    frame.IconFrame:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        0,
        0
    )

    frame.IconFrame:SetSize(
        settings.height,
        settings.height
    )

    -- The icon texture was originally constrained by four anchors.
    -- Clear those anchors and explicitly size the texture as well,
    -- otherwise Classic can keep the old rendered texture dimensions.
    frame.Icon:ClearAllPoints()

    frame.Icon:SetPoint(
        "CENTER",
        frame.IconFrame,
        "CENTER",
        0,
        0
    )

    frame.Icon:SetSize(
        math.max(1, settings.height - 4),
        math.max(1, settings.height - 4)
    )

    frame.IconFrame:SetShown(
        settings.showIcon
    )

    --------------------------------------------------
    -- STATUS BAR
    --
    -- Set an explicit size instead of relying only on
    -- opposing anchors. This makes width/height config
    -- changes resize the actual StatusBar texture too.
    --------------------------------------------------

    frame.Bar:ClearAllPoints()

    if settings.showIcon then
        frame.Bar:SetPoint(
            "LEFT",
            frame.IconFrame,
            "RIGHT",
            5,
            0
        )
    else
        frame.Bar:SetPoint(
            "LEFT",
            frame,
            "LEFT",
            0,
            0
        )
    end

    frame.Bar:SetSize(
        settings.width,
        settings.height
    )

    --------------------------------------------------
    -- SHADE
    --------------------------------------------------

    if frame.Shade then
        frame.Shade:SetHeight(
            settings.height * 0.45
        )
    end

    --------------------------------------------------
    -- TEXT
    --------------------------------------------------

    SetFontSize(
        frame.SpellName,
        settings.spellNameSize
    )

    SetFontSize(
        frame.TimeText,
        settings.castTimeSize
    )

    frame.SpellName:SetShown(
        settings.showSpellName
    )

    frame.TimeText:SetShown(
        settings.showCastTime
    )

    --------------------------------------------------
    -- ENABLED
    --------------------------------------------------

    if not settings.enabled then
        frame.casting = false
        frame.channeling = false
        frame:Hide()
    end
end

function CastBars:ApplyConfig()
    ApplyFrameConfig("player")
    ApplyFrameConfig("target")

    -- If a cast is already active while settings are changed,
    -- the next cast event/update will restore the live display.
end

function CastBars:ResetSection(key)
    if key ~= "player" and key ~= "target" then
        return
    end

    local settings = EnsureCastBarConfig()

    settings[key] =
        CopyDefaults(DEFAULTS[key])

    self:ApplyConfig()
end

function CastBars:GetConfig(key)
    return EnsureCastBarConfig()[key]
end

function CastBars:SetOption(
    key,
    option,
    value
)
    if key ~= "player"
        and key ~= "target" then
        return
    end

    local settings =
        EnsureCastBarConfig()[key]

    settings[option] = value

    ApplyFrameConfig(key)
end

EnsureCastBarConfig()
CastBars:ApplyConfig()

--------------------------------------------------
-- GET CAST INFORMATION
--------------------------------------------------

local function GetCastInfo(frame)
    local unit =
        frame.unit

    --------------------------------------------------
    -- NORMAL CAST
    --------------------------------------------------

    local name,
    text,
    texture,
    startTimeMS,
    endTimeMS,
    isTradeSkill,
    castID,
    notInterruptible =
        UnitCastingInfo(unit)

    if name then
        return
            "CAST",
            name,
            texture,
            startTimeMS,
            endTimeMS,
            notInterruptible
    end

    --------------------------------------------------
    -- CHANNEL
    --------------------------------------------------

    local channelName,
    channelText,
    channelTexture,
    channelStartMS,
    channelEndMS,
    isTradeSkillChannel,
    channelNotInterruptible =
        UnitChannelInfo(unit)

    if channelName then
        return
            "CHANNEL",
            channelName,
            channelTexture,
            channelStartMS,
            channelEndMS,
            channelNotInterruptible
    end

    return nil
end

--------------------------------------------------
-- START / UPDATE CAST
--------------------------------------------------

local function UpdateCast(frame)
    local key = frame.unit == "player" and "player" or "target"
    local settings = EnsureCastBarConfig()[key]

    if not settings.enabled then
        frame.casting = false
        frame.channeling = false
        frame:Hide()
        return
    end

    local castType,
    spellName,
    texture,
    startTimeMS,
    endTimeMS,
    notInterruptible =
        GetCastInfo(frame)

    --------------------------------------------------
    -- NO ACTIVE CAST
    --------------------------------------------------

    if not castType then
        frame.casting = false
        frame.channeling = false

        frame:Hide()

        return
    end

    --------------------------------------------------
    -- TIME
    --------------------------------------------------

    frame.startTime =
        startTimeMS / 1000

    frame.endTime =
        endTimeMS / 1000

    local duration =
        frame.endTime -
        frame.startTime

    if duration <= 0 then
        duration = 0.01
    end

    --------------------------------------------------
    -- CAST TYPE
    --------------------------------------------------

    frame.casting =
        castType == "CAST"

    frame.channeling =
        castType == "CHANNEL"

    --------------------------------------------------
    -- BAR
    --------------------------------------------------

    frame.Bar:SetMinMaxValues(
        0,
        duration
    )

    --------------------------------------------------
    -- SPELL
    --------------------------------------------------

    frame.SpellName:SetText(
        string.upper(
            spellName or ""
        )
    )

    frame.Icon:SetTexture(
        texture
    )

    --------------------------------------------------
    -- INTERRUPT COLOR
    --------------------------------------------------

    if frame.unit == "target" then
        if notInterruptible then
            -- Cannot interrupt
            frame.Bar:SetStatusBarColor(
                0.48,
                0.48,
                0.48,
                1
            )

            frame.Accent:SetColorTexture(
                0.75,
                0.15,
                0.15,
                1
            )
        else
            -- Interruptible
            frame.Bar:SetStatusBarColor(
                0.72,
                0.48,
                0.10,
                1
            )

            frame.Accent:SetColorTexture(
                0.95,
                0.72,
                0.12,
                1
            )
        end
    else
        --------------------------------------------------
        -- PLAYER CAST COLOR
        --------------------------------------------------

        frame.Bar:SetStatusBarColor(
            0.18,
            0.48,
            0.78,
            1
        )

        frame.Accent:SetColorTexture(
            0.30,
            0.65,
            1.00,
            1
        )
    end

    frame.SpellName:SetShown(settings.showSpellName)
    frame.TimeText:SetShown(settings.showCastTime)
    frame.IconFrame:SetShown(settings.showIcon)

    frame:Show()
end

--------------------------------------------------
-- SMOOTH BAR ANIMATION
--------------------------------------------------

local function OnUpdate(
    frame,
    elapsed
)
    if not frame.casting
        and not frame.channeling then
        return
    end

    --------------------------------------------------
    -- KEEP LIVE CONFIG APPLIED
    --------------------------------------------------

    local key =
        frame.unit == "player"
        and "player"
        or "target"

    local settings =
        EnsureCastBarConfig()[key]

    if not settings.enabled then
        frame.casting = false
        frame.channeling = false
        frame:Hide()
        return
    end

    -- Re-apply the COMPLETE visual layout while casting.
    -- This keeps the actual StatusBar and icon synchronized
    -- with changes made from /bui.
    ApplyFrameConfig(key)

    local now =
        GetTime()

    local duration =
        frame.endTime -
        frame.startTime

    --------------------------------------------------
    -- NORMAL CAST
    --------------------------------------------------

    if frame.casting then
        local progress =
            now -
            frame.startTime

        local remaining =
            frame.endTime -
            now

        if remaining <= 0 then
            frame.casting = false

            frame:Hide()

            return
        end

        frame.Bar:SetValue(
            progress
        )

        frame.TimeText:SetText(
            string.format(
                "%.1f",
                remaining
            )
        )

        --------------------------------------------------
        -- CHANNEL
        --------------------------------------------------
    elseif frame.channeling then
        local remaining =
            frame.endTime -
            now

        if remaining <= 0 then
            frame.channeling = false

            frame:Hide()

            return
        end

        frame.Bar:SetValue(
            remaining
        )

        frame.TimeText:SetText(
            string.format(
                "%.1f",
                remaining
            )
        )
    end
end

--------------------------------------------------
-- PLAYER EVENTS
--------------------------------------------------

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_START",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_STOP",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_FAILED",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_INTERRUPTED",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_DELAYED",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_START",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "player"
)

PlayerCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "player"
)

--------------------------------------------------
-- PLAYER EVENT HANDLER
--------------------------------------------------

PlayerCast:SetScript(
    "OnEvent",
    function(self, event)
        if event == "UNIT_SPELLCAST_START"
            or event == "UNIT_SPELLCAST_DELAYED"
            or event == "UNIT_SPELLCAST_CHANNEL_START"
            or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
            UpdateCast(self)
        else
            local castType =
                GetCastInfo(self)

            if castType then
                UpdateCast(self)
            else
                self.casting = false
                self.channeling = false

                self:Hide()
            end
        end
    end
)

PlayerCast:SetScript(
    "OnUpdate",
    OnUpdate
)

--------------------------------------------------
-- TARGET EVENTS
--------------------------------------------------

TargetCast:RegisterEvent(
    "PLAYER_TARGET_CHANGED"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_START",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_STOP",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_FAILED",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_INTERRUPTED",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_DELAYED",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_START",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "target"
)

TargetCast:RegisterUnitEvent(
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "target"
)

--------------------------------------------------
-- TARGET EVENT HANDLER
--------------------------------------------------

TargetCast:SetScript(
    "OnEvent",
    function(self, event)
        if event ==
            "PLAYER_TARGET_CHANGED" then
            UpdateCast(self)

            return
        end

        if event ==
            "UNIT_SPELLCAST_START"
            or event ==
            "UNIT_SPELLCAST_DELAYED"
            or event ==
            "UNIT_SPELLCAST_CHANNEL_START"
            or event ==
            "UNIT_SPELLCAST_CHANNEL_UPDATE"
            or event ==
            "UNIT_SPELLCAST_INTERRUPTIBLE"
            or event ==
            "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            UpdateCast(self)
        else
            local castType =
                GetCastInfo(self)

            if castType then
                UpdateCast(self)
            else
                self.casting = false
                self.channeling = false

                self:Hide()
            end
        end
    end
)

TargetCast:SetScript(
    "OnUpdate",
    OnUpdate
)

--------------------------------------------------
-- BLACKOUT MOVERS
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    PlayerCast,
    "PlayerCastBar",
    "PLAYER CAST"
)

BlackoutUI:RegisterMovableFrame(
    TargetCast,
    "TargetCastBar",
    "TARGET CAST"
)
