--------------------------------------------------
-- BLACKOUTUI FOREVER
-- Minimap.lua
--------------------------------------------------

local addonName, BlackoutUI = ...
local BUI = BlackoutUI

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local function EnsureMinimapDB()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.Minimap =
        BlackoutUIDB.Config.Minimap or {}

    local db =
        BlackoutUIDB.Config.Minimap

    if db.enabled == nil then
        db.enabled = true
    end

    if db.buttonEnabled == nil then
        db.buttonEnabled = true
    end

    if db.buttonAngle == nil then
        db.buttonAngle = 225
    end

    if db.buttonSize == nil then
        db.buttonSize = 28
    end

    if db.size == nil then
        db.size = 190
    end

    if db.scale == nil then
        db.scale = 1.0
    end

    if db.square == nil then
        db.square = true
    end

    if db.positionX == nil then
        db.positionX = -30
    end

    if db.positionY == nil then
        db.positionY = -30
    end

    if db.showCoordinates == nil then db.showCoordinates = true end
    if db.showClock == nil then db.showClock = true end
    if db.showZoneText == nil then db.showZoneText = true end
    if db.hideZoomButtons == nil then db.hideZoomButtons = true end
    if db.hideCalendarButton == nil then db.hideCalendarButton = true end
    if db.hideWorldMapButton == nil then db.hideWorldMapButton = true end
    if db.hideNorthTag == nil then db.hideNorthTag = true end
    if db.controlsOnHover == nil then db.controlsOnHover = true end

    return db
end

--------------------------------------------------
-- FORWARD DECLARATIONS
--------------------------------------------------

local PositionButton

--------------------------------------------------
-- MINIMAP STYLE
--------------------------------------------------

local minimapBackdrop =
    CreateFrame(
        "Frame",
        "BlackoutUIForeverMinimapBackdrop",
        UIParent,
        "BackdropTemplate"
    )

BUI.MinimapBackdrop =
    minimapBackdrop

minimapBackdrop:SetFrameStrata("BACKGROUND")

minimapBackdrop:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})

minimapBackdrop:SetBackdropColor(
    0.008,
    0.014,
    0.015,
    0.96
)

minimapBackdrop:SetBackdropBorderColor(
    0.00,
    0.62,
    0.64,
    0.95
)

local function HideMinimapElement(frame)
    if not frame then
        return
    end

    frame:Hide()

    if frame.SetAlpha then
        frame:SetAlpha(0)
    end
end

local StripBlizzardMinimapArt

local function ApplyMinimapStyle()
    local db =
        EnsureMinimapDB()

    if not db then
        return
    end

    if db.enabled == false then
        Minimap:Hide()
        minimapBackdrop:Hide()
        return
    end

    Minimap:Show()
    minimapBackdrop:Show()

    local size =
        db.size or 190

    -- BlackoutUI moves MinimapCluster. Keep the actual map attached
    -- to the cluster so /bui move updates immediately without /reload.
    Minimap:ClearAllPoints()
    Minimap:SetPoint(
        "CENTER",
        MinimapCluster,
        "CENTER",
        0,
        0
    )

    Minimap:SetSize(
        size,
        size
    )

    Minimap:SetScale(
        db.scale or 1
    )

    minimapBackdrop:ClearAllPoints()
    minimapBackdrop:SetPoint(
        "TOPLEFT",
        Minimap,
        "TOPLEFT",
        -3,
        3
    )
    minimapBackdrop:SetPoint(
        "BOTTOMRIGHT",
        Minimap,
        "BOTTOMRIGHT",
        3,
        -3
    )

    if db.square then
        Minimap:SetMaskTexture(
            "Interface\\Buttons\\WHITE8X8"
        )
    else
        Minimap:SetMaskTexture(
            "Interface\\CharacterFrame\\TempPortraitAlphaMask"
        )
    end

    -- Remove Blizzard artwork while leaving functional minimap data intact.
    StripBlizzardMinimapArt()

    -- Modern / Forever clients put the large circular artwork in
    -- Minimap.MinimapBackdrop (not the old MinimapBorder globals).
    local nativeBackdrop =
        Minimap.MinimapBackdrop
        or _G.MinimapBackdrop

    if nativeBackdrop then
        nativeBackdrop:Hide()

        if nativeBackdrop.SetAlpha then
            nativeBackdrop:SetAlpha(0)
        end

        -- Explicitly remove the known decorative children as well.
        local compass =
            nativeBackdrop.MinimapCompassTexture

        if compass then
            compass:Hide()
            compass:SetAlpha(0)
        end

        local staticOverlay =
            nativeBackdrop.StaticOverlayTexture

        if staticOverlay then
            staticOverlay:Hide()
            staticOverlay:SetAlpha(0)
        end
    end

    HideMinimapElement(
        _G.MinimapBorder
    )

    HideMinimapElement(
        _G.MinimapBorderTop
    )

    -- We use our own centered zone text. Blizzard's zone label otherwise
    -- reappears in the corner after reload/login.
    HideMinimapElement(
        _G.MinimapZoneTextButton
    )
end

BlackoutUI.ApplyMinimapStyle =
    ApplyMinimapStyle

--------------------------------------------------
-- BLIZZARD MINIMAP ART CLEANUP
--------------------------------------------------

StripBlizzardMinimapArt = function()
    local nativeBackdrop =
        Minimap
        and (
            Minimap.MinimapBackdrop
            or _G.MinimapBackdrop
        )

    if nativeBackdrop then
        nativeBackdrop:Hide()

        if nativeBackdrop.SetAlpha then
            nativeBackdrop:SetAlpha(0)
        end

        if nativeBackdrop.MinimapCompassTexture then
            nativeBackdrop.MinimapCompassTexture:Hide()
            nativeBackdrop.MinimapCompassTexture:SetAlpha(0)
        end

        if nativeBackdrop.StaticOverlayTexture then
            nativeBackdrop.StaticOverlayTexture:Hide()
            nativeBackdrop.StaticOverlayTexture:SetAlpha(0)
        end
    end

    local namedFrames = {
        _G.MinimapBorder,
        _G.MinimapBorderTop,
    }

    for _, frame in ipairs(namedFrames) do
        if frame then
            frame:Hide()

            if frame.SetAlpha then
                frame:SetAlpha(0)
            end
        end
    end

    -- Modern clients keep several decorative textures directly on the
    -- MinimapCluster. Hide only obvious border/background artwork.
    if _G.MinimapCluster then
        local regions = {
            _G.MinimapCluster:GetRegions()
        }

        for _, region in ipairs(regions) do
            if region
                and region.GetObjectType
                and region:GetObjectType() == "Texture"
            then
                local texture =
                    region.GetTexture
                    and region:GetTexture()

                local atlas =
                    region.GetAtlas
                    and region:GetAtlas()

                local atlasText =
                    atlas
                    and string.lower(
                        tostring(atlas)
                    )
                    or ""

                if atlasText:find("border")
                    or atlasText:find("background")
                -- Tracking is a functional control and is handled separately.
                then
                    region:Hide()
                    region:SetAlpha(0)
                end
            end
        end
    end

    -- These modern children are artwork/buttons rather than map data.
    local modern = {
        _G.MinimapCluster
        and _G.MinimapCluster.BorderTop,
        _G.MinimapCluster
        and _G.MinimapCluster.MinimapBorder,
        _G.MinimapCluster
        and _G.MinimapCluster.ZoneTextButton
        and nil,
    }

    for _, frame in ipairs(modern) do
        if frame then
            frame:Hide()
            frame:SetAlpha(0)
        end
    end
end

BUI.StripBlizzardMinimapArt =
    StripBlizzardMinimapArt

--------------------------------------------------
-- MINIMAP EDIT MODE
--------------------------------------------------

local editOverlay =
    CreateFrame(
        "Frame",
        "BlackoutUIForeverMinimapEditOverlay",
        Minimap,
        "BackdropTemplate"
    )

BUI.MinimapEditOverlay =
    editOverlay

editOverlay:SetAllPoints(Minimap)
editOverlay:SetFrameStrata("DIALOG")
editOverlay:SetFrameLevel(
    Minimap:GetFrameLevel() + 20
)

editOverlay:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})

editOverlay:SetBackdropColor(
    0.00,
    0.65,
    0.67,
    0.08
)

editOverlay:SetBackdropBorderColor(
    0.00,
    0.95,
    0.95,
    1
)

local editText =
    editOverlay:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

editText:SetPoint("CENTER")
editText:SetText("MINIMAP\\nDRAG TO MOVE")
editText:SetTextColor(
    0.00,
    0.95,
    0.95
)

editOverlay:EnableMouse(true)
editOverlay:SetMovable(true)
editOverlay:RegisterForDrag("LeftButton")
editOverlay:Hide()

local draggingMinimap = false

editOverlay:SetScript(
    "OnDragStart",
    function()
        draggingMinimap = true
    end
)

editOverlay:SetScript(
    "OnDragStop",
    function()
        if not draggingMinimap then
            return
        end

        draggingMinimap = false

        local db =
            EnsureMinimapDB()

        if not db then
            return
        end

        local right =
            UIParent:GetRight()

        local top =
            UIParent:GetTop()

        local miniRight =
            Minimap:GetRight()

        local miniTop =
            Minimap:GetTop()

        if right
            and top
            and miniRight
            and miniTop
        then
            db.positionX =
                miniRight - right

            db.positionY =
                miniTop - top
        end

        ApplyMinimapStyle()
        PositionButton()
    end
)

editOverlay:SetScript(
    "OnUpdate",
    function()
        if not draggingMinimap then
            return
        end

        local scale =
            UIParent:GetEffectiveScale()

        local cursorX, cursorY =
            GetCursorPosition()

        cursorX =
            cursorX / scale

        cursorY =
            cursorY / scale

        local width =
            Minimap:GetWidth()
            * Minimap:GetScale()

        local height =
            Minimap:GetHeight()
            * Minimap:GetScale()

        Minimap:ClearAllPoints()
        Minimap:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            cursorX,
            cursorY
        )
    end
)

function BUI:SetMinimapEditMode(enabled)
    if enabled then
        Minimap:Show()
        minimapBackdrop:Show()
        editOverlay:Show()
    else
        editOverlay:Hide()
        ApplyMinimapStyle()
        PositionButton()
    end
end

--------------------------------------------------
-- MINIMAP MOUSE CONTROLS
--------------------------------------------------

Minimap:EnableMouseWheel(true)

Minimap:SetScript(
    "OnMouseWheel",
    function(self, delta)
        if delta > 0 then
            self:SetZoom(
                math.min(
                    self:GetZoom() + 1,
                    5
                )
            )
        else
            self:SetZoom(
                math.max(
                    self:GetZoom() - 1,
                    0
                )
            )
        end
    end
)

--------------------------------------------------
-- BLACKOUTUI MINIMAP BUTTON
--------------------------------------------------

-- Reuse BlackoutUI's button if another module already created it.
-- This prevents duplicate "B" minimap buttons.
local button =
    BUI.MinimapButton
    or _G.BlackoutUI_MinimapButton

if not button then
    button =
        CreateFrame(
            "Button",
            "BlackoutUI_MinimapButton",
            Minimap,
            "BackdropTemplate"
        )
end

BUI.MinimapButton = button

-- Retire the old Forever-named button if it exists from an older module.
if _G.BlackoutUIForeverMinimapButton
    and _G.BlackoutUIForeverMinimapButton ~= button then
    _G.BlackoutUIForeverMinimapButton:Hide()
    _G.BlackoutUIForeverMinimapButton:SetParent(nil)
end

button:SetFrameStrata("HIGH")
button:SetSize(28, 28)

button:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})

button:SetBackdropColor(
    0.015,
    0.025,
    0.026,
    0.96
)

button:SetBackdropBorderColor(
    0.00,
    0.72,
    0.73,
    1
)

local inner =
    button:CreateTexture(
        nil,
        "ARTWORK"
    )

inner:SetPoint("TOPLEFT", 3, -3)
inner:SetPoint("BOTTOMRIGHT", -3, 3)

inner:SetColorTexture(
    0.00,
    0.18,
    0.19,
    0.95
)

local text =
    button:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

text:SetPoint("CENTER", 0, 0)
text:SetText("B")

text:SetTextColor(
    0.00,
    0.95,
    0.95
)

--------------------------------------------------
-- POSITION
--------------------------------------------------

PositionButton = function()
    local db =
        EnsureMinimapDB()

    if not db then
        return
    end

    local angle =
        math.rad(
            db.buttonAngle or 225
        )

    local radius =
        82

    local x =
        math.cos(angle)
        * radius

    local y =
        math.sin(angle)
        * radius

    button:ClearAllPoints()

    button:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        x,
        y
    )

    button:SetSize(
        db.buttonSize or 28,
        db.buttonSize or 28
    )

    if db.enabled == false
        or db.buttonEnabled == false
    then
        button:Hide()
    else
        button:Show()
    end
end

BlackoutUI.PositionMinimapButton =
    PositionButton

--------------------------------------------------
-- CONFIG TOGGLE
--------------------------------------------------

local function ToggleConfig()
    if BlackoutUI.ConfigFrame then
        if BlackoutUI.ConfigFrame:IsShown() then
            BlackoutUI.ConfigFrame:Hide()
        else
            BlackoutUI.ConfigFrame:Show()

            if BlackoutUI.RefreshConfig then
                BlackoutUI:RefreshConfig()
            end
        end

        return
    end

    -- Fallback to the slash command if Config.lua changes later.
    if SlashCmdList
        and SlashCmdList.BLACKOUTUI
    then
        SlashCmdList.BLACKOUTUI("")
    end
end

button:SetScript(
    "OnClick",
    function(self, mouseButton)
        if mouseButton == "LeftButton" then
            ToggleConfig()
        end
    end
)

button:RegisterForClicks(
    "LeftButtonUp"
)

--------------------------------------------------
-- TOOLTIP
--------------------------------------------------

button:SetScript(
    "OnEnter",
    function(self)
        self:SetBackdropBorderColor(
            0.00,
            1.00,
            1.00,
            1
        )

        GameTooltip:SetOwner(
            self,
            "ANCHOR_LEFT"
        )

        GameTooltip:AddLine(
            "BlackoutUI Forever",
            1,
            1,
            1
        )

        GameTooltip:AddLine(
            "Left Click: Open /bui",
            0.00,
            0.85,
            0.85
        )

        GameTooltip:Show()
    end
)

button:SetScript(
    "OnLeave",
    function(self)
        self:SetBackdropBorderColor(
            0.00,
            0.72,
            0.73,
            1
        )

        GameTooltip:Hide()
    end
)

--------------------------------------------------
-- DRAG AROUND MINIMAP
--------------------------------------------------

button:RegisterForDrag(
    "LeftButton"
)

local dragging = false

button:SetScript(
    "OnDragStart",
    function()
        dragging = true
    end
)

button:SetScript(
    "OnDragStop",
    function()
        dragging = false
    end
)

button:SetScript(
    "OnUpdate",
    function()
        if not dragging then
            return
        end

        local db =
            EnsureMinimapDB()

        if not db then
            return
        end

        local scale =
            Minimap:GetEffectiveScale()

        local mx, my =
            Minimap:GetCenter()

        local cursorX, cursorY =
            GetCursorPosition()

        cursorX =
            cursorX / scale

        cursorY =
            cursorY / scale

        local angle =
            math.deg(
                math.atan2(
                    cursorY - my,
                    cursorX - mx
                )
            )

        db.buttonAngle =
            angle

        PositionButton()
    end
)

--------------------------------------------------
-- INITIALIZE
--------------------------------------------------

local events =
    CreateFrame("Frame")

events:RegisterEvent(
    "PLAYER_LOGIN"
)

events:SetScript(
    "OnEvent",
    function()
        ApplyMinimapStyle()
        StripBlizzardMinimapArt()
        PositionButton()

        if C_Timer
            and C_Timer.After
        then
            C_Timer.After(
                0.5,
                function()
                    StripBlizzardMinimapArt()
                    ApplyMinimapStyle()
                    PositionButton()
                end
            )

            C_Timer.After(
                2,
                function()
                    StripBlizzardMinimapArt()
                    if BlackoutUI.Minimap
                        and BlackoutUI.Minimap.ApplyConfig then
                        BlackoutUI.Minimap:ApplyConfig()
                    end
                end
            )
        end
    end
)

--------------------------------------------------
-- BLACKOUT INFO OVERLAYS
--------------------------------------------------

local InfoLayer = CreateFrame("Frame", "BlackoutUI_MinimapInfo", Minimap)
InfoLayer:SetAllPoints(Minimap)
InfoLayer:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 6)

-- This frame is display-only. It must never intercept clicks intended
-- for tracking or other minimap controls.
InfoLayer:EnableMouse(false)

local function MakeInfoText(point, x, y, justify)
    local text = InfoLayer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint(point, InfoLayer, point, x, y)
    text:SetJustifyH(justify or "CENTER")
    text:SetTextColor(0.86, 0.88, 0.90, 1)
    return text
end

local Coordinates = MakeInfoText("BOTTOM", 0, 5, "CENTER")
local ZoneText = MakeInfoText("TOP", 0, -5, "CENTER")
local ClockText = MakeInfoText("BOTTOMRIGHT", -5, 5, "RIGHT")

local NorthText = MakeInfoText("TOP", 0, -22, "CENTER")
NorthText:SetText("N")
NorthText:SetTextColor(0.72, 0.74, 0.76, 1)


--------------------------------------------------
-- BLACKOUTUI MINIMAP CONTROL STRIP
--------------------------------------------------

local ControlStrip =
    CreateFrame(
        "Frame",
        "BlackoutUI_MinimapControlStrip",
        Minimap,
        "BackdropTemplate"
    )

ControlStrip:SetPoint(
    "TOPRIGHT",
    Minimap,
    "TOPRIGHT",
    -4,
    -4
)
ControlStrip:SetSize(22, 92)
ControlStrip:SetFrameStrata("HIGH")
ControlStrip:SetFrameLevel(
    (Minimap:GetFrameLevel() or 1) + 30
)
ControlStrip:EnableMouse(false)

local function CreateBUIControl(
    name,
    label,
    tooltip,
    onClick
)
    local b =
        CreateFrame(
            "Button",
            "BlackoutUI_Minimap_" .. name,
            ControlStrip,
            "BackdropTemplate"
        )

    b:SetSize(20, 20)
    b:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    b:SetBackdropColor(0.025, 0.025, 0.025, 0.94)
    b:SetBackdropBorderColor(0.18, 0.20, 0.22, 1)
    b:EnableMouse(true)

    local text =
        b:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalSmall"
        )

    text:SetPoint("CENTER", 0, 0)
    text:SetText(label)
    text:SetTextColor(0.86, 0.88, 0.90, 1)
    b.Label = text

    b:SetScript(
        "OnEnter",
        function(self)
            self:SetBackdropBorderColor(
                0.22, 0.66, 0.92, 1
            )
            self.Label:SetTextColor(
                0.22, 0.66, 0.92, 1
            )

            GameTooltip:SetOwner(
                self,
                "ANCHOR_LEFT"
            )
            GameTooltip:SetText(tooltip)
            GameTooltip:Show()
        end
    )

    b:SetScript(
        "OnLeave",
        function(self)
            self:SetBackdropBorderColor(
                0.18, 0.20, 0.22, 1
            )
            self.Label:SetTextColor(
                0.86, 0.88, 0.90, 1
            )
            GameTooltip:Hide()
        end
    )

    b:SetScript("OnClick", onClick)

    return b
end

local WorldMapButton =
    CreateBUIControl(
        "WorldMap",
        "M",
        "World Map",
        function()
            if ToggleWorldMap then
                ToggleWorldMap()
            elseif _G.MiniMapWorldMapButton
                and _G.MiniMapWorldMapButton.Click then
                _G.MiniMapWorldMapButton:Click()
            end
        end
    )

local ZoomInButton =
    CreateBUIControl(
        "ZoomIn",
        "+",
        "Zoom In",
        function()
            Minimap:SetZoom(
                math.min(
                    (Minimap:GetZoom() or 0) + 1,
                    5
                )
            )
        end
    )

local ZoomOutButton =
    CreateBUIControl(
        "ZoomOut",
        "-",
        "Zoom Out",
        function()
            Minimap:SetZoom(
                math.max(
                    (Minimap:GetZoom() or 0) - 1,
                    0
                )
            )
        end
    )

local BUIControls = {
    WorldMapButton,
    ZoomInButton,
    ZoomOutButton,
}

local function PolishControl(button, texture)
    if button.Label then button.Label:Hide() end

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 4, -4)
    icon:SetPoint("BOTTOMRIGHT", -4, 4)
    icon:SetTexture(texture)
    icon:SetVertexColor(0.86, 0.88, 0.90, 1)
    button.Icon = icon

    local enter = button:GetScript("OnEnter")
    local leave = button:GetScript("OnLeave")

    button:SetScript("OnEnter", function(self)
        if enter then enter(self) end
        self.Icon:SetVertexColor(0.22, 0.66, 0.92, 1)
    end)

    button:SetScript("OnLeave", function(self)
        if leave then leave(self) end
        self.Icon:SetVertexColor(0.86, 0.88, 0.90, 1)
    end)
end

PolishControl(WorldMapButton, "Interface\\WorldMap\\UI-World-Icon")
PolishControl(ZoomInButton, "Interface\\Buttons\\UI-PlusButton-Up")
PolishControl(ZoomOutButton, "Interface\\Buttons\\UI-MinusButton-Up")

for index, control
in ipairs(BUIControls) do
    control:ClearAllPoints()
    control:SetPoint(
        "TOP",
        ControlStrip,
        "TOP",
        0,
        -((index - 1) * 23)
    )
end

ControlStrip:SetHeight(
    (#BUIControls * 23) - 3
)

local controlHoverElapsed = 0
ControlStrip:HookScript("OnUpdate", function(self, elapsed)
    controlHoverElapsed = controlHoverElapsed + elapsed
    if controlHoverElapsed < 0.08 then return end
    controlHoverElapsed = 0

    local db = EnsureMinimapDB()
    if not db or db.enabled == false then return end

    if db.controlsOnHover then
        self:SetAlpha(
            (Minimap:IsMouseOver() or self:IsMouseOver()) and 1 or 0
        )
    else
        self:SetAlpha(1)
    end
end)

local infoElapsed = 0
InfoLayer:SetScript("OnUpdate", function(self, elapsed)
    infoElapsed = infoElapsed + elapsed
    if infoElapsed < 0.25 then return end
    infoElapsed = 0

    local db = EnsureMinimapDB()
    if not db or db.enabled == false then
        Coordinates:SetText("")
        ZoneText:SetText("")
        ClockText:SetText("")
        return
    end

    if db.showCoordinates and C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition then
        local mapID = C_Map.GetBestMapForUnit("player")
        local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            Coordinates:SetFormattedText("%.1f, %.1f", pos.x * 100, pos.y * 100)
        else
            Coordinates:SetText("")
        end
    else
        Coordinates:SetText("")
    end

    if db.showZoneText then
        ZoneText:SetText(GetMinimapZoneText() or "")
        ZoneText:Show()
    else
        ZoneText:SetText("")
        ZoneText:Hide()
    end

    if db.showClock then
        local h, m = GetGameTime()
        ClockText:SetFormattedText("%02d:%02d", h or 0, m or 0)
        ClockText:Show()
    else
        ClockText:SetText("")
        ClockText:Hide()
    end

    NorthText:SetShown(not db.hideNorthTag)
end)

local oldApply = BlackoutUI.ApplyMinimapStyle
BlackoutUI.ApplyMinimapStyle = function(...)
    if oldApply then oldApply(...) end
    local db = EnsureMinimapDB()
    if not db then return end

    InfoLayer:SetShown(db.enabled ~= false)

    -- Force our custom information elements immediately when config changes,
    -- rather than waiting for the next OnUpdate tick.
    ZoneText:SetShown(db.showZoneText == true)
    ClockText:SetShown(db.showClock == true)
    NorthText:SetShown(not db.hideNorthTag)

    -- Blizzard zone text is never used by this skin.
    if _G.MinimapZoneTextButton then
        _G.MinimapZoneTextButton:Hide()
        _G.MinimapZoneTextButton:SetAlpha(0)
    end
end

BlackoutUI.Minimap = BlackoutUI.Minimap or {}
BlackoutUI.Minimap.ApplyConfig = function()
    if BlackoutUI.ApplyMinimapStyle then
        BlackoutUI.ApplyMinimapStyle()
    end
    if BlackoutUI.PositionMinimapButton then
        BlackoutUI.PositionMinimapButton()
    end
end

--------------------------------------------------
-- CURRENT BLACKOUTUI MOVE SYSTEM
--------------------------------------------------

local function ApplySavedMinimapPosition()
    local db = EnsureMinimapDB()
    if not db then return end

    MinimapCluster:ClearAllPoints()
    MinimapCluster:SetPoint(
        db.point or "TOPRIGHT",
        UIParent,
        db.relativePoint or "TOPRIGHT",
        db.positionX or -28,
        db.positionY or -28
    )
end

local function SaveMinimapPosition()
    local db = EnsureMinimapDB()
    if not db then return end

    local point, _, relativePoint, x, y =
        MinimapCluster:GetPoint(1)

    db.point = point or "TOPRIGHT"
    db.relativePoint = relativePoint or "TOPRIGHT"
    db.positionX = math.floor((x or 0) + 0.5)
    db.positionY = math.floor((y or 0) + 0.5)
end

local MoveHandle =
    CreateFrame(
        "Frame",
        "BlackoutUI_MinimapMover",
        UIParent,
        "BackdropTemplate"
    )

MoveHandle:SetFrameStrata("DIALOG")
MoveHandle:SetClampedToScreen(true)
MoveHandle:EnableMouse(true)
MoveHandle:SetMovable(true)
MoveHandle:RegisterForDrag("LeftButton")
MoveHandle:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
MoveHandle:SetBackdropColor(0.02, 0.02, 0.02, 0.72)
MoveHandle:SetBackdropBorderColor(0.22, 0.66, 0.92, 1)
MoveHandle:Hide()

local MoveText =
    MoveHandle:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

MoveText:SetPoint("CENTER")
MoveText:SetText("MINIMAP")
MoveText:SetTextColor(0.86, 0.88, 0.90, 1)

local function SizeMoveHandle()
    local db = EnsureMinimapDB()
    local size = (db and db.size) or 190
    local scale = (db and db.scale) or 1

    MoveHandle:SetSize(
        size * scale,
        size * scale
    )

    MoveHandle:ClearAllPoints()
    MoveHandle:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        0,
        0
    )
end

MoveHandle:SetScript(
    "OnDragStart",
    function(self)
        MinimapCluster:StartMoving()
        self:SetScript(
            "OnUpdate",
            function()
                SizeMoveHandle()
            end
        )
    end
)

MoveHandle:SetScript(
    "OnDragStop",
    function(self)
        MinimapCluster:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
        SaveMinimapPosition()
        SizeMoveHandle()
    end
)

MinimapCluster:SetMovable(true)
MinimapCluster:SetClampedToScreen(true)

local function SetMinimapMoveMode(enabled)
    if enabled then
        SizeMoveHandle()
        MoveHandle:Show()
    else
        MoveHandle:Hide()
    end
end

-- Register with BlackoutUI's shared mover table.
BlackoutUI.MovableFrames =
    BlackoutUI.MovableFrames or {}

BlackoutUI.MovableFrames.Minimap = {
    frame = MinimapCluster,
    overlay = MoveHandle,
    name = "Minimap",
    SetMoveMode = SetMinimapMoveMode,
}

BlackoutUI.Minimap.SetMoveMode =
    SetMinimapMoveMode

BlackoutUI.Minimap.ResetPosition =
    function()
        local db = EnsureMinimapDB()

        db.point = "TOPRIGHT"
        db.relativePoint = "TOPRIGHT"
        db.positionX = -28
        db.positionY = -28

        ApplySavedMinimapPosition()
        SizeMoveHandle()
    end

-- Keep the mover matched to config changes.
local previousApply =
    BlackoutUI.Minimap.ApplyConfig

BlackoutUI.Minimap.ApplyConfig =
    function(self)
        if previousApply then
            previousApply(self)
        end

        ApplySavedMinimapPosition()
        SizeMoveHandle()
    end

ApplySavedMinimapPosition()

--------------------------------------------------
-- BLIZZARD MINIMAP CLEANUP
--------------------------------------------------

local function SetShownSafe(frame, shown)
    if not frame then
        return
    end

    if shown then
        frame:Show()
    else
        frame:Hide()
    end
end

local function SetAnyShown(frames, shown)
    for _, frame in ipairs(frames) do
        if frame then
            if frame.SetAlpha then
                frame:SetAlpha(shown and 1 or 0)
            end
            frame:SetShown(shown)
        end
    end
end

local function PrepareBlizzardControl(frame, point, x, y)
    if not frame then
        return
    end

    -- The stock circular backdrop can be hidden. Functional controls must
    -- therefore live directly on the actual Minimap instead of hidden art.
    if frame.SetParent then
        frame:SetParent(Minimap)
    end

    if frame.ClearAllPoints and frame.SetPoint then
        frame:ClearAllPoints()
        frame:SetPoint(
            point,
            Minimap,
            point,
            x,
            y
        )
    end

    if frame.SetFrameStrata then
        frame:SetFrameStrata("HIGH")
    end

    if frame.SetFrameLevel then
        frame:SetFrameLevel(
            (Minimap:GetFrameLevel() or 1) + 12
        )
    end
end

local function ApplyMinimapCleanup()
    local db = EnsureMinimapDB()
    if not db then
        return
    end

    --------------------------------------------------
    -- HIDE STOCK BLIZZARD CONTROLS
    --------------------------------------------------

    local calendar =
        _G.GameTimeFrame
        or _G.TimeManagerClockButton

    local worldMap =
        _G.MiniMapWorldMapButton
        or _G.MinimapWorldMapButton

    SetAnyShown({
        _G.MinimapZoomIn,
        _G.MinimapZoomOut,
        calendar,
        worldMap,
    }, false)

    --------------------------------------------------
    -- BLACKOUTUI CONTROLS
    --------------------------------------------------

    WorldMapButton:SetShown(
        not db.hideWorldMapButton
    )

    ZoomInButton:SetShown(
        not db.hideZoomButtons
    )

    ZoomOutButton:SetShown(
        not db.hideZoomButtons
    )

    -- Repack visible buttons so there are never empty holes.
    local visibleIndex = 0

    for _, control
    in ipairs(BUIControls) do
        if control:IsShown() then
            control:ClearAllPoints()
            control:SetPoint(
                "TOP",
                ControlStrip,
                "TOP",
                0,
                -(visibleIndex * 23)
            )
            visibleIndex =
                visibleIndex + 1
        end
    end

    ControlStrip:SetHeight(
        math.max(
            20,
            (visibleIndex * 23) - 3
        )
    )

    ControlStrip:SetShown(
        db.enabled ~= false
        and visibleIndex > 0
    )

    --------------------------------------------------
    -- BLACKOUT INFO
    --------------------------------------------------

    ZoneText:SetShown(
        db.showZoneText == true
    )

    if db.showZoneText then
        ZoneText:SetText(
            GetMinimapZoneText() or ""
        )
    else
        ZoneText:SetText("")
    end

    ClockText:SetShown(
        db.showClock == true
    )

    if db.showClock then
        local hour, minute =
            GetGameTime()

        ClockText:SetFormattedText(
            "%02d:%02d",
            hour or 0,
            minute or 0
        )
    else
        ClockText:SetText("")
    end

    NorthText:SetShown(
        not db.hideNorthTag
    )

    --------------------------------------------------
    -- STOCK ART
    --------------------------------------------------

    if _G.MinimapZoneTextButton then
        _G.MinimapZoneTextButton:Hide()
        _G.MinimapZoneTextButton:SetAlpha(0)
    end

    if _G.MinimapBorder then
        _G.MinimapBorder:Hide()
    end

    if _G.MinimapBorderTop then
        _G.MinimapBorderTop:Hide()
    end
end

local cleanupPreviousApply =
    BlackoutUI.Minimap.ApplyConfig

BlackoutUI.Minimap.ApplyConfig =
    function(self)
        if cleanupPreviousApply then
            cleanupPreviousApply(self)
        end

        ApplyMinimapCleanup()
    end

ApplyMinimapCleanup()
