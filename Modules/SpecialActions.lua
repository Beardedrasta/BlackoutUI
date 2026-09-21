--------------------------------------------------
-- BLACKOUT UI
-- Modules/SpecialActions.lua
--
-- STEP 10E
-- Extra Action Button + Vehicle Exit support
--
-- Important:
-- We keep Blizzard's underlying protected special-action
-- buttons alive and create Blackout-styled secure click
-- proxies. This avoids replacing protected encounter/
-- vehicle logic with insecure addon code.
--------------------------------------------------

local addonName, BlackoutUI = ...

local BUTTON_SIZE = 44
local BUTTON_SPACING = 4

--------------------------------------------------
-- CONTAINER
--------------------------------------------------

local SpecialBar = CreateFrame(
    "Frame",
    "BlackoutUI_SpecialActionBar",
    UIParent
)

SpecialBar:SetSize(
    (BUTTON_SIZE * 2) + BUTTON_SPACING,
    BUTTON_SIZE
)

SpecialBar:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    0,
    -180
)

SpecialBar:SetFrameStrata("HIGH")

local bg = SpecialBar:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", -4, 4)
bg:SetPoint("BOTTOMRIGHT", 4, -4)
bg:SetColorTexture(0.008, 0.008, 0.008, 0.94)

BlackoutUI:CreateBorder(
    SpecialBar,
    1,
    "borderBright"
)

--------------------------------------------------
-- BUTTON FACTORY
--------------------------------------------------

local function CreateProxyButton(name)
    local button = CreateFrame(
        "CheckButton",
        name,
        SpecialBar,
        "SecureActionButtonTemplate"
    )

    button:SetSize(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

    button:RegisterForClicks(
        "AnyUp",
        "AnyDown"
    )

    button:SetAttribute(
        "useOnKeyDown",
        false
    )

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

    local highlight =
        button:CreateTexture(
            nil,
            "HIGHLIGHT"
        )

    highlight:SetPoint("TOPLEFT", 2, -2)
    highlight:SetPoint("BOTTOMRIGHT", -2, 2)
    highlight:SetColorTexture(
        1,
        1,
        1,
        0.14
    )

    button:SetHighlightTexture(
        highlight
    )

    local pushed =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    pushed:SetPoint("TOPLEFT", 2, -2)
    pushed:SetPoint("BOTTOMRIGHT", -2, 2)
    pushed:SetColorTexture(
        0,
        0,
        0,
        0.30
    )

    button:SetPushedTexture(
        pushed
    )

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    local cooldown = CreateFrame(
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

    button.Cooldown = cooldown

    local hotkey =
        BlackoutUI:CreateFont(
            button,
            8
        )

    hotkey:SetPoint(
        "TOPRIGHT",
        -3,
        -3
    )

    hotkey:SetJustifyH("RIGHT")
    hotkey:SetTextColor(
        0.85,
        0.85,
        0.85,
        1
    )

    button.Hotkey = hotkey

    return button
end

--------------------------------------------------
-- EXTRA ACTION
--------------------------------------------------

local ExtraButton =
    CreateProxyButton(
        "BlackoutUI_ExtraActionButton"
    )

ExtraButton:SetPoint(
    "LEFT",
    SpecialBar,
    "LEFT",
    0,
    0
)

ExtraButton:Hide()

--------------------------------------------------
-- VEHICLE EXIT
--------------------------------------------------

local VehicleButton =
    CreateProxyButton(
        "BlackoutUI_VehicleExitButton"
    )

VehicleButton:SetPoint(
    "LEFT",
    ExtraButton,
    "RIGHT",
    BUTTON_SPACING,
    0
)

VehicleButton:Hide()

--------------------------------------------------
-- VEHICLE EXIT VISUAL
--------------------------------------------------

VehicleButton.Icon:SetTexture(
    "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up"
)

local ExitText =
    BlackoutUI:CreateFont(
        VehicleButton,
        8
    )

ExitText:SetPoint(
    "BOTTOM",
    VehicleButton,
    "BOTTOM",
    0,
    4
)

ExitText:SetText("EXIT")
ExitText:SetTextColor(
    1,
    0.82,
    0.40,
    1
)

--------------------------------------------------
-- SECURE TARGET REFRESH
--------------------------------------------------

local function RefreshSecureTargets()
    if InCombatLockdown() then
        return
    end

    --------------------------------------------------
    -- EXTRA ACTION
    --------------------------------------------------

    if ExtraActionButton1 then
        ExtraButton:SetAttribute(
            "type",
            "click"
        )

        ExtraButton:SetAttribute(
            "clickbutton",
            ExtraActionButton1
        )
    else
        ExtraButton:SetAttribute(
            "type",
            nil
        )

        ExtraButton:SetAttribute(
            "clickbutton",
            nil
        )
    end

    --------------------------------------------------
    -- VEHICLE EXIT
    --------------------------------------------------

    local exitTarget =
        MainMenuBarVehicleLeaveButton
        or OverrideActionBarLeaveFrameLeaveButton
        or VehicleExitButton

    if exitTarget then
        VehicleButton:SetAttribute(
            "type",
            "click"
        )

        VehicleButton:SetAttribute(
            "clickbutton",
            exitTarget
        )
    else
        VehicleButton:SetAttribute(
            "type",
            nil
        )

        VehicleButton:SetAttribute(
            "clickbutton",
            nil
        )
    end
end

--------------------------------------------------
-- EXTRA ACTION VISUALS
--------------------------------------------------

local function GetExtraActionSlot()
    if not HasExtraActionBar
        or not HasExtraActionBar() then
        return nil
    end

    if not GetExtraBarIndex then
        return nil
    end

    local page =
        GetExtraBarIndex()

    if not page then
        return nil
    end

    return 1
        + (
            (page - 1)
            * 12
        )
end

local function UpdateExtraAction()
    local slot =
        GetExtraActionSlot()

    if not slot
        or not HasAction(slot) then
        ExtraButton:Hide()
        return
    end

    ExtraButton:Show()

    ExtraButton.Icon:SetTexture(
        GetActionTexture(slot)
    )

    local start,
    duration,
    enable =
        GetActionCooldown(slot)

    if start
        and duration
        and duration > 0
        and enable ~= 0 then
        ExtraButton.Cooldown:SetCooldown(
            start,
            duration
        )
    else
        ExtraButton.Cooldown:Clear()
    end

    local key =
        GetBindingKey(
            "EXTRAACTIONBUTTON1"
        )

    ExtraButton.Hotkey:SetText(
        key or ""
    )
end

--------------------------------------------------
-- VEHICLE VISIBILITY
--------------------------------------------------

local function CanExitVehicleNow()
    if CanExitVehicle then
        local canExit =
            CanExitVehicle()

        if canExit then
            return true
        end
    end

    if UnitHasVehicleUI
        and UnitHasVehicleUI("player") then
        return true
    end

    return false
end

local function UpdateVehicleExit()
    if CanExitVehicleNow() then
        VehicleButton:Show()
    else
        VehicleButton:Hide()
    end
end

--------------------------------------------------
-- BAR VISIBILITY / SIZE
--------------------------------------------------

local function UpdateContainer()
    local extra =
        ExtraButton:IsShown()

    local vehicle =
        VehicleButton:IsShown()

    if not extra
        and not vehicle then
        SpecialBar:Hide()
        return
    end

    SpecialBar:Show()

    if extra
        and vehicle then
        SpecialBar:SetWidth(
            (BUTTON_SIZE * 2)
            + BUTTON_SPACING
        )

        ExtraButton:ClearAllPoints()
        ExtraButton:SetPoint(
            "LEFT",
            SpecialBar,
            "LEFT",
            0,
            0
        )

        VehicleButton:ClearAllPoints()
        VehicleButton:SetPoint(
            "LEFT",
            ExtraButton,
            "RIGHT",
            BUTTON_SPACING,
            0
        )
    elseif extra then
        SpecialBar:SetWidth(
            BUTTON_SIZE
        )

        ExtraButton:ClearAllPoints()
        ExtraButton:SetPoint(
            "CENTER",
            SpecialBar,
            "CENTER",
            0,
            0
        )
    else
        SpecialBar:SetWidth(
            BUTTON_SIZE
        )

        VehicleButton:ClearAllPoints()
        VehicleButton:SetPoint(
            "CENTER",
            SpecialBar,
            "CENTER",
            0,
            0
        )
    end
end

--------------------------------------------------
-- TOOLTIPS
--------------------------------------------------

ExtraButton:SetScript(
    "OnEnter",
    function(self)
        local slot =
            GetExtraActionSlot()

        if not slot
            or not HasAction(slot) then
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

ExtraButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

VehicleButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(
            self,
            "ANCHOR_RIGHT"
        )

        GameTooltip:SetText(
            "Exit Vehicle",
            0.85,
            0.92,
            1
        )

        GameTooltip:Show()
    end
)

VehicleButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

--------------------------------------------------
-- UPDATE
--------------------------------------------------

local function UpdateAll()
    UpdateExtraAction()
    UpdateVehicleExit()
    UpdateContainer()
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
    "UPDATE_EXTRA_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_UPDATE_COOLDOWN"
)

EventFrame:RegisterEvent(
    "ACTIONBAR_SLOT_CHANGED"
)

EventFrame:RegisterEvent(
    "UNIT_ENTERED_VEHICLE"
)

EventFrame:RegisterEvent(
    "UNIT_EXITED_VEHICLE"
)

EventFrame:RegisterEvent(
    "VEHICLE_UPDATE"
)

EventFrame:RegisterEvent(
    "UPDATE_VEHICLE_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "UPDATE_OVERRIDE_ACTIONBAR"
)

EventFrame:RegisterEvent(
    "UPDATE_POSSESS_BAR"
)

EventFrame:RegisterEvent(
    "PLAYER_REGEN_ENABLED"
)

EventFrame:RegisterEvent(
    "ADDON_LOADED"
)

EventFrame:RegisterEvent(
    "UPDATE_BINDINGS"
)

EventFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        if (
                event == "UNIT_ENTERED_VEHICLE"
                or event == "UNIT_EXITED_VEHICLE"
            )
            and unit
            and unit ~= "player" then
            return
        end

        if event ==
            "PLAYER_ENTERING_WORLD"
            or event ==
            "PLAYER_REGEN_ENABLED"
            or event ==
            "ADDON_LOADED" then
            RefreshSecureTargets()
        end

        UpdateAll()
    end
)

--------------------------------------------------
-- BLACKOUT MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    SpecialBar,
    "SpecialActionBar",
    "SPECIAL / VEHICLE ACTION"
)

--------------------------------------------------
-- INITIAL
--------------------------------------------------

RefreshSecureTargets()
UpdateAll()
