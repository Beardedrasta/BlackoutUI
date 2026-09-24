------------------------------------------------------------
-- BLACKOUT UI
-- Modules/LootFrames.lua
-- Classic Loot Window - Step 1
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.LootFrames =
    BlackoutUI.LootFrames or {}

local LootFrames =
    BlackoutUI.LootFrames

------------------------------------------------------------
-- DEFAULTS
------------------------------------------------------------

local DEFAULTS = {
    enabled = true,
    scale = 1.00,
    point = "TOPLEFT",
    relativePoint = "TOPLEFT",
    x = 20,
    y = -180,
}

local function GetConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.LootFrames =
        BlackoutUIDB.Config.LootFrames or {}

    local db =
        BlackoutUIDB.Config.LootFrames

    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

------------------------------------------------------------
-- COLORS
------------------------------------------------------------

local BG = { 0.018, 0.018, 0.018, 0.96 }
local BORDER = { 0.12, 0.12, 0.12, 1 }
local ACCENT = { 0.22, 0.66, 0.92, 1 }

local function GetQualityColor(quality)
    if quality ~= nil
        and ITEM_QUALITY_COLORS
        and ITEM_QUALITY_COLORS[quality] then
        local c =
            ITEM_QUALITY_COLORS[quality]

        return c.r, c.g, c.b, 1
    end

    return BORDER[1],
        BORDER[2],
        BORDER[3],
        BORDER[4]
end

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function HideTexture(texture)
    if texture and texture.SetAlpha then
        texture:SetAlpha(0)
    end
end

local function HideNamedTextures(prefix)
    local suffixes = {
        "Bg",
        "Background",
        "Portrait",
        "TopLeftCorner",
        "TopRightCorner",
        "BottomLeftCorner",
        "BottomRightCorner",
        "TopEdge",
        "BottomEdge",
        "LeftEdge",
        "RightEdge",
    }

    for _, suffix in ipairs(suffixes) do
        HideTexture(
            _G[prefix .. suffix]
        )
    end
end

local function CreateBlackoutBorder(parent)
    local border =
        CreateFrame(
            "Frame",
            nil,
            parent,
            "BackdropTemplate"
        )

    border:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        -1,
        1
    )

    border:SetPoint(
        "BOTTOMRIGHT",
        parent,
        "BOTTOMRIGHT",
        1,
        -1
    )

    border:SetFrameLevel(
        parent:GetFrameLevel() + 2
    )

    border:EnableMouse(false)

    border:SetBackdrop({
        edgeFile =
        "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    border:SetBackdropBorderColor(
        unpack(BORDER)
    )

    return border
end

------------------------------------------------------------
-- LOOT FRAME MOVER
------------------------------------------------------------

local LootMover =
    CreateFrame(
        "Frame",
        "BlackoutUI_LootFrameMover",
        UIParent,
        "BackdropTemplate"
    )

LootMover:SetSize(190, 32)
LootMover:SetFrameStrata("DIALOG")
LootMover:SetClampedToScreen(true)
LootMover:SetMovable(true)
LootMover:RegisterForDrag("LeftButton")
LootMover:EnableMouse(false)
LootMover:Hide()

LootMover:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})

LootMover:SetBackdropColor(0.01, 0.01, 0.01, 0.92)
LootMover:SetBackdropBorderColor(unpack(ACCENT))

local LootMoverText =
    LootMover:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

LootMoverText:SetPoint("CENTER")
LootMoverText:SetText("LOOT WINDOW")
LootMoverText:SetTextColor(unpack(ACCENT))

local function PositionLootMover()
    local db = GetConfig()

    LootMover:ClearAllPoints()
    LootMover:SetPoint(
        db.point or "TOPLEFT",
        UIParent,
        db.relativePoint or "TOPLEFT",
        db.x or 20,
        db.y or -180
    )
end

local function SaveLootMover()
    local db = GetConfig()
    local point, _, relativePoint, x, y =
        LootMover:GetPoint(1)

    db.point = point
    db.relativePoint = relativePoint
    db.x = x
    db.y = y
end

LootMover:SetScript(
    "OnDragStart",
    function(self)
        if not InCombatLockdown() then
            self:StartMoving()
        end
    end
)

LootMover:SetScript(
    "OnDragStop",
    function(self)
        self:StopMovingOrSizing()
        SaveLootMover()
    end
)

LootFrames.Mover = LootMover

------------------------------------------------------------
-- MAIN LOOT FRAME BACKGROUND
------------------------------------------------------------

local LootBackdrop = nil

local function EnsureLootBackdrop()
    local frame = _G.LootFrame

    if not frame then
        return
    end

    if LootBackdrop then
        return
    end

    LootBackdrop =
        CreateFrame(
            "Frame",
            "BlackoutUI_LootBackdrop",
            frame,
            "BackdropTemplate"
        )

    LootBackdrop:SetAllPoints(frame)
    LootBackdrop:SetFrameLevel(
        math.max(
            0,
            frame:GetFrameLevel() - 1
        )
    )

    LootBackdrop:EnableMouse(false)

    LootBackdrop:SetBackdrop({
        bgFile =
        "Interface\\Buttons\\WHITE8X8",
        edgeFile =
        "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    LootBackdrop:SetBackdropColor(
        unpack(BG)
    )

    LootBackdrop:SetBackdropBorderColor(
        unpack(ACCENT)
    )
end

------------------------------------------------------------
-- HIDE BLIZZARD OUTER ART
------------------------------------------------------------

local function HideBlizzardLootArt()
    local frame = _G.LootFrame

    if not frame then
        return
    end

    if frame.NineSlice then
        frame.NineSlice:SetAlpha(0)
    end

    if frame.Bg then
        frame.Bg:SetAlpha(0)
    end

    if frame.Background then
        frame.Background:SetAlpha(0)
    end

    HideNamedTextures("LootFrame")

    -- Classic 1.15 loot frame artwork uses additional named pieces.
    for _, name in ipairs({
        "LootFramePortrait",
        "LootFrameBg",
        "LootFrameBackground",
        "LootFrameTopBorder",
        "LootFrameBottomBorder",
        "LootFrameLeftBorder",
        "LootFrameRightBorder",
        "LootFrameInsetBg",
    }) do
        HideTexture(_G[name])
    end

    if frame.Inset then
        if frame.Inset.Bg then
            frame.Inset.Bg:SetAlpha(0)
        end

        if frame.Inset.NineSlice then
            frame.Inset.NineSlice:SetAlpha(0)
        end
    end

    -- Only hide texture regions directly owned by LootFrame.
    -- Item icons/buttons are children and remain untouched.
    local regions =
    { frame:GetRegions() }

    for _, region in ipairs(regions) do
        if region
            and region.GetObjectType
            and region:GetObjectType() == "Texture"
            and region.SetAlpha then
            region:SetAlpha(0)
        end
    end
end

------------------------------------------------------------
-- INNER LOOT PANEL
------------------------------------------------------------

local InnerPanel = nil

local function EnsureInnerPanel()
    local frame = _G.LootFrame
    if not frame or InnerPanel then return end

    InnerPanel =
        CreateFrame(
            "Frame",
            nil,
            frame,
            "BackdropTemplate"
        )

    InnerPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -70)
    InnerPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 7)
    InnerPanel:SetFrameLevel(math.max(0, frame:GetFrameLevel() - 1))
    InnerPanel:EnableMouse(false)

    InnerPanel:SetBackdrop({
        bgFile = "Interface\\\\Buttons\\\\WHITE8X8",
        edgeFile = "Interface\\\\Buttons\\\\WHITE8X8",
        edgeSize = 1,
    })

    InnerPanel:SetBackdropColor(0.012, 0.012, 0.012, 0.96)
    InnerPanel:SetBackdropBorderColor(0.10, 0.10, 0.10, 1)
end

------------------------------------------------------------
-- TITLE
------------------------------------------------------------

local function StyleTitle()
    local title =
        _G.LootFrameTitleText
        or _G.LootFrameTitle
        or (
            _G.LootFrame
            and (
                _G.LootFrame.TitleText
                or _G.LootFrame.title
            )
        )

    if not title then
        return
    end

    title:SetTextColor(
        ACCENT[1],
        ACCENT[2],
        ACCENT[3],
        1
    )

    local font, _, flags =
        title:GetFont()

    if font then
        title:SetFont(
            font,
            12,
            flags
        )
    end
end

------------------------------------------------------------
-- CLOSE BUTTON
------------------------------------------------------------

local function StyleCloseButton()
    local button =
        _G.LootFrameCloseButton
        or (
            _G.LootFrame
            and _G.LootFrame.CloseButton
        )

    if not button then
        return
    end

    if button.BlackoutStyled then
        return
    end

    button.BlackoutStyled = true

    for _, region
    in ipairs({ button:GetRegions() }) do
        if region
            and region.GetObjectType
            and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end

    local bg =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    bg:SetAllPoints()
    bg:SetColorTexture(
        0.03,
        0.03,
        0.03,
        1
    )

    local text =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalSmall"
        )

    text:SetPoint("CENTER", 0, 0)
    text:SetText("X")
    text:SetTextColor(
        0.80,
        0.82,
        0.84,
        1
    )

    button.BlackoutText = text

    button:HookScript(
        "OnEnter",
        function(self)
            self.BlackoutText:SetTextColor(
                ACCENT[1],
                ACCENT[2],
                ACCENT[3],
                1
            )
        end
    )

    button:HookScript(
        "OnLeave",
        function(self)
            self.BlackoutText:SetTextColor(
                0.80,
                0.82,
                0.84,
                1
            )
        end
    )
end

------------------------------------------------------------
-- LOOT BUTTONS
------------------------------------------------------------

local function GetLootButton(index)
    return _G["LootButton" .. index]
        or _G["LootFrameLootButton" .. index]
end

local function GetLootButtonIcon(button)
    if not button then
        return nil
    end

    return button.Icon
        or button.icon
        or _G[
        button:GetName()
        and (
            button:GetName()
            .. "IconTexture"
        )
        or ""
        ]
end

local function GetLootButtonText(button)
    if not button then
        return nil
    end

    return button.Text
        or button.Name
        or (
            button.GetName
            and button:GetName()
            and _G[
            button:GetName()
            .. "Text"
            ]
        )
end

local function EnsureLootButtonStyle(button)
    if not button
        or button.BlackoutStyled then
        return
    end

    button.BlackoutStyled = true

    local bg =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    bg:SetAllPoints()
    bg:SetColorTexture(
        0.025,
        0.025,
        0.025,
        0.92
    )

    button.BlackoutBackground = bg

    button.BlackoutBorder =
        CreateBlackoutBorder(button)

    local icon =
        GetLootButtonIcon(button)

    if icon then
        icon:SetTexCoord(
            0.08,
            0.92,
            0.08,
            0.92
        )
    end
end

local function StyleLootButton(
    button,
    slotIndex
)
    if not button then
        return
    end

    EnsureLootButtonStyle(button)

    local quality = nil

    if slotIndex
        and GetLootSlotLink then
        local link =
            GetLootSlotLink(slotIndex)

        if link then
            quality =
                select(
                    3,
                    GetItemInfo(link)
                )
        end
    end

    local r, g, b, a =
        GetQualityColor(quality)

    if button.BlackoutBorder then
        button.BlackoutBorder:
            SetBackdropBorderColor(
                r,
                g,
                b,
                a
            )
    end

    local text =
        GetLootButtonText(button)

    if text
        and text.SetTextColor then
        text:SetTextColor(
            0.88,
            0.90,
            0.92,
            1
        )
    end
end

local function StyleLootButtons()
    local count =
        GetNumLootItems
        and GetNumLootItems()
        or 0

    -- Classic normally exposes four visible loot buttons per page.
    -- Scan farther so this remains harmless on builds with more.
    for index = 1, 16 do
        local button =
            GetLootButton(index)

        if button then
            StyleLootButton(
                button,
                index <= count
                and index
                or nil
            )
        end
    end
end

------------------------------------------------------------
-- PERMANENT LOOT POSITION LOCK
------------------------------------------------------------

local positionGuard = false
local positionHooked = false

local function ForceLootPosition()
    local frame = _G.LootFrame

    if not frame or positionGuard then
        return
    end

    positionGuard = true

    frame:ClearAllPoints()
    frame:SetPoint(
        "TOPLEFT",
        LootMover,
        "TOPLEFT",
        0,
        -36
    )

    positionGuard = false
end

local function HookLootPosition()
    local frame = _G.LootFrame

    if not frame or positionHooked then
        return
    end

    positionHooked = true

    hooksecurefunc(
        frame,
        "SetPoint",
        function()
            if positionGuard then
                return
            end

            -- Correct Blizzard's attempted default placement immediately.
            ForceLootPosition()
        end
    )

    ForceLootPosition()
end

------------------------------------------------------------
-- APPLY
------------------------------------------------------------

local function ApplyStyle()
    local db = GetConfig()
    local frame = _G.LootFrame

    if not frame then
        return
    end

    if db.enabled == false then
        if LootBackdrop then
            LootBackdrop:Hide()
        end

        frame:SetScale(1)
        return
    end

    EnsureLootBackdrop()
    EnsureInnerPanel()

    frame:SetScale(
        db.scale or 1
    )

    if BlackoutUI.MoveMode ~= true then
        PositionLootMover()
    end

    HookLootPosition()
    ForceLootPosition()

    HideBlizzardLootArt()
    StyleTitle()
    StyleCloseButton()
    StyleLootButtons()

    if LootBackdrop then
        LootBackdrop:Show()
    end

    if InnerPanel then
        InnerPanel:Show()
    end
end

LootFrames.ApplyConfig =
    ApplyStyle

function LootFrames:ResetConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.LootFrames = nil

    local db = GetConfig()

    PositionLootMover()
    ForceLootPosition()
    ApplyStyle()
end

------------------------------------------------------------
-- MOVE MODE
------------------------------------------------------------

local lastMoveMode = nil
local MoveWatcher = CreateFrame("Frame")

MoveWatcher:SetScript(
    "OnUpdate",
    function()
        local moveMode =
            BlackoutUI.MoveMode == true

        if moveMode == lastMoveMode then
            return
        end

        lastMoveMode = moveMode

        if moveMode then
            PositionLootMover()
            LootMover:EnableMouse(true)
            LootMover:Show()
        else
            LootMover:EnableMouse(false)
            LootMover:Hide()
            ApplyStyle()
        end
    end
)

------------------------------------------------------------
-- HOOK CLASSIC LOOT REFRESH
------------------------------------------------------------

if _G.LootFrame_Update then
    hooksecurefunc(
        "LootFrame_Update",
        function()
            C_Timer.After(
                0,
                ApplyStyle
            )
        end
    )
end

if _G.LootFrame_Show then
    hooksecurefunc(
        "LootFrame_Show",
        function()
            C_Timer.After(
                0,
                ApplyStyle
            )
        end
    )
end

------------------------------------------------------------
-- EVENTS
------------------------------------------------------------

local Events =
    CreateFrame("Frame")

Events:RegisterEvent(
    "PLAYER_LOGIN"
)

Events:RegisterEvent(
    "LOOT_OPENED"
)

Events:RegisterEvent(
    "LOOT_SLOT_CLEARED"
)

Events:RegisterEvent(
    "LOOT_CLOSED"
)

Events:SetScript(
    "OnEvent",
    function(self, event)
        if event == "LOOT_CLOSED" then
            return
        end

        C_Timer.After(
            0,
            ApplyStyle
        )

        C_Timer.After(
            0.05,
            ApplyStyle
        )
    end
)

------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------

C_Timer.After(
    0,
    function()
        PositionLootMover()
        HookLootPosition()
        ForceLootPosition()
        ApplyStyle()
    end
)
