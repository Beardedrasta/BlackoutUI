--------------------------------------------------
-- BLACKOUT UI
-- Modules/Config.lua
--
-- STEP 11A
-- Blackout configuration window
--
-- /bui       = open / close configuration
-- /bui move  = use the original Blackout move/grid mode
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SAVED CONFIG
--------------------------------------------------

local function EnsureConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.XPTracker =
        BlackoutUIDB.Config.XPTracker
        or {}

    local xp =
        BlackoutUIDB.Config.XPTracker

    if xp.enabled == nil then
        xp.enabled = true
    end

    if xp.hoverDashboard == nil then
        xp.hoverDashboard = true
    end

    if xp.showRested == nil then
        xp.showRested = true
    end

    if xp.width == nil then
        xp.width = 520
    end

    if xp.height == nil then
        xp.height = 18
    end

    if xp.scale == nil then
        xp.scale = 1.00
    end

    if xp.showLevel == nil then
        xp.showLevel = true
    end

    if xp.showProgress == nil then
        xp.showProgress = true
    end

    if xp.showPercent == nil then
        xp.showPercent = true
    end

    if xp.textSize == nil then
        xp.textSize = 10
    end

    if xp.dashboardScale == nil then
        xp.dashboardScale = 1.00
    end

    BlackoutUIDB.Config.ActionBars =
        BlackoutUIDB.Config.ActionBars
        or {}

    local bars =
        BlackoutUIDB.Config.ActionBars

    if bars.buttonSize == nil then
        bars.buttonSize = 42
    end

    if bars.spacing == nil then
        bars.spacing = 2
    end

    if bars.scale == nil then
        bars.scale = 1.00
    end

    bars.visible = bars.visible or {}
    bars.bars = bars.bars or {}

    for barID = 1, 5 do
        if bars.visible[barID] == nil then bars.visible[barID] = true end

        bars.bars[barID] = bars.bars[barID] or {}
        local bar = bars.bars[barID]

        if bar.enabled == nil then bar.enabled = bars.visible[barID] end
        if bar.buttonCount == nil then bar.buttonCount = 12 end
        if bar.buttonsPerRow == nil then bar.buttonsPerRow = 12 end
        if bar.buttonSize == nil then bar.buttonSize = bars.buttonSize end
        if bar.spacing == nil then bar.spacing = bars.spacing end
        if bar.scale == nil then bar.scale = bars.scale end
    end

    BlackoutUIDB.Config.ClassBars =
        BlackoutUIDB.Config.ClassBars
        or {}

    local classBars =
        BlackoutUIDB.Config.ClassBars

    classBars.stance =
        classBars.stance or {}

    classBars.pet =
        classBars.pet or {}

    for _, section in ipairs({
        classBars.stance,
        classBars.pet,
    }) do
        if section.enabled == nil then section.enabled = true end
        if section.buttonSize == nil then section.buttonSize = 38 end
        if section.spacing == nil then section.spacing = 2 end
        if section.scale == nil then section.scale = 1.00 end
        if section.buttonsPerRow == nil then section.buttonsPerRow = 10 end
    end

    BlackoutUIDB.Config.CastBars =
        BlackoutUIDB.Config.CastBars
        or {}

    local castBars =
        BlackoutUIDB.Config.CastBars

    local function EnsureCastBar(key)
        castBars[key] = castBars[key] or {}
        local section = castBars[key]

        -- Icon size follows bar height; discard the old
        -- independent icon-size setting from earlier builds.
        section.iconSize = nil

        local defaults = {
            enabled = true,
            width = 310,
            height = 30,
            scale = 1.00,
            showIcon = true,
            showSpellName = true,
            spellNameSize = 11,
            showCastTime = true,
            castTimeSize = 11,
        }

        for option, value in pairs(defaults) do
            if section[option] == nil then
                section[option] = value
            end
        end
    end

    EnsureCastBar("player")
    EnsureCastBar("target")

    BlackoutUIDB.Config.UtilityBar =
        BlackoutUIDB.Config.UtilityBar
        or {}

    local utilityDefaults = {
        enabled = true,
        scale = 1.00,
        showCharacter = true,
        showSpellbook = true,
        showTalents = true,
        showQuest = true,
        showSocial = true,
        showMap = true,
        showKeyRing = true,
        showPerformance = true,
        showBagButton = true,
        showFreeSlots = true,
    }

    for key, value in pairs(utilityDefaults) do
        if BlackoutUIDB.Config.UtilityBar[key] == nil then
            BlackoutUIDB.Config.UtilityBar[key] = value
        end
    end

    BlackoutUIDB.Config.Auras =
        BlackoutUIDB.Config.Auras
        or {}

    local auraDefaults = {
        enabled = true,
        iconSize = 28,
        spacing = 4,
        iconsPerRow = 8,
        maxDebuffs = 8,
        maxBuffs = 8,
        showDebuffs = true,
        showBuffs = true,
        showDuration = true,
        showStacks = true,
        durationTextSize = 9,
        stackTextSize = 10,
    }

    for key, value in pairs(auraDefaults) do
        if BlackoutUIDB.Config.Auras[key] == nil then
            BlackoutUIDB.Config.Auras[key] = value
        end
    end

    BlackoutUIDB.Config.UnitFrames =
        BlackoutUIDB.Config.UnitFrames
        or {}

    local unitFrames =
        BlackoutUIDB.Config.UnitFrames

    local function EnsureUnitFrame(key, defaults)
        unitFrames[key] = unitFrames[key] or {}
        local frame = unitFrames[key]

        for option, value in pairs(defaults) do
            if frame[option] == nil then
                frame[option] = value
            end
        end
    end

    EnsureUnitFrame("player", {
        enabled = true,
        width = 360,
        height = 99,
        scale = 1.00,
        headerHeight = 22,
        healthHeight = 43,
        powerHeight = 19,
        nameSize = 12,
        levelSize = 10,
        healthValueSize = 12,
        healthPercentSize = 14,
        powerLabelSize = 9,
        powerValueSize = 10,
        showName = true,
        showLevel = true,
        showHealthValue = true,
        showHealthPercent = true,
        showPowerLabel = true,
        showPowerValue = true,
    })

    EnsureUnitFrame("target", {
        enabled = true,
        width = 360,
        height = 99,
        scale = 1.00,
        headerHeight = 22,
        healthHeight = 43,
        powerHeight = 19,
        nameSize = 12,
        levelSize = 10,
        healthValueSize = 12,
        healthPercentSize = 14,
        powerLabelSize = 9,
        powerValueSize = 10,
        showName = true,
        showLevel = true,
        showHealthValue = true,
        showHealthPercent = true,
        showPowerLabel = true,
        showPowerValue = true,
    })

    EnsureUnitFrame("targettarget", {
        enabled = true,
        width = 200,
        height = 42,
        scale = 1.00,
        healthHeight = 14,
        nameSize = 10,
        healthPercentSize = 10,
        showName = true,
        showHealthPercent = true,
    })

    EnsureUnitFrame("pet", {
        enabled = true,
        width = 280,
        height = 82,
        scale = 1.00,
        headerHeight = 19,
        healthHeight = 34,
        powerHeight = 15,
        nameSize = 11,
        levelSize = 9,
        healthValueSize = 11,
        healthPercentSize = 12,
        powerLabelSize = 8,
        powerValueSize = 9,
        showName = true,
        showLevel = true,
        showHealthValue = true,
        showHealthPercent = true,
        showPowerLabel = true,
        showPowerValue = true,
        showPowerBar = true,
    })

    EnsureUnitFrame("party", {
        enabled = true,
        width = 125,
        height = 48,
        scale = 1.00,
        spacing = 4,
        growthDirection = "VERTICAL",

        nameSize = 10,
        levelSize = 8,
        healthTextSize = 9,
        auraIconSize = 14,
        resourceHeight = 5,

        showName = true,
        showHealthPercent = true,
        showResourceBar = true,

        showAuraIndicators = true,
        showMyBuffs = true,
        showDispellableDebuffs = true,
        showMissingClassBuff = true,

        showIncomingHeals = true,
        incomingHealAlpha = 0.45,
        showThreat = true,
        rangeFading = true,
        outOfRangeAlpha = 0.45,
        showStatusText = true,
        deadAlpha = 0.55,
        offlineAlpha = 0.35,
        showPlayer = true,
    })

    EnsureUnitFrame("raid", {
        enabled = true,
        width = 105,
        height = 42,
        scale = 1.00,

        horizontalSpacing = 3,
        verticalSpacing = 3,
        groupSpacing = 8,
        unitsPerColumn = 5,
        groupsPerRow = 4,

        nameSize = 9,
        levelSize = 7,
        healthTextSize = 8,

        resourceHeight = 4,
        auraIconSize = 11,

        showResourceBar = true,
        showAuraIndicators = true,
        showHots = true,
        showClassBuffs = true,
        showDispellableDebuffs = true,

        rangeFading = true,
        outOfRangeAlpha = 0.45,

        showStatusText = true,
        deadAlpha = 0.55,
        offlineAlpha = 0.35,

        showIncomingHeals = true,
        incomingHealAlpha = 0.45,
        showThreat = true,

        showName = true,
        showHealthPercent = true,
    })

    BlackoutUIDB.Config.Minimap =
        BlackoutUIDB.Config.Minimap
        or {}

    local minimap =
        BlackoutUIDB.Config.Minimap

    if minimap.enabled == nil then minimap.enabled = true end
    if minimap.size == nil then minimap.size = 190 end
    if minimap.scale == nil then minimap.scale = 1.00 end
    if minimap.square == nil then minimap.square = true end
    if minimap.showCoordinates == nil then minimap.showCoordinates = true end
    if minimap.showZoneText == nil then minimap.showZoneText = true end
    if minimap.showClock == nil then minimap.showClock = true end
    if minimap.controlsOnHover == nil then minimap.controlsOnHover = true end

    return BlackoutUIDB.Config
end

--------------------------------------------------
-- COLORS
--------------------------------------------------

local BG = { 0.008, 0.008, 0.008, 0.985 }
local PANEL = { 0.018, 0.018, 0.018, 0.98 }
local TEXT = { 0.86, 0.88, 0.90, 1 }
local MUTED = { 0.46, 0.48, 0.50, 1 }
local ACCENT = { 0.22, 0.66, 0.92, 1 }

--------------------------------------------------
-- WINDOW
--------------------------------------------------

local ConfigFrame =
    CreateFrame(
        "Frame",
        "BlackoutUI_ConfigFrame",
        UIParent
    )

ConfigFrame:SetSize(650, 430)
ConfigFrame:SetPoint("CENTER")
ConfigFrame:SetFrameStrata("DIALOG")
ConfigFrame:SetClampedToScreen(true)

BlackoutUI.ConfigFrame = ConfigFrame
ConfigFrame:EnableMouse(true)
ConfigFrame:SetMovable(true)
ConfigFrame:RegisterForDrag("LeftButton")
ConfigFrame:Hide()

ConfigFrame:SetScript(
    "OnDragStart",
    function(self)
        self:StartMoving()
    end
)

ConfigFrame:SetScript(
    "OnDragStop",
    function(self)
        self:StopMovingOrSizing()
    end
)

local bg =
    ConfigFrame:CreateTexture(
        nil,
        "BACKGROUND"
    )

bg:SetAllPoints()
bg:SetColorTexture(unpack(BG))

BlackoutUI:CreateBorder(
    ConfigFrame,
    1,
    "borderBright"
)

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header =
    CreateFrame(
        "Frame",
        nil,
        ConfigFrame
    )

Header:SetPoint("TOPLEFT", 1, -1)
Header:SetPoint("TOPRIGHT", -1, -1)
Header:SetHeight(46)

local headerBG =
    Header:CreateTexture(
        nil,
        "BACKGROUND"
    )

headerBG:SetAllPoints()
headerBG:SetColorTexture(
    0.012,
    0.012,
    0.012,
    1
)

local Title =
    BlackoutUI:CreateFont(
        Header,
        14
    )

Title:SetPoint(
    "LEFT",
    Header,
    "LEFT",
    16,
    4
)

Title:SetText("BLACKOUT UI")
Title:SetTextColor(unpack(ACCENT))

local Subtitle =
    BlackoutUI:CreateFont(
        Header,
        8
    )

Subtitle:SetPoint(
    "LEFT",
    Title,
    "LEFT",
    0,
    -17
)

Subtitle:SetText(
    "CLEAN • SQUARE • MODERN CLASSIC UI"
)

Subtitle:SetTextColor(unpack(MUTED))

local Close =
    CreateFrame(
        "Button",
        nil,
        Header
    )

Close:SetSize(34, 34)
Close:SetPoint(
    "RIGHT",
    Header,
    "RIGHT",
    -6,
    0
)

local closeText =
    BlackoutUI:CreateFont(
        Close,
        14
    )

closeText:SetPoint("CENTER")
closeText:SetText("×")
closeText:SetTextColor(unpack(TEXT))

Close:SetScript(
    "OnClick",
    function()
        ConfigFrame:Hide()
    end
)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local Sidebar =
    CreateFrame(
        "Frame",
        nil,
        ConfigFrame
    )

Sidebar:SetPoint(
    "TOPLEFT",
    ConfigFrame,
    "TOPLEFT",
    1,
    -47
)

Sidebar:SetPoint(
    "BOTTOMLEFT",
    ConfigFrame,
    "BOTTOMLEFT",
    1,
    1
)

Sidebar:SetWidth(150)

local sideBG =
    Sidebar:CreateTexture(
        nil,
        "BACKGROUND"
    )

sideBG:SetAllPoints()
sideBG:SetColorTexture(unpack(PANEL))

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content =
    CreateFrame(
        "Frame",
        nil,
        ConfigFrame
    )

Content:SetPoint(
    "TOPLEFT",
    Sidebar,
    "TOPRIGHT",
    1,
    0
)

Content:SetPoint(
    "BOTTOMRIGHT",
    ConfigFrame,
    "BOTTOMRIGHT",
    -1,
    1
)

--------------------------------------------------
-- PAGE SYSTEM
--------------------------------------------------

local Pages = {}
local NavButtons = {}

local function CreatePage(key, title)
    local page = CreateFrame("Frame", nil, Content)
    page:SetAllPoints()
    page:Hide()

    -- Scroll viewport: header/sidebar remain fixed.
    local scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -18, 0)
    scroll:EnableMouseWheel(true)

    local scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetWidth(460)
    scrollChild:SetHeight(760)
    scroll:SetScrollChild(scrollChild)

    -- Thin Blackout scrollbar.
    local track = CreateFrame("Frame", nil, page)
    track:SetPoint("TOPRIGHT", page, "TOPRIGHT", -7, -12)
    track:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -7, 12)
    track:SetWidth(5)

    local trackBG = track:CreateTexture(nil, "BACKGROUND")
    trackBG:SetAllPoints()
    trackBG:SetColorTexture(1, 1, 1, 0.05)

    local thumb = CreateFrame("Frame", nil, track)
    thumb:SetWidth(5)
    thumb:SetHeight(54)

    local thumbBG = thumb:CreateTexture(nil, "ARTWORK")
    thumbBG:SetAllPoints()
    thumbBG:SetColorTexture(unpack(ACCENT))

    local function GetRange()
        return math.max(0, scrollChild:GetHeight() - scroll:GetHeight())
    end

    local function UpdateThumb()
        local range = GetRange()

        if range <= 0 then
            track:Hide()
            return
        end

        track:Show()

        local trackHeight = track:GetHeight()
        local thumbHeight = math.max(
            42,
            trackHeight * (scroll:GetHeight() / scrollChild:GetHeight())
        )

        thumb:SetHeight(thumbHeight)

        local available = math.max(0, trackHeight - thumbHeight)
        local percent = scroll:GetVerticalScroll() / range

        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(available * percent))
    end

    local function SetScroll(offset)
        offset = math.max(0, math.min(GetRange(), offset))
        scroll:SetVerticalScroll(offset)
        UpdateThumb()
    end

    scroll:SetScript("OnMouseWheel", function(_, delta)
        SetScroll(scroll:GetVerticalScroll() + (delta > 0 and -46 or 46))
    end)

    scroll:SetScript("OnScrollRangeChanged", UpdateThumb)

    -- Drag the scrollbar thumb.
    thumb:EnableMouse(true)

    local dragging = false
    local dragStartY = 0
    local dragStartScroll = 0

    thumb:SetScript("OnMouseDown", function()
        dragging = true
        local _, y = GetCursorPosition()
        dragStartY = y / UIParent:GetEffectiveScale()
        dragStartScroll = scroll:GetVerticalScroll()

        thumb:SetScript("OnUpdate", function()
            if not dragging then return end

            local _, currentY = GetCursorPosition()
            currentY = currentY / UIParent:GetEffectiveScale()

            local available = math.max(1, track:GetHeight() - thumb:GetHeight())
            local deltaY = dragStartY - currentY

            SetScroll(
                dragStartScroll
                + (deltaY / available) * GetRange()
            )
        end)
    end)

    thumb:SetScript("OnMouseUp", function()
        dragging = false
        thumb:SetScript("OnUpdate", nil)
    end)

    page:SetScript("OnShow", function()
        SetScroll(0)
    end)

    local heading = BlackoutUI:CreateFont(scrollChild, 14)
    heading:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 22, -22)
    heading:SetText(title)
    heading:SetTextColor(unpack(TEXT))

    local line = scrollChild:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 22, -48)
    line:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -22, -48)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.08)

    Pages[key] = page
    page.ScrollFrame = scroll
    page.ScrollChild = scrollChild

    -- Existing page code now creates controls inside the scroll child.
    return scrollChild
end

local function ShowPage(key)
    for pageKey, page
    in pairs(Pages) do
        page:SetShown(
            pageKey == key
        )
    end

    for buttonKey, button
    in pairs(NavButtons) do
        if buttonKey == key then
            button.Text:SetTextColor(
                unpack(ACCENT)
            )

            button.Selection:Show()
        else
            button.Text:SetTextColor(
                unpack(MUTED)
            )

            button.Selection:Hide()
        end
    end
end

local function CreateNavButton(
    key,
    text,
    index
)
    local button =
        CreateFrame(
            "Button",
            nil,
            Sidebar
        )

    button:SetSize(150, 32)

    button:SetPoint(
        "TOPLEFT",
        Sidebar,
        "TOPLEFT",
        0,
        -8 - ((index - 1) * 32)
    )

    local selection =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    selection:SetAllPoints()
    selection:SetColorTexture(
        0.08,
        0.22,
        0.30,
        0.35
    )

    selection:Hide()
    button.Selection = selection

    local accent =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    accent:SetPoint(
        "LEFT",
        button,
        "LEFT",
        0,
        0
    )

    accent:SetSize(2, 32)
    accent:SetColorTexture(
        unpack(ACCENT)
    )

    accent:Hide()
    button.Accent = accent

    local label =
        BlackoutUI:CreateFont(
            button,
            9
        )

    label:SetPoint(
        "LEFT",
        button,
        "LEFT",
        14,
        0
    )

    label:SetText(text)
    label:SetTextColor(unpack(MUTED))
    button.Text = label

    button:SetScript(
        "OnEnter",
        function(self)
            if not self.Selection:IsShown() then
                self.Text:SetTextColor(
                    0.72,
                    0.78,
                    0.82,
                    1
                )
            end
        end
    )

    button:SetScript(
        "OnLeave",
        function(self)
            if not self.Selection:IsShown() then
                self.Text:SetTextColor(
                    unpack(MUTED)
                )
            end
        end
    )

    button:SetScript(
        "OnClick",
        function()
            ShowPage(key)
        end
    )

    hooksecurefunc(
        selection,
        "Show",
        function()
            accent:Show()
        end
    )

    hooksecurefunc(
        selection,
        "Hide",
        function()
            accent:Hide()
        end
    )

    NavButtons[key] = button
end

--------------------------------------------------
-- CONTROL HELPERS
--------------------------------------------------

local function CreateCheckbox(
    parent,
    label,
    x,
    y,
    getter,
    setter
)
    local button =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    button:SetSize(300, 24)
    button:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        x,
        y
    )

    local box =
        CreateFrame(
            "Frame",
            nil,
            button
        )

    box:SetSize(16, 16)
    box:SetPoint(
        "LEFT",
        button,
        "LEFT",
        0,
        0
    )

    local boxBG =
        box:CreateTexture(
            nil,
            "BACKGROUND"
        )

    boxBG:SetAllPoints()
    boxBG:SetColorTexture(
        0.015,
        0.015,
        0.015,
        1
    )

    BlackoutUI:CreateBorder(
        box,
        1,
        "borderBright"
    )

    local check =
        BlackoutUI:CreateFont(
            box,
            12
        )

    check:SetPoint("CENTER", 0, 1)
    check:SetText("✓")
    check:SetTextColor(unpack(ACCENT))

    local text =
        BlackoutUI:CreateFont(
            button,
            10
        )

    text:SetPoint(
        "LEFT",
        box,
        "RIGHT",
        9,
        0
    )

    text:SetText(label)
    text:SetTextColor(unpack(TEXT))

    local function Refresh()
        check:SetShown(
            getter() and true or false
        )
    end

    button:SetScript(
        "OnClick",
        function()
            setter(
                not getter()
            )

            Refresh()
        end
    )

    button.Refresh = Refresh
    Refresh()

    return button
end

local function CreateStepper(
    parent,
    label,
    x,
    y,
    width,
    getter,
    setter,
    step,
    minimum,
    maximum,
    formatter
)
    local holder =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    holder:SetSize(
        width or 330,
        28
    )

    holder:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        x,
        y
    )

    local labelText =
        BlackoutUI:CreateFont(
            holder,
            10
        )

    labelText:SetPoint(
        "LEFT",
        holder,
        "LEFT",
        0,
        0
    )

    labelText:SetText(label)
    labelText:SetTextColor(unpack(TEXT))

    local minus =
        CreateFrame(
            "Button",
            nil,
            holder
        )

    minus:SetSize(26, 24)
    minus:SetPoint(
        "RIGHT",
        holder,
        "RIGHT",
        -88,
        0
    )

    local valueBox =
        CreateFrame(
            "Frame",
            nil,
            holder
        )

    valueBox:SetSize(56, 24)
    valueBox:SetPoint(
        "LEFT",
        minus,
        "RIGHT",
        3,
        0
    )

    local plus =
        CreateFrame(
            "Button",
            nil,
            holder
        )

    plus:SetSize(26, 24)
    plus:SetPoint(
        "LEFT",
        valueBox,
        "RIGHT",
        3,
        0
    )

    for _, button
    in ipairs({ minus, plus }) do
        local buttonBG =
            button:CreateTexture(
                nil,
                "BACKGROUND"
            )

        buttonBG:SetAllPoints()
        buttonBG:SetColorTexture(
            0.025,
            0.025,
            0.025,
            1
        )

        BlackoutUI:CreateBorder(
            button,
            1,
            "borderBright"
        )
    end

    local minusText =
        BlackoutUI:CreateFont(
            minus,
            12
        )

    minusText:SetPoint("CENTER")
    minusText:SetText("−")

    local plusText =
        BlackoutUI:CreateFont(
            plus,
            12
        )

    plusText:SetPoint("CENTER")
    plusText:SetText("+")

    local valueBG =
        valueBox:CreateTexture(
            nil,
            "BACKGROUND"
        )

    valueBG:SetAllPoints()
    valueBG:SetColorTexture(
        0.012,
        0.012,
        0.012,
        1
    )

    BlackoutUI:CreateBorder(
        valueBox,
        1,
        "borderBright"
    )

    local valueText =
        BlackoutUI:CreateFont(
            valueBox,
            9
        )

    valueText:SetPoint("CENTER")
    valueText:SetTextColor(unpack(ACCENT))

    local function Refresh()
        local value =
            tonumber(getter())
            or minimum

        if formatter then
            valueText:SetText(
                formatter(value)
            )
        else
            valueText:SetText(
                tostring(value)
            )
        end
    end

    local function Change(delta)
        local value =
            tonumber(getter())
            or minimum

        value =
            math.max(
                minimum,
                math.min(
                    maximum,
                    value + delta
                )
            )

        -- Avoid floating point junk in SavedVariables.
        value =
            math.floor(
                value * 100 + 0.5
            ) / 100

        setter(value)
        Refresh()
    end

    minus:SetScript(
        "OnClick",
        function()
            Change(-step)
        end
    )

    plus:SetScript(
        "OnClick",
        function()
            Change(step)
        end
    )

    holder.Refresh = Refresh
    Refresh()

    return holder
end

local function CreateActionButton(
    parent,
    text,
    x,
    y,
    width,
    onClick
)
    local button =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    button:SetSize(
        width or 170,
        30
    )

    button:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        x,
        y
    )

    local buttonBG =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    buttonBG:SetAllPoints()
    buttonBG:SetColorTexture(
        0.025,
        0.025,
        0.025,
        1
    )

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    local label =
        BlackoutUI:CreateFont(
            button,
            9
        )

    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(unpack(TEXT))

    button:SetScript(
        "OnEnter",
        function()
            buttonBG:SetColorTexture(
                0.05,
                0.10,
                0.13,
                1
            )
        end
    )

    button:SetScript(
        "OnLeave",
        function()
            buttonBG:SetColorTexture(
                0.025,
                0.025,
                0.025,
                1
            )
        end
    )

    button:SetScript(
        "OnClick",
        onClick
    )

    return button
end

--------------------------------------------------
-- GENERAL PAGE
--------------------------------------------------

local General =
    CreatePage(
        "general",
        "GENERAL"
    )

local generalInfo =
    BlackoutUI:CreateFont(
        General,
        10
    )

generalInfo:SetPoint(
    "TOPLEFT",
    General,
    "TOPLEFT",
    22,
    -72
)

generalInfo:SetWidth(420)
generalInfo:SetJustifyH("LEFT")
generalInfo:SetText(
    "BlackoutUI configuration is now active. "
    .. "More module controls will be added here as "
    .. "we finish each system."
)

generalInfo:SetTextColor(unpack(MUTED))

--------------------------------------------------
-- ORIGINAL /BUI MOVE MODE
--------------------------------------------------

local PreviousSlashHandler =
    SlashCmdList
    and SlashCmdList["BLACKOUTUI"]

CreateActionButton(
    General,
    "ENTER MOVE / GRID MODE",
    22,
    -128,
    205,
    function()
        ConfigFrame:Hide()

        if PreviousSlashHandler then
            PreviousSlashHandler("")
        end
    end
)

local moveHelp =
    BlackoutUI:CreateFont(
        General,
        9
    )

moveHelp:SetPoint(
    "TOPLEFT",
    General,
    "TOPLEFT",
    22,
    -171
)

moveHelp:SetText(
    "You can also type  /bui move"
)

moveHelp:SetTextColor(unpack(MUTED))

--------------------------------------------------
-- XP TRACKER PAGE
--------------------------------------------------

local XPPage =
    CreatePage(
        "xp",
        "XP / LEVELING TRACKER"
    )

local XPControls = {}

local function XPConfig()
    return EnsureConfig().XPTracker
end

local function ApplyXPConfig()
    if BlackoutUI.XPTracker
        and BlackoutUI.XPTracker.ApplyConfig then
        BlackoutUI.XPTracker:ApplyConfig()
    end
end

local function AddXPCheckbox(key, label, y)
    XPControls[key] =
        CreateCheckbox(
            XPPage,
            label,
            22,
            y,
            function()
                return XPConfig()[key]
            end,
            function(value)
                XPConfig()[key] = value
                ApplyXPConfig()
            end
        )
end

local function AddXPStepper(
    key, label, y, step, minimum, maximum, formatter
)
    XPControls[key] =
        CreateStepper(
            XPPage,
            label,
            22,
            y,
            420,
            function()
                return XPConfig()[key]
            end,
            function(value)
                XPConfig()[key] = value
                ApplyXPConfig()
            end,
            step,
            minimum,
            maximum,
            formatter
        )
end

AddXPCheckbox("enabled", "Enable XP Bar", -72)
AddXPCheckbox("hoverDashboard", "Enable Hover Dashboard", -104)
AddXPCheckbox("showRested", "Show Rested XP Projection", -136)

local sizeTitle = BlackoutUI:CreateFont(XPPage, 9)
sizeTitle:SetPoint("TOPLEFT", XPPage, "TOPLEFT", 22, -182)
sizeTitle:SetText("SIZE")
sizeTitle:SetTextColor(unpack(ACCENT))

AddXPStepper("width", "XP Bar Width", -207, 10, 250, 900,
    function(v) return string.format("%d px", v) end)

AddXPStepper("height", "XP Bar Height", -239, 1, 12, 40,
    function(v) return string.format("%d px", v) end)

AddXPStepper("scale", "XP Bar Scale", -271, 0.05, 0.60, 1.60,
    function(v) return string.format("%.2f", v) end)

AddXPStepper("dashboardScale", "Hover Dashboard Scale", -303, 0.05, 0.70, 1.50,
    function(v) return string.format("%.2f", v) end)

local textTitle = BlackoutUI:CreateFont(XPPage, 9)
textTitle:SetPoint("TOPLEFT", XPPage, "TOPLEFT", 22, -349)
textTitle:SetText("BAR TEXT")
textTitle:SetTextColor(unpack(ACCENT))

AddXPCheckbox("showLevel", "Show Current Level", -374)
AddXPCheckbox("showProgress", "Show Current XP / Required XP", -406)
AddXPCheckbox("showPercent", "Show XP Percentage", -438)

AddXPStepper("textSize", "XP Bar Text Size", -470, 1, 7, 20,
    function(v) return string.format("%d pt", v) end)

local trackingTitle = BlackoutUI:CreateFont(XPPage, 9)
trackingTitle:SetPoint("TOPLEFT", XPPage, "TOPLEFT", 22, -516)
trackingTitle:SetText("SESSION DATA")
trackingTitle:SetTextColor(unpack(ACCENT))

local trackingInfo = BlackoutUI:CreateFont(XPPage, 9)
trackingInfo:SetPoint("TOPLEFT", XPPage, "TOPLEFT", 22, -539)
trackingInfo:SetWidth(420)
trackingInfo:SetJustifyH("LEFT")
trackingInfo:SetText(
    "The tracker stores XP, kill, quest and elapsed-time statistics "
    .. "across /reload. Reset only when you want to start a new leveling session."
)
trackingInfo:SetTextColor(unpack(MUTED))

CreateActionButton(
    XPPage,
    "RESET SESSION DATA",
    22,
    -605,
    180,
    function()
        if BlackoutUI.XPTracker
            and BlackoutUI.XPTracker.ResetSession then
            BlackoutUI.XPTracker:ResetSession()
        end
    end
)

XPPage:SetHeight(690)

--------------------------------------------------
-- PLACEHOLDER PAGES
--------------------------------------------------

local function MakeComingSoonPage(
    key,
    title,
    description
)
    local page =
        CreatePage(
            key,
            title
        )

    local text =
        BlackoutUI:CreateFont(
            page,
            10
        )

    text:SetPoint(
        "TOPLEFT",
        page,
        "TOPLEFT",
        22,
        -72
    )

    text:SetWidth(420)
    text:SetJustifyH("LEFT")
    text:SetText(description)
    text:SetTextColor(unpack(MUTED))
end

--------------------------------------------------
-- UNIT FRAMES PAGE
--------------------------------------------------

local UnitFramesPage = CreatePage("unitframes", "UNIT FRAMES")
local UnitFrameControls = {}
local UnitFrameSelectorButtons = {}
local SelectedUnitFrame = "player"

local UnitFrameOrder = {
    { key = "player",       label = "PLAYER" },
    { key = "target",       label = "TARGET" },
    { key = "targettarget", label = "TARGET OF TARGET" },
    { key = "pet",          label = "PET" },
    { key = "party",        label = "PARTY" },
    { key = "raid",         label = "RAID" },
}

local function UnitFrameConfig()
    return EnsureConfig().UnitFrames
end

local function SelectedUnitConfig()
    return UnitFrameConfig()[SelectedUnitFrame]
end

local function ApplySelectedUnitFrame()
    if SelectedUnitFrame == "player" then
        if BlackoutUI.PlayerFrame and BlackoutUI.PlayerFrame.ApplyConfig then
            BlackoutUI.PlayerFrame:ApplyConfig()
        end
    elseif SelectedUnitFrame == "target" then
        if BlackoutUI.TargetFrame and BlackoutUI.TargetFrame.ApplyConfig then
            BlackoutUI.TargetFrame:ApplyConfig()
        end
    elseif SelectedUnitFrame == "targettarget" then
        if BlackoutUI.TargetOfTarget and BlackoutUI.TargetOfTarget.ApplyConfig then
            BlackoutUI.TargetOfTarget:ApplyConfig()
        end
    elseif SelectedUnitFrame == "pet" then
        if BlackoutUI.PetFrame and BlackoutUI.PetFrame.ApplyConfig then
            BlackoutUI.PetFrame:ApplyConfig()
        end
    elseif SelectedUnitFrame == "party" then
        if BlackoutUI.PartyFrames and BlackoutUI.PartyFrames.ApplyConfig then
            BlackoutUI.PartyFrames:ApplyConfig()
        end
    elseif SelectedUnitFrame == "raid" then
        if BlackoutUI.RaidFrames and BlackoutUI.RaidFrames.ApplyConfig then
            BlackoutUI.RaidFrames:ApplyConfig()
        end
    end
end

local unitSelectorTitle = BlackoutUI:CreateFont(UnitFramesPage, 9)
unitSelectorTitle:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -70)
unitSelectorTitle:SetText("EDIT INDIVIDUAL UNIT FRAME")
unitSelectorTitle:SetTextColor(unpack(ACCENT))

for index, info in ipairs(UnitFrameOrder) do
    local button = CreateFrame("Button", nil, UnitFramesPage)
    local width =
        info.key == "targettarget"
        and 98
        or (
            info.key == "raid"
            and 54
            or 62
        )
    button:SetSize(width, 28)

    if index == 1 then
        button:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -91)
    else
        button:SetPoint("LEFT", UnitFrameSelectorButtons[index - 1], "RIGHT", 6, 0)
    end

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.025, 0.025, 0.025, 1)
    button.Background = bg
    BlackoutUI:CreateBorder(button, 1, "borderBright")

    local text = BlackoutUI:CreateFont(button, 9)
    text:SetPoint("CENTER")
    text:SetText(info.label)
    button.Text = text
    button.UnitKey = info.key

    button:SetScript("OnClick", function()
        SelectedUnitFrame = info.key
        if UnitFramesPage.Refresh then UnitFramesPage:Refresh() end
    end)

    UnitFrameSelectorButtons[index] = button
end

local function AddUnitStepper(key, label, y, step, minimum, maximum, formatter, onlyFullFrame)
    local control = CreateStepper(
        UnitFramesPage, label, 22, y, 420,
        function()
            return SelectedUnitConfig()[key] or minimum
        end,
        function(value)
            SelectedUnitConfig()[key] = value
            ApplySelectedUnitFrame()
        end,
        step, minimum, maximum, formatter
    )
    control.OnlyFullFrame = onlyFullFrame
    UnitFrameControls[key] = control
    return control
end

local function AddUnitCheckbox(key, label, y, onlyFullFrame)
    local control = CreateCheckbox(
        UnitFramesPage, label, 22, y,
        function()
            return SelectedUnitConfig()[key]
        end,
        function(value)
            SelectedUnitConfig()[key] = value
            ApplySelectedUnitFrame()
        end
    )

    control.OnlyFullFrame = onlyFullFrame
    UnitFrameControls[key] = control
    return control
end

UnitFrameControls.enabled = CreateCheckbox(
    UnitFramesPage, "Enable Selected Unit Frame", 22, -128,
    function() return SelectedUnitConfig().enabled end,
    function(value)
        SelectedUnitConfig().enabled = value
        ApplySelectedUnitFrame()
    end
)

AddUnitStepper("width", "Width", -158, 5, 60, 600,
    function(v) return string.format("%d px", v) end)
AddUnitStepper("height", "Health Cell Height", -188, 1, 32, 180,
    function(v) return string.format("%d px", v) end)
AddUnitStepper("scale", "Frame Scale", -218, 0.05, 0.50, 1.75,
    function(v) return string.format("%.2f", v) end)

local barsTitle = BlackoutUI:CreateFont(UnitFramesPage, 9)
barsTitle:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -252)
barsTitle:SetText("BARS")
barsTitle:SetTextColor(unpack(ACCENT))

AddUnitStepper("headerHeight", "Header Height", -276, 1, 16, 40,
    function(v) return string.format("%d px", v) end, true)
AddUnitStepper("healthHeight", "Health Bar Height", -306, 1, 8, 80,
    function(v) return string.format("%d px", v) end)
AddUnitStepper("powerHeight", "Power Bar Height", -336, 1, 8, 40,
    function(v) return string.format("%d px", v) end, true)

local textTitle = BlackoutUI:CreateFont(UnitFramesPage, 9)
textTitle:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -370)
textTitle:SetText("TEXT")
textTitle:SetTextColor(unpack(ACCENT))

AddUnitStepper("nameSize", "Name Text Size", -394, 1, 7, 22,
    function(v) return string.format("%d pt", v) end)
AddUnitStepper("levelSize", "Level Text Size", -424, 1, 7, 20,
    function(v) return string.format("%d pt", v) end, true)
AddUnitStepper("healthValueSize", "Health Value Size", -454, 1, 7, 22,
    function(v) return string.format("%d pt", v) end, true)
AddUnitStepper("healthPercentSize", "Health Percent Size", -484, 1, 7, 24,
    function(v) return string.format("%d pt", v) end)
AddUnitStepper("powerLabelSize", "Power Label Size", -514, 1, 7, 20,
    function(v) return string.format("%d pt", v) end, true)
AddUnitStepper("powerValueSize", "Power Value Size", -544, 1, 7, 22,
    function(v) return string.format("%d pt", v) end, true)

--------------------------------------------------
-- PARTY-SPECIFIC LAYOUT / PREVIEW
--------------------------------------------------

local partyLayoutTitle =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        9
    )

partyLayoutTitle:SetPoint(
    "TOPLEFT",
    UnitFramesPage,
    "TOPLEFT",
    22,
    -580
)

partyLayoutTitle:SetText("GRID PARTY SETTINGS")
partyLayoutTitle:SetTextColor(unpack(ACCENT))

local partyGridNote =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        8
    )

partyGridNote:SetPoint(
    "TOPLEFT",
    UnitFramesPage,
    "TOPLEFT",
    22,
    -598
)

partyGridNote:SetText(
    "Compact group frame: center name/health, level top-left, HoTs top-right, buffs bottom-left, debuffs bottom-right."
)

partyGridNote:SetTextColor(
    0.58,
    0.62,
    0.68,
    1
)

partyGridNote:SetWidth(410)
partyGridNote:SetJustifyH("LEFT")

local partyPreviewButton

partyPreviewButton =
    CreateActionButton(
        UnitFramesPage,
        "SHOW PARTY PREVIEW",
        22,
        -628,
        200,
        function()
            if BlackoutUI.PartyFrames
                and BlackoutUI.PartyFrames.SetPreview then
                local enabled =
                    not BlackoutUI.PartyFrames:IsPreviewEnabled()

                BlackoutUI.PartyFrames:SetPreview(enabled)

                if partyPreviewButton.Text then
                    partyPreviewButton.Text:SetText(
                        enabled
                        and "HIDE PARTY PREVIEW"
                        or "SHOW PARTY PREVIEW"
                    )
                end
            end
        end
    )

local partyDirectionButton

partyDirectionButton =
    CreateActionButton(
        UnitFramesPage,
        "LAYOUT: VERTICAL",
        232,
        -670,
        200,
        function()
            local config = SelectedUnitConfig()

            local direction =
                config.growthDirection == "HORIZONTAL"
                and "VERTICAL"
                or "HORIZONTAL"

            config.growthDirection = direction

            if BlackoutUI.PartyFrames
                and BlackoutUI.PartyFrames.SetGrowthDirection then
                BlackoutUI.PartyFrames:SetGrowthDirection(direction)
            else
                ApplySelectedUnitFrame()
            end

            if partyDirectionButton.Text then
                partyDirectionButton.Text:SetText(
                    "LAYOUT: " .. direction
                )
            end
        end
    )

local partySpacingControl =
    CreateStepper(
        UnitFramesPage,
        "Party Frame Spacing",
        22,
        -664,
        420,
        function()
            return SelectedUnitConfig().spacing or 8
        end,
        function(value)
            SelectedUnitConfig().spacing = value
            ApplySelectedUnitFrame()
        end,
        1,
        0,
        30,
        function(value)
            return string.format("%d px", value)
        end
    )

local partyResourceToggle =
    CreateCheckbox(
        UnitFramesPage,
        "Show Resource Bar",
        22,
        -698,
        function()
            return SelectedUnitConfig().showResourceBar
        end,
        function(value)
            SelectedUnitConfig().showResourceBar = value
            ApplySelectedUnitFrame()
        end
    )

local partyResourceHeight =
    CreateStepper(
        UnitFramesPage,
        "Resource Bar Height (Below Health)",
        22,
        -728,
        420,
        function()
            return SelectedUnitConfig().resourceHeight or 5
        end,
        function(value)
            SelectedUnitConfig().resourceHeight = value
            ApplySelectedUnitFrame()
        end,
        1,
        2,
        10,
        function(value)
            return string.format("%d px", value)
        end
    )


local partyCombatTitle =
    BlackoutUI:CreateFont(UnitFramesPage, 9)

partyCombatTitle:SetText("HEALING / THREAT")
partyCombatTitle:SetTextColor(unpack(ACCENT))

local partyIncomingHeals =
    CreateCheckbox(
        UnitFramesPage,
        "Show Incoming Heal Prediction",
        22, -606,
        function()
            return SelectedUnitConfig().showIncomingHeals
        end,
        function(value)
            SelectedUnitConfig().showIncomingHeals = value
            ApplySelectedUnitFrame()
        end
    )

local partyIncomingHealAlpha =
    CreateStepper(
        UnitFramesPage,
        "Incoming Heal Opacity",
        22, -638, 420,
        function()
            return SelectedUnitConfig().incomingHealAlpha or 0.45
        end,
        function(value)
            SelectedUnitConfig().incomingHealAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 1.00,
        function(value)
            return string.format(
                "%d%%",
                math.floor(value * 100 + 0.5)
            )
        end
    )

local partyThreat =
    CreateCheckbox(
        UnitFramesPage,
        "Show Aggro / Threat Border",
        22, -670,
        function()
            return SelectedUnitConfig().showThreat
        end,
        function(value)
            SelectedUnitConfig().showThreat = value
            ApplySelectedUnitFrame()
        end
    )


local partyRangeTitle = BlackoutUI:CreateFont(UnitFramesPage, 9)
partyRangeTitle:SetText("RANGE / STATUS")
partyRangeTitle:SetTextColor(unpack(ACCENT))

local partyShowPlayer =
    CreateCheckbox(
        UnitFramesPage, "Show Yourself in Party Frames", 22, -736,
        function() return SelectedUnitConfig().showPlayer end,
        function(value)
            SelectedUnitConfig().showPlayer = value
            ApplySelectedUnitFrame()
        end
    )

local partyRangeFading =
    CreateCheckbox(
        UnitFramesPage, "Fade Out-of-Range Units", 22, -768,
        function() return SelectedUnitConfig().rangeFading end,
        function(value)
            SelectedUnitConfig().rangeFading = value
            ApplySelectedUnitFrame()
        end
    )

local partyOutOfRangeAlpha =
    CreateStepper(
        UnitFramesPage, "Out-of-Range Opacity", 22, -800, 420,
        function() return SelectedUnitConfig().outOfRangeAlpha or 0.45 end,
        function(value)
            SelectedUnitConfig().outOfRangeAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 0.90,
        function(value)
            return string.format("%d%%", math.floor(value * 100 + 0.5))
        end
    )

local partyStatusText =
    CreateCheckbox(
        UnitFramesPage, "Show DEAD / GHOST / OFFLINE Text", 22, -832,
        function() return SelectedUnitConfig().showStatusText end,
        function(value)
            SelectedUnitConfig().showStatusText = value
            ApplySelectedUnitFrame()
        end
    )

local partyDeadAlpha =
    CreateStepper(
        UnitFramesPage, "Dead / Ghost Opacity", 22, -864, 420,
        function() return SelectedUnitConfig().deadAlpha or 0.55 end,
        function(value)
            SelectedUnitConfig().deadAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 1.00,
        function(value)
            return string.format("%d%%", math.floor(value * 100 + 0.5))
        end
    )

local partyOfflineAlpha =
    CreateStepper(
        UnitFramesPage, "Offline Opacity", 22, -896, 420,
        function() return SelectedUnitConfig().offlineAlpha or 0.35 end,
        function(value)
            SelectedUnitConfig().offlineAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 1.00,
        function(value)
            return string.format("%d%%", math.floor(value * 100 + 0.5))
        end
    )

local function RefreshPartyControls()
    local isParty =
        SelectedUnitFrame == "party"

    partyLayoutTitle:SetShown(isParty)
    partyGridNote:SetShown(isParty)
    partyPreviewButton:SetShown(isParty)
    partyDirectionButton:SetShown(isParty)
    partySpacingControl:SetShown(isParty)
    partyResourceToggle:SetShown(isParty)
    partyResourceHeight:SetShown(isParty)
    partyCombatTitle:SetShown(isParty)
    partyIncomingHeals:SetShown(isParty)
    partyIncomingHealAlpha:SetShown(isParty)
    partyThreat:SetShown(isParty)
    partyRangeTitle:SetShown(isParty)
    partyShowPlayer:SetShown(isParty)
    partyRangeFading:SetShown(isParty)
    partyOutOfRangeAlpha:SetShown(isParty)
    partyStatusText:SetShown(isParty)
    partyDeadAlpha:SetShown(isParty)
    partyOfflineAlpha:SetShown(isParty)

    if not isParty then
        return
    end

    local config = SelectedUnitConfig()

    if partyDirectionButton.Text then
        partyDirectionButton.Text:SetText(
            "LAYOUT: "
            .. (config.growthDirection or "VERTICAL")
        )
    end

    if partyPreviewButton.Text
        and BlackoutUI.PartyFrames
        and BlackoutUI.PartyFrames.IsPreviewEnabled then
        partyPreviewButton.Text:SetText(
            BlackoutUI.PartyFrames:IsPreviewEnabled()
            and "HIDE PARTY PREVIEW"
            or "SHOW PARTY PREVIEW"
        )
    end

    if partySpacingControl.Refresh then
        partySpacingControl:Refresh()
    end

    if partyResourceToggle.Refresh then
        partyResourceToggle:Refresh()
    end

    if partyResourceHeight.Refresh then
        partyResourceHeight:Refresh()
    end

    if partyIncomingHeals.Refresh then
        partyIncomingHeals:Refresh()
    end

    if partyIncomingHealAlpha.Refresh then
        partyIncomingHealAlpha:Refresh()
    end

    if partyThreat.Refresh then
        partyThreat:Refresh()
    end

    for _, control in ipairs({
        partyShowPlayer,
        partyRangeFading,
        partyOutOfRangeAlpha,
        partyStatusText,
        partyDeadAlpha,
        partyOfflineAlpha,
    }) do
        if control.Refresh then control:Refresh() end
    end
end


--------------------------------------------------
-- RAID-SPECIFIC GRID LAYOUT / PREVIEW
--------------------------------------------------

local raidLayoutTitle =
    BlackoutUI:CreateFont(UnitFramesPage, 9)

raidLayoutTitle:SetPoint(
    "TOPLEFT",
    UnitFramesPage,
    "TOPLEFT",
    22,
    -580
)

raidLayoutTitle:SetText("GRID RAID SETTINGS")
raidLayoutTitle:SetTextColor(unpack(ACCENT))

local raidGridNote =
    BlackoutUI:CreateFont(UnitFramesPage, 8)

raidGridNote:SetPoint(
    "TOPLEFT",
    UnitFramesPage,
    "TOPLEFT",
    22,
    -598
)

raidGridNote:SetWidth(410)
raidGridNote:SetJustifyH("LEFT")
raidGridNote:SetText(
    "Compact 5-player groups. Level top-left, HoTs top-right, class buffs bottom-left, dispellable debuffs bottom-right."
)
raidGridNote:SetTextColor(
    0.58, 0.62, 0.68, 1
)

local raidPreviewButton =
    CreateActionButton(
        UnitFramesPage,
        "SHOW RAID PREVIEW",
        22,
        -628,
        200,
        function()
            if BlackoutUI.RaidFrames
                and BlackoutUI.RaidFrames.SetPreview then
                local enabled =
                    not BlackoutUI.RaidFrames:IsPreviewEnabled()

                BlackoutUI.RaidFrames:SetPreview(enabled)

                if UnitFramesPage.Refresh then
                    UnitFramesPage:Refresh()
                end
            end
        end
    )

local raidPreview10 =
    CreateActionButton(
        UnitFramesPage,
        "10 PLAYER",
        232,
        -628,
        92,
        function()
            if BlackoutUI.RaidFrames
                and BlackoutUI.RaidFrames.SetPreviewSize then
                BlackoutUI.RaidFrames:SetPreviewSize(10)
                BlackoutUI.RaidFrames:SetPreview(true)

                if UnitFramesPage.Refresh then
                    UnitFramesPage:Refresh()
                end
            end
        end
    )

local raidPreview20 =
    CreateActionButton(
        UnitFramesPage,
        "20 PLAYER",
        330,
        -628,
        92,
        function()
            if BlackoutUI.RaidFrames
                and BlackoutUI.RaidFrames.SetPreviewSize then
                BlackoutUI.RaidFrames:SetPreviewSize(20)
                BlackoutUI.RaidFrames:SetPreview(true)

                if UnitFramesPage.Refresh then
                    UnitFramesPage:Refresh()
                end
            end
        end
    )

local raidPreview40 =
    CreateActionButton(
        UnitFramesPage,
        "40 PLAYER",
        232,
        -660,
        92,
        function()
            if BlackoutUI.RaidFrames
                and BlackoutUI.RaidFrames.SetPreviewSize then
                BlackoutUI.RaidFrames:SetPreviewSize(40)
                BlackoutUI.RaidFrames:SetPreview(true)

                if UnitFramesPage.Refresh then
                    UnitFramesPage:Refresh()
                end
            end
        end
    )

local raidGroupsPerRow =
    CreateStepper(
        UnitFramesPage,
        "Groups Per Row",
        22,
        -698,
        420,
        function()
            return SelectedUnitConfig().groupsPerRow or 4
        end,
        function(value)
            SelectedUnitConfig().groupsPerRow = value
            ApplySelectedUnitFrame()
        end,
        1, 1, 8,
        function(value)
            return string.format("%d", value)
        end
    )

local raidHorizontalSpacing =
    CreateStepper(
        UnitFramesPage,
        "Horizontal Spacing Between Groups",
        22,
        -728,
        420,
        function()
            return SelectedUnitConfig().horizontalSpacing or 3
        end,
        function(value)
            SelectedUnitConfig().horizontalSpacing = value
            ApplySelectedUnitFrame()
        end,
        1, 0, 20,
        function(value)
            return string.format("%d px", value)
        end
    )

local raidVerticalSpacing =
    CreateStepper(
        UnitFramesPage,
        "Vertical Cell Spacing",
        22,
        -758,
        420,
        function()
            return SelectedUnitConfig().verticalSpacing or 3
        end,
        function(value)
            SelectedUnitConfig().verticalSpacing = value
            ApplySelectedUnitFrame()
        end,
        1, 0, 20,
        function(value)
            return string.format("%d px", value)
        end
    )

local raidGroupSpacing =
    CreateStepper(
        UnitFramesPage,
        "Vertical Spacing Between Group Rows",
        22,
        -788,
        420,
        function()
            return SelectedUnitConfig().groupSpacing or 8
        end,
        function(value)
            SelectedUnitConfig().groupSpacing = value
            ApplySelectedUnitFrame()
        end,
        1, 0, 40,
        function(value)
            return string.format("%d px", value)
        end
    )

local raidResourceToggle =
    CreateCheckbox(
        UnitFramesPage,
        "Show Resource Bar",
        22,
        -822,
        function()
            return SelectedUnitConfig().showResourceBar
        end,
        function(value)
            SelectedUnitConfig().showResourceBar = value
            ApplySelectedUnitFrame()
        end
    )

local raidResourceHeight =
    CreateStepper(
        UnitFramesPage,
        "Resource Bar Height (Below Health)",
        22,
        -852,
        420,
        function()
            return SelectedUnitConfig().resourceHeight or 4
        end,
        function(value)
            SelectedUnitConfig().resourceHeight = value
            ApplySelectedUnitFrame()
        end,
        1, 2, 10,
        function(value)
            return string.format("%d px", value)
        end
    )


local raidAuraTitle =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        9
    )

raidAuraTitle:SetText(
    "RAID INDICATORS"
)

raidAuraTitle:SetTextColor(
    unpack(ACCENT)
)

local raidAuraIconSize =
    CreateStepper(
        UnitFramesPage,
        "Indicator Icon Size",
        22,
        -716,
        420,
        function()
            return SelectedUnitConfig().auraIconSize or 11
        end,
        function(value)
            SelectedUnitConfig().auraIconSize = value
            ApplySelectedUnitFrame()
        end,
        1,
        7,
        24,
        function(value)
            return string.format("%d px", value)
        end
    )

local raidShowHots =
    CreateCheckbox(
        UnitFramesPage,
        "Show Relevant HoTs",
        22,
        -750,
        function()
            return SelectedUnitConfig().showHots
        end,
        function(value)
            SelectedUnitConfig().showHots = value
            ApplySelectedUnitFrame()
        end
    )

local raidShowClassBuffs =
    CreateCheckbox(
        UnitFramesPage,
        "Show Class Buffs / Missing Buffs",
        22,
        -782,
        function()
            return SelectedUnitConfig().showClassBuffs
        end,
        function(value)
            SelectedUnitConfig().showClassBuffs = value
            ApplySelectedUnitFrame()
        end
    )

local raidShowDispels =
    CreateCheckbox(
        UnitFramesPage,
        "Show Dispellable Debuffs",
        22,
        -814,
        function()
            return SelectedUnitConfig().showDispellableDebuffs
        end,
        function(value)
            SelectedUnitConfig().showDispellableDebuffs = value
            ApplySelectedUnitFrame()
        end
    )


local raidRangeTitle =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        9
    )

raidRangeTitle:SetText(
    "RANGE"
)

raidRangeTitle:SetTextColor(
    unpack(ACCENT)
)

local raidRangeFading =
    CreateCheckbox(
        UnitFramesPage,
        "Fade Out-of-Range Units",
        22,
        -882,
        function()
            return SelectedUnitConfig().rangeFading
        end,
        function(value)
            SelectedUnitConfig().rangeFading = value
            ApplySelectedUnitFrame()
        end
    )

local raidOutOfRangeAlpha =
    CreateStepper(
        UnitFramesPage,
        "Out-of-Range Opacity",
        22,
        -914,
        420,
        function()
            return SelectedUnitConfig().outOfRangeAlpha or 0.45
        end,
        function(value)
            SelectedUnitConfig().outOfRangeAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05,
        0.10,
        0.90,
        function(value)
            return string.format(
                "%d%%",
                math.floor(value * 100 + 0.5)
            )
        end
    )


local raidStatusTitle =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        9
    )

raidStatusTitle:SetText("UNIT STATUS")
raidStatusTitle:SetTextColor(
    unpack(ACCENT)
)

local raidStatusText =
    CreateCheckbox(
        UnitFramesPage,
        "Show DEAD / GHOST / OFFLINE Text",
        22,
        -982,
        function()
            return SelectedUnitConfig().showStatusText
        end,
        function(value)
            SelectedUnitConfig().showStatusText = value
            ApplySelectedUnitFrame()
        end
    )

local raidDeadAlpha =
    CreateStepper(
        UnitFramesPage,
        "Dead / Ghost Opacity",
        22,
        -1014,
        420,
        function()
            return SelectedUnitConfig().deadAlpha or 0.55
        end,
        function(value)
            SelectedUnitConfig().deadAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 1.00,
        function(value)
            return string.format(
                "%d%%",
                math.floor(value * 100 + 0.5)
            )
        end
    )

local raidOfflineAlpha =
    CreateStepper(
        UnitFramesPage,
        "Offline Opacity",
        22,
        -1046,
        420,
        function()
            return SelectedUnitConfig().offlineAlpha or 0.35
        end,
        function(value)
            SelectedUnitConfig().offlineAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05, 0.10, 1.00,
        function(value)
            return string.format(
                "%d%%",
                math.floor(value * 100 + 0.5)
            )
        end
    )


local raidHealingTitle =
    BlackoutUI:CreateFont(
        UnitFramesPage,
        9
    )

raidHealingTitle:SetText(
    "HEALING"
)

raidHealingTitle:SetTextColor(
    unpack(ACCENT)
)

local raidIncomingHeals =
    CreateCheckbox(
        UnitFramesPage,
        "Show Incoming Heal Prediction",
        22,
        -1110,
        function()
            return SelectedUnitConfig().showIncomingHeals
        end,
        function(value)
            SelectedUnitConfig().showIncomingHeals = value
            ApplySelectedUnitFrame()
        end
    )

local raidIncomingHealAlpha =
    CreateStepper(
        UnitFramesPage,
        "Incoming Heal Opacity",
        22,
        -1142,
        420,
        function()
            return SelectedUnitConfig().incomingHealAlpha or 0.45
        end,
        function(value)
            SelectedUnitConfig().incomingHealAlpha = value
            ApplySelectedUnitFrame()
        end,
        0.05,
        0.10,
        1.00,
        function(value)
            return string.format(
                "%d%%",
                math.floor(value * 100 + 0.5)
            )
        end
    )


local raidThreat =
    CreateCheckbox(
        UnitFramesPage,
        "Show Aggro / Threat Border",
        22,
        -1194,
        function()
            return SelectedUnitConfig().showThreat
        end,
        function(value)
            SelectedUnitConfig().showThreat = value
            ApplySelectedUnitFrame()
        end
    )

local function RefreshRaidControls()
    local isRaid =
        SelectedUnitFrame == "raid"

    raidLayoutTitle:SetShown(isRaid)
    raidGridNote:SetShown(isRaid)
    raidPreviewButton:SetShown(isRaid)
    raidPreview10:SetShown(isRaid)
    raidPreview20:SetShown(isRaid)
    raidPreview40:SetShown(isRaid)
    raidGroupsPerRow:SetShown(isRaid)
    raidHorizontalSpacing:SetShown(isRaid)
    raidVerticalSpacing:SetShown(isRaid)
    raidGroupSpacing:SetShown(isRaid)
    raidResourceToggle:SetShown(isRaid)
    raidResourceHeight:SetShown(isRaid)
    raidAuraTitle:SetShown(isRaid)
    raidAuraIconSize:SetShown(isRaid)
    raidShowHots:SetShown(isRaid)
    raidShowClassBuffs:SetShown(isRaid)
    raidShowDispels:SetShown(isRaid)
    raidRangeTitle:SetShown(isRaid)
    raidRangeFading:SetShown(isRaid)
    raidOutOfRangeAlpha:SetShown(isRaid)
    raidStatusTitle:SetShown(isRaid)
    raidStatusText:SetShown(isRaid)
    raidDeadAlpha:SetShown(isRaid)
    raidOfflineAlpha:SetShown(isRaid)
    raidHealingTitle:SetShown(isRaid)
    raidIncomingHeals:SetShown(isRaid)
    raidIncomingHealAlpha:SetShown(isRaid)
    raidThreat:SetShown(isRaid)

    if not isRaid then
        return
    end

    if raidPreviewButton.Text
        and BlackoutUI.RaidFrames
        and BlackoutUI.RaidFrames.IsPreviewEnabled then
        raidPreviewButton.Text:SetText(
            BlackoutUI.RaidFrames:IsPreviewEnabled()
            and "HIDE RAID PREVIEW"
            or "SHOW RAID PREVIEW"
        )
    end

    for _, control in ipairs({
        raidGroupsPerRow,
        raidHorizontalSpacing,
        raidVerticalSpacing,
        raidGroupSpacing,
        raidResourceToggle,
        raidResourceHeight,
        raidAuraIconSize,
        raidShowHots,
        raidShowClassBuffs,
        raidShowDispels,
        raidRangeFading,
        raidOutOfRangeAlpha,
        raidStatusText,
        raidDeadAlpha,
        raidOfflineAlpha,
        raidIncomingHeals,
        raidIncomingHealAlpha,
        raidThreat,
    }) do
        if control.Refresh then
            control:Refresh()
        end
    end
end

local displayTitle = BlackoutUI:CreateFont(UnitFramesPage, 9)
displayTitle:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -890)
displayTitle:SetText("DISPLAY")
displayTitle:SetTextColor(unpack(ACCENT))

AddUnitCheckbox("showName", "Show Name", -914, false)
AddUnitCheckbox("showLevel", "Show Level", -944, true)
AddUnitCheckbox("showHealthValue", "Show Health Value", -974, true)
AddUnitCheckbox("showHealthPercent", "Show Health Percent", -1004, false)
AddUnitCheckbox("showPowerLabel", "Show Power Label", -1034, true)
AddUnitCheckbox("showPowerValue", "Show Power Value", -1064, true)
AddUnitCheckbox("showPowerBar", "Show Power Bar", -1094, true)

local resetUnitButton = CreateActionButton(
    UnitFramesPage, "RESET SELECTED FRAME", 22, -1134, 190,
    function()
        if SelectedUnitFrame == "player"
            and BlackoutUI.PlayerFrame
            and BlackoutUI.PlayerFrame.ResetConfig then
            BlackoutUI.PlayerFrame:ResetConfig()
        elseif SelectedUnitFrame == "target"
            and BlackoutUI.TargetFrame
            and BlackoutUI.TargetFrame.ResetConfig then
            BlackoutUI.TargetFrame:ResetConfig()
        elseif SelectedUnitFrame == "targettarget"
            and BlackoutUI.TargetOfTarget
            and BlackoutUI.TargetOfTarget.ResetConfig then
            BlackoutUI.TargetOfTarget:ResetConfig()
        elseif SelectedUnitFrame == "pet"
            and BlackoutUI.PetFrame
            and BlackoutUI.PetFrame.ResetConfig then
            BlackoutUI.PetFrame:ResetConfig()
        elseif SelectedUnitFrame == "party"
            and BlackoutUI.PartyFrames
            and BlackoutUI.PartyFrames.ResetConfig then
            BlackoutUI.PartyFrames:ResetConfig()
        elseif SelectedUnitFrame == "raid"
            and BlackoutUI.RaidFrames
            and BlackoutUI.RaidFrames.ResetConfig then
            BlackoutUI.RaidFrames:ResetConfig()
        end

        EnsureConfig()
        if UnitFramesPage.Refresh then UnitFramesPage:Refresh() end
    end
)


-- This page now has more controls than the visible config window.
-- Increase only this page's scrollable canvas.
UnitFramesPage:SetHeight(1490)

function UnitFramesPage:Refresh()
    local compact = SelectedUnitFrame == "targettarget"
    local partyGrid = SelectedUnitFrame == "party"
    local raidGrid = SelectedUnitFrame == "raid"
    local groupGrid = partyGrid or raidGrid

    for _, button in ipairs(UnitFrameSelectorButtons) do
        local selected = button.UnitKey == SelectedUnitFrame
        button.Text:SetTextColor(unpack(selected and ACCENT or TEXT))
        button.Background:SetColorTexture(
            selected and 0.05 or 0.025,
            selected and 0.10 or 0.025,
            selected and 0.13 or 0.025,
            1
        )
    end

    for key, control in pairs(UnitFrameControls) do
        if groupGrid then
            local allowed =
                key == "enabled"
                or key == "width"
                or key == "height"
                or key == "scale"
                or key == "nameSize"
                or key == "showName"
                or key == "showHealthPercent"

            control:SetShown(allowed)
        elseif control.OnlyFullFrame then
            control:SetShown(not compact)
        else
            control:Show()
        end

        if control.Refresh then
            control:Refresh()
        end
    end

    -- Old full-frame headings are not relevant to Party/Raid Grid cells.
    barsTitle:SetShown(not groupGrid)
    textTitle:SetShown(not groupGrid)
    displayTitle:SetShown(not groupGrid)

    --------------------------------------------------
    -- COMPACT GRID PAGE LAYOUT
    --------------------------------------------------
    -- Hidden full-frame controls must not leave visual holes.
    -- Re-anchor the controls that Party/Raid actually use into
    -- one continuous stack.
    if groupGrid then
        local compactY = {
            enabled = -128,
            width = -162,
            height = -196,
            scale = -230,
            nameSize = -264,
            showName = -298,
            showHealthPercent = -330,
        }

        for key, y in pairs(compactY) do
            local control = UnitFrameControls[key]

            if control then
                control:ClearAllPoints()
                control:SetPoint(
                    "TOPLEFT",
                    UnitFramesPage,
                    "TOPLEFT",
                    22,
                    y
                )
            end
        end

        -- Party/Raid-specific sections start directly below
        -- the shared Grid controls instead of at the old
        -- full-frame page coordinates.
        if partyGrid then
            partyLayoutTitle:ClearAllPoints()
            partyLayoutTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -372
            )

            partyGridNote:ClearAllPoints()
            partyGridNote:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -390
            )

            partyPreviewButton:ClearAllPoints()
            partyPreviewButton:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -420
            )

            partyDirectionButton:ClearAllPoints()
            partyDirectionButton:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -456
            )

            partySpacingControl:ClearAllPoints()
            partySpacingControl:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -492
            )

            partyResourceToggle:ClearAllPoints()
            partyResourceToggle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -528
            )

            partyResourceHeight:ClearAllPoints()
            partyResourceHeight:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -562
            )

            partyCombatTitle:ClearAllPoints()
            partyCombatTitle:SetPoint(
                "TOPLEFT", UnitFramesPage,
                "TOPLEFT", 22, -604
            )

            partyIncomingHeals:ClearAllPoints()
            partyIncomingHeals:SetPoint(
                "TOPLEFT", UnitFramesPage,
                "TOPLEFT", 22, -628
            )

            partyIncomingHealAlpha:ClearAllPoints()
            partyIncomingHealAlpha:SetPoint(
                "TOPLEFT", UnitFramesPage,
                "TOPLEFT", 22, -660
            )

            partyThreat:ClearAllPoints()
            partyThreat:SetPoint(
                "TOPLEFT", UnitFramesPage,
                "TOPLEFT", 22, -692
            )

            partyRangeTitle:ClearAllPoints()
            partyRangeTitle:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -734)
            partyShowPlayer:ClearAllPoints()
            partyShowPlayer:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -758)
            partyRangeFading:ClearAllPoints()
            partyRangeFading:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -790)
            partyOutOfRangeAlpha:ClearAllPoints()
            partyOutOfRangeAlpha:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -822)
            partyStatusText:ClearAllPoints()
            partyStatusText:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -854)
            partyDeadAlpha:ClearAllPoints()
            partyDeadAlpha:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -886)
            partyOfflineAlpha:ClearAllPoints()
            partyOfflineAlpha:SetPoint("TOPLEFT", UnitFramesPage, "TOPLEFT", 22, -918)
        elseif raidGrid then
            raidLayoutTitle:ClearAllPoints()
            raidLayoutTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -372
            )

            raidGridNote:ClearAllPoints()
            raidGridNote:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -390
            )

            raidPreviewButton:ClearAllPoints()
            raidPreviewButton:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -420
            )

            raidPreview10:ClearAllPoints()
            raidPreview10:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                232,
                -420
            )

            raidPreview20:ClearAllPoints()
            raidPreview20:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                330,
                -420
            )

            raidPreview40:ClearAllPoints()
            raidPreview40:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                232,
                -456
            )

            raidGroupsPerRow:ClearAllPoints()
            raidGroupsPerRow:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -498
            )

            raidHorizontalSpacing:ClearAllPoints()
            raidHorizontalSpacing:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -532
            )

            raidVerticalSpacing:ClearAllPoints()
            raidVerticalSpacing:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -566
            )

            raidGroupSpacing:ClearAllPoints()
            raidGroupSpacing:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -600
            )

            raidResourceToggle:ClearAllPoints()
            raidResourceToggle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -638
            )

            raidResourceHeight:ClearAllPoints()
            raidResourceHeight:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -672
            )

            raidAuraTitle:ClearAllPoints()
            raidAuraTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -714
            )

            raidAuraIconSize:ClearAllPoints()
            raidAuraIconSize:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -738
            )

            raidShowHots:ClearAllPoints()
            raidShowHots:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -772
            )

            raidShowClassBuffs:ClearAllPoints()
            raidShowClassBuffs:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -804
            )

            raidShowDispels:ClearAllPoints()
            raidShowDispels:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -836
            )

            raidRangeTitle:ClearAllPoints()
            raidRangeTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -878
            )

            raidRangeFading:ClearAllPoints()
            raidRangeFading:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -902
            )

            raidOutOfRangeAlpha:ClearAllPoints()
            raidOutOfRangeAlpha:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -934
            )

            raidStatusTitle:ClearAllPoints()
            raidStatusTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -976
            )

            raidStatusText:ClearAllPoints()
            raidStatusText:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1000
            )

            raidDeadAlpha:ClearAllPoints()
            raidDeadAlpha:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1032
            )

            raidOfflineAlpha:ClearAllPoints()
            raidOfflineAlpha:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1064
            )

            raidHealingTitle:ClearAllPoints()
            raidHealingTitle:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1106
            )

            raidIncomingHeals:ClearAllPoints()
            raidIncomingHeals:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1130
            )

            raidIncomingHealAlpha:ClearAllPoints()
            raidIncomingHealAlpha:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1162
            )

            raidThreat:ClearAllPoints()
            raidThreat:SetPoint(
                "TOPLEFT",
                UnitFramesPage,
                "TOPLEFT",
                22,
                -1194
            )
        end
    end

    RefreshPartyControls()
    RefreshRaidControls()
end

UnitFramesPage:Refresh()

--------------------------------------------------
-- MINIMAP PAGE
--------------------------------------------------

local MinimapPage = CreatePage("minimap", "MINIMAP")
local MinimapControls = {}

local function MinimapConfig()
    return EnsureConfig().Minimap
end

local function ApplyMinimapConfig()
    if BlackoutUI.Minimap and BlackoutUI.Minimap.ApplyConfig then
        BlackoutUI.Minimap:ApplyConfig()
    elseif BlackoutUI.ApplyMinimapStyle then
        BlackoutUI.ApplyMinimapStyle()
    end
end

MinimapControls.enabled = CreateCheckbox(
    MinimapPage, "Enable Blackout Minimap", 22, -70,
    function() return MinimapConfig().enabled end,
    function(value)
        MinimapConfig().enabled = value
        ApplyMinimapConfig()
    end
)

MinimapControls.square = CreateCheckbox(
    MinimapPage, "Square Minimap", 22, -102,
    function() return MinimapConfig().square end,
    function(value)
        MinimapConfig().square = value
        ApplyMinimapConfig()
    end
)

MinimapControls.coordinates = CreateCheckbox(
    MinimapPage, "Show Coordinates", 22, -134,
    function() return MinimapConfig().showCoordinates end,
    function(value)
        MinimapConfig().showCoordinates = value
        ApplyMinimapConfig()
    end
)

MinimapControls.zone = CreateCheckbox(
    MinimapPage, "Show Zone Text", 22, -166,
    function() return MinimapConfig().showZoneText end,
    function(value)
        MinimapConfig().showZoneText = value
        ApplyMinimapConfig()
    end
)

MinimapControls.clock = CreateCheckbox(
    MinimapPage, "Show Clock", 22, -198,
    function() return MinimapConfig().showClock end,
    function(value)
        MinimapConfig().showClock = value
        ApplyMinimapConfig()
    end
)

MinimapControls.controlsOnHover = CreateCheckbox(
    MinimapPage, "Show Controls Only On Hover", 22, -230,
    function() return MinimapConfig().controlsOnHover end,
    function(value)
        MinimapConfig().controlsOnHover = value
        ApplyMinimapConfig()
    end
)

MinimapControls.size = CreateStepper(
    MinimapPage, "Minimap Size", 22, -310, 420,
    function() return MinimapConfig().size end,
    function(value)
        MinimapConfig().size = value
        ApplyMinimapConfig()
    end,
    5, 120, 350,
    function(value) return string.format("%d px", value) end
)

MinimapControls.scale = CreateStepper(
    MinimapPage, "Minimap Scale", 22, -342, 420,
    function() return MinimapConfig().scale end,
    function(value)
        MinimapConfig().scale = value
        ApplyMinimapConfig()
    end,
    0.05, 0.50, 2.00,
    function(value) return string.format("%.2f", value) end
)

local minimapNote = BlackoutUI:CreateFont(MinimapPage, 8)
minimapNote:SetPoint("TOPLEFT", MinimapPage, "TOPLEFT", 22, -358)
minimapNote:SetWidth(440)
minimapNote:SetJustifyH("LEFT")
minimapNote:SetText(
    "Mouse wheel over the minimap zooms in/out. Position is handled through /bui move. Tracking remains Blizzard-functional."
)
minimapNote:SetTextColor(unpack(MUTED))

--------------------------------------------------
-- ACTION BARS PAGE
--------------------------------------------------

local ActionBarsPage = CreatePage("actionbars", "ACTION BARS")
local ActionBarControls = {}
local SelectedActionBar = 1
local BarSelectorButtons = {}

local function ActionBarConfig()
    return EnsureConfig().ActionBars
end

local function SelectedBarConfig()
    return ActionBarConfig().bars[SelectedActionBar]
end

local function ApplyActionBarConfig()
    if BlackoutUI.ActionBars and BlackoutUI.ActionBars.ApplyConfig then
        BlackoutUI.ActionBars:ApplyConfig()
    end
end

local selectorTitle = BlackoutUI:CreateFont(ActionBarsPage, 9)
selectorTitle:SetPoint("TOPLEFT", ActionBarsPage, "TOPLEFT", 22, -70)
selectorTitle:SetText("EDIT INDIVIDUAL BAR")
selectorTitle:SetTextColor(unpack(ACCENT))

local GridDescription = BlackoutUI:CreateFont(ActionBarsPage, 9)
GridDescription:SetPoint("TOPLEFT", ActionBarsPage, "TOPLEFT", 22, -335)
GridDescription:SetTextColor(unpack(MUTED))

local function RefreshActionBarPage()
    for _, control in pairs(ActionBarControls) do
        if control.Refresh then control:Refresh() end
    end

    for barID, button in ipairs(BarSelectorButtons) do
        local selected = barID == SelectedActionBar
        button.Text:SetTextColor(
            unpack(selected and ACCENT or TEXT)
        )
        button.Background:SetColorTexture(
            selected and 0.05 or 0.025,
            selected and 0.10 or 0.025,
            selected and 0.13 or 0.025,
            1
        )
    end

    local bar = SelectedBarConfig()
    local columns = math.min(bar.buttonCount, bar.buttonsPerRow)
    local rows = math.ceil(bar.buttonCount / bar.buttonsPerRow)

    GridDescription:SetText(
        string.format(
            "BAR %d LAYOUT:  %d COLUMN%s × %d ROW%s",
            SelectedActionBar,
            columns, columns == 1 and "" or "S",
            rows, rows == 1 and "" or "S"
        )
    )
end

for barID = 1, 5 do
    local button = CreateFrame("Button", nil, ActionBarsPage)
    button:SetSize(58, 28)
    button:SetPoint("TOPLEFT", ActionBarsPage, "TOPLEFT", 22 + ((barID - 1) * 64), -91)

    local b = button:CreateTexture(nil, "BACKGROUND")
    b:SetAllPoints()
    b:SetColorTexture(0.025, 0.025, 0.025, 1)
    button.Background = b
    BlackoutUI:CreateBorder(button, 1, "borderBright")

    local t = BlackoutUI:CreateFont(button, 9)
    t:SetPoint("CENTER")
    t:SetText("BAR " .. barID)
    button.Text = t

    button:SetScript("OnClick", function()
        SelectedActionBar = barID
        RefreshActionBarPage()
    end)

    BarSelectorButtons[barID] = button
end

ActionBarControls.enabled = CreateCheckbox(
    ActionBarsPage, "Enable Selected Bar", 22, -135,
    function() return SelectedBarConfig().enabled end,
    function(value)
        SelectedBarConfig().enabled = value
        ActionBarConfig().visible[SelectedActionBar] = value
        ApplyActionBarConfig()
    end
)

ActionBarControls.buttonCount = CreateStepper(
    ActionBarsPage, "Buttons Shown", 22, -169, 420,
    function() return SelectedBarConfig().buttonCount end,
    function(value)
        local bar = SelectedBarConfig()
        bar.buttonCount = value
        if bar.buttonsPerRow > value then bar.buttonsPerRow = value end
        ApplyActionBarConfig()
        RefreshActionBarPage()
    end,
    1, 1, 12,
    function(value) return string.format("%d", value) end
)

ActionBarControls.perRow = CreateStepper(
    ActionBarsPage, "Buttons Per Row / Columns", 22, -201, 420,
    function() return SelectedBarConfig().buttonsPerRow end,
    function(value)
        local bar = SelectedBarConfig()
        bar.buttonsPerRow = math.min(value, bar.buttonCount)
        ApplyActionBarConfig()
        RefreshActionBarPage()
    end,
    1, 1, 12,
    function(value) return string.format("%d", value) end
)

ActionBarControls.buttonSize = CreateStepper(
    ActionBarsPage, "Button Size", 22, -233, 420,
    function() return SelectedBarConfig().buttonSize end,
    function(value)
        SelectedBarConfig().buttonSize = value
        ApplyActionBarConfig()
    end,
    1, 28, 64,
    function(value) return string.format("%d px", value) end
)

ActionBarControls.spacing = CreateStepper(
    ActionBarsPage, "Button Spacing", 22, -265, 420,
    function() return SelectedBarConfig().spacing end,
    function(value)
        SelectedBarConfig().spacing = value
        ApplyActionBarConfig()
    end,
    1, 0, 12,
    function(value) return string.format("%d px", value) end
)

ActionBarControls.scale = CreateStepper(
    ActionBarsPage, "Individual Bar Scale", 22, -297, 420,
    function() return SelectedBarConfig().scale end,
    function(value)
        SelectedBarConfig().scale = value
        ApplyActionBarConfig()
    end,
    0.05, 0.60, 1.60,
    function(value) return string.format("%.2f", value) end
)

CreateActionButton(
    ActionBarsPage, "RESET SELECTED BAR", 22, -365, 180,
    function()
        if BlackoutUI.ActionBars and BlackoutUI.ActionBars.ResetBar then
            BlackoutUI.ActionBars:ResetBar(SelectedActionBar)
            RefreshActionBarPage()
        end
    end
)

local layoutNote = BlackoutUI:CreateFont(ActionBarsPage, 8)
layoutNote:SetPoint("TOPLEFT", ActionBarsPage, "TOPLEFT", 220, -370)
layoutNote:SetWidth(260)
layoutNote:SetJustifyH("LEFT")
layoutNote:SetText("1 per row = vertical.  12 per row = horizontal.  Use values between them for custom grids.")
layoutNote:SetTextColor(unpack(MUTED))

RefreshActionBarPage()

--------------------------------------------------
-- CLASS BARS PAGE
--------------------------------------------------

local ClassBarsPage =
    CreatePage(
        "classbars",
        "CLASS BARS"
    )

local ClassBarControls = {}
local SelectedClassBar = "stance"

local function ClassBarConfig()
    return EnsureConfig().ClassBars
end

local function SelectedClassConfig()
    return ClassBarConfig()[SelectedClassBar]
end

local function ApplyClassBarConfig()
    if BlackoutUI.ClassBars
        and BlackoutUI.ClassBars.ApplyConfig then
        BlackoutUI.ClassBars:ApplyConfig()
    end
end

local classSelectorTitle =
    BlackoutUI:CreateFont(
        ClassBarsPage,
        9
    )

classSelectorTitle:SetPoint(
    "TOPLEFT",
    ClassBarsPage,
    "TOPLEFT",
    22,
    -70
)

classSelectorTitle:SetText("EDIT CLASS BAR")
classSelectorTitle:SetTextColor(unpack(ACCENT))

local ClassSelectorButtons = {}

local function RefreshClassBarPage()
    for _, control
    in pairs(ClassBarControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for key, button
    in pairs(ClassSelectorButtons) do
        local selected =
            key == SelectedClassBar

        button.Text:SetTextColor(
            unpack(
                selected
                and ACCENT
                or TEXT
            )
        )

        button.Background:SetColorTexture(
            selected and 0.05 or 0.025,
            selected and 0.10 or 0.025,
            selected and 0.13 or 0.025,
            1
        )
    end
end

local classChoices = {
    { "stance", "STANCE / FORM" },
    { "pet",    "PET BAR" },
}

for index, info
in ipairs(classChoices) do
    local key = info[1]

    local button =
        CreateFrame(
            "Button",
            nil,
            ClassBarsPage
        )

    button:SetSize(130, 28)

    button:SetPoint(
        "TOPLEFT",
        ClassBarsPage,
        "TOPLEFT",
        22 + ((index - 1) * 136),
        -91
    )

    local buttonBG =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    buttonBG:SetAllPoints()
    buttonBG:SetColorTexture(
        0.025,
        0.025,
        0.025,
        1
    )

    button.Background =
        buttonBG

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    local text =
        BlackoutUI:CreateFont(
            button,
            9
        )

    text:SetPoint("CENTER")
    text:SetText(info[2])

    button.Text = text

    button:SetScript(
        "OnClick",
        function()
            SelectedClassBar = key
            RefreshClassBarPage()
        end
    )

    ClassSelectorButtons[key] =
        button
end

ClassBarControls.enabled =
    CreateCheckbox(
        ClassBarsPage,
        "Enable Selected Class Bar",
        22,
        -137,
        function()
            return SelectedClassConfig().enabled
        end,
        function(value)
            SelectedClassConfig().enabled =
                value

            ApplyClassBarConfig()
        end
    )

ClassBarControls.buttonSize =
    CreateStepper(
        ClassBarsPage,
        "Button Size",
        22,
        -174,
        420,
        function()
            return SelectedClassConfig().buttonSize
        end,
        function(value)
            SelectedClassConfig().buttonSize =
                value

            ApplyClassBarConfig()
        end,
        1,
        28,
        64,
        function(value)
            return string.format("%d px", value)
        end
    )

ClassBarControls.spacing =
    CreateStepper(
        ClassBarsPage,
        "Button Spacing",
        22,
        -206,
        420,
        function()
            return SelectedClassConfig().spacing
        end,
        function(value)
            SelectedClassConfig().spacing =
                value

            ApplyClassBarConfig()
        end,
        1,
        0,
        12,
        function(value)
            return string.format("%d px", value)
        end
    )

ClassBarControls.scale =
    CreateStepper(
        ClassBarsPage,
        "Bar Scale",
        22,
        -238,
        420,
        function()
            return SelectedClassConfig().scale
        end,
        function(value)
            SelectedClassConfig().scale =
                value

            ApplyClassBarConfig()
        end,
        0.05,
        0.60,
        1.60,
        function(value)
            return string.format("%.2f", value)
        end
    )

ClassBarControls.perRow =
    CreateStepper(
        ClassBarsPage,
        "Buttons Per Row / Columns",
        22,
        -270,
        420,
        function()
            return SelectedClassConfig().buttonsPerRow
        end,
        function(value)
            SelectedClassConfig().buttonsPerRow =
                value

            ApplyClassBarConfig()
        end,
        1,
        1,
        10,
        function(value)
            return string.format("%d", value)
        end
    )

local classLayoutHelp =
    BlackoutUI:CreateFont(
        ClassBarsPage,
        9
    )

classLayoutHelp:SetPoint(
    "TOPLEFT",
    ClassBarsPage,
    "TOPLEFT",
    22,
    -315
)

classLayoutHelp:SetWidth(420)
classLayoutHelp:SetJustifyH("LEFT")
classLayoutHelp:SetText(
    "1 per row creates a vertical bar. "
    .. "Higher values create horizontal or grid layouts."
)

classLayoutHelp:SetTextColor(unpack(MUTED))

CreateActionButton(
    ClassBarsPage,
    "RESET SELECTED CLASS BAR",
    22,
    -355,
    220,
    function()
        if BlackoutUI.ClassBars
            and BlackoutUI.ClassBars.ResetSection then
            BlackoutUI.ClassBars:ResetSection(
                SelectedClassBar
            )

            RefreshClassBarPage()
        end
    end
)

RefreshClassBarPage()

--------------------------------------------------
-- AURAS PAGE
--------------------------------------------------

local AurasPage = CreatePage("auras", "AURAS")
local AuraControls = {}

local function AuraConfig()
    return EnsureConfig().Auras
end

local function SetAuraOption(key, value)
    AuraConfig()[key] = value

    if BlackoutUI.Auras
        and BlackoutUI.Auras.SetOption then
        BlackoutUI.Auras:SetOption(key, value)
    end
end

local auraTitle = BlackoutUI:CreateFont(AurasPage, 9)
auraTitle:SetPoint("TOPLEFT", AurasPage, "TOPLEFT", 22, -70)
auraTitle:SetText("TARGET AURAS")
auraTitle:SetTextColor(unpack(ACCENT))

local function AddAuraCheckbox(key, label, y)
    AuraControls[key] =
        CreateCheckbox(
            AurasPage,
            label,
            22,
            y,
            function()
                return AuraConfig()[key]
            end,
            function(value)
                SetAuraOption(key, value)
            end
        )
end

local function AddAuraStepper(
    key, label, y, step, minimum, maximum, formatter
)
    AuraControls[key] =
        CreateStepper(
            AurasPage,
            label,
            22,
            y,
            420,
            function()
                return AuraConfig()[key]
            end,
            function(value)
                SetAuraOption(key, value)
            end,
            step,
            minimum,
            maximum,
            formatter
        )
end

AddAuraCheckbox("enabled", "Enable Target Auras", -96)
AddAuraCheckbox("showDebuffs", "Show Target Debuffs", -128)
AddAuraCheckbox("showBuffs", "Show Target Buffs", -160)

local layoutTitle = BlackoutUI:CreateFont(AurasPage, 9)
layoutTitle:SetPoint("TOPLEFT", AurasPage, "TOPLEFT", 22, -202)
layoutTitle:SetText("LAYOUT")
layoutTitle:SetTextColor(unpack(ACCENT))

AddAuraStepper("iconSize", "Icon Size", -227, 1, 18, 60,
    function(v) return string.format("%d px", v) end)
AddAuraStepper("spacing", "Icon Spacing", -259, 1, 0, 20,
    function(v) return string.format("%d px", v) end)
AddAuraStepper("iconsPerRow", "Icons Per Row / Columns", -291, 1, 1, 8,
    function(v) return string.format("%d", v) end)
AddAuraStepper("maxDebuffs", "Maximum Debuffs", -323, 1, 1, 8,
    function(v) return string.format("%d", v) end)
AddAuraStepper("maxBuffs", "Maximum Buffs", -355, 1, 1, 8,
    function(v) return string.format("%d", v) end)

local textTitle = BlackoutUI:CreateFont(AurasPage, 9)
textTitle:SetPoint("TOPLEFT", AurasPage, "TOPLEFT", 22, -397)
textTitle:SetText("TEXT")
textTitle:SetTextColor(unpack(ACCENT))

AddAuraCheckbox("showDuration", "Show Duration Text", -422)
AddAuraStepper("durationTextSize", "Duration Text Size", -454, 1, 7, 20,
    function(v) return string.format("%d pt", v) end)
AddAuraCheckbox("showStacks", "Show Stack Count", -491)
AddAuraStepper("stackTextSize", "Stack Count Text Size", -523, 1, 7, 20,
    function(v) return string.format("%d pt", v) end)

local auraHelp = BlackoutUI:CreateFont(AurasPage, 9)
auraHelp:SetPoint("TOPLEFT", AurasPage, "TOPLEFT", 22, -568)
auraHelp:SetWidth(420)
auraHelp:SetJustifyH("LEFT")
auraHelp:SetText(
    "Debuffs remain above buffs. Icons grow right-to-left and "
    .. "wrap into extra rows using the selected column count."
)
auraHelp:SetTextColor(unpack(MUTED))

CreateActionButton(
    AurasPage,
    "RESET AURA SETTINGS",
    22,
    -625,
    205,
    function()
        if BlackoutUI.Auras
            and BlackoutUI.Auras.Reset then
            BlackoutUI.Auras:Reset()
        else
            BlackoutUIDB.Config.Auras = nil
            EnsureConfig()
        end

        for _, control in pairs(AuraControls) do
            if control.Refresh then
                control:Refresh()
            end
        end
    end
)

AurasPage:SetHeight(720)


--------------------------------------------------
-- CAST BARS PAGE
--------------------------------------------------

local CastBarsPage =
    CreatePage(
        "castbars",
        "CAST BARS"
    )

local CastBarControls = {}
local CastSelectorButtons = {}
local SelectedCastBar = "player"

local function CastBarConfig()
    return EnsureConfig().CastBars
end

local function SelectedCastConfig()
    return CastBarConfig()[SelectedCastBar]
end

local function ApplyCastBarConfig()
    if BlackoutUI.CastBars
        and BlackoutUI.CastBars.ApplyConfig then
        BlackoutUI.CastBars:ApplyConfig()
    end
end

local castSelectorTitle =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

castSelectorTitle:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -70
)

castSelectorTitle:SetText("EDIT CAST BAR")
castSelectorTitle:SetTextColor(unpack(ACCENT))

local castChoices = {
    { "player", "PLAYER CAST BAR" },
    { "target", "TARGET CAST BAR" },
}

local function RefreshCastBarPage()
    for _, control
    in pairs(AuraControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(CastBarControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for key, button
    in pairs(CastSelectorButtons) do
        local selected =
            key == SelectedCastBar

        button.Text:SetTextColor(
            unpack(
                selected
                and ACCENT
                or TEXT
            )
        )

        button.Background:SetColorTexture(
            selected and 0.05 or 0.025,
            selected and 0.10 or 0.025,
            selected and 0.13 or 0.025,
            1
        )
    end
end

for index, info
in ipairs(castChoices) do
    local key = info[1]

    local button =
        CreateFrame(
            "Button",
            nil,
            CastBarsPage
        )

    button:SetSize(145, 28)

    button:SetPoint(
        "TOPLEFT",
        CastBarsPage,
        "TOPLEFT",
        22 + ((index - 1) * 151),
        -91
    )

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
        1
    )

    button.Background = bg

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    local text =
        BlackoutUI:CreateFont(
            button,
            9
        )

    text:SetPoint("CENTER")
    text:SetText(info[2])
    button.Text = text

    button:SetScript(
        "OnClick",
        function()
            SelectedCastBar = key
            RefreshCastBarPage()
        end
    )

    CastSelectorButtons[key] = button
end

local function AddCastStepper(
    key,
    label,
    y,
    step,
    minimum,
    maximum,
    formatter
)
    local control =
        CreateStepper(
            CastBarsPage,
            label,
            22,
            y,
            420,
            function()
                return SelectedCastConfig()[key]
            end,
            function(value)
                SelectedCastConfig()[key] = value

                if BlackoutUI.CastBars
                    and BlackoutUI.CastBars.SetOption then
                    BlackoutUI.CastBars:SetOption(
                        SelectedCastBar,
                        key,
                        value
                    )
                else
                    ApplyCastBarConfig()
                end
            end,
            step,
            minimum,
            maximum,
            formatter
        )

    CastBarControls[key] = control
    return control
end

local function AddCastCheckbox(
    key,
    label,
    y
)
    local control =
        CreateCheckbox(
            CastBarsPage,
            label,
            22,
            y,
            function()
                return SelectedCastConfig()[key]
            end,
            function(value)
                SelectedCastConfig()[key] = value

                if BlackoutUI.CastBars
                    and BlackoutUI.CastBars.SetOption then
                    BlackoutUI.CastBars:SetOption(
                        SelectedCastBar,
                        key,
                        value
                    )
                else
                    ApplyCastBarConfig()
                end
            end
        )

    CastBarControls[key] = control
    return control
end

AddCastCheckbox(
    "enabled",
    "Enable Selected Cast Bar",
    -137
)

local sizeTitle =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

sizeTitle:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -178
)

sizeTitle:SetText("SIZE")
sizeTitle:SetTextColor(unpack(ACCENT))

AddCastStepper(
    "width",
    "Bar Width",
    -203,
    5,
    150,
    600,
    function(value)
        return string.format("%d px", value)
    end
)

AddCastStepper(
    "height",
    "Bar Height",
    -235,
    1,
    18,
    60,
    function(value)
        return string.format("%d px", value)
    end
)

AddCastStepper(
    "scale",
    "Cast Bar Scale",
    -267,
    0.05,
    0.60,
    1.60,
    function(value)
        return string.format("%.2f", value)
    end
)

local iconTitle =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

iconTitle:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -308
)

iconTitle:SetText("ICON")
iconTitle:SetTextColor(unpack(ACCENT))

AddCastCheckbox(
    "showIcon",
    "Show Spell Icon",
    -333
)

local textTitle =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

textTitle:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -370
)

textTitle:SetText("TEXT")
textTitle:SetTextColor(unpack(ACCENT))

AddCastCheckbox(
    "showSpellName",
    "Show Spell Name",
    -395
)

AddCastStepper(
    "spellNameSize",
    "Spell Name Size",
    -427,
    1,
    8,
    24,
    function(value)
        return string.format("%d pt", value)
    end
)

AddCastCheckbox(
    "showCastTime",
    "Show Cast Time",
    -464
)

AddCastStepper(
    "castTimeSize",
    "Cast Time Size",
    -496,
    1,
    8,
    24,
    function(value)
        return string.format("%d pt", value)
    end
)

local appearanceTitle =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

appearanceTitle:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -539
)

appearanceTitle:SetText("TARGET INTERRUPT STATUS")
appearanceTitle:SetTextColor(unpack(ACCENT))

local interruptNote =
    BlackoutUI:CreateFont(
        CastBarsPage,
        9
    )

interruptNote:SetPoint(
    "TOPLEFT",
    CastBarsPage,
    "TOPLEFT",
    22,
    -564
)

interruptNote:SetWidth(420)
interruptNote:SetJustifyH("LEFT")
interruptNote:SetText(
    "Target casts automatically use the Blackout interrupt colors: "
    .. "gold for interruptible casts and gray/red for casts that cannot be interrupted."
)
interruptNote:SetTextColor(unpack(MUTED))

CreateActionButton(
    CastBarsPage,
    "RESET SELECTED CAST BAR",
    22,
    -629,
    205,
    function()
        if BlackoutUI.CastBars
            and BlackoutUI.CastBars.ResetSection then
            BlackoutUI.CastBars:ResetSection(
                SelectedCastBar
            )

            EnsureConfig()
            RefreshCastBarPage()
        end
    end
)

CastBarsPage:SetHeight(760)
RefreshCastBarPage()

--------------------------------------------------
-- UTILITY BAR PAGE
--------------------------------------------------

local UtilityPage =
    CreatePage(
        "utility",
        "UTILITY BAR"
    )

local UtilityControls = {}

local function UtilityConfig()
    return EnsureConfig().UtilityBar
end

local function SetUtilityOption(key, value)
    UtilityConfig()[key] = value

    if BlackoutUI.UtilityBar
        and BlackoutUI.UtilityBar.SetOption then
        BlackoutUI.UtilityBar:SetOption(key, value)
    elseif BlackoutUI.UtilityBar
        and BlackoutUI.UtilityBar.ApplyConfig then
        BlackoutUI.UtilityBar:ApplyConfig()
    end
end

local function AddUtilityCheckbox(key, label, y)
    UtilityControls[key] =
        CreateCheckbox(
            UtilityPage,
            label,
            22,
            y,
            function()
                return UtilityConfig()[key]
            end,
            function(value)
                SetUtilityOption(key, value)
            end
        )
end

local utilityTitle =
    BlackoutUI:CreateFont(
        UtilityPage,
        9
    )

utilityTitle:SetPoint(
    "TOPLEFT",
    UtilityPage,
    "TOPLEFT",
    22,
    -70
)

utilityTitle:SetText("UTILITY BAR")
utilityTitle:SetTextColor(unpack(ACCENT))

AddUtilityCheckbox(
    "enabled",
    "Enable Utility Bar",
    -96
)

UtilityControls.scale =
    CreateStepper(
        UtilityPage,
        "Utility Bar Scale",
        22,
        -128,
        420,
        function()
            return UtilityConfig().scale
        end,
        function(value)
            SetUtilityOption("scale", value)
        end,
        0.05,
        0.60,
        1.60,
        function(value)
            return string.format("%.2f", value)
        end
    )

local menuTitle =
    BlackoutUI:CreateFont(
        UtilityPage,
        9
    )

menuTitle:SetPoint(
    "TOPLEFT",
    UtilityPage,
    "TOPLEFT",
    22,
    -177
)

menuTitle:SetText("MICRO MENU BUTTONS")
menuTitle:SetTextColor(unpack(ACCENT))

AddUtilityCheckbox("showCharacter", "Character", -203)
AddUtilityCheckbox("showSpellbook", "Spellbook", -235)
AddUtilityCheckbox("showTalents", "Talents", -267)
AddUtilityCheckbox("showQuest", "Quest Log", -299)
AddUtilityCheckbox("showSocial", "Social", -331)
AddUtilityCheckbox("showMap", "World Map", -363)
AddUtilityCheckbox("showKeyRing", "Key Ring", -395)
AddUtilityCheckbox("showPerformance", "FPS / Latency Meter", -427)

local bagTitle =
    BlackoutUI:CreateFont(
        UtilityPage,
        9
    )

bagTitle:SetPoint(
    "TOPLEFT",
    UtilityPage,
    "TOPLEFT",
    22,
    -476
)

bagTitle:SetText("BAGS")
bagTitle:SetTextColor(unpack(ACCENT))

AddUtilityCheckbox("showBagButton", "Bag Button / Equipped Bag Popup", -502)
AddUtilityCheckbox("showFreeSlots", "Free Bag Slot Counter", -534)

local utilityHelp =
    BlackoutUI:CreateFont(
        UtilityPage,
        9
    )

utilityHelp:SetPoint(
    "TOPLEFT",
    UtilityPage,
    "TOPLEFT",
    22,
    -579
)

utilityHelp:SetWidth(420)
utilityHelp:SetJustifyH("LEFT")
utilityHelp:SetText(
    "The FPS / latency meter keeps its color-coded connection display. "
    .. "Right-click the Bag button to manage equipped bags."
)
utilityHelp:SetTextColor(unpack(MUTED))

CreateActionButton(
    UtilityPage,
    "RESET UTILITY BAR",
    22,
    -635,
    190,
    function()
        if BlackoutUI.UtilityBar
            and BlackoutUI.UtilityBar.Reset then
            BlackoutUI.UtilityBar:Reset()
        else
            BlackoutUIDB.Config.UtilityBar = nil
            EnsureConfig()
        end

        for _, control in pairs(UtilityControls) do
            if control.Refresh then
                control:Refresh()
            end
        end
    end
)

UtilityPage:SetHeight(710)


MakeComingSoonPage(
    "special",
    "SPECIAL ACTIONS",
    "Vehicle, override and extra-action controls will live here."
)

--------------------------------------------------
-- NAVIGATION
--------------------------------------------------

local nav = {
    { "general",    "GENERAL" },
    { "unitframes", "UNIT FRAMES" },
    { "minimap",    "MINIMAP" },
    { "actionbars", "ACTION BARS" },
    { "xp",         "XP TRACKER" },
    { "classbars",  "CLASS BARS" },
    { "auras",      "AURAS" },
    { "castbars",   "CAST BARS" },
    { "utility",    "UTILITY BAR" },
    { "special",    "SPECIAL" },
}

for index, info
in ipairs(nav) do
    CreateNavButton(
        info[1],
        info[2],
        index
    )
end

--------------------------------------------------
-- REFRESH
--------------------------------------------------

local function RefreshConfig()
    EnsureConfig()

    for _, control
    in pairs(MinimapControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(XPControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(ActionBarControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(ClassBarControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(CastBarControls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    for _, control
    in pairs(UtilityControls) do
        if control.Refresh then
            control:Refresh()
        end
    end
end

-- Expose the real local refresh function only after it exists.
BlackoutUI.RefreshConfig = RefreshConfig

ConfigFrame:SetScript(
    "OnShow",
    function()
        RefreshConfig()
        ShowPage("general")
    end
)

--------------------------------------------------
-- /BUI COMMAND
--------------------------------------------------

SLASH_BLACKOUTUI1 = "/bui"

SlashCmdList["BLACKOUTUI"] =
    function(message)
        message =
            string.lower(
                message or ""
            )

        message =
            message:match("^%s*(.-)%s*$")

        if message == "move"
            or message == "grid" then
            ConfigFrame:Hide()

            if PreviousSlashHandler then
                PreviousSlashHandler("")
            end

            return
        end

        if ConfigFrame:IsShown() then
            ConfigFrame:Hide()
        else
            ConfigFrame:Show()
        end
    end

--------------------------------------------------
-- ESCAPE KEY SUPPORT
--------------------------------------------------

table.insert(
    UISpecialFrames,
    "BlackoutUI_ConfigFrame"
)

EnsureConfig()
ShowPage("general")
