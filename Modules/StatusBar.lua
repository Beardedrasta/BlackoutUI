--------------------------------------------------
-- BLACKOUT UI
-- Modules/StatusBar.lua
--
-- STEP 10B
-- Blackout XP Bar + Rested XP + Leveling Dashboard
--
-- Tracks:
--   Current XP / Level
--   Rested XP
--   Session XP
--   Quest XP / hour
--   Kill XP / hour
--   Average XP / quest
--   Average XP / kill
--   Estimated quests / kills to level
--
-- IMPORTANT:
-- Quest XP is directly reported by QUEST_TURNED_IN.
-- Kill XP is inferred from XP changes associated with
-- recent hostile deaths. Anything not confidently
-- attributable remains in "Other XP".
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local BAR_WIDTH = 520
local BAR_HEIGHT = 18

local PANEL_WIDTH = 330
local PANEL_HEIGHT = 430

local SESSION_KEY = "LevelingSession"

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local function EnsureXPConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.XPTracker =
        BlackoutUIDB.Config.XPTracker
        or {}

    local config =
        BlackoutUIDB.Config.XPTracker

    if config.enabled == nil then
        config.enabled = true
    end

    if config.hoverDashboard == nil then
        config.hoverDashboard = true
    end

    if config.showRested == nil then
        config.showRested = true
    end

    if config.width == nil then
        config.width = BAR_WIDTH
    end

    if config.height == nil then
        config.height = BAR_HEIGHT
    end

    if config.scale == nil then
        config.scale = 1.00
    end

    if config.showLevel == nil then
        config.showLevel = true
    end

    if config.showProgress == nil then
        config.showProgress = true
    end

    if config.showPercent == nil then
        config.showPercent = true
    end

    if config.textSize == nil then
        config.textSize = 10
    end

    if config.dashboardScale == nil then
        config.dashboardScale = 1.00
    end

    return config
end

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function FormatNumber(value)
    value =
        math.floor(
            tonumber(value) or 0
        )

    local formatted =
        tostring(value)

    while true do
        local replaced

        formatted,
        replaced =
            formatted:gsub(
                "^(-?%d+)(%d%d%d)",
                "%1,%2"
            )

        if replaced == 0 then
            break
        end
    end

    return formatted
end

local function FormatTime(seconds)
    seconds =
        math.max(
            0,
            math.floor(seconds or 0)
        )

    local hours =
        math.floor(
            seconds / 3600
        )

    local minutes =
        math.floor(
            (seconds % 3600) / 60
        )

    if hours > 0 then
        return string.format(
            "%dh %02dm",
            hours,
            minutes
        )
    end

    local secs =
        seconds % 60

    return string.format(
        "%dm %02ds",
        minutes,
        secs
    )
end

local function SafeRate(amount, seconds)
    if not seconds
        or seconds <= 0 then
        return 0
    end

    return amount
        / seconds
        * 3600
end

local function SafeAverage(amount, count)
    if not count
        or count <= 0 then
        return 0
    end

    return amount / count
end

local function EstimateCount(remaining, average)
    if not average
        or average <= 0 then
        return nil
    end

    return math.ceil(
        remaining / average
    )
end

--------------------------------------------------
-- SAVED SESSION DATA
--------------------------------------------------

local Session = nil

local function EnsureSession()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB[SESSION_KEY] =
        BlackoutUIDB[SESSION_KEY]
        or {}

    Session =
        BlackoutUIDB[SESSION_KEY]

    Session.totalXP =
        Session.totalXP or 0

    Session.questXP =
        Session.questXP or 0

    Session.killXP =
        Session.killXP or 0

    Session.otherXP =
        Session.otherXP or 0

    Session.quests =
        Session.quests or 0

    Session.kills =
        Session.kills or 0

    Session.elapsed =
        Session.elapsed or 0

    Session.levelStart =
        Session.levelStart
        or UnitLevel("player")

    Session.lastXP =
        UnitXP("player") or 0

    Session.lastXPMax =
        UnitXPMax("player") or 0

    Session.lastLevel =
        UnitLevel("player") or 0

    Session.pendingQuestXP =
        Session.pendingQuestXP or 0

    Session.pendingKill =
        false

    Session.pendingKillTime =
        0
end

--------------------------------------------------
-- MAIN XP FRAME
--------------------------------------------------

local XPFrame =
    CreateFrame(
        "Frame",
        "BlackoutUI_XPBar",
        UIParent
    )

XPFrame:SetSize(
    BAR_WIDTH,
    BAR_HEIGHT
)

XPFrame:SetPoint(
    "BOTTOM",
    UIParent,
    "BOTTOM",
    0,
    20
)

XPFrame:SetFrameStrata(
    "MEDIUM"
)

XPFrame:EnableMouse(true)

--------------------------------------------------
-- BACKGROUND
--------------------------------------------------

local Background =
    XPFrame:CreateTexture(
        nil,
        "BACKGROUND"
    )

Background:SetAllPoints()

Background:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.96
)

--------------------------------------------------
-- RESTED PROJECTION
--
-- This sits behind the current XP fill and shows
-- where current XP + available rested XP reaches.
--------------------------------------------------

local RestedFill =
    XPFrame:CreateTexture(
        nil,
        "BORDER"
    )

RestedFill:SetPoint(
    "LEFT",
    XPFrame,
    "LEFT",
    2,
    0
)

RestedFill:SetHeight(
    BAR_HEIGHT - 4
)

RestedFill:SetColorTexture(
    0.12,
    0.32,
    0.58,
    0.55
)

--------------------------------------------------
-- CURRENT XP FILL
--------------------------------------------------

local XPFill =
    XPFrame:CreateTexture(
        nil,
        "ARTWORK"
    )

XPFill:SetPoint(
    "LEFT",
    XPFrame,
    "LEFT",
    2,
    0
)

XPFill:SetHeight(
    BAR_HEIGHT - 4
)

XPFill:SetColorTexture(
    0.16,
    0.48,
    0.82,
    0.95
)

--------------------------------------------------
-- TOP SHINE
--------------------------------------------------

local Shine =
    XPFrame:CreateTexture(
        nil,
        "OVERLAY"
    )

Shine:SetPoint(
    "TOPLEFT",
    XPFrame,
    "TOPLEFT",
    2,
    -2
)

Shine:SetPoint(
    "TOPRIGHT",
    XPFrame,
    "TOPRIGHT",
    -2,
    -2
)

Shine:SetHeight(1)

Shine:SetColorTexture(
    1,
    1,
    1,
    0.12
)

--------------------------------------------------
-- BORDER
--------------------------------------------------

BlackoutUI:CreateBorder(
    XPFrame,
    1,
    "borderBright"
)

--------------------------------------------------
-- LEFT TEXT
--------------------------------------------------

local LevelText =
    BlackoutUI:CreateFont(
        XPFrame,
        10
    )

LevelText:SetPoint(
    "LEFT",
    XPFrame,
    "LEFT",
    7,
    0
)

LevelText:SetJustifyH(
    "LEFT"
)

--------------------------------------------------
-- CENTER TEXT
--------------------------------------------------

local ProgressText =
    BlackoutUI:CreateFont(
        XPFrame,
        10
    )

ProgressText:SetPoint(
    "CENTER",
    XPFrame,
    "CENTER",
    0,
    0
)

--------------------------------------------------
-- RIGHT TEXT
--------------------------------------------------

local PercentText =
    BlackoutUI:CreateFont(
        XPFrame,
        10
    )

PercentText:SetPoint(
    "RIGHT",
    XPFrame,
    "RIGHT",
    -7,
    0
)

PercentText:SetJustifyH(
    "RIGHT"
)

--------------------------------------------------
-- HOVER PANEL
--------------------------------------------------

local Panel =
    CreateFrame(
        "Frame",
        "BlackoutUI_XPDashboard",
        UIParent
    )

Panel:SetSize(
    PANEL_WIDTH,
    PANEL_HEIGHT
)

Panel:SetFrameStrata(
    "DIALOG"
)

Panel:SetClampedToScreen(true)
Panel:Hide()

--------------------------------------------------
-- PANEL BACKGROUND
--------------------------------------------------

local PanelBackground =
    Panel:CreateTexture(
        nil,
        "BACKGROUND"
    )

PanelBackground:SetAllPoints()

PanelBackground:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.98
)

BlackoutUI:CreateBorder(
    Panel,
    1,
    "borderBright"
)

--------------------------------------------------
-- PANEL TITLE
--------------------------------------------------

local PanelTitle =
    BlackoutUI:CreateFont(
        Panel,
        12
    )

PanelTitle:SetPoint(
    "TOPLEFT",
    Panel,
    "TOPLEFT",
    12,
    -11
)

PanelTitle:SetText(
    "LEVELING PROGRESS"
)

PanelTitle:SetTextColor(
    0.72,
    0.86,
    1,
    1
)

--------------------------------------------------
-- PANEL SUBTITLE
--------------------------------------------------

local PanelSubtitle =
    BlackoutUI:CreateFont(
        Panel,
        9
    )

PanelSubtitle:SetPoint(
    "TOPRIGHT",
    Panel,
    "TOPRIGHT",
    -12,
    -12
)

PanelSubtitle:SetText(
    "BLACKOUT UI"
)

PanelSubtitle:SetTextColor(
    0.42,
    0.42,
    0.42,
    1
)

--------------------------------------------------
-- DIVIDER HELPER
--------------------------------------------------

local function CreateDivider(y)
    local divider =
        Panel:CreateTexture(
            nil,
            "BORDER"
        )

    divider:SetPoint(
        "TOPLEFT",
        Panel,
        "TOPLEFT",
        10,
        y
    )

    divider:SetPoint(
        "TOPRIGHT",
        Panel,
        "TOPRIGHT",
        -10,
        y
    )

    divider:SetHeight(1)

    divider:SetColorTexture(
        1,
        1,
        1,
        0.08
    )

    return divider
end

CreateDivider(-32)

--------------------------------------------------
-- ROW STORAGE
--------------------------------------------------

local Rows = {}

local function CreateRow(
    key,
    label,
    y,
    isHeader
)
    if isHeader then
        local header =
            BlackoutUI:CreateFont(
                Panel,
                9
            )

        header:SetPoint(
            "TOPLEFT",
            Panel,
            "TOPLEFT",
            12,
            y
        )

        header:SetText(label)

        header:SetTextColor(
            0.40,
            0.72,
            0.95,
            1
        )

        Rows[key] = {
            header = header
        }

        return
    end

    local left =
        BlackoutUI:CreateFont(
            Panel,
            9
        )

    left:SetPoint(
        "TOPLEFT",
        Panel,
        "TOPLEFT",
        12,
        y
    )

    left:SetText(label)

    left:SetTextColor(
        0.68,
        0.68,
        0.68,
        1
    )

    local right =
        BlackoutUI:CreateFont(
            Panel,
            9
        )

    right:SetPoint(
        "TOPRIGHT",
        Panel,
        "TOPRIGHT",
        -12,
        y
    )

    right:SetJustifyH(
        "RIGHT"
    )

    right:SetTextColor(
        0.95,
        0.95,
        0.95,
        1
    )

    Rows[key] = {
        left = left,
        right = right
    }
end

--------------------------------------------------
-- PROGRESS SECTION
--------------------------------------------------

CreateRow(
    "progressHeader",
    "PROGRESS",
    -45,
    true
)

CreateRow(
    "level",
    "Current Level",
    -62
)

CreateRow(
    "xp",
    "Current XP",
    -78
)

CreateRow(
    "remaining",
    "XP Remaining",
    -94
)

CreateRow(
    "rested",
    "Rested XP",
    -110
)

--------------------------------------------------
-- SESSION SECTION
--------------------------------------------------

CreateDivider(-128)

CreateRow(
    "sessionHeader",
    "SESSION",
    -141,
    true
)

CreateRow(
    "time",
    "Session Time",
    -158
)

CreateRow(
    "totalXP",
    "Total XP Gained",
    -174
)

CreateRow(
    "overallRate",
    "Overall XP / Hour",
    -190
)

--------------------------------------------------
-- KILL SECTION
--------------------------------------------------

CreateDivider(-208)

CreateRow(
    "killHeader",
    "KILLS",
    -221,
    true
)

CreateRow(
    "killRate",
    "XP / Hour",
    -238
)

CreateRow(
    "avgKill",
    "Average XP / Kill",
    -254
)

CreateRow(
    "kills",
    "Kills This Session",
    -270
)

CreateRow(
    "killsToLevel",
    "Est. Kills to Level",
    -286
)

--------------------------------------------------
-- QUEST SECTION
--------------------------------------------------

CreateDivider(-304)

-- Leave enough room beneath the final quest row
-- for the explanatory footnote.
Panel:SetHeight(PANEL_HEIGHT)

CreateRow(
    "questHeader",
    "QUESTS",
    -317,
    true
)

CreateRow(
    "questRate",
    "XP / Hour",
    -334
)

CreateRow(
    "avgQuest",
    "Average XP / Quest",
    -350
)

CreateRow(
    "quests",
    "Quests Turned In",
    -366
)

CreateRow(
    "questsToLevel",
    "Est. Quests to Level",
    -382
)

--------------------------------------------------
-- PANEL FOOTNOTE
--------------------------------------------------

local Footnote =
    BlackoutUI:CreateFont(
        Panel,
        8
    )

Footnote:SetPoint(
    "BOTTOMLEFT",
    Panel,
    "BOTTOMLEFT",
    12,
    10
)

Footnote:SetText(
    "Kill XP is estimated from XP gains following hostile deaths."
)

Footnote:SetTextColor(
    0.40,
    0.40,
    0.40,
    1
)

--------------------------------------------------
-- PANEL POSITION
--------------------------------------------------

local function PositionPanel()
    Panel:ClearAllPoints()

    local _, screenHeight =
        UIParent:GetSize()

    local centerY =
        XPFrame:GetCenter()

    local frameY =
        select(
            2,
            XPFrame:GetCenter()
        )

    if frameY
        and screenHeight
        and frameY > screenHeight * 0.55 then
        Panel:SetPoint(
            "TOP",
            XPFrame,
            "BOTTOM",
            0,
            -8
        )
    else
        Panel:SetPoint(
            "BOTTOM",
            XPFrame,
            "TOP",
            0,
            8
        )
    end
end

--------------------------------------------------
-- UPDATE BAR
--------------------------------------------------

local function UpdateXPBar()
    local level =
        UnitLevel("player") or 0

    local currentXP =
        UnitXP("player") or 0

    local maxXP =
        UnitXPMax("player") or 0

    local config =
        EnsureXPConfig()

    local rested =
        config.showRested
        and (
            GetXPExhaustion()
            or 0
        )
        or 0

    if maxXP <= 0 then
        XPFill:SetWidth(1)
        RestedFill:SetWidth(1)

        LevelText:SetText(
            "LEVEL " .. level
        )

        ProgressText:SetText(
            "MAX LEVEL"
        )

        PercentText:SetText(
            "100%"
        )

        return
    end

    local innerWidth =
        math.max(
            1,
            XPFrame:GetWidth() - 4
        )

    local progress =
        math.max(
            0,
            math.min(
                1,
                currentXP / maxXP
            )
        )

    local restedProgress =
        math.max(
            progress,
            math.min(
                1,
                (currentXP + rested)
                / maxXP
            )
        )

    XPFill:SetWidth(
        math.max(
            1,
            innerWidth * progress
        )
    )

    RestedFill:SetWidth(
        math.max(
            1,
            innerWidth
            * restedProgress
        )
    )

    LevelText:SetText(
        "LEVEL "
        .. level
    )

    ProgressText:SetText(
        FormatNumber(currentXP)
        .. " / "
        .. FormatNumber(maxXP)
    )

    PercentText:SetText(
        string.format(
            "%.1f%%",
            progress * 100
        )
    )
end

--------------------------------------------------
-- UPDATE HOVER DASHBOARD
--------------------------------------------------

local function UpdatePanel()
    if not Session then
        return
    end

    local level =
        UnitLevel("player") or 0

    local currentXP =
        UnitXP("player") or 0

    local maxXP =
        UnitXPMax("player") or 0

    local remaining =
        math.max(
            0,
            maxXP - currentXP
        )

    local rested =
        GetXPExhaustion()
        or 0

    local elapsed =
        Session.elapsed or 0

    local overallRate =
        SafeRate(
            Session.totalXP,
            elapsed
        )

    local killRate =
        SafeRate(
            Session.killXP,
            elapsed
        )

    local questRate =
        SafeRate(
            Session.questXP,
            elapsed
        )

    local averageKill =
        SafeAverage(
            Session.killXP,
            Session.kills
        )

    local averageQuest =
        SafeAverage(
            Session.questXP,
            Session.quests
        )

    local killsToLevel =
        EstimateCount(
            remaining,
            averageKill
        )

    local questsToLevel =
        EstimateCount(
            remaining,
            averageQuest
        )

    Rows.level.right:SetText(
        tostring(level)
    )

    Rows.xp.right:SetText(
        FormatNumber(currentXP)
        .. " / "
        .. FormatNumber(maxXP)
    )

    Rows.remaining.right:SetText(
        FormatNumber(remaining)
    )

    local restedPercent = 0

    if maxXP > 0 then
        restedPercent =
            rested
            / maxXP
            * 100
    end

    Rows.rested.right:SetText(
        FormatNumber(rested)
        .. string.format(
            "  (%.1f%%)",
            restedPercent
        )
    )

    Rows.time.right:SetText(
        FormatTime(elapsed)
    )

    Rows.totalXP.right:SetText(
        FormatNumber(
            Session.totalXP
        )
    )

    Rows.overallRate.right:SetText(
        FormatNumber(overallRate)
        .. "/hr"
    )

    Rows.killRate.right:SetText(
        FormatNumber(killRate)
        .. "/hr"
    )

    Rows.avgKill.right:SetText(
        Session.kills > 0
        and FormatNumber(
            averageKill
        )
        or "--"
    )

    Rows.kills.right:SetText(
        tostring(
            Session.kills
        )
    )

    Rows.killsToLevel.right:SetText(
        killsToLevel
        and FormatNumber(
            killsToLevel
        )
        or "--"
    )

    Rows.questRate.right:SetText(
        FormatNumber(questRate)
        .. "/hr"
    )

    Rows.avgQuest.right:SetText(
        Session.quests > 0
        and FormatNumber(
            averageQuest
        )
        or "--"
    )

    Rows.quests.right:SetText(
        tostring(
            Session.quests
        )
    )

    Rows.questsToLevel.right:SetText(
        questsToLevel
        and FormatNumber(
            questsToLevel
        )
        or "--"
    )
end

--------------------------------------------------
-- XP DELTA HANDLING
--------------------------------------------------

local function HandleXPChange()
    if not Session then
        return
    end

    local currentXP =
        UnitXP("player") or 0

    local maxXP =
        UnitXPMax("player") or 0

    local currentLevel =
        UnitLevel("player") or 0

    local lastXP =
        Session.lastXP
        or currentXP

    local lastXPMax =
        Session.lastXPMax
        or maxXP

    local lastLevel =
        Session.lastLevel
        or currentLevel

    local gained = 0

    --------------------------------------------------
    -- SAME LEVEL
    --------------------------------------------------

    if currentLevel == lastLevel then
        gained =
            currentXP - lastXP

        --------------------------------------------------
        -- LEVELED UP
        --------------------------------------------------
    elseif currentLevel > lastLevel then
        gained =
            math.max(
                0,
                lastXPMax - lastXP
            )
            + currentXP
    end

    if gained > 0 then
        Session.totalXP =
            Session.totalXP
            + gained

        --------------------------------------------------
        -- QUEST ATTRIBUTION
        --------------------------------------------------

        if Session.pendingQuestXP
            and Session.pendingQuestXP > 0 then
            local questPart =
                math.min(
                    gained,
                    Session.pendingQuestXP
                )

            Session.questXP =
                Session.questXP
                + questPart

            Session.pendingQuestXP =
                math.max(
                    0,
                    Session.pendingQuestXP
                    - questPart
                )

            gained =
                gained - questPart
        end

        --------------------------------------------------
        -- KILL ATTRIBUTION
        --------------------------------------------------

        if gained > 0
            and Session.pendingKill
            and (
                GetTime()
                - (
                    Session.pendingKillTime
                    or 0
                )
            ) <= 2.5 then
            Session.killXP =
                Session.killXP
                + gained

            Session.kills =
                Session.kills + 1

            Session.pendingKill =
                false

            gained = 0
        end

        --------------------------------------------------
        -- UNATTRIBUTED XP
        --------------------------------------------------

        if gained > 0 then
            Session.otherXP =
                Session.otherXP
                + gained
        end
    end

    Session.lastXP =
        currentXP

    Session.lastXPMax =
        maxXP

    Session.lastLevel =
        currentLevel

    UpdateXPBar()

    if Panel:IsShown() then
        UpdatePanel()
    end
end

--------------------------------------------------
-- HOVER BEHAVIOR
--------------------------------------------------

XPFrame:SetScript(
    "OnEnter",
    function()
        local config =
            EnsureXPConfig()

        if not config.enabled
            or not config.hoverDashboard then
            Panel:Hide()
            return
        end

        PositionPanel()
        UpdatePanel()
        Panel:Show()
    end
)

XPFrame:SetScript(
    "OnLeave",
    function()
        if Panel:IsMouseOver() then
            return
        end

        Panel:Hide()
    end
)

Panel:EnableMouse(true)

Panel:SetScript(
    "OnLeave",
    function()
        if XPFrame:IsMouseOver() then
            return
        end

        Panel:Hide()
    end
)

--------------------------------------------------
-- EVENTS
--------------------------------------------------

local EventFrame =
    CreateFrame("Frame")

EventFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

EventFrame:RegisterEvent(
    "PLAYER_XP_UPDATE"
)

EventFrame:RegisterEvent(
    "PLAYER_LEVEL_UP"
)

EventFrame:RegisterEvent(
    "UPDATE_EXHAUSTION"
)

EventFrame:RegisterEvent(
    "QUEST_TURNED_IN"
)

EventFrame:RegisterEvent(
    "COMBAT_LOG_EVENT_UNFILTERED"
)

EventFrame:SetScript(
    "OnEvent",
    function(self, event, ...)
        --------------------------------------------------
        -- INITIALIZE
        --------------------------------------------------

        if event ==
            "PLAYER_ENTERING_WORLD" then
            EnsureSession()
            UpdateXPBar()

            return
        end

        if not Session then
            EnsureSession()
        end

        --------------------------------------------------
        -- XP CHANGED
        --------------------------------------------------

        if event ==
            "PLAYER_XP_UPDATE" then
            HandleXPChange()

            return
        end

        --------------------------------------------------
        -- LEVEL UP
        --------------------------------------------------

        if event ==
            "PLAYER_LEVEL_UP" then
            -- PLAYER_XP_UPDATE will do the XP delta.
            -- We refresh visual state here as well.
            UpdateXPBar()

            return
        end

        --------------------------------------------------
        -- RESTED XP CHANGED
        --------------------------------------------------

        if event ==
            "UPDATE_EXHAUSTION" then
            UpdateXPBar()

            if Panel:IsShown() then
                UpdatePanel()
            end

            return
        end

        --------------------------------------------------
        -- QUEST TURNED IN
        --------------------------------------------------

        if event ==
            "QUEST_TURNED_IN" then
            local questID,
            xpReward =
                ...

            xpReward =
                tonumber(xpReward)
                or 0

            Session.quests =
                Session.quests + 1

            Session.pendingQuestXP =
                Session.pendingQuestXP
                + xpReward

            if Panel:IsShown() then
                UpdatePanel()
            end

            return
        end

        --------------------------------------------------
        -- HOSTILE UNIT DEATH
        --------------------------------------------------

        if event ==
            "COMBAT_LOG_EVENT_UNFILTERED" then
            local _,
            subevent,
            _,
            sourceGUID,
            sourceName,
            sourceFlags,
            sourceRaidFlags,
            destGUID,
            destName,
            destFlags =
                CombatLogGetCurrentEventInfo()

            if subevent ==
                "UNIT_DIED"
                and destGUID then
                --------------------------------------------------
                -- Mark a short attribution window.
                -- We only increment the kill count if XP
                -- actually arrives immediately afterward.
                --------------------------------------------------

                Session.pendingKill =
                    true

                Session.pendingKillTime =
                    GetTime()
            end

            return
        end
    end
)

--------------------------------------------------
-- SESSION CLOCK
--------------------------------------------------

local Clock =
    CreateFrame("Frame")

local clockElapsed = 0

Clock:SetScript(
    "OnUpdate",
    function(self, elapsed)
        if not Session then
            return
        end

        clockElapsed =
            clockElapsed + elapsed

        if clockElapsed < 1 then
            return
        end

        local wholeSeconds =
            math.floor(
                clockElapsed
            )

        clockElapsed =
            clockElapsed
            - wholeSeconds

        Session.elapsed =
            Session.elapsed
            + wholeSeconds

        if Panel:IsShown() then
            UpdatePanel()
        end
    end
)

--------------------------------------------------
-- BLACKOUT MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    XPFrame,
    "XPBar",
    "XP / LEVELING BAR"
)

--------------------------------------------------
-- CONFIG API
--------------------------------------------------

BlackoutUI.XPTracker =
    BlackoutUI.XPTracker or {}

function BlackoutUI.XPTracker:ApplyConfig()
    local config =
        EnsureXPConfig()

    XPFrame:SetSize(
        config.width,
        config.height
    )

    XPFrame:SetScale(
        config.scale
    )

    RestedFill:SetHeight(
        math.max(1, config.height - 4)
    )

    XPFill:SetHeight(
        math.max(1, config.height - 4)
    )

    Panel:SetScale(
        config.dashboardScale
    )

    local function SetFontSize(fontString, size)
        local font, _, flags =
            fontString:GetFont()

        if font then
            fontString:SetFont(
                font,
                size,
                flags
            )
        end
    end

    SetFontSize(
        LevelText,
        config.textSize
    )

    SetFontSize(
        ProgressText,
        config.textSize
    )

    SetFontSize(
        PercentText,
        config.textSize
    )

    LevelText:SetShown(
        config.showLevel
    )

    ProgressText:SetShown(
        config.showProgress
    )

    PercentText:SetShown(
        config.showPercent
    )

    if config.enabled then
        XPFrame:Show()
        UpdateXPBar()
    else
        Panel:Hide()
        XPFrame:Hide()
    end
end

function BlackoutUI.XPTracker:ResetSession()
    EnsureSession()

    Session.totalXP = 0
    Session.questXP = 0
    Session.killXP = 0
    Session.otherXP = 0
    Session.quests = 0
    Session.kills = 0
    Session.elapsed = 0
    Session.pendingQuestXP = 0
    Session.pendingKill = false
    Session.pendingKillTime = 0

    Session.lastXP =
        UnitXP("player") or 0

    Session.lastXPMax =
        UnitXPMax("player") or 0

    Session.lastLevel =
        UnitLevel("player") or 0

    UpdateXPBar()
    UpdatePanel()
end

--------------------------------------------------
-- INITIAL UPDATE
--------------------------------------------------

EnsureSession()
UpdateXPBar()
BlackoutUI.XPTracker:ApplyConfig()
