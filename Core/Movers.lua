--------------------------------------------------
-- BLACKOUT UI
-- Core/Movers.lua
--------------------------------------------------

local addonName, BlackoutUI = ...


--------------------------------------------------
-- STORAGE
--------------------------------------------------

BlackoutUI.MovableFrames = {}
BlackoutUI.MoveMode = false

--------------------------------------------------
-- GRID SETTINGS
--------------------------------------------------

local GRID_SIZE = 10
local MAJOR_GRID_SIZE = 30

local GridFrame = nil

--------------------------------------------------
-- DEFAULT DATABASE
--------------------------------------------------

local defaults = {

    positions = {}

}

--------------------------------------------------
-- INITIALIZE DATABASE
--------------------------------------------------

function BlackoutUI:InitializeDatabase()
    if not BlackoutUIDB then
        BlackoutUIDB = {}
    end

    if not BlackoutUIDB.positions then
        BlackoutUIDB.positions = {}
    end
end

--------------------------------------------------
-- SAVE FRAME POSITION
--------------------------------------------------

function BlackoutUI:SavePosition(frame)
    if not frame
        or not frame.BlackoutMoverKey then
        return
    end

    self:InitializeDatabase()

    local point,
    relativeTo,
    relativePoint,
    x,
    y =
        frame:GetPoint(1)

    if not point then
        return
    end

    --------------------------------------------------
    -- SAVE
    --------------------------------------------------

    BlackoutUIDB.positions[
    frame.BlackoutMoverKey
    ] = {

        point = point,

        relativePoint =
            relativePoint or point,

        x = x or 0,

        y = y or 0

    }
end

--------------------------------------------------
-- RESTORE FRAME POSITION
--------------------------------------------------

function BlackoutUI:RestorePosition(frame)
    if not frame
        or not frame.BlackoutMoverKey then
        return
    end

    self:InitializeDatabase()

    local saved =
        BlackoutUIDB.positions[
        frame.BlackoutMoverKey
        ]

    if not saved then
        return
    end

    frame:ClearAllPoints()

    frame:SetPoint(
        saved.point or "CENTER",
        UIParent,
        saved.relativePoint or saved.point or "CENTER",
        saved.x or 0,
        saved.y or 0
    )
end

--------------------------------------------------
-- CREATE ALIGNMENT GRID
--------------------------------------------------

function BlackoutUI:CreateAlignmentGrid()
    --------------------------------------------------
    -- ONLY CREATE IT ONCE
    --------------------------------------------------

    if GridFrame then
        return GridFrame
    end

    --------------------------------------------------
    -- MAIN GRID FRAME
    --------------------------------------------------

    GridFrame = CreateFrame(
        "Frame",
        "BlackoutUI_AlignmentGrid",
        UIParent
    )

    GridFrame:SetAllPoints(
        UIParent
    )

    --------------------------------------------------
    -- KEEP GRID BEHIND OUR MOVERS
    --------------------------------------------------

    GridFrame:SetFrameStrata(
        "BACKGROUND"
    )

    GridFrame:SetFrameLevel(0)

    --------------------------------------------------
    -- DO NOT BLOCK MOUSE
    --------------------------------------------------

    GridFrame:EnableMouse(false)

    --------------------------------------------------
    -- DARK SCREEN OVERLAY
    --------------------------------------------------

    local shade =
        GridFrame:CreateTexture(
            nil,
            "BACKGROUND"
        )

    shade:SetAllPoints()

    shade:SetColorTexture(
        0,
        0,
        0,
        0.12
    )

    --------------------------------------------------
    -- SCREEN SIZE
    --------------------------------------------------

    local screenWidth =
        UIParent:GetWidth()

    local screenHeight =
        UIParent:GetHeight()

    --------------------------------------------------
    -- VERTICAL GRID LINES
    --------------------------------------------------

    local x = 0

    while x <= screenWidth do
        local line =
            GridFrame:CreateTexture(
                nil,
                "ARTWORK"
            )

        line:SetWidth(1)

        line:SetPoint(
            "TOPLEFT",
            GridFrame,
            "TOPLEFT",
            x,
            0
        )

        line:SetPoint(
            "BOTTOMLEFT",
            GridFrame,
            "BOTTOMLEFT",
            x,
            0
        )

        --------------------------------------------------
        -- MAJOR LINE EVERY 30 PIXELS
        --------------------------------------------------

        if x % MAJOR_GRID_SIZE == 0 then
            line:SetColorTexture(
                0.30,
                0.65,
                0.85,
                0.22
            )
        else
            line:SetColorTexture(
                1,
                1,
                1,
                0.055
            )
        end

        x = x + GRID_SIZE
    end

    --------------------------------------------------
    -- HORIZONTAL GRID LINES
    --------------------------------------------------

    local y = 0

    while y <= screenHeight do
        local line =
            GridFrame:CreateTexture(
                nil,
                "ARTWORK"
            )

        line:SetHeight(1)

        line:SetPoint(
            "BOTTOMLEFT",
            GridFrame,
            "BOTTOMLEFT",
            0,
            y
        )

        line:SetPoint(
            "BOTTOMRIGHT",
            GridFrame,
            "BOTTOMRIGHT",
            0,
            y
        )

        --------------------------------------------------
        -- MAJOR LINE EVERY 50 PIXELS
        --------------------------------------------------

        if y % MAJOR_GRID_SIZE == 0 then
            line:SetColorTexture(
                0.30,
                0.65,
                0.85,
                0.22
            )
        else
            line:SetColorTexture(
                1,
                1,
                1,
                0.055
            )
        end

        y = y + GRID_SIZE
    end

    --------------------------------------------------
    -- CENTER VERTICAL LINE
    --------------------------------------------------

    local centerVertical =
        GridFrame:CreateTexture(
            nil,
            "OVERLAY"
        )

    centerVertical:SetWidth(2)

    centerVertical:SetPoint(
        "TOP",
        GridFrame,
        "TOP",
        0,
        0
    )

    centerVertical:SetPoint(
        "BOTTOM",
        GridFrame,
        "BOTTOM",
        0,
        0
    )

    centerVertical:SetColorTexture(
        0.20,
        0.85,
        1.00,
        0.75
    )

    --------------------------------------------------
    -- CENTER HORIZONTAL LINE
    --------------------------------------------------

    local centerHorizontal =
        GridFrame:CreateTexture(
            nil,
            "OVERLAY"
        )

    centerHorizontal:SetHeight(2)

    centerHorizontal:SetPoint(
        "LEFT",
        GridFrame,
        "LEFT",
        0,
        0
    )

    centerHorizontal:SetPoint(
        "RIGHT",
        GridFrame,
        "RIGHT",
        0,
        0
    )

    centerHorizontal:SetColorTexture(
        0.20,
        0.85,
        1.00,
        0.75
    )

    --------------------------------------------------
    -- CENTER MARKER
    --------------------------------------------------

    local centerBox =
        CreateFrame(
            "Frame",
            nil,
            GridFrame
        )

    centerBox:SetSize(
        10,
        10
    )

    centerBox:SetPoint(
        "CENTER",
        GridFrame,
        "CENTER",
        0,
        0
    )

    local centerBoxTexture =
        centerBox:CreateTexture(
            nil,
            "OVERLAY"
        )

    centerBoxTexture:SetAllPoints()

    centerBoxTexture:SetColorTexture(
        0.20,
        0.85,
        1.00,
        0.85
    )

    --------------------------------------------------
    -- CENTER LABEL
    --------------------------------------------------

    local centerText =
        BlackoutUI:CreateFont(
            GridFrame,
            10
        )

    centerText:SetPoint(
        "TOP",
        centerBox,
        "BOTTOM",
        0,
        -5
    )

    centerText:SetText(
        "SCREEN CENTER"
    )

    centerText:SetTextColor(
        0.30,
        0.85,
        1.00,
        1
    )

    --------------------------------------------------
    -- GRID INFORMATION
    --------------------------------------------------

    local info =
        BlackoutUI:CreateFont(
            GridFrame,
            11
        )

    info:SetPoint(
        "TOPLEFT",
        GridFrame,
        "TOPLEFT",
        15,
        -15
    )

    info:SetText(
        "BLACKOUT UI  •  MOVE MODE  •  GRID 10px / 30px"
    )

    info:SetTextColor(
        0.50,
        0.85,
        1.00,
        1
    )

    --------------------------------------------------
    -- START HIDDEN
    --------------------------------------------------

    GridFrame:Hide()

    return GridFrame
end

--------------------------------------------------
-- SHOW ALIGNMENT GRID
--------------------------------------------------

function BlackoutUI:ShowAlignmentGrid()
    local grid =
        self:CreateAlignmentGrid()

    grid:Show()
end

--------------------------------------------------
-- HIDE ALIGNMENT GRID
--------------------------------------------------

function BlackoutUI:HideAlignmentGrid()
    if GridFrame then
        GridFrame:Hide()
    end
end

--------------------------------------------------
-- CREATE MOVER OVERLAY
--------------------------------------------------

local function CreateMoverOverlay(frame, label)
    local overlay = CreateFrame(
        "Frame",
        nil,
        frame
    )

    overlay:SetAllPoints(frame)

    --------------------------------------------------
    -- IMPORTANT
    -- Keep mover above normal frame content.
    --------------------------------------------------

    overlay:SetFrameLevel(
        frame:GetFrameLevel() + 50
    )

    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local background =
        overlay:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    background:SetColorTexture(
        0.05,
        0.55,
        0.75,
        0.32
    )

    --------------------------------------------------
    -- BORDER
    --------------------------------------------------

    local top =
        overlay:CreateTexture(
            nil,
            "OVERLAY"
        )

    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(1)

    top:SetColorTexture(
        0.20,
        0.80,
        1.00,
        1
    )

    local bottom =
        overlay:CreateTexture(
            nil,
            "OVERLAY"
        )

    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)

    bottom:SetColorTexture(
        0.20,
        0.80,
        1.00,
        1
    )

    local left =
        overlay:CreateTexture(
            nil,
            "OVERLAY"
        )

    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(1)

    left:SetColorTexture(
        0.20,
        0.80,
        1.00,
        1
    )

    local right =
        overlay:CreateTexture(
            nil,
            "OVERLAY"
        )

    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(1)

    right:SetColorTexture(
        0.20,
        0.80,
        1.00,
        1
    )

    --------------------------------------------------
    -- LABEL
    --------------------------------------------------

    local text =
        BlackoutUI:CreateFont(
            overlay,
            11
        )

    text:SetPoint(
        "CENTER",
        overlay,
        "CENTER",
        0,
        0
    )

    text:SetText(
        label or "MOVE"
    )

    text:SetTextColor(
        1,
        1,
        1,
        1
    )

    overlay.Label = text

    --------------------------------------------------
    -- MOVEMENT
    --------------------------------------------------

    overlay:EnableMouse(true)

    overlay:RegisterForDrag(
        "LeftButton"
    )

    overlay:SetScript(
        "OnDragStart",
        function()
            frame:StartMoving()
        end
    )

    overlay:SetScript(
        "OnDragStop",
        function()
            frame:StopMovingOrSizing()

            BlackoutUI:SavePosition(
                frame
            )
        end
    )

    overlay:Hide()

    return overlay
end

--------------------------------------------------
-- REGISTER MOVABLE FRAME
--------------------------------------------------

function BlackoutUI:RegisterMovableFrame(
    frame,
    key,
    label
)
    if not frame
        or not key then
        return
    end

    frame.BlackoutMoverKey = key

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)

    --------------------------------------------------
    -- CREATE OVERLAY
    --------------------------------------------------

    local overlay =
        CreateMoverOverlay(
            frame,
            label or key
        )

    frame.BlackoutMoverOverlay =
        overlay

    --------------------------------------------------
    -- STORE
    --------------------------------------------------

    self.MovableFrames[key] = {

        frame = frame,
        overlay = overlay,
        label = label or key

    }

    --------------------------------------------------
    -- RESTORE SAVED POSITION
    --------------------------------------------------

    self:RestorePosition(frame)
end

--------------------------------------------------
-- ENABLE MOVE MODE
--------------------------------------------------

function BlackoutUI:EnableMoveMode()
    self.MoveMode = true

    --------------------------------------------------
    -- SHOW ALIGNMENT GRID
    --------------------------------------------------

    self:ShowAlignmentGrid()

    for key, data
    in pairs(self.MovableFrames) do
        local frame =
            data.frame

        local overlay =
            data.overlay

        --------------------------------------------------
        -- REMEMBER WHETHER FRAME WAS SHOWN
        --------------------------------------------------

        data.wasShown =
            frame:IsShown()

        --------------------------------------------------
        -- SHOW FRAME FOR POSITIONING
        --------------------------------------------------

        frame:Show()
        overlay:Show()
    end

    print(
        "|cff666666[|r" ..
        "|cffffffffBlackoutUI|r" ..
        "|cff666666]|r " ..
        "|cff33ccffMove Mode ON|r"
    )
end

--------------------------------------------------
-- DISABLE MOVE MODE
--------------------------------------------------

function BlackoutUI:DisableMoveMode()
    self.MoveMode = false

    --------------------------------------------------
    -- HIDE ALIGNMENT GRID
    --------------------------------------------------

    self:HideAlignmentGrid()

    for key, data
    in pairs(self.MovableFrames) do
        local frame =
            data.frame

        local overlay =
            data.overlay

        overlay:Hide()

        --------------------------------------------------
        -- PLAYER FRAME ALWAYS STAYS VISIBLE
        --------------------------------------------------

        if key == "PlayerFrame" then
            frame:Show()

            --------------------------------------------------
            -- OTHER FRAMES RETURN TO PREVIOUS STATE
            --------------------------------------------------
        elseif data.wasShown then
            frame:Show()
        else
            frame:Hide()
        end
    end

    print(
        "|cff666666[|r" ..
        "|cffffffffBlackoutUI|r" ..
        "|cff666666]|r " ..
        "|cffaaaaaaMove Mode OFF|r"
    )
end

--------------------------------------------------
-- TOGGLE MOVE MODE
--------------------------------------------------

function BlackoutUI:ToggleMoveMode()
    if self.MoveMode then
        self:DisableMoveMode()
    else
        self:EnableMoveMode()
    end
end

--------------------------------------------------
-- RESET POSITIONS
--------------------------------------------------

function BlackoutUI:ResetPositions()
    self:InitializeDatabase()

    BlackoutUIDB.positions = {}

    print(
        "|cff666666[|r" ..
        "|cffffffffBlackoutUI|r" ..
        "|cff666666]|r " ..
        "Positions reset. Type |cffffffff/reload|r."
    )
end

--------------------------------------------------
-- SLASH COMMAND
--------------------------------------------------

SLASH_BLACKOUTUI1 = "/bui"
SLASH_BLACKOUTUI2 = "/blackoutui"

SlashCmdList["BLACKOUTUI"] =
    function(message)
        message =
            string.lower(
                message or ""
            )

        --------------------------------------------------
        -- RESET
        --------------------------------------------------

        if message == "reset" then
            BlackoutUI:ResetPositions()

            return
        end

        --------------------------------------------------
        -- HELP
        --------------------------------------------------

        if message == "help" then
            print(
                "|cffffffffBlackoutUI Commands:|r"
            )

            print(
                "|cff33ccff/bui|r - Toggle Move Mode"
            )

            print(
                "|cff33ccff/bui reset|r - Reset positions"
            )

            return
        end

        --------------------------------------------------
        -- DEFAULT = MOVE MODE
        --------------------------------------------------

        BlackoutUI:ToggleMoveMode()
    end

--------------------------------------------------
-- DATABASE INITIALIZATION
--------------------------------------------------

local DatabaseLoader =
    CreateFrame("Frame")

DatabaseLoader:RegisterEvent(
    "ADDON_LOADED"
)

DatabaseLoader:SetScript(
    "OnEvent",
    function(self, event, loadedAddon)
        if loadedAddon ~= addonName then
            return
        end

        BlackoutUI:InitializeDatabase()

        self:UnregisterEvent(
            "ADDON_LOADED"
        )
    end
)
