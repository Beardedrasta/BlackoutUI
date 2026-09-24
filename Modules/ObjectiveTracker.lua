------------------------------------------------------------
-- BlackoutUI
-- ObjectiveTracker.lua
-- Objective / Quest Tracker - Step 1
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.ObjectiveTracker =
    BlackoutUI.ObjectiveTracker or {}

local Tracker = BlackoutUI.ObjectiveTracker

------------------------------------------------------------
-- DEFAULTS
------------------------------------------------------------

local DEFAULTS = {
    enabled = true,
    width = 285,
    scale = 1.00,
    opacity = 0.72,
    showBackground = true,
    titleSize = 12,
    objectiveSize = 10,
    completedColor = true,
    point = "TOPRIGHT",
    relativePoint = "TOPRIGHT",
    x = -35,
    y = -220,
}

local function GetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.ObjectiveTracker =
        BlackoutUIDB.Config.ObjectiveTracker or {}

    local db =
        BlackoutUIDB.Config.ObjectiveTracker

    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

------------------------------------------------------------
-- FIND CLASSIC TRACKER
------------------------------------------------------------

local function GetBlizzardTracker()
    return _G.ObjectiveTrackerFrame
        or _G.QuestWatchFrame
        or _G.WatchFrame
end

------------------------------------------------------------
-- BLACKOUT BACKDROP
------------------------------------------------------------

local Backdrop =
    CreateFrame(
        "Frame",
        "BlackoutUI_ObjectiveTrackerBackdrop",
        UIParent,
        "BackdropTemplate"
    )

Backdrop:SetFrameStrata("BACKGROUND")
Backdrop:SetClampedToScreen(true)
Backdrop:EnableMouse(false)
Backdrop:Hide()

Backdrop:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})

local Header =
    CreateFrame(
        "Frame",
        nil,
        Backdrop,
        "BackdropTemplate"
    )

Header:SetPoint("TOPLEFT", Backdrop, "TOPLEFT", 1, -1)
Header:SetPoint("TOPRIGHT", Backdrop, "TOPRIGHT", -1, -1)
Header:SetHeight(25)
Header:EnableMouse(false)

Header:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
})

Header:SetBackdropColor(0.02, 0.02, 0.02, 0.96)

local HeaderText =
    Header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

HeaderText:SetPoint("LEFT", Header, "LEFT", 8, 0)
HeaderText:SetText("OBJECTIVES")
HeaderText:SetTextColor(0.22, 0.66, 0.92, 1)

------------------------------------------------------------
-- MOVER
------------------------------------------------------------

local Mover =
    CreateFrame(
        "Frame",
        "BlackoutUI_ObjectiveTrackerMover",
        UIParent,
        "BackdropTemplate"
    )

Mover:SetSize(285, 34)
Mover:SetFrameStrata("DIALOG")
Mover:SetClampedToScreen(true)
Mover:SetMovable(true)
Mover:RegisterForDrag("LeftButton")
Mover:EnableMouse(false)
Mover:Hide()

Mover:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})

Mover:SetBackdropColor(0.01, 0.01, 0.01, 0.92)
Mover:SetBackdropBorderColor(0.22, 0.66, 0.92, 1)

local MoverText =
    Mover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

MoverText:SetPoint("CENTER")
MoverText:SetText("OBJECTIVE TRACKER")
MoverText:SetTextColor(0.22, 0.66, 0.92, 1)

local function PositionMover()
    local db = GetConfig()

    Mover:ClearAllPoints()
    Mover:SetPoint(
        db.point or "TOPRIGHT",
        UIParent,
        db.relativePoint or "TOPRIGHT",
        db.x or -35,
        db.y or -220
    )

    Mover:SetWidth(db.width or 285)
end

local function SaveMover()
    local db = GetConfig()
    local point, _, relativePoint, x, y = Mover:GetPoint(1)

    db.point = point
    db.relativePoint = relativePoint
    db.x = x
    db.y = y
end

Mover:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)

Mover:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveMover()
end)

Tracker.Mover = Mover

------------------------------------------------------------
-- TRACKER TEXT STYLING
------------------------------------------------------------

local function SetFontSize(fs, size)
    if not fs or not fs.GetFont then return end
    local font, _, flags = fs:GetFont()
    if font then fs:SetFont(font, size, flags) end
end

local function StyleClassicQuestWatch(db)
    if not _G.QuestWatchFrame
        or not GetNumQuestWatches
        or not GetQuestIndexForWatch then
        return false
    end

    local lineIndex = 1

    for watchIndex = 1, (GetNumQuestWatches() or 0) do
        local questIndex = GetQuestIndexForWatch(watchIndex)

        if questIndex then
            local numObjectives = GetNumQuestLeaderBoards(questIndex) or 0

            if numObjectives > 0 then
                local title = _G["QuestWatchLine" .. lineIndex]
                local allComplete = true

                for objectiveIndex = 1, numObjectives do
                    local _, _, finished =
                        GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                    if not finished then
                        allComplete = false
                    end
                end

                if title then
                    SetFontSize(title, db.titleSize or 12)

                    if allComplete and db.completedColor ~= false then
                        title:SetTextColor(0.25, 0.90, 0.45, 1)
                    else
                        title:SetTextColor(0.95, 0.78, 0.20, 1)
                    end
                end

                lineIndex = lineIndex + 1

                for objectiveIndex = 1, numObjectives do
                    local objective = _G["QuestWatchLine" .. lineIndex]
                    local _, _, finished =
                        GetQuestLogLeaderBoard(objectiveIndex, questIndex)

                    if objective then
                        SetFontSize(objective, db.objectiveSize or 10)

                        if finished and db.completedColor ~= false then
                            objective:SetTextColor(0.25, 0.90, 0.45, 1)
                        else
                            objective:SetTextColor(0.82, 0.84, 0.86, 1)
                        end
                    end

                    lineIndex = lineIndex + 1
                end
            end
        end
    end

    return true
end

local function StyleFrameText(frame, db, depth)
    if not frame or depth > 8 then return end

    for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetObjectType
            and region:GetObjectType() == "FontString" then
            SetFontSize(region, db.objectiveSize or 10)
        end
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        StyleFrameText(child, db, depth + 1)
    end
end

local function StyleTrackerText()
    local db = GetConfig()
    local frame = GetBlizzardTracker()

    if db.enabled == false or not frame then return end

    if frame == _G.QuestWatchFrame and StyleClassicQuestWatch(db) then
        return
    end

    StyleFrameText(frame, db, 0)
end

local function HideBlizzardTrackerArt(frame)
    if not frame then return end

    local names = {
        "HeaderMenu",
        "Header",
        "Background",
        "Backdrop",
        "Border",
    }

    for _, key in ipairs(names) do
        local obj = frame[key]
        if obj and obj ~= Header then
            if obj.SetAlpha then
                obj:SetAlpha(0)
            elseif obj.Hide then
                obj:Hide()
            end
        end
    end

    -- Hide texture regions belonging to the outer Blizzard tracker frame only.
    -- Child quest buttons/text remain untouched and clickable.
    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
        if region
            and region.GetObjectType
            and region:GetObjectType() == "Texture"
            and region.SetAlpha then
            region:SetAlpha(0)
        end
    end
end

local function ApplyStyle()
    local db = GetConfig()
    local frame = GetBlizzardTracker()

    -- Never reposition the mover while the user is actively moving frames.
    -- The mover's drag position is authoritative until OnDragStop saves it.
    local moving =
        BlackoutUI.MoveMode == true

    if not frame then
        Backdrop:Hide()
        return
    end

    if db.enabled == false then
        Backdrop:Hide()
        frame:SetScale(1)
        return
    end

    -- Blizzard recreates/shows tracker artwork when quests are newly tracked.
    -- Re-hide it every time the tracker refreshes.
    HideBlizzardTrackerArt(frame)

    frame:SetScale(db.scale or 1)

    if frame.SetWidth then
        frame:SetWidth(db.width or 285)
    end

    if not moving then
        PositionMover()
    end

    -- Anchor the Blizzard tracker to the mover. While move mode is active the
    -- tracker follows the mover live without resetting the mover itself.
    frame:ClearAllPoints()
    frame:SetPoint(
        "TOPRIGHT",
        Mover,
        "TOPRIGHT",
        0,
        -34
    )

    Backdrop:SetFrameLevel(
        math.max(0, frame:GetFrameLevel() - 2)
    )

    Backdrop:ClearAllPoints()
    Backdrop:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        -8,
        30
    )
    Backdrop:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        8,
        -8
    )

    Backdrop:SetBackdropColor(
        0.008,
        0.008,
        0.008,
        db.showBackground == false
        and 0
        or (db.opacity or 0.72)
    )

    Backdrop:SetBackdropBorderColor(
        0.22,
        0.66,
        0.92,
        1
    )

    Backdrop:SetShown(
        frame:IsShown()
    )

    StyleTrackerText()
end

Tracker.ApplyConfig = ApplyStyle

------------------------------------------------------------
-- CLASSIC TRACKER REFRESH / POSITION LOCK
------------------------------------------------------------

local positionGuard = false
local hookedTracker = nil

local function ForceTrackerPosition()
    local db = GetConfig()
    local frame = GetBlizzardTracker()

    if db.enabled == false or not frame or positionGuard then
        return
    end

    positionGuard = true
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", Mover, "TOPRIGHT", 0, -34)
    positionGuard = false
end

local function HookTrackerPosition()
    local frame = GetBlizzardTracker()
    if not frame or frame == hookedTracker then return end

    hookedTracker = frame

    hooksecurefunc(frame, "SetPoint", function()
        if positionGuard
            or GetConfig().enabled == false
            or BlackoutUI.MoveMode == true then
            return
        end

        C_Timer.After(0, ForceTrackerPosition)
    end)
end

if _G.QuestWatch_Update then
    hooksecurefunc("QuestWatch_Update", function()
        C_Timer.After(0, function()
            HookTrackerPosition()
            ForceTrackerPosition()
            ApplyStyle()
        end)
    end)
end


function Tracker:ResetPosition()
    local db = GetConfig()

    db.point = "TOPRIGHT"
    db.relativePoint = "TOPRIGHT"
    db.x = -35
    db.y = -220

    PositionMover()
    ApplyStyle()
end

------------------------------------------------------------
-- KEEP BACKDROP SYNCHRONIZED
------------------------------------------------------------

local elapsed = 0

Backdrop:SetScript(
    "OnUpdate",
    function(self, delta)
        elapsed = elapsed + delta

        if elapsed < 0.15 then
            return
        end

        elapsed = 0

        local db = GetConfig()
        local frame = GetBlizzardTracker()

        if db.enabled == false
            or not frame
            or not frame:IsShown() then
            self:Hide()
            return
        end

        if BlackoutUI.MoveMode == true then
            -- Do not fight StartMoving() by restoring saved coordinates.
            -- The tracker and backdrop remain anchored and follow the mover.
            self:Show()
            return
        end

        ApplyStyle()
    end
)

------------------------------------------------------------
-- MOVE MODE
------------------------------------------------------------

local lastMoveMode = nil
local MoveWatcher = CreateFrame("Frame")

MoveWatcher:SetScript("OnUpdate", function()
    local moveMode = BlackoutUI.MoveMode == true

    if moveMode == lastMoveMode then
        return
    end

    lastMoveMode = moveMode

    if moveMode then
        PositionMover()
        Mover:EnableMouse(true)
        Mover:Show()
    else
        Mover:EnableMouse(false)
        Mover:Hide()
        ApplyStyle()
    end
end)

------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------

local Events =
    CreateFrame("Frame")

Events:RegisterEvent("PLAYER_LOGIN")
Events:RegisterEvent("QUEST_LOG_UPDATE")

-- Different Classic builds refresh the watch list through different events.
-- Register optional events safely so an unavailable event cannot break loading.
for _, eventName in ipairs({
    "QUEST_WATCH_UPDATE",
    "QUEST_ACCEPTED",
    "QUEST_REMOVED",
}) do
    pcall(
        Events.RegisterEvent,
        Events,
        eventName
    )
end

Events:SetScript(
    "OnEvent",
    function()
        C_Timer.After(
            0.2,
            function()
                HookTrackerPosition()
                ForceTrackerPosition()
                ApplyStyle()
            end
        )
    end
)

------------------------------------------------------------
-- EXPORT
------------------------------------------------------------

BlackoutUI.ObjectiveTracker = Tracker
