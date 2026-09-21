--------------------------------------------------
-- BLACKOUT UI
-- Modules/UtilityBar.lua
--
-- STEP 10C
-- Blackout Micro Menu + Bag Controls
--
-- This module creates compact Blackout controls while
-- leaving Blizzard's underlying menu/bag functionality
-- intact.
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local BUTTON_SIZE = 30
local BUTTON_SPACING = 2

local UTILITY_DEFAULTS = {
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

local function EnsureUtilityConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.UtilityBar =
        BlackoutUIDB.Config.UtilityBar or {}

    local config = BlackoutUIDB.Config.UtilityBar
    for key, value in pairs(UTILITY_DEFAULTS) do
        if config[key] == nil then
            config[key] = value
        end
    end
    return config
end

local MICRO_BUTTONS = {
    {
        label = "C",
        configKey = "showCharacter",
        tooltip = "Character",
        binding = "TOGGLECHARACTER0",
        click = function()
            ToggleCharacter("PaperDollFrame")
        end,
    },
    {
        label = "S",
        configKey = "showSpellbook",
        tooltip = "Spellbook",
        binding = "TOGGLESPELLBOOK",
        click = function()
            ToggleSpellBook(BOOKTYPE_SPELL)
        end,
    },
    {
        label = "T",
        configKey = "showTalents",
        tooltip = "Talents",
        binding = "TOGGLETALENTS",
        click = function()
            if ToggleTalentFrame then
                ToggleTalentFrame()
            elseif PlayerTalentFrame_Toggle then
                PlayerTalentFrame_Toggle()
            end
        end,
    },
    {
        label = "Q",
        configKey = "showQuest",
        tooltip = "Quest Log / Map",
        binding = "TOGGLEQUESTLOG",
        click = function()
            if ToggleQuestLog then
                ToggleQuestLog()
            elseif ToggleWorldMap then
                ToggleWorldMap()
            end
        end,
    },
    {
        label = "F",
        configKey = "showSocial",
        tooltip = "Social",
        binding = "TOGGLESOCIAL",
        click = function()
            ToggleFriendsFrame(1)
        end,
    },
    {
        label = "M",
        configKey = "showMap",
        tooltip = "World Map",
        binding = "TOGGLEWORLDMAP",
        click = function()
            ToggleWorldMap()
        end,
    },
    {
        label = "K",
        configKey = "showKeyRing",
        tooltip = "Key Ring",
        click = function()
            if ToggleKeyRing then
                ToggleKeyRing()
            elseif KeyRingButton and KeyRingButton:GetScript("OnClick") then
                KeyRingButton:GetScript("OnClick")(KeyRingButton, "LeftButton")
            end
        end,
    },
    {
        label = "0",
        configKey = "showPerformance",
        tooltip = "Performance",
        width = 62,
        performanceMeter = true,
    },
}

--------------------------------------------------
-- MAIN UTILITY FRAME
--------------------------------------------------

local UtilityBar = CreateFrame(
    "Frame",
    "BlackoutUI_UtilityBar",
    UIParent
)

local totalWidth = 0

for _, info in ipairs(MICRO_BUTTONS) do
    totalWidth = totalWidth + (info.width or BUTTON_SIZE)
end

-- Micro buttons + gaps + separator + two bag buttons.
totalWidth =
    totalWidth
    + (BUTTON_SPACING * (#MICRO_BUTTONS - 1))
    + 10
    + BUTTON_SIZE
    + BUTTON_SPACING
    + BUTTON_SIZE

UtilityBar:SetSize(
    totalWidth,
    BUTTON_SIZE
)

UtilityBar:SetPoint(
    "BOTTOMRIGHT",
    UIParent,
    "BOTTOMRIGHT",
    -18,
    18
)

UtilityBar:SetFrameStrata("MEDIUM")

--------------------------------------------------
-- BAR BACKGROUND
--------------------------------------------------

local Background =
    UtilityBar:CreateTexture(
        nil,
        "BACKGROUND"
    )

Background:SetPoint(
    "TOPLEFT",
    UtilityBar,
    "TOPLEFT",
    -4,
    4
)

Background:SetPoint(
    "BOTTOMRIGHT",
    UtilityBar,
    "BOTTOMRIGHT",
    4,
    -4
)

Background:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.94
)

BlackoutUI:CreateBorder(
    UtilityBar,
    1,
    "borderBright"
)

--------------------------------------------------
-- GENERIC BLACKOUT BUTTON
--------------------------------------------------

local function CreateBlackoutButton(
    parent,
    name,
    width,
    label,
    template
)
    local button =
        CreateFrame(
            "Button",
            name,
            parent,
            template
        )

    button:SetSize(
        width or BUTTON_SIZE,
        BUTTON_SIZE
    )

    local bg =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    bg:SetAllPoints()

    bg:SetColorTexture(
        0.018,
        0.018,
        0.018,
        1
    )

    button.Background = bg

    local hover =
        button:CreateTexture(
            nil,
            "HIGHLIGHT"
        )

    hover:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT",
        1,
        -1
    )

    hover:SetPoint(
        "BOTTOMRIGHT",
        button,
        "BOTTOMRIGHT",
        -1,
        1
    )

    hover:SetColorTexture(
        0.18,
        0.55,
        0.82,
        0.20
    )

    button:SetHighlightTexture(hover)

    local pushed =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    pushed:SetPoint(
        "TOPLEFT",
        2,
        -2
    )

    pushed:SetPoint(
        "BOTTOMRIGHT",
        -2,
        2
    )

    pushed:SetColorTexture(
        0,
        0,
        0,
        0.35
    )

    button:SetPushedTexture(pushed)

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    local text =
        BlackoutUI:CreateFont(
            button,
            label == "ESC" and 8 or 10
        )

    text:SetPoint(
        "CENTER",
        button,
        "CENTER",
        0,
        0
    )

    text:SetText(label)

    text:SetTextColor(
        0.78,
        0.88,
        0.96,
        1
    )

    button.Label = text

    return button
end

--------------------------------------------------
-- TOOLTIP
--------------------------------------------------

local function ShowTooltip(
    button,
    title,
    binding
)
    GameTooltip:SetOwner(
        button,
        "ANCHOR_TOP"
    )

    GameTooltip:SetText(
        title,
        0.85,
        0.92,
        1
    )

    if binding then
        local key =
            GetBindingKey(binding)

        if key then
            GameTooltip:AddLine(
                key,
                0.55,
                0.55,
                0.55
            )
        end
    end

    GameTooltip:Show()
end

--------------------------------------------------
-- MICRO MENU BUTTONS
--------------------------------------------------

local previous = nil
local MicroButtons = {}

local function GetLatencyColor(ms)
    ms = tonumber(ms) or 0

    if ms <= 60 then
        return 0.25, 1.00, 0.45
    elseif ms <= 120 then
        return 1.00, 0.85, 0.20
    elseif ms <= 200 then
        return 1.00, 0.50, 0.15
    else
        return 1.00, 0.20, 0.20
    end
end

for index, info
in ipairs(MICRO_BUTTONS) do
    local button =
        CreateBlackoutButton(
            UtilityBar,
            "BlackoutUI_MicroButton" .. index,
            info.width or BUTTON_SIZE,
            info.label
        )

    if not previous then
        button:SetPoint(
            "LEFT",
            UtilityBar,
            "LEFT",
            0,
            0
        )
    else
        button:SetPoint(
            "LEFT",
            previous,
            "RIGHT",
            BUTTON_SPACING,
            0
        )
    end

    if info.performanceMeter then
        local elapsed = 0

        button:SetScript(
            "OnUpdate",
            function(self, delta)
                elapsed = elapsed + delta

                if elapsed < 1 then
                    return
                end

                elapsed = 0

                local fps =
                    math.floor(
                        GetFramerate() + 0.5
                    )

                local _, _, homeMS, worldMS =
                    GetNetStats()

                local latency =
                    worldMS or homeMS or 0

                local r, g, b =
                    GetLatencyColor(latency)

                self.Label:SetText(
                    string.format(
                        "%d | %d",
                        fps,
                        latency
                    )
                )

                self.Label:SetTextColor(
                    r,
                    g,
                    b,
                    1
                )
            end
        )

        button:SetScript(
            "OnEnter",
            function(self)
                local fps =
                    math.floor(
                        GetFramerate() + 0.5
                    )

                local _, _, homeMS, worldMS =
                    GetNetStats()

                GameTooltip:SetOwner(
                    self,
                    "ANCHOR_TOP"
                )

                GameTooltip:SetText(
                    "Performance",
                    0.85,
                    0.92,
                    1
                )

                GameTooltip:AddLine(
                    "FPS: " .. fps,
                    0.75,
                    0.75,
                    0.75
                )

                GameTooltip:AddLine(
                    "Home Latency: "
                    .. tostring(homeMS or 0)
                    .. " ms",
                    0.75,
                    0.75,
                    0.75
                )

                local latency =
                    worldMS or homeMS or 0

                local r, g, b =
                    GetLatencyColor(latency)

                local status =
                    latency <= 60 and "Excellent"
                    or latency <= 120 and "Good"
                    or latency <= 200 and "Elevated"
                    or "High"

                GameTooltip:AddLine(
                    "World Latency: "
                    .. tostring(worldMS or 0)
                    .. " ms",
                    r,
                    g,
                    b
                )

                GameTooltip:AddLine(
                    "Connection: " .. status,
                    r,
                    g,
                    b
                )

                GameTooltip:Show()
            end
        )

        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        )
    else
        button:SetScript(
            "OnClick",
            function()
                if info.click then
                    info.click()
                end
            end
        )
    end

    if not info.performanceMeter then
        button:SetScript(
            "OnEnter",
            function(self)
                ShowTooltip(
                    self,
                    info.tooltip,
                    info.binding
                )
            end
        )

        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        )
    end

    button.UtilityInfo = info
    MicroButtons[index] = button
    previous = button
end

--------------------------------------------------
-- SEPARATOR
--------------------------------------------------

local Separator =
    UtilityBar:CreateTexture(
        nil,
        "ARTWORK"
    )

Separator:SetSize(
    1,
    BUTTON_SIZE - 8
)

Separator:SetPoint(
    "LEFT",
    previous,
    "RIGHT",
    5,
    0
)

Separator:SetColorTexture(
    1,
    1,
    1,
    0.12
)

--------------------------------------------------
-- BAG BUTTON
--------------------------------------------------

-- Forward declaration:
-- BagButton's click handler is created before the popup
-- implementation later in this file, so Lua needs the local
-- variable declared here first.
local ToggleBagPopup

local BagButton =
    CreateBlackoutButton(
        UtilityBar,
        "BlackoutUI_BagButton",
        BUTTON_SIZE,
        "B"
    )

BagButton:SetPoint(
    "LEFT",
    Separator,
    "RIGHT",
    5,
    0
)

BagButton:SetScript(
    "OnClick",
    function(self, mouseButton)
        if mouseButton == "RightButton" then
            ToggleBagPopup()
            return
        end

        if ToggleAllBags then
            ToggleAllBags()
        else
            ToggleBackpack()
        end
    end
)

BagButton:RegisterForClicks(
    "LeftButtonUp",
    "RightButtonUp"
)

BagButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(
            self,
            "ANCHOR_TOP"
        )

        GameTooltip:SetText(
            "Bags",
            0.85,
            0.92,
            1
        )

        GameTooltip:AddLine(
            "Left-click: Toggle all bags",
            0.60,
            0.60,
            0.60
        )

        GameTooltip:AddLine(
            "Right-click: Equipped bag slots",
            0.60,
            0.60,
            0.60
        )

        GameTooltip:Show()
    end
)

BagButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

--------------------------------------------------
-- EQUIPPED BAG POPUP
--
-- Custom Blackout buttons instead of reparenting Blizzard's
-- CharacterBag slots. This prevents Blizzard's layout system
-- from forcing the original bag buttons back onto the bottom bar.
--------------------------------------------------

local BagPopup =
    CreateFrame(
        "Frame",
        "BlackoutUI_BagPopup",
        UIParent
    )

BagPopup:SetSize(
    (BUTTON_SIZE * 4)
    + (BUTTON_SPACING * 3)
    + 12,
    BUTTON_SIZE + 12
)

BagPopup:SetFrameStrata("DIALOG")
BagPopup:SetToplevel(true)
BagPopup:Hide()

table.insert(
    UISpecialFrames,
    "BlackoutUI_BagPopup"
)

local popupBG =
    BagPopup:CreateTexture(
        nil,
        "BACKGROUND"
    )

popupBG:SetAllPoints()
popupBG:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.97
)

BlackoutUI:CreateBorder(
    BagPopup,
    1,
    "borderBright"
)

local BagSlotButtons = {}

-- Return the equipped inventory slot for bag IDs 1-4.
-- Classic 1.15.x exposes the container conversion through
-- C_Container on newer builds, while older Classic code may
-- still expose the global function.
local function GetBagInventorySlot(bagID)
    if C_Container
        and C_Container.ContainerIDToInventoryID then
        return C_Container.ContainerIDToInventoryID(
            bagID
        )
    end

    if ContainerIDToInventoryID then
        return ContainerIDToInventoryID(
            bagID
        )
    end

    -- Final compatibility fallback.
    local slotName =
        "BAG"
        .. tostring(bagID - 1)
        .. "SLOT"

    return GetInventorySlotInfo(
        slotName
    )
end

local function GetEquippedBagTexture(bagID)
    local inventoryID =
        GetBagInventorySlot(bagID)

    if not inventoryID then
        return nil
    end

    return GetInventoryItemTexture(
        "player",
        inventoryID
    )
end

local function UpdateEquippedBagPopup()
    for bagID = 1, 4 do
        local button =
            BagSlotButtons[bagID]

        if button then
            local texture =
                GetEquippedBagTexture(bagID)

            if texture then
                button.Icon:SetTexture(texture)
                button.Icon:SetDesaturated(false)
                button.EmptyText:Hide()
            else
                button.Icon:SetTexture(nil)
                button.EmptyText:Show()
            end
        end
    end
end

for bagID = 1, 4 do
    local button =
        CreateFrame(
            "Button",
            "BlackoutUI_EquippedBag" .. bagID,
            BagPopup
        )

    button:SetSize(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

    button:SetPoint(
        "LEFT",
        BagPopup,
        "LEFT",
        6
        + (
            (bagID - 1)
            * (
                BUTTON_SIZE
                + BUTTON_SPACING
            )
        ),
        0
    )

    local bg =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    bg:SetAllPoints()
    bg:SetColorTexture(
        0.018,
        0.018,
        0.018,
        1
    )

    local icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexCoord(
        0.08,
        0.92,
        0.08,
        0.92
    )

    button.Icon = icon

    local emptyText =
        BlackoutUI:CreateFont(
            button,
            8
        )

    emptyText:SetPoint("CENTER")
    emptyText:SetText("EMPTY")
    emptyText:SetTextColor(
        0.45,
        0.45,
        0.45
    )

    button.EmptyText = emptyText

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    button:RegisterForClicks(
        "LeftButtonUp",
        "RightButtonUp"
    )

    button:RegisterForDrag(
        "LeftButton"
    )

    button:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(
                self,
                "ANCHOR_TOP"
            )

            local inventoryID =
                GetBagInventorySlot(bagID)

            if inventoryID then
                GameTooltip:SetInventoryItem(
                    "player",
                    inventoryID
                )
            else
                GameTooltip:SetText(
                    "Bag Slot " .. bagID
                )
            end

            GameTooltip:Show()
        end
    )

    button:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    local function HandleBagSlot()
        if InCombatLockdown() then
            return
        end

        local inventoryID =
            GetBagInventorySlot(bagID)

        if not inventoryID then
            print(
                "|cff66ccffBlackoutUI:|r "
                .. "Could not resolve equipped bag slot "
                .. tostring(bagID)
            )
            return
        end

        -- PickupBagFromSlot handles BOTH directions:
        -- no cursor item  -> picks up the equipped bag
        -- bag on cursor   -> equips/swaps it into this slot
        if PickupBagFromSlot then
            PickupBagFromSlot(
                inventoryID
            )
        elseif PickupInventoryItem then
            -- Compatibility fallback.
            PickupInventoryItem(
                inventoryID
            )
        end

        C_Timer.After(
            0,
            UpdateEquippedBagPopup
        )
    end

    button:SetScript(
        "OnClick",
        HandleBagSlot
    )

    button:SetScript(
        "OnDragStart",
        HandleBagSlot
    )

    button:SetScript(
        "OnReceiveDrag",
        HandleBagSlot
    )

    BagSlotButtons[bagID] =
        button
end

local function ShowBagPopup()
    if InCombatLockdown() then
        return
    end

    BagPopup:ClearAllPoints()

    BagPopup:SetPoint(
        "BOTTOMRIGHT",
        BagButton,
        "TOPRIGHT",
        0,
        8
    )

    UpdateEquippedBagPopup()
    BagPopup:Show()
end

local function HideBagPopup()
    BagPopup:Hide()
end

ToggleBagPopup = function()
    if BagPopup:IsShown() then
        HideBagPopup()
    else
        ShowBagPopup()
    end
end

--------------------------------------------------
-- BACKPACK FREE-SLOT BUTTON
--------------------------------------------------

local FreeSlotButton =
    CreateBlackoutButton(
        UtilityBar,
        "BlackoutUI_FreeSlotButton",
        BUTTON_SIZE,
        "--"
    )

FreeSlotButton:SetPoint(
    "LEFT",
    BagButton,
    "RIGHT",
    BUTTON_SPACING,
    0
)

FreeSlotButton:SetScript(
    "OnClick",
    function()
        if ToggleAllBags then
            ToggleAllBags()
        else
            ToggleBackpack()
        end
    end
)

--------------------------------------------------
-- BAG SLOT COUNT
--------------------------------------------------

local function GetFreeBagSlots()
    local free = 0
    local total = 0

    -- Backpack + equipped bag slots.
    for bag = 0, NUM_BAG_SLOTS do
        local slots =
            C_Container
            and C_Container.GetContainerNumSlots
            and C_Container.GetContainerNumSlots(bag)
            or GetContainerNumSlots(bag)
            or 0

        local freeSlots =
            C_Container
            and C_Container.GetContainerNumFreeSlots
            and C_Container.GetContainerNumFreeSlots(bag)
            or GetContainerNumFreeSlots(bag)
            or 0

        total =
            total + slots

        free =
            free + freeSlots
    end

    return free, total
end

local function UpdateBagCount()
    local free,
    total =
        GetFreeBagSlots()

    FreeSlotButton.Label:SetText(
        tostring(free)
    )

    if free <= 3 then
        FreeSlotButton.Label:SetTextColor(
            1,
            0.25,
            0.25,
            1
        )
    elseif free <= 8 then
        FreeSlotButton.Label:SetTextColor(
            1,
            0.72,
            0.25,
            1
        )
    else
        FreeSlotButton.Label:SetTextColor(
            0.65,
            0.90,
            0.70,
            1
        )
    end

    FreeSlotButton.freeSlots = free
    FreeSlotButton.totalSlots = total
end

FreeSlotButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(
            self,
            "ANCHOR_TOP"
        )

        GameTooltip:SetText(
            "Bag Space",
            0.85,
            0.92,
            1
        )

        GameTooltip:AddLine(
            string.format(
                "%d free of %d slots",
                self.freeSlots or 0,
                self.totalSlots or 0
            ),
            0.65,
            0.65,
            0.65
        )

        GameTooltip:Show()
    end
)

FreeSlotButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

--------------------------------------------------
-- HIDE BLIZZARD MICRO/BAG CONTROLS
--
-- We preserve their actual functions and frames;
-- they are simply moved to a hidden parent while
-- BlackoutUI provides the visible controls.
--------------------------------------------------

local Hider =
    CreateFrame(
        "Frame",
        "BlackoutUI_UtilityHider",
        UIParent
    )

Hider:Hide()

-- IMPORTANT:
-- Do NOT hide/reparent Blizzard's individual MicroMenu children.
-- Classic's MicroMenuContainer/Edit Mode still enumerates those buttons
-- and expects their anchors to remain valid. Pulling them out causes
-- MicroMenuContainer.lua nil-coordinate layout errors.

local function SuppressBlizzardMicroMenu()
    if InCombatLockdown() then
        return
    end

    local microMenu =
        _G["MicroMenu"]

    if microMenu then
        -- Leave Blizzard's children and anchors intact.
        -- Move only the complete container off-screen.
        microMenu:ClearAllPoints()
        microMenu:SetPoint(
            "TOPLEFT",
            UIParent,
            "BOTTOMLEFT",
            -2000,
            -2000
        )
        microMenu:SetAlpha(0)
    end
end

local BlizzardBagButtons = {
    "MainMenuBarBackpackButton",
    "KeyRingButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
}

local function HideBlizzardBagButtons()
    if InCombatLockdown() then
        return
    end

    for _, name
    in ipairs(BlizzardBagButtons) do
        local frame =
            _G[name]

        if frame then
            frame:Hide()
            frame:SetParent(Hider)
        end
    end
end

local function HideBlizzardUtilities()
    if InCombatLockdown() then
        return
    end

    SuppressBlizzardMicroMenu()
    HideBlizzardBagButtons()
end

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

BlackoutUI.UtilityBar =
    BlackoutUI.UtilityBar or {}

local function LayoutUtilityBar()
    local config = EnsureUtilityConfig()
    local visible = {}

    for _, button in ipairs(MicroButtons) do
        local info = button.UtilityInfo
        local shown =
            config[info.configKey] ~= false

        button:SetShown(shown)

        if shown then
            table.insert(visible, button)
        end
    end

    BagButton:SetShown(config.showBagButton)
    FreeSlotButton:SetShown(config.showFreeSlots)

    local x = 0

    for _, button in ipairs(visible) do
        button:ClearAllPoints()
        button:SetPoint(
            "LEFT",
            UtilityBar,
            "LEFT",
            x,
            0
        )

        x = x + button:GetWidth() + BUTTON_SPACING
    end

    Separator:ClearAllPoints()

    local hasMicro = #visible > 0
    local hasBags =
        config.showBagButton
        or config.showFreeSlots

    if hasMicro and hasBags then
        Separator:Show()
        Separator:SetPoint(
            "LEFT",
            UtilityBar,
            "LEFT",
            x + 3,
            0
        )
        x = x + 10
    else
        Separator:Hide()
    end

    if config.showBagButton then
        BagButton:ClearAllPoints()
        BagButton:SetPoint(
            "LEFT",
            UtilityBar,
            "LEFT",
            x,
            0
        )
        x = x + BagButton:GetWidth() + BUTTON_SPACING
    end

    if config.showFreeSlots then
        FreeSlotButton:ClearAllPoints()
        FreeSlotButton:SetPoint(
            "LEFT",
            UtilityBar,
            "LEFT",
            x,
            0
        )
        x = x + FreeSlotButton:GetWidth() + BUTTON_SPACING
    end

    UtilityBar:SetWidth(
        math.max(BUTTON_SIZE, x > 0 and x - BUTTON_SPACING or BUTTON_SIZE)
    )

    UtilityBar:SetScale(config.scale)

    if config.enabled then
        UtilityBar:Show()
    else
        BagPopup:Hide()
        UtilityBar:Hide()
    end
end

function BlackoutUI.UtilityBar:ApplyConfig()
    LayoutUtilityBar()
end

function BlackoutUI.UtilityBar:SetOption(key, value)
    EnsureUtilityConfig()[key] = value
    LayoutUtilityBar()
end

function BlackoutUI.UtilityBar:Reset()
    BlackoutUIDB.Config.UtilityBar = nil
    EnsureUtilityConfig()
    LayoutUtilityBar()
end

EnsureUtilityConfig()
LayoutUtilityBar()

--------------------------------------------------
-- EVENTS
--------------------------------------------------

local EventFrame =
    CreateFrame("Frame")

EventFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

EventFrame:RegisterEvent(
    "BAG_UPDATE"
)

EventFrame:RegisterEvent(
    "BAG_UPDATE_DELAYED"
)

EventFrame:RegisterEvent(
    "PLAYERBANKSLOTS_CHANGED"
)

EventFrame:RegisterEvent(
    "PLAYER_REGEN_ENABLED"
)

EventFrame:RegisterEvent(
    "ADDON_LOADED"
)

EventFrame:SetScript(
    "OnEvent",
    function(self, event)
        if event == "BAG_UPDATE"
            or event == "BAG_UPDATE_DELAYED"
            or event == "PLAYERBANKSLOTS_CHANGED" then
            UpdateBagCount()
            UpdateEquippedBagPopup()
            return
        end

        if event == "PLAYER_ENTERING_WORLD"
            or event == "PLAYER_REGEN_ENABLED"
            or event == "ADDON_LOADED" then
            HideBlizzardUtilities()
            UpdateBagCount()
            LayoutUtilityBar()
        end
    end
)

--------------------------------------------------
-- BLACKOUT MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    UtilityBar,
    "UtilityBar",
    "MICRO MENU / BAGS"
)

--------------------------------------------------
-- INITIAL
--------------------------------------------------

UpdateBagCount()
HideBlizzardUtilities()
LayoutUtilityBar()
