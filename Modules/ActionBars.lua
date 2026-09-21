--------------------------------------------------
-- BLACKOUT UI
-- Modules/ActionBars.lua
--
-- STEP 9D
-- Five Blackout action bars + direct keybind routing
-- Shift+MouseWheel secure Bar 1 paging
-- Secure bonus/form/possess/vehicle/override paging
-- Bar 1: paged main bar
-- Bar 2: slots 61-72
-- Bar 3: slots 49-60
-- Bar 4: slots 25-36
-- Bar 5: slots 37-48
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local BUTTON_SIZE = 42
local BUTTON_SPACING = 2
local BUTTON_COUNT = 12

local layoutRefreshPending = false

local function EnsureActionBarConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.ActionBars =
        BlackoutUIDB.Config.ActionBars
        or {}

    local config =
        BlackoutUIDB.Config.ActionBars

    if config.buttonSize == nil then
        config.buttonSize = BUTTON_SIZE
    end

    if config.spacing == nil then
        config.spacing = BUTTON_SPACING
    end

    if config.scale == nil then
        config.scale = 1.00
    end

    config.visible =
        config.visible or {}

    config.bars =
        config.bars or {}

    for barID = 1, 5 do
        if config.visible[barID] == nil then
            config.visible[barID] = true
        end

        config.bars[barID] =
            config.bars[barID]
            or {}

        local bar =
            config.bars[barID]

        if bar.enabled == nil then
            bar.enabled = config.visible[barID]
        end

        if bar.buttonCount == nil then
            bar.buttonCount = 12
        end

        if bar.buttonsPerRow == nil then
            bar.buttonsPerRow = 12
        end

        if bar.buttonSize == nil then
            bar.buttonSize = config.buttonSize
        end

        if bar.spacing == nil then
            bar.spacing = config.spacing
        end

        if bar.scale == nil then
            bar.scale = config.scale
        end
    end

    return config
end

local BAR_WIDTH =
    (BUTTON_SIZE * BUTTON_COUNT)
    + (BUTTON_SPACING * (BUTTON_COUNT - 1))

local BAR_HEIGHT = BUTTON_SIZE

--------------------------------------------------
-- STORAGE
--------------------------------------------------

local Bars = {}
local AllButtons = {}

--------------------------------------------------
-- BAR DEFINITIONS
--------------------------------------------------

local BarDefinitions = {

    [1] = {
        name = "BlackoutUI_ActionBar1",
        label = "ACTION BAR 1",
        moverKey = "ActionBar1",
        bindingPrefix = "ACTIONBUTTON",
        paged = true,
        baseSlot = 1,
        y = 70,
    },

    [2] = {
        name = "BlackoutUI_ActionBar2",
        label = "ACTION BAR 2",
        moverKey = "ActionBar2",
        bindingPrefix = "MULTIACTIONBAR1BUTTON",
        paged = false,
        baseSlot = 61,
        y = 114,
    },

    [3] = {
        name = "BlackoutUI_ActionBar3",
        label = "ACTION BAR 3",
        moverKey = "ActionBar3",
        bindingPrefix = "MULTIACTIONBAR2BUTTON",
        paged = false,
        baseSlot = 49,
        y = 158,
    },

    [4] = {
        name = "BlackoutUI_ActionBar4",
        label = "ACTION BAR 4",
        moverKey = "ActionBar4",
        bindingPrefix = "MULTIACTIONBAR3BUTTON",
        paged = false,
        baseSlot = 25,
        y = 202,
    },

    [5] = {
        name = "BlackoutUI_ActionBar5",
        label = "ACTION BAR 5",
        moverKey = "ActionBar5",
        bindingPrefix = "MULTIACTIONBAR4BUTTON",
        paged = false,
        baseSlot = 37,
        y = 246,
    },

}

--------------------------------------------------
-- CREATE BAR
--------------------------------------------------

local function CreateBar(definition, barID)
    local bar = CreateFrame(
        "Frame",
        definition.name,
        UIParent
    )

    bar:SetSize(
        BAR_WIDTH,
        BAR_HEIGHT
    )

    bar:SetPoint(
        "BOTTOM",
        UIParent,
        "BOTTOM",
        0,
        definition.y
    )

    bar:SetFrameStrata("MEDIUM")

    bar.barID = barID
    bar.definition = definition
    bar.BlackoutButtons = {}

    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local background =
        bar:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetPoint(
        "TOPLEFT",
        bar,
        "TOPLEFT",
        -3,
        3
    )

    background:SetPoint(
        "BOTTOMRIGHT",
        bar,
        "BOTTOMRIGHT",
        3,
        -3
    )

    background:SetColorTexture(
        0.008,
        0.008,
        0.008,
        0.92
    )

    bar.Background = background

    Bars[barID] = bar

    return bar
end

for barID = 1, 5 do
    CreateBar(
        BarDefinitions[barID],
        barID
    )
end

--------------------------------------------------
-- KEYBIND OVERRIDE OWNER
--
-- We read the player's EXISTING WoW bindings and
-- temporarily route those same keys to our secure
-- Blackout buttons. We do not rewrite or save the
-- player's actual binding set.
--------------------------------------------------

local BindingOwner = CreateFrame(
    "Frame",
    "BlackoutUI_ActionBarBindingOwner",
    UIParent
)

local bindingsNeedRefresh = false

--------------------------------------------------
-- INVISIBLE SECURE PAGE BUTTONS
--
-- These use SecureActionButtonTemplate's "actionbar"
-- action type, so Shift+MouseWheel can page Bar 1
-- through secure clicks even during combat.
--------------------------------------------------

local PagePreviousButton = CreateFrame(
    "Button",
    "BlackoutUI_ActionPagePrevious",
    UIParent,
    "SecureActionButtonTemplate"
)

PagePreviousButton:SetAttribute(
    "type",
    "actionbar"
)

PagePreviousButton:SetAttribute(
    "action",
    "decrement"
)

PagePreviousButton:RegisterForClicks(
    "AnyUp",
    "AnyDown"
)

local PageNextButton = CreateFrame(
    "Button",
    "BlackoutUI_ActionPageNext",
    UIParent,
    "SecureActionButtonTemplate"
)

PageNextButton:SetAttribute(
    "type",
    "actionbar"
)

PageNextButton:SetAttribute(
    "action",
    "increment"
)

PageNextButton:RegisterForClicks(
    "AnyUp",
    "AnyDown"
)

--------------------------------------------------
-- SHORTEN KEYBIND TEXT
--------------------------------------------------

local function ShortenKeybind(key)
    if not key then
        return ""
    end

    key = key:gsub("SHIFT%-", "S")
    key = key:gsub("CTRL%-", "C")
    key = key:gsub("ALT%-", "A")

    key = key:gsub(
        "MOUSEWHEELUP",
        "MWU"
    )

    key = key:gsub(
        "MOUSEWHEELDOWN",
        "MWD"
    )

    key = key:gsub(
        "BUTTON",
        "M"
    )

    key = key:gsub(
        "NUMPAD",
        "N"
    )

    key = key:gsub(
        "SPACE",
        "SPC"
    )

    return key
end

--------------------------------------------------
-- EFFECTIVE MAIN BAR PAGE
--
-- GetActionBarPage() only reports the player-selected
-- page. Vehicles, possession, temporary shapeshifts and
-- class bonus bars can temporarily replace that page.
--------------------------------------------------

local function GetEffectiveMainBarPage()
    if HasVehicleActionBar
        and HasVehicleActionBar()
        and GetVehicleBarIndex then
        return GetVehicleBarIndex()
    end

    if HasOverrideActionBar
        and HasOverrideActionBar()
        and GetOverrideBarIndex then
        return GetOverrideBarIndex()
    end

    if HasTempShapeshiftActionBar
        and HasTempShapeshiftActionBar()
        and GetTempShapeshiftBarIndex then
        return GetTempShapeshiftBarIndex()
    end

    local bonusOffset =
        GetBonusBarOffset
        and GetBonusBarOffset()
        or 0

    if bonusOffset
        and bonusOffset > 0 then
        return NUM_ACTIONBAR_PAGES
            + bonusOffset
    end

    return GetActionBarPage()
        or 1
end

--------------------------------------------------
-- SECURE MAIN BAR PAGE DRIVER
--
-- Bar 1's secure buttons inherit "actionpage" from the
-- parent. The state driver updates that attribute from
-- secure code, allowing vehicle / possess / form swaps
-- to happen correctly even during combat.
--------------------------------------------------

local function SetupSecureMainBarPaging()
    local bar =
        Bars[1]

    if not bar then
        return
    end

    if InCombatLockdown() then
        return
    end

    bar:SetAttribute(
        "_onstate-page",
        [[
            local page = newstate

            if newstate == "special" then

                if HasVehicleActionBar
                    and HasVehicleActionBar()
                    and GetVehicleBarIndex then

                    page =
                        GetVehicleBarIndex()

                elseif HasOverrideActionBar
                    and HasOverrideActionBar()
                    and GetOverrideBarIndex then

                    page =
                        GetOverrideBarIndex()

                elseif HasTempShapeshiftActionBar
                    and HasTempShapeshiftActionBar()
                    and GetTempShapeshiftBarIndex then

                    page =
                        GetTempShapeshiftBarIndex()

                else

                    local offset =
                        GetBonusBarOffset
                        and GetBonusBarOffset()
                        or 0

                    if offset
                        and offset > 0 then

                        page =
                            NUM_ACTIONBAR_PAGES
                            + offset

                    else

                        page =
                            GetActionBarPage()
                            or 1
                    end
                end
            end

            page =
                tonumber(page)
                or 1

            self:SetAttribute(
                "actionpage",
                page
            )
        ]]
    )

    UnregisterStateDriver(
        bar,
        "page"
    )

    RegisterStateDriver(
        bar,
        "page",
        "[overridebar][vehicleui][possessbar][shapeshift][bonusbar:1][bonusbar:2][bonusbar:3][bonusbar:4][bonusbar:5] special; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; 1"
    )
end

--------------------------------------------------
-- CURRENT MAIN BAR SLOT
--------------------------------------------------

local function GetMainBarActionSlot(index)
    local page =
        GetEffectiveMainBarPage()

    return index
        + ((page - 1) * BUTTON_COUNT)
end

--------------------------------------------------
-- GET BUTTON SLOT
--------------------------------------------------

local function GetButtonSlot(button)
    local definition =
        BarDefinitions[
        button.barID
        ]

    if definition.paged then
        return GetMainBarActionSlot(
            button.buttonIndex
        )
    end

    return button.baseSlot
end

--------------------------------------------------
-- UPDATE KEYBIND LABEL
--------------------------------------------------

local function UpdateHotkey(button)
    local definition =
        BarDefinitions[
        button.barID
        ]

    local command =
        definition.bindingPrefix
        .. button.buttonIndex

    local key1 =
        GetBindingKey(command)

    button.Hotkey:SetText(
        ShortenKeybind(key1)
    )
end

--------------------------------------------------
-- CREATE EQUIPPED BORDER
--------------------------------------------------

local function CreateEquippedBorder(button)
    local border =
        CreateFrame(
            "Frame",
            nil,
            button
        )

    border:SetAllPoints()

    border:SetFrameLevel(
        button:GetFrameLevel() + 4
    )

    local function MakeEdge()
        local texture =
            border:CreateTexture(
                nil,
                "OVERLAY"
            )

        texture:SetColorTexture(
            0.85,
            0.68,
            0.12,
            1
        )

        return texture
    end

    local top = MakeEdge()
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)

    local bottom = MakeEdge()
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(2)

    local left = MakeEdge()
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(2)

    local right = MakeEdge()
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(2)

    border:Hide()

    return border
end

--------------------------------------------------
-- CREATE PROC GLOW
--
-- This is our own lightweight Blackout glow.
-- We do not rely on Blizzard's action-button
-- overlay frame for our custom buttons.
--------------------------------------------------

local function CreateProcGlow(button)
    local glow =
        CreateFrame(
            "Frame",
            nil,
            button
        )

    glow:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT",
        -2,
        2
    )

    glow:SetPoint(
        "BOTTOMRIGHT",
        button,
        "BOTTOMRIGHT",
        2,
        -2
    )

    glow:SetFrameLevel(
        button:GetFrameLevel() + 8
    )

    local pulse =
        glow:CreateTexture(
            nil,
            "OVERLAY"
        )

    pulse:SetAllPoints()

    pulse:SetColorTexture(
        1.00,
        0.72,
        0.12,
        0.16
    )

    glow.Pulse = pulse

    local function MakeEdge()
        local texture =
            glow:CreateTexture(
                nil,
                "OVERLAY"
            )

        texture:SetColorTexture(
            1.00,
            0.72,
            0.12,
            1
        )

        return texture
    end

    local top = MakeEdge()
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)

    local bottom = MakeEdge()
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(2)

    local left = MakeEdge()
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(2)

    local right = MakeEdge()
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(2)

    glow.elapsed = 0

    glow:SetScript(
        "OnUpdate",
        function(self, elapsed)
            self.elapsed =
                self.elapsed + elapsed

            local alpha =
                0.10
                + (
                    (
                        math.sin(
                            self.elapsed * 5
                        )
                        + 1
                    )
                    * 0.08
                )

            self.Pulse:SetAlpha(alpha)
        end
    )

    glow:Hide()

    return glow
end

--------------------------------------------------
-- CREATE BUTTON
--------------------------------------------------

local function CreateActionButton(
    parent,
    index,
    baseSlot,
    barID
)
    local button =
        CreateFrame(
            "CheckButton",
            parent:GetName()
            .. "Button"
            .. index,
            parent,
            "SecureActionButtonTemplate"
        )

    button:SetSize(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

    button.buttonIndex = index
    button.baseSlot = baseSlot
    button.barID = barID
    button.actionSlot = baseSlot
    button.procSpellID = nil

    -- A positive button ID enables WoW's secure action-page
    -- calculation for Bar 1.
    if BarDefinitions[barID].paged then
        button:SetID(index)
    end

    --------------------------------------------------
    -- POSITION
    --------------------------------------------------

    if index == 1 then
        button:SetPoint(
            "LEFT",
            parent,
            "LEFT",
            0,
            0
        )
    else
        button:SetPoint(
            "LEFT",
            parent.BlackoutButtons[index - 1],
            "RIGHT",
            BUTTON_SPACING,
            0
        )
    end

    --------------------------------------------------
    -- SECURE ACTION
    --------------------------------------------------

    button:SetAttribute(
        "type",
        "action"
    )

    button:SetAttribute(
        "action",
        baseSlot
    )

    if BarDefinitions[barID].paged then
        button:SetAttribute(
            "useparent-actionpage",
            true
        )
    end

    button:SetAttribute(
        "useOnKeyDown",
        false
    )

    button:RegisterForClicks(
        "AnyUp",
        "AnyDown"
    )

    --------------------------------------------------
    -- DRAGGING
    --------------------------------------------------

    button:EnableMouse(true)

    button:RegisterForDrag(
        "LeftButton"
    )

    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local background =
        button:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    background:SetColorTexture(
        0.012,
        0.012,
        0.012,
        1
    )

    button.Background =
        background

    --------------------------------------------------
    -- EMPTY SLOT INNER PANEL
    --------------------------------------------------

    local empty =
        button:CreateTexture(
            nil,
            "BORDER"
        )

    empty:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT",
        3,
        -3
    )

    empty:SetPoint(
        "BOTTOMRIGHT",
        button,
        "BOTTOMRIGHT",
        -3,
        3
    )

    empty:SetColorTexture(
        0.035,
        0.035,
        0.035,
        1
    )

    button.Empty =
        empty

    --------------------------------------------------
    -- ICON
    --------------------------------------------------

    local icon =
        button:CreateTexture(
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

    button.Icon = icon

    --------------------------------------------------
    -- DARK OVERLAY
    --------------------------------------------------

    local dark =
        button:CreateTexture(
            nil,
            "OVERLAY"
        )

    dark:SetPoint(
        "TOPLEFT",
        icon,
        "TOPLEFT"
    )

    dark:SetPoint(
        "BOTTOMRIGHT",
        icon,
        "BOTTOMRIGHT"
    )

    dark:SetColorTexture(
        0,
        0,
        0,
        0
    )

    button.Dark = dark

    --------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------

    local highlight =
        button:CreateTexture(
            nil,
            "HIGHLIGHT"
        )

    highlight:SetPoint(
        "TOPLEFT",
        2,
        -2
    )

    highlight:SetPoint(
        "BOTTOMRIGHT",
        -2,
        2
    )

    highlight:SetColorTexture(
        1,
        1,
        1,
        0.12
    )

    button:SetHighlightTexture(
        highlight
    )

    --------------------------------------------------
    -- PUSHED
    --------------------------------------------------

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
        0.28
    )

    button:SetPushedTexture(
        pushed
    )

    --------------------------------------------------
    -- ACTIVE / CHECKED
    --------------------------------------------------

    local checked =
        button:CreateTexture(
            nil,
            "OVERLAY"
        )

    checked:SetPoint(
        "TOPLEFT",
        1,
        -1
    )

    checked:SetPoint(
        "BOTTOMRIGHT",
        -1,
        1
    )

    checked:SetColorTexture(
        0.85,
        0.70,
        0.15,
        0.22
    )

    button:SetCheckedTexture(
        checked
    )

    --------------------------------------------------
    -- BORDER
    --------------------------------------------------

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    --------------------------------------------------
    -- EQUIPPED BORDER
    --------------------------------------------------

    button.EquippedBorder =
        CreateEquippedBorder(
            button
        )

    --------------------------------------------------
    -- COOLDOWN
    --------------------------------------------------

    local cooldown =
        CreateFrame(
            "Cooldown",
            nil,
            button,
            "CooldownFrameTemplate"
        )

    cooldown:SetPoint(
        "TOPLEFT",
        icon,
        "TOPLEFT"
    )

    cooldown:SetPoint(
        "BOTTOMRIGHT",
        icon,
        "BOTTOMRIGHT"
    )

    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetReverse(false)

    button.Cooldown =
        cooldown

    --------------------------------------------------
    -- HOTKEY
    --------------------------------------------------

    local hotkey =
        BlackoutUI:CreateFont(
            button,
            9
        )

    hotkey:SetPoint(
        "TOPRIGHT",
        -3,
        -3
    )

    hotkey:SetJustifyH(
        "RIGHT"
    )

    hotkey:SetTextColor(
        0.85,
        0.85,
        0.85,
        1
    )

    button.Hotkey = hotkey

    --------------------------------------------------
    -- COUNT
    --------------------------------------------------

    local count =
        BlackoutUI:CreateFont(
            button,
            10
        )

    count:SetPoint(
        "BOTTOMRIGHT",
        -3,
        3
    )

    count:SetJustifyH(
        "RIGHT"
    )

    button.Count = count

    --------------------------------------------------
    -- PROC GLOW
    --------------------------------------------------

    button.ProcGlow =
        CreateProcGlow(
            button
        )

    --------------------------------------------------
    -- TOOLTIP
    --------------------------------------------------

    button:SetScript(
        "OnEnter",
        function(self)
            local slot =
                GetButtonSlot(self)

            self.actionSlot = slot

            if not HasAction(slot) then
                return
            end

            GameTooltip:SetOwner(
                self,
                "ANCHOR_RIGHT"
            )

            GameTooltip:SetAction(slot)
            GameTooltip:Show()
        end
    )

    button:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    --------------------------------------------------
    -- DRAG ACTION
    --------------------------------------------------

    button:SetScript(
        "OnDragStart",
        function(self)
            if InCombatLockdown() then
                return
            end

            local slot =
                GetButtonSlot(self)

            self.actionSlot = slot

            PickupAction(slot)
        end
    )

    --------------------------------------------------
    -- DROP ACTION
    --------------------------------------------------

    button:SetScript(
        "OnReceiveDrag",
        function(self)
            if InCombatLockdown() then
                return
            end

            local slot =
                GetButtonSlot(self)

            self.actionSlot = slot

            PlaceAction(slot)
        end
    )

    parent.BlackoutButtons[index] =
        button

    table.insert(
        AllButtons,
        button
    )

    return button
end

--------------------------------------------------
-- CREATE ALL BUTTONS
--------------------------------------------------

for barID = 1, 5 do
    local definition =
        BarDefinitions[barID]

    local bar =
        Bars[barID]

    for index = 1, BUTTON_COUNT do
        local slot

        if definition.paged then
            slot = index
        else
            slot =
                definition.baseSlot
                + index
                - 1
        end

        CreateActionButton(
            bar,
            index,
            slot,
            barID
        )
    end
end

--------------------------------------------------
-- UPDATE SECURE ACTION SLOTS
--------------------------------------------------

local function UpdateSecureActionSlots()
    if InCombatLockdown() then
        return
    end

    for _, button
    in ipairs(AllButtons) do
        local slot =
            GetButtonSlot(button)

        button.actionSlot = slot

        local definition =
            BarDefinitions[
            button.barID
            ]

        -- Fixed bars use a fixed secure action slot.
        -- Bar 1 uses button ID + inherited secure actionpage.
        if not definition.paged then
            button:SetAttribute(
                "action",
                slot
            )
        end
    end
end

--------------------------------------------------
-- UPDATE COOLDOWN
--------------------------------------------------

local function UpdateCooldown(button)
    local start,
    duration,
    enable =
        GetActionCooldown(
            button.actionSlot
        )

    if start
        and duration
        and duration > 0
        and enable ~= 0 then
        button.Cooldown:SetCooldown(
            start,
            duration
        )
    else
        button.Cooldown:Clear()
    end
end

--------------------------------------------------
-- GET SPELL ID FOR PROC GLOW
--------------------------------------------------

local function GetButtonSpellID(button)
    local slot =
        button.actionSlot

    if not slot
        or not HasAction(slot) then
        return nil
    end

    local actionType,
    id =
        GetActionInfo(slot)

    if actionType == "spell" then
        return id
    end

    if actionType == "macro"
        and id
        and GetMacroSpell then
        local _, _, spellID =
            GetMacroSpell(id)

        return spellID
    end

    return nil
end

--------------------------------------------------
-- UPDATE PROC GLOW
--------------------------------------------------

local function UpdateProcGlow(button)
    local spellID =
        GetButtonSpellID(button)

    button.procSpellID =
        spellID

    if spellID
        and IsSpellOverlayed
        and IsSpellOverlayed(
            spellID
        ) then
        button.ProcGlow:Show()
    else
        button.ProcGlow:Hide()
    end
end

--------------------------------------------------
-- UPDATE ONE BUTTON
--------------------------------------------------

local function UpdateButton(button)
    local slot =
        GetButtonSlot(button)

    button.actionSlot = slot

    --------------------------------------------------
    -- EMPTY
    --------------------------------------------------

    if not HasAction(slot) then
        button.Icon:SetTexture(nil)

        button.Icon:SetVertexColor(
            1,
            1,
            1
        )

        button.Dark:SetColorTexture(
            0,
            0,
            0,
            0
        )

        button.Empty:Show()
        button.Count:SetText("")
        button:SetChecked(false)
        button.EquippedBorder:Hide()
        button.ProcGlow:Hide()
        button.Cooldown:Clear()

        button:SetAlpha(0.72)

        UpdateHotkey(button)

        return
    end

    --------------------------------------------------
    -- HAS ACTION
    --------------------------------------------------

    button.Empty:Hide()

    button.Icon:SetTexture(
        GetActionTexture(slot)
    )

    button:SetAlpha(1)

    --------------------------------------------------
    -- COUNT
    --------------------------------------------------

    local count =
        GetActionCount(slot)

    if count
        and count > 1 then
        button.Count:SetText(
            count
        )
    else
        button.Count:SetText("")
    end

    --------------------------------------------------
    -- ACTIVE STATE
    --------------------------------------------------

    button:SetChecked(
        IsCurrentAction(slot)
        or IsAutoRepeatAction(slot)
    )

    --------------------------------------------------
    -- EQUIPPED ITEM
    --------------------------------------------------

    if IsEquippedAction(slot) then
        button.EquippedBorder:Show()
    else
        button.EquippedBorder:Hide()
    end

    --------------------------------------------------
    -- USABILITY
    --------------------------------------------------

    local usable,
    noMana =
        IsUsableAction(slot)

    if usable then
        button.Icon:SetVertexColor(
            1,
            1,
            1
        )

        button.Dark:SetColorTexture(
            0,
            0,
            0,
            0
        )
    elseif noMana then
        button.Icon:SetVertexColor(
            0.45,
            0.55,
            1
        )

        button.Dark:SetColorTexture(
            0,
            0,
            0,
            0.15
        )
    else
        button.Icon:SetVertexColor(
            0.45,
            0.45,
            0.45
        )

        button.Dark:SetColorTexture(
            0,
            0,
            0,
            0.30
        )
    end

    --------------------------------------------------
    -- RANGE
    --------------------------------------------------

    local inRange =
        IsActionInRange(slot)

    if inRange == false then
        button.Hotkey:SetTextColor(
            1,
            0.18,
            0.18,
            1
        )
    else
        button.Hotkey:SetTextColor(
            0.85,
            0.85,
            0.85,
            1
        )
    end

    --------------------------------------------------
    -- KEYBIND
    --------------------------------------------------

    UpdateHotkey(button)

    --------------------------------------------------
    -- COOLDOWN
    --------------------------------------------------

    UpdateCooldown(button)

    --------------------------------------------------
    -- PROC GLOW
    --------------------------------------------------

    UpdateProcGlow(button)
end

--------------------------------------------------
-- UPDATE ALL BUTTONS
--------------------------------------------------

local function UpdateAllButtons()
    for _, button
    in ipairs(AllButtons) do
        UpdateButton(button)
    end
end

--------------------------------------------------
-- UPDATE PROC GLOWS ONLY
--------------------------------------------------

local function UpdateAllProcGlows()
    for _, button
    in ipairs(AllButtons) do
        UpdateProcGlow(button)
    end
end

--------------------------------------------------
-- APPLY BLACKOUT KEYBIND OVERRIDES
--
-- SetOverrideBindingClick is protected from changes
-- during combat, so updates are deferred until combat
-- ends. Existing WoW bindings are only READ here.
--------------------------------------------------

local function ApplyBlackoutBindings()
    if InCombatLockdown() then
        bindingsNeedRefresh = true
        return
    end

    bindingsNeedRefresh = false

    ClearOverrideBindings(
        BindingOwner
    )

    --------------------------------------------------
    -- BLACKOUT PAGE SWITCHING
    --
    -- Normal wheel remains untouched.
    -- Only Shift+Wheel is overridden.
    --------------------------------------------------

    SetOverrideBindingClick(
        BindingOwner,
        true,
        "SHIFT-MOUSEWHEELUP",
        PagePreviousButton:GetName(),
        "LeftButton"
    )

    SetOverrideBindingClick(
        BindingOwner,
        true,
        "SHIFT-MOUSEWHEELDOWN",
        PageNextButton:GetName(),
        "LeftButton"
    )

    for barID = 1, 5 do
        local definition =
            BarDefinitions[barID]

        local bar =
            Bars[barID]

        for index = 1, BUTTON_COUNT do
            local command =
                definition.bindingPrefix
                .. index

            local keys = {
                GetBindingKey(command)
            }

            local button =
                bar.BlackoutButtons[index]

            for _, key
            in ipairs(keys) do
                if key
                    and key ~= "" then
                    SetOverrideBindingClick(
                        BindingOwner,
                        true,
                        key,
                        button:GetName(),
                        "LeftButton"
                    )
                end
            end
        end
    end
end

--------------------------------------------------
-- EVENTS
--------------------------------------------------

local EventFrame =
    CreateFrame("Frame")

EventFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_SLOT_CHANGED"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_UPDATE_USABLE"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_UPDATE_STATE"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_UPDATE_COOLDOWN"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_PAGE_CHANGED"
)

EventFrame:RegisterEvent(
    "UPDATE_BONUS_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "UPDATE_OVERRIDE_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "UPDATE_VEHICLE_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "UPDATE_POSSESS_BAR"
)

EventFrame:RegisterEvent(
    "UPDATE_SHAPESHIFT_FORM"
)

EventFrame:RegisterEvent(
    "UPDATE_SHAPESHIFT_FORMS"
)

EventFrame:RegisterEvent(
    "UNIT_ENTERED_VEHICLE"
)

EventFrame:RegisterEvent(
    "UNIT_EXITED_VEHICLE"
)

EventFrame:RegisterEvent(
    "UPDATE_BINDINGS"
)

EventFrame:RegisterEvent(
    "PLAYER_TARGET_CHANGED"
)

EventFrame:RegisterEvent(
    "SPELL_UPDATE_USABLE"
)

EventFrame:RegisterEvent(
    "BAG_UPDATE"
)

EventFrame:RegisterEvent(
    "PLAYER_EQUIPMENT_CHANGED"
)

EventFrame:RegisterEvent(
    "PLAYER_REGEN_ENABLED"
)

EventFrame:RegisterEvent(
    "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"
)

EventFrame:RegisterEvent(
    "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE"
)

--------------------------------------------------
-- EVENT HANDLER
--------------------------------------------------

EventFrame:SetScript(
    "OnEvent",
    function(self, event)
        --------------------------------------------------
        -- UPDATE SECURE SLOTS WHEN SAFE
        --------------------------------------------------

        if event == "PLAYER_ENTERING_WORLD"
            or event == "ACTIONBAR_PAGE_CHANGED"
            or event == "UPDATE_BONUS_ACTIONBAR"
            or event == "UPDATE_OVERRIDE_ACTIONBAR"
            or event == "UPDATE_VEHICLE_ACTIONBAR"
            or event == "UPDATE_POSSESS_BAR"
            or event == "UPDATE_SHAPESHIFT_FORM"
            or event == "UPDATE_SHAPESHIFT_FORMS"
            or event == "UNIT_ENTERED_VEHICLE"
            or event == "UNIT_EXITED_VEHICLE"
            or event == "PLAYER_REGEN_ENABLED" then
            SetupSecureMainBarPaging()
            UpdateSecureActionSlots()
        end

        --------------------------------------------------
        -- KEYBIND ROUTING
        --------------------------------------------------

        if event == "PLAYER_ENTERING_WORLD"
            or event == "UPDATE_BINDINGS"
            or event == "PLAYER_REGEN_ENABLED" then
            ApplyBlackoutBindings()
        end

        if event == "PLAYER_REGEN_ENABLED"
            and layoutRefreshPending then
            ApplyActionBarLayout()
        end

        --------------------------------------------------
        -- PROC EVENTS
        --------------------------------------------------

        if event ==
            "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"
            or event ==
            "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
            UpdateAllProcGlows()

            return
        end

        --------------------------------------------------
        -- NORMAL REFRESH
        --------------------------------------------------

        UpdateAllButtons()
    end
)

--------------------------------------------------
-- LIGHTWEIGHT RANGE / USABILITY UPDATE
--------------------------------------------------

local elapsedSinceUpdate = 0

local UpdateDriver =
    CreateFrame("Frame")

UpdateDriver:SetScript(
    "OnUpdate",
    function(self, elapsed)
        elapsedSinceUpdate =
            elapsedSinceUpdate + elapsed

        if elapsedSinceUpdate < 0.20 then
            return
        end

        elapsedSinceUpdate = 0

        for _, button
        in ipairs(AllButtons) do
            if HasAction(
                    button.actionSlot
                ) then
                --------------------------------------------------
                -- RANGE
                --------------------------------------------------

                local inRange =
                    IsActionInRange(
                        button.actionSlot
                    )

                if inRange == false then
                    button.Hotkey:SetTextColor(
                        1,
                        0.18,
                        0.18,
                        1
                    )
                else
                    button.Hotkey:SetTextColor(
                        0.85,
                        0.85,
                        0.85,
                        1
                    )
                end

                --------------------------------------------------
                -- USABILITY
                --------------------------------------------------

                local usable,
                noMana =
                    IsUsableAction(
                        button.actionSlot
                    )

                if usable then
                    button.Icon:SetVertexColor(
                        1,
                        1,
                        1
                    )

                    button.Dark:SetColorTexture(
                        0,
                        0,
                        0,
                        0
                    )
                elseif noMana then
                    button.Icon:SetVertexColor(
                        0.45,
                        0.55,
                        1
                    )

                    button.Dark:SetColorTexture(
                        0,
                        0,
                        0,
                        0.15
                    )
                else
                    button.Icon:SetVertexColor(
                        0.45,
                        0.45,
                        0.45
                    )

                    button.Dark:SetColorTexture(
                        0,
                        0,
                        0,
                        0.30
                    )
                end
            end
        end
    end
)

--------------------------------------------------
-- CONFIGURABLE LAYOUT
--------------------------------------------------

local function ApplyActionBarLayout()
    if InCombatLockdown() then
        layoutRefreshPending = true
        return
    end

    layoutRefreshPending = false

    local config =
        EnsureActionBarConfig()

    for barID = 1, 5 do
        local bar =
            Bars[barID]

        local settings =
            config.bars[barID]

        local buttonCount =
            math.max(
                1,
                math.min(
                    BUTTON_COUNT,
                    tonumber(settings.buttonCount)
                    or BUTTON_COUNT
                )
            )

        local perRow =
            math.max(
                1,
                math.min(
                    buttonCount,
                    tonumber(settings.buttonsPerRow)
                    or buttonCount
                )
            )

        local size =
            math.max(
                28,
                math.min(
                    64,
                    tonumber(settings.buttonSize)
                    or BUTTON_SIZE
                )
            )

        local spacing =
            math.max(
                0,
                math.min(
                    12,
                    tonumber(settings.spacing)
                    or BUTTON_SPACING
                )
            )

        local scale =
            math.max(
                0.60,
                math.min(
                    1.60,
                    tonumber(settings.scale)
                    or 1
                )
            )

        settings.buttonCount = buttonCount
        settings.buttonsPerRow = perRow
        settings.buttonSize = size
        settings.spacing = spacing
        settings.scale = scale

        local columns =
            math.min(
                perRow,
                buttonCount
            )

        local rows =
            math.ceil(
                buttonCount / perRow
            )

        local width =
            (columns * size)
            + (
                math.max(0, columns - 1)
                * spacing
            )

        local height =
            (rows * size)
            + (
                math.max(0, rows - 1)
                * spacing
            )

        bar:SetScale(scale)
        bar:SetSize(width, height)

        for index = 1, BUTTON_COUNT do
            local button =
                bar.BlackoutButtons[index]

            button:SetSize(size, size)
            button:ClearAllPoints()

            if index <= buttonCount then
                local zeroIndex =
                    index - 1

                local column =
                    zeroIndex % perRow

                local row =
                    math.floor(
                        zeroIndex / perRow
                    )

                button:SetPoint(
                    "TOPLEFT",
                    bar,
                    "TOPLEFT",
                    column * (size + spacing),
                    -(row * (size + spacing))
                )

                button:Show()
            else
                button:Hide()
            end
        end

        local enabled =
            settings.enabled ~= false

        config.visible[barID] =
            enabled

        bar:SetShown(enabled)
    end
end

BlackoutUI.ActionBars =
    BlackoutUI.ActionBars or {}

function BlackoutUI.ActionBars:ApplyConfig()
    ApplyActionBarLayout()
end

function BlackoutUI.ActionBars:ResetConfig()
    BlackoutUIDB =
        BlackoutUIDB or {}

    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    local bars = {}

    for barID = 1, 5 do
        bars[barID] = {
            enabled = true,
            buttonCount = 12,
            buttonsPerRow = 12,
            buttonSize = BUTTON_SIZE,
            spacing = BUTTON_SPACING,
            scale = 1.00,
        }
    end

    BlackoutUIDB.Config.ActionBars = {
        buttonSize = BUTTON_SIZE,
        spacing = BUTTON_SPACING,
        scale = 1.00,
        visible = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
        },
        bars = bars,
    }

    ApplyActionBarLayout()
end

function BlackoutUI.ActionBars:ResetBar(barID)
    local config =
        EnsureActionBarConfig()

    config.bars[barID] = {
        enabled = true,
        buttonCount = 12,
        buttonsPerRow = 12,
        buttonSize = BUTTON_SIZE,
        spacing = BUTTON_SPACING,
        scale = 1.00,
    }

    config.visible[barID] = true

    ApplyActionBarLayout()
end

--------------------------------------------------
-- BLACKOUT MOVERS
--------------------------------------------------

for barID = 1, 5 do
    local bar =
        Bars[barID]

    local definition =
        BarDefinitions[barID]

    BlackoutUI:RegisterMovableFrame(
        bar,
        definition.moverKey,
        definition.label
    )
end

--------------------------------------------------
-- INITIAL SETUP
--------------------------------------------------

SetupSecureMainBarPaging()
UpdateSecureActionSlots()
ApplyBlackoutBindings()
ApplyActionBarLayout()
UpdateAllButtons()
