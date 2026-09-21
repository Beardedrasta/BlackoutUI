--------------------------------------------------
-- BLACKOUT UI
-- Modules/ClassBars.lua
--
-- STEP 10D
-- Blackout Stance/Form Bar + Pet Bar
--
-- Stance buttons securely cast the current stance/form
-- spell. Pet buttons use SecureActionButtonTemplate's
-- native "pet" action type.
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local BUTTON_SIZE = 38
local BUTTON_SPACING = 2
local MAX_STANCE_BUTTONS = 10
local MAX_PET_BUTTONS = 10

local classLayoutPending = false

local function EnsureClassBarConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.ClassBars =
        BlackoutUIDB.Config.ClassBars or {}

    local config = BlackoutUIDB.Config.ClassBars

    config.stance = config.stance or {}
    config.pet = config.pet or {}

    local stance = config.stance
    local pet = config.pet

    if stance.enabled == nil then stance.enabled = true end
    if stance.buttonSize == nil then stance.buttonSize = BUTTON_SIZE end
    if stance.spacing == nil then stance.spacing = BUTTON_SPACING end
    if stance.scale == nil then stance.scale = 1.00 end
    if stance.buttonsPerRow == nil then stance.buttonsPerRow = 10 end

    if pet.enabled == nil then pet.enabled = true end
    if pet.buttonSize == nil then pet.buttonSize = BUTTON_SIZE end
    if pet.spacing == nil then pet.spacing = BUTTON_SPACING end
    if pet.scale == nil then pet.scale = 1.00 end
    if pet.buttonsPerRow == nil then pet.buttonsPerRow = 10 end

    return config
end

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function SetCooldown(
    cooldown,
    start,
    duration,
    enable
)
    if start
        and duration
        and duration > 0
        and enable ~= 0 then
        cooldown:SetCooldown(
            start,
            duration
        )
    else
        cooldown:Clear()
    end
end

local function CreateBaseButton(
    parent,
    name
)
    local button =
        CreateFrame(
            "CheckButton",
            name,
            parent,
            "SecureActionButtonTemplate"
        )

    button:SetSize(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

    button:SetAttribute(
        "useOnKeyDown",
        false
    )

    button:RegisterForClicks(
        "AnyUp",
        "AnyDown"
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
    -- CHECKED / ACTIVE
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
        0.20,
        0.62,
        0.95,
        0.28
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
            8
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
        0.82,
        0.82,
        0.82,
        1
    )

    button.Hotkey =
        hotkey

    return button
end

--------------------------------------------------
-- STANCE / FORM BAR
--------------------------------------------------

local StanceBar =
    CreateFrame(
        "Frame",
        "BlackoutUI_StanceBar",
        UIParent
    )

StanceBar:SetSize(
    (BUTTON_SIZE * MAX_STANCE_BUTTONS)
    + (
        BUTTON_SPACING
        * (MAX_STANCE_BUTTONS - 1)
    ),
    BUTTON_SIZE
)

StanceBar:SetPoint(
    "BOTTOM",
    UIParent,
    "BOTTOM",
    -170,
    300
)

StanceBar:SetFrameStrata(
    "MEDIUM"
)

local StanceBackground =
    StanceBar:CreateTexture(
        nil,
        "BACKGROUND"
    )

StanceBackground:SetPoint(
    "TOPLEFT",
    StanceBar,
    "TOPLEFT",
    -3,
    3
)

StanceBackground:SetPoint(
    "BOTTOMRIGHT",
    StanceBar,
    "BOTTOMRIGHT",
    3,
    -3
)

StanceBackground:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.92
)

local StanceButtons = {}

for index = 1,
MAX_STANCE_BUTTONS do
    local button =
        CreateBaseButton(
            StanceBar,
            "BlackoutUI_StanceButton"
            .. index
        )

    button.stanceIndex =
        index

    if index == 1 then
        button:SetPoint(
            "LEFT",
            StanceBar,
            "LEFT",
            0,
            0
        )
    else
        button:SetPoint(
            "LEFT",
            StanceButtons[index - 1],
            "RIGHT",
            BUTTON_SPACING,
            0
        )
    end

    button:SetScript(
        "OnEnter",
        function(self)
            local stanceIndex =
                self.stanceIndex

            local texture,
            active,
            castable,
            spellID =
                GetShapeshiftFormInfo(
                    stanceIndex
                )

            if not spellID then
                return
            end

            GameTooltip:SetOwner(
                self,
                "ANCHOR_RIGHT"
            )

            if GameTooltip.SetShapeshift then
                GameTooltip:SetShapeshift(
                    stanceIndex
                )
            else
                GameTooltip:SetSpellByID(
                    spellID
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

    StanceButtons[index] =
        button
end

--------------------------------------------------
-- STANCE SECURE ATTRIBUTES
--
-- We use secure spell actions. These attributes are
-- refreshed only while out of combat.
--------------------------------------------------

local function UpdateStanceSecureActions()
    if InCombatLockdown() then
        return
    end

    local numForms =
        GetNumShapeshiftForms()
        or 0

    for index = 1,
    MAX_STANCE_BUTTONS do
        local button =
            StanceButtons[index]

        if index <= numForms then
            local icon,
            active,
            castable,
            spellID =
                GetShapeshiftFormInfo(
                    index
                )

            if spellID then
                button:SetAttribute(
                    "type",
                    "spell"
                )

                button:SetAttribute(
                    "spell",
                    spellID
                )
            else
                button:SetAttribute(
                    "type",
                    nil
                )

                button:SetAttribute(
                    "spell",
                    nil
                )
            end
        else
            button:SetAttribute(
                "type",
                nil
            )

            button:SetAttribute(
                "spell",
                nil
            )
        end
    end
end

--------------------------------------------------
-- UPDATE STANCE BAR
--------------------------------------------------

local function UpdateStanceBar()
    local numForms =
        GetNumShapeshiftForms()
        or 0

    local config =
        EnsureClassBarConfig()

    if numForms <= 0
        or config.stance.enabled == false then
        StanceBar:Hide()
        return
    end

    StanceBar:Show()

    local currentForm =
        GetShapeshiftForm()
        or 0

    for index = 1,
    MAX_STANCE_BUTTONS do
        local button =
            StanceButtons[index]

        if index <= numForms then
            local texture,
            active,
            castable,
            spellID =
                GetShapeshiftFormInfo(
                    index
                )

            button:Show()

            if isToken then
                button.Icon:SetTexture(
                    _G[texture]
                )
            else
                button.Icon:SetTexture(
                    texture
                )
            end

            button:SetChecked(
                active
                or currentForm == index
            )

            if castable == false then
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
            else
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
            end

            local start,
            duration,
            enable =
                GetShapeshiftFormCooldown(
                    index
                )

            SetCooldown(
                button.Cooldown,
                start,
                duration,
                enable
            )

            local key =
                GetBindingKey(
                    "SHAPESHIFTBUTTON"
                    .. index
                )

            button.Hotkey:SetText(
                key or ""
            )
        else
            button:Hide()
        end
    end
end

--------------------------------------------------
-- PET BAR
--------------------------------------------------

local PetBar =
    CreateFrame(
        "Frame",
        "BlackoutUI_PetBar",
        UIParent
    )

PetBar:SetSize(
    (BUTTON_SIZE * MAX_PET_BUTTONS)
    + (
        BUTTON_SPACING
        * (MAX_PET_BUTTONS - 1)
    ),
    BUTTON_SIZE
)

PetBar:SetPoint(
    "BOTTOM",
    UIParent,
    "BOTTOM",
    170,
    300
)

PetBar:SetFrameStrata(
    "MEDIUM"
)

local PetBackground =
    PetBar:CreateTexture(
        nil,
        "BACKGROUND"
    )

PetBackground:SetPoint(
    "TOPLEFT",
    PetBar,
    "TOPLEFT",
    -3,
    3
)

PetBackground:SetPoint(
    "BOTTOMRIGHT",
    PetBar,
    "BOTTOMRIGHT",
    3,
    -3
)

PetBackground:SetColorTexture(
    0.008,
    0.008,
    0.008,
    0.92
)

local PetButtons = {}

for index = 1,
MAX_PET_BUTTONS do
    local button =
        CreateBaseButton(
            PetBar,
            "BlackoutUI_PetButton"
            .. index
        )

    button.petIndex =
        index

    button:SetAttribute(
        "type",
        "pet"
    )

    button:SetAttribute(
        "action",
        index
    )

    if index == 1 then
        button:SetPoint(
            "LEFT",
            PetBar,
            "LEFT",
            0,
            0
        )
    else
        button:SetPoint(
            "LEFT",
            PetButtons[index - 1],
            "RIGHT",
            BUTTON_SPACING,
            0
        )
    end

    --------------------------------------------------
    -- PET TOOLTIP
    --------------------------------------------------

    button:SetScript(
        "OnEnter",
        function(self)
            local name,
            texture,
            isToken =
                GetPetActionInfo(
                    self.petIndex
                )

            if not name then
                return
            end

            if isToken then
                name = _G[name] or name
            end

            GameTooltip:SetOwner(
                self,
                "ANCHOR_RIGHT"
            )

            GameTooltip:SetText(
                name,
                0.85,
                0.92,
                1
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

    PetButtons[index] =
        button
end

--------------------------------------------------
-- UPDATE PET BAR
--------------------------------------------------

local function UpdatePetBar()
    local hasPet =
        UnitExists("pet")

    local hasActions = false

    for index = 1,
    MAX_PET_BUTTONS do
        local name,
        texture,
        isToken,
        isActive,
        autoCastAllowed,
        autoCastEnabled =
            GetPetActionInfo(
                index
            )

        local button =
            PetButtons[index]

        if name then
            hasActions = true

            button:Show()

            if isToken then
                button.Icon:SetTexture(
                    _G[texture]
                )
            else
                button.Icon:SetTexture(
                    texture
                )
            end

            button:SetChecked(
                isActive
                or autoCastEnabled
            )

            if autoCastEnabled then
                button.Icon:SetVertexColor(
                    0.78,
                    0.90,
                    1
                )
            else
                button.Icon:SetVertexColor(
                    1,
                    1,
                    1
                )
            end

            button.Dark:SetColorTexture(
                0,
                0,
                0,
                0
            )

            local start,
            duration,
            enable =
                GetPetActionCooldown(
                    index
                )

            SetCooldown(
                button.Cooldown,
                start,
                duration,
                enable
            )

            local key =
                GetBindingKey(
                    "BONUSACTIONBUTTON"
                    .. index
                )

            button.Hotkey:SetText(
                key or ""
            )
        else
            button:Hide()
        end
    end

    local config =
        EnsureClassBarConfig()

    if hasPet
        and hasActions
        and config.pet.enabled ~= false then
        PetBar:Show()
    else
        PetBar:Hide()
    end
end

--------------------------------------------------
-- CONFIGURABLE CLASS BAR LAYOUT
--------------------------------------------------

local function LayoutButtonGroup(
    frame,
    buttons,
    visibleCount,
    settings
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

    local perRow =
        math.max(
            1,
            math.min(
                math.max(1, visibleCount),
                tonumber(settings.buttonsPerRow)
                or 10
            )
        )

    settings.buttonSize = size
    settings.spacing = spacing
    settings.scale = scale
    settings.buttonsPerRow = perRow

    local columns =
        math.min(
            math.max(1, visibleCount),
            perRow
        )

    local rows =
        math.max(
            1,
            math.ceil(
                math.max(1, visibleCount)
                / perRow
            )
        )

    frame:SetScale(scale)

    frame:SetSize(
        (columns * size)
        + (
            math.max(0, columns - 1)
            * spacing
        ),
        (rows * size)
        + (
            math.max(0, rows - 1)
            * spacing
        )
    )

    for index, button
    in ipairs(buttons) do
        button:SetSize(size, size)
        button:ClearAllPoints()

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
            frame,
            "TOPLEFT",
            column * (size + spacing),
            -(row * (size + spacing))
        )
    end
end

local function ApplyClassBarLayout()
    if InCombatLockdown() then
        classLayoutPending = true
        return
    end

    classLayoutPending = false

    local config =
        EnsureClassBarConfig()

    local numForms =
        GetNumShapeshiftForms()
        or 0

    LayoutButtonGroup(
        StanceBar,
        StanceButtons,
        numForms,
        config.stance
    )

    LayoutButtonGroup(
        PetBar,
        PetButtons,
        MAX_PET_BUTTONS,
        config.pet
    )

    UpdateStanceBar()
    UpdatePetBar()
end

BlackoutUI.ClassBars =
    BlackoutUI.ClassBars or {}

function BlackoutUI.ClassBars:ApplyConfig()
    ApplyClassBarLayout()
end

function BlackoutUI.ClassBars:ResetSection(section)
    local config =
        EnsureClassBarConfig()

    config[section] = {
        enabled = true,
        buttonSize = BUTTON_SIZE,
        spacing = BUTTON_SPACING,
        scale = 1.00,
        buttonsPerRow = 10,
    }

    ApplyClassBarLayout()
end

--------------------------------------------------
-- HIDE BLIZZARD STANCE / PET BAR
--------------------------------------------------

local Hider =
    CreateFrame(
        "Frame",
        "BlackoutUI_ClassBarHider",
        UIParent
    )

Hider:Hide()

local function HideBlizzardClassBars()
    if InCombatLockdown() then
        return
    end

    local stanceFrames = {
        "StanceBar",
        "StanceBarFrame",
    }

    local petFrames = {
        "PetActionBar",
        "PetActionBarFrame",
    }

    for _, name
    in ipairs(stanceFrames) do
        local frame =
            _G[name]

        if frame
            and frame ~= StanceBar then
            frame:Hide()
            frame:SetParent(Hider)
        end
    end

    for _, name
    in ipairs(petFrames) do
        local frame =
            _G[name]

        if frame
            and frame ~= PetBar then
            frame:Hide()
            frame:SetParent(Hider)
        end
    end

    --------------------------------------------------
    -- FALLBACK: HIDE INDIVIDUAL DEFAULT BUTTONS
    --------------------------------------------------

    for index = 1,
    MAX_STANCE_BUTTONS do
        local frame =
            _G[
            "StanceButton"
            .. index
            ]

        if frame then
            frame:Hide()
            frame:SetParent(Hider)
        end
    end

    for index = 1,
    MAX_PET_BUTTONS do
        local frame =
            _G[
            "PetActionButton"
            .. index
            ]

        if frame then
            frame:Hide()
            frame:SetParent(Hider)
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
    "UPDATE_SHAPESHIFT_FORMS"
)

EventFrame:RegisterEvent(
    "UPDATE_SHAPESHIFT_FORM"
)

EventFrame:RegisterEvent(
    "UPDATE_SHAPESHIFT_USABLE"
)

EventFrame:RegisterEvent(
    "UPDATE_SHAPESHIFT_COOLDOWN"
)

EventFrame:RegisterEvent(
    "PET_BAR_UPDATE"
)

EventFrame:RegisterEvent(
    "PET_BAR_UPDATE_COOLDOWN"
)

EventFrame:RegisterEvent(
    "PET_BAR_SHOWGRID"
)

EventFrame:RegisterEvent(
    "PET_BAR_HIDEGRID"
)

EventFrame:RegisterEvent(
    "UNIT_PET"
)

EventFrame:RegisterEvent(
    "PLAYER_CONTROL_GAINED"
)

EventFrame:RegisterEvent(
    "PLAYER_CONTROL_LOST"
)

EventFrame:RegisterEvent(
    "PLAYER_REGEN_ENABLED"
)

EventFrame:RegisterEvent(
    "UPDATE_BINDINGS"
)

EventFrame:RegisterEvent(
    "ADDON_LOADED"
)

EventFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        --------------------------------------------------
        -- SECURE STANCE ATTRIBUTES
        --------------------------------------------------

        if event ==
            "PLAYER_ENTERING_WORLD"
            or event ==
            "UPDATE_SHAPESHIFT_FORMS"
            or event ==
            "PLAYER_REGEN_ENABLED" then
            UpdateStanceSecureActions()
        end

        if event == "PLAYER_REGEN_ENABLED"
            and classLayoutPending then
            ApplyClassBarLayout()
        end

        --------------------------------------------------
        -- PET FILTER
        --------------------------------------------------

        if event == "UNIT_PET"
            and unit ~= "player" then
            return
        end

        --------------------------------------------------
        -- CLEANUP
        --------------------------------------------------

        if event ==
            "PLAYER_ENTERING_WORLD"
            or event ==
            "PLAYER_REGEN_ENABLED"
            or event ==
            "ADDON_LOADED" then
            HideBlizzardClassBars()
        end

        --------------------------------------------------
        -- VISUAL REFRESH
        --------------------------------------------------

        UpdateStanceBar()
        UpdatePetBar()
    end
)

--------------------------------------------------
-- BLACKOUT MOVERS
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    StanceBar,
    "StanceBar",
    "STANCE / FORM BAR"
)

BlackoutUI:RegisterMovableFrame(
    PetBar,
    "PetBar",
    "PET BAR"
)

--------------------------------------------------
-- INITIAL
--------------------------------------------------

UpdateStanceSecureActions()
ApplyClassBarLayout()
HideBlizzardClassBars()
