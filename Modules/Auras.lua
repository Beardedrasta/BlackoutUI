--------------------------------------------------
-- BLACKOUT UI
-- Modules/Auras.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local ICON_SIZE = 28
local ICON_SPACING = 4

local MAX_DEBUFFS = 8
local MAX_BUFFS = 8

local AURA_DEFAULTS = {
    enabled = true,
    iconSize = ICON_SIZE,
    spacing = ICON_SPACING,
    iconsPerRow = 8,
    maxDebuffs = MAX_DEBUFFS,
    maxBuffs = MAX_BUFFS,
    showDebuffs = true,
    showBuffs = true,
    showDuration = true,
    showStacks = true,
    durationTextSize = 9,
    stackTextSize = 10,
}

local function EnsureAuraConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.Auras = BlackoutUIDB.Config.Auras or {}

    local config = BlackoutUIDB.Config.Auras
    for key, value in pairs(AURA_DEFAULTS) do
        if config[key] == nil then
            config[key] = value
        end
    end
    return config
end

local function SetAuraFontSize(fontString, size)
    local font, _, flags = fontString:GetFont()
    if font then
        fontString:SetFont(font, size, flags)
    end
end

--------------------------------------------------
-- MAIN TARGET AURA FRAME
--------------------------------------------------

local AuraFrame = CreateFrame(
    "Frame",
    "BlackoutUI_TargetAuras",
    UIParent
)

AuraFrame:SetSize(
    252,
    68
)

AuraFrame:SetPoint(
    "TOPRIGHT",
    BlackoutUI_TargetFrame,
    "BOTTOMRIGHT",
    0,
    -7
)

--------------------------------------------------
-- TABLES
--------------------------------------------------

local DebuffButtons = {}
local BuffButtons = {}

--------------------------------------------------
-- FORMAT DURATION
--------------------------------------------------

local function FormatDuration(seconds)
    if not seconds
        or seconds <= 0 then
        return ""
    end

    if seconds >= 60 then
        return string.format(
            "%dm",
            math.ceil(seconds / 60)
        )
    end

    return string.format(
        "%d",
        math.ceil(seconds)
    )
end

--------------------------------------------------
-- CREATE AURA BUTTON
--------------------------------------------------

local function CreateAuraButton(
    parent,
    index,
    isDebuff
)
    local button = CreateFrame(
        "Frame",
        nil,
        parent
    )

    button:SetSize(
        ICON_SIZE,
        ICON_SIZE
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
        0.02,
        0.02,
        0.02,
        1
    )

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
        button,
        "TOPLEFT",
        2,
        -2
    )

    icon:SetPoint(
        "BOTTOMRIGHT",
        button,
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
    -- BORDER
    --------------------------------------------------

    BlackoutUI:CreateBorder(
        button,
        1,
        "borderBright"
    )

    --------------------------------------------------
    -- STACK COUNT
    --------------------------------------------------

    local count =
        BlackoutUI:CreateFont(
            button,
            10
        )

    count:SetPoint(
        "BOTTOMRIGHT",
        button,
        "BOTTOMRIGHT",
        -2,
        2
    )

    count:SetJustifyH(
        "RIGHT"
    )

    button.Count = count

    --------------------------------------------------
    -- DURATION
    --------------------------------------------------

    local duration =
        BlackoutUI:CreateFont(
            button,
            9
        )

    duration:SetPoint(
        "TOP",
        button,
        "BOTTOM",
        0,
        -2
    )

    duration:SetJustifyH(
        "CENTER"
    )

    button.DurationText =
        duration

    --------------------------------------------------
    -- VARIABLES
    --------------------------------------------------

    button.expirationTime = 0
    button.duration = 0
    button.isDebuff = isDebuff

    button:Hide()

    return button
end

--------------------------------------------------
-- CREATE DEBUFF BUTTONS
--------------------------------------------------

for i = 1, MAX_DEBUFFS do
    local button =
        CreateAuraButton(
            AuraFrame,
            i,
            true
        )

    --------------------------------------------------
    -- RIGHT TO LEFT
    --------------------------------------------------

    button:SetPoint(
        "TOPRIGHT",
        AuraFrame,
        "TOPRIGHT",
        -((i - 1) * (ICON_SIZE + ICON_SPACING)),
        0
    )

    DebuffButtons[i] =
        button
end

--------------------------------------------------
-- CREATE BUFF BUTTONS
--------------------------------------------------

for i = 1, MAX_BUFFS do
    local button =
        CreateAuraButton(
            AuraFrame,
            i,
            false
        )

    --------------------------------------------------
    -- SECOND ROW
    --------------------------------------------------

    button:SetPoint(
        "TOPRIGHT",
        AuraFrame,
        "TOPRIGHT",
        -((i - 1) * (ICON_SIZE + ICON_SPACING)),
        -(ICON_SIZE + 15)
    )

    BuffButtons[i] =
        button
end

--------------------------------------------------
-- DEBUFF BORDER COLOR
--------------------------------------------------

local function SetDebuffBorder(
    button,
    debuffType
)
    local r = 0.65
    local g = 0.12
    local b = 0.12

    --------------------------------------------------
    -- MAGIC
    --------------------------------------------------

    if debuffType == "Magic" then
        r = 0.20
        g = 0.60
        b = 1.00

        --------------------------------------------------
        -- CURSE
        --------------------------------------------------
    elseif debuffType == "Curse" then
        r = 0.60
        g = 0.00
        b = 1.00

        --------------------------------------------------
        -- DISEASE
        --------------------------------------------------
    elseif debuffType == "Disease" then
        r = 0.60
        g = 0.40
        b = 0.00

        --------------------------------------------------
        -- POISON
        --------------------------------------------------
    elseif debuffType == "Poison" then
        r = 0.00
        g = 0.60
        b = 0.00
    end

    local border =
        button.BlackoutBorder

    if not border then
        return
    end

    border.top:SetColorTexture(
        r, g, b, 1
    )

    border.bottom:SetColorTexture(
        r, g, b, 1
    )

    border.left:SetColorTexture(
        r, g, b, 1
    )

    border.right:SetColorTexture(
        r, g, b, 1
    )
end

--------------------------------------------------
-- NORMAL BUFF BORDER
--------------------------------------------------

local function SetBuffBorder(button)
    local border =
        button.BlackoutBorder

    if not border then
        return
    end

    local r = 0.30
    local g = 0.30
    local b = 0.30

    border.top:SetColorTexture(
        r, g, b, 1
    )

    border.bottom:SetColorTexture(
        r, g, b, 1
    )

    border.left:SetColorTexture(
        r, g, b, 1
    )

    border.right:SetColorTexture(
        r, g, b, 1
    )
end

--------------------------------------------------
-- CONFIGURATION / LAYOUT
--------------------------------------------------

BlackoutUI.Auras = BlackoutUI.Auras or {}

local function LayoutAuraButtons()
    local config = EnsureAuraConfig()
    local size = config.iconSize
    local spacing = config.spacing
    local perRow = math.max(1, config.iconsPerRow)

    local debuffRows = 0
    if config.showDebuffs then
        debuffRows = math.ceil(
            math.min(config.maxDebuffs, MAX_DEBUFFS) / perRow
        )
    end

    for i, button in ipairs(DebuffButtons) do
        local slot = i - 1
        local column = slot % perRow
        local row = math.floor(slot / perRow)

        button:ClearAllPoints()
        button:SetSize(size, size)
        button:SetPoint(
            "TOPRIGHT",
            AuraFrame,
            "TOPRIGHT",
            -(column * (size + spacing)),
            -(row * (size + 15))
        )

        SetAuraFontSize(button.Count, config.stackTextSize)
        SetAuraFontSize(button.DurationText, config.durationTextSize)
    end

    local buffStartY = -(debuffRows * (size + 15))

    for i, button in ipairs(BuffButtons) do
        local slot = i - 1
        local column = slot % perRow
        local row = math.floor(slot / perRow)

        button:ClearAllPoints()
        button:SetSize(size, size)
        button:SetPoint(
            "TOPRIGHT",
            AuraFrame,
            "TOPRIGHT",
            -(column * (size + spacing)),
            buffStartY - (row * (size + 15))
        )

        SetAuraFontSize(button.Count, config.stackTextSize)
        SetAuraFontSize(button.DurationText, config.durationTextSize)
    end

    local debuffCount =
        config.showDebuffs
        and math.min(config.maxDebuffs, MAX_DEBUFFS)
        or 0

    local buffCount =
        config.showBuffs
        and math.min(config.maxBuffs, MAX_BUFFS)
        or 0

    local columns =
        math.max(
            1,
            math.min(
                perRow,
                math.max(debuffCount, buffCount)
            )
        )

    local buffRows = 0
    if config.showBuffs then
        buffRows = math.ceil(buffCount / perRow)
    end

    local rows = math.max(1, debuffRows + buffRows)

    AuraFrame:SetSize(
        columns * size + math.max(0, columns - 1) * spacing,
        rows * (size + 15)
    )
end

function BlackoutUI.Auras:ApplyConfig()
    LayoutAuraButtons()
    local config = EnsureAuraConfig()

    if not config.enabled then
        AuraFrame:Hide()
    end
end

function BlackoutUI.Auras:SetOption(key, value)
    EnsureAuraConfig()[key] = value
    self:ApplyConfig()

    if UpdateAuras then
        UpdateAuras()
    end
end

function BlackoutUI.Auras:Reset()
    BlackoutUIDB.Config.Auras = nil
    EnsureAuraConfig()
    self:ApplyConfig()

    if UpdateAuras then
        UpdateAuras()
    end
end

EnsureAuraConfig()
LayoutAuraButtons()

--------------------------------------------------
-- HIDE ALL
--------------------------------------------------

local function HideAll()
    for i = 1, MAX_DEBUFFS do
        DebuffButtons[i]:Hide()
    end

    for i = 1, MAX_BUFFS do
        BuffButtons[i]:Hide()
    end
end

--------------------------------------------------
-- UPDATE DEBUFFS
--------------------------------------------------

local function UpdateDebuffs()
    local config = EnsureAuraConfig()

    for i = 1, MAX_DEBUFFS do
        local button =
            DebuffButtons[i]

        if not config.showDebuffs
            or i > config.maxDebuffs then
            button:Hide()
        else
            local name,
            icon,
            count,
            debuffType,
            duration,
            expirationTime =
                UnitDebuff(
                    "target",
                    i
                )

            --------------------------------------------------
            -- NO MORE DEBUFFS
            --------------------------------------------------

            if not name then
                button:Hide()
            else
                --------------------------------------------------
                -- ICON
                --------------------------------------------------

                button.Icon:SetTexture(
                    icon
                )

                --------------------------------------------------
                -- STACK
                --------------------------------------------------

                if count
                    and count > 1 then
                    button.Count:SetText(
                        count
                    )
                else
                    button.Count:SetText(
                        ""
                    )
                end

                --------------------------------------------------
                -- TIMER
                --------------------------------------------------

                button.duration =
                    duration or 0

                button.expirationTime =
                    expirationTime or 0

                --------------------------------------------------
                -- BORDER
                --------------------------------------------------

                SetDebuffBorder(
                    button,
                    debuffType
                )

                button:Show()
            end
        end
    end
end

--------------------------------------------------
-- UPDATE BUFFS
--------------------------------------------------

local function UpdateBuffs()
    local config = EnsureAuraConfig()

    for i = 1, MAX_BUFFS do
        local button =
            BuffButtons[i]

        if not config.showBuffs
            or i > config.maxBuffs then
            button:Hide()
        else
            local name,
            icon,
            count,
            debuffType,
            duration,
            expirationTime =
                UnitBuff(
                    "target",
                    i
                )

            --------------------------------------------------
            -- NO MORE BUFFS
            --------------------------------------------------

            if not name then
                button:Hide()
            else
                --------------------------------------------------
                -- ICON
                --------------------------------------------------

                button.Icon:SetTexture(
                    icon
                )

                --------------------------------------------------
                -- STACK
                --------------------------------------------------

                if count
                    and count > 1 then
                    button.Count:SetText(
                        count
                    )
                else
                    button.Count:SetText(
                        ""
                    )
                end

                --------------------------------------------------
                -- TIMER
                --------------------------------------------------

                button.duration =
                    duration or 0

                button.expirationTime =
                    expirationTime or 0

                SetBuffBorder(
                    button
                )

                button:Show()
            end
        end
    end
end

--------------------------------------------------
-- UPDATE ALL AURAS
--------------------------------------------------

local function UpdateAuras()
    local config = EnsureAuraConfig()

    if not config.enabled then
        HideAll()
        AuraFrame:Hide()
        return
    end

    LayoutAuraButtons()

    --------------------------------------------------
    -- NO TARGET
    --------------------------------------------------

    if not UnitExists("target") then
        HideAll()

        AuraFrame:Hide()

        return
    end

    AuraFrame:Show()

    UpdateDebuffs()
    UpdateBuffs()

    for _, button in ipairs(DebuffButtons) do
        button.Count:SetShown(config.showStacks)
        button.DurationText:SetShown(config.showDuration)
    end

    for _, button in ipairs(BuffButtons) do
        button.Count:SetShown(config.showStacks)
        button.DurationText:SetShown(config.showDuration)
    end
end

--------------------------------------------------
-- UPDATE TIMER TEXT
--------------------------------------------------

local timerAccumulator = 0

AuraFrame:SetScript(
    "OnUpdate",
    function(self, elapsed)
        timerAccumulator =
            timerAccumulator + elapsed

        --------------------------------------------------
        -- ONLY UPDATE 10 TIMES / SECOND
        --------------------------------------------------

        if timerAccumulator < 0.10 then
            return
        end

        timerAccumulator = 0

        local now =
            GetTime()

        --------------------------------------------------
        -- DEBUFF TIMERS
        --------------------------------------------------

        for i = 1, MAX_DEBUFFS do
            local button =
                DebuffButtons[i]

            if button:IsShown() then
                if button.expirationTime
                    and button.expirationTime > 0 then
                    local remaining =
                        button.expirationTime - now

                    if remaining > 0 then
                        button.DurationText:SetText(
                            FormatDuration(
                                remaining
                            )
                        )
                    else
                        button.DurationText:SetText(
                            ""
                        )
                    end
                else
                    button.DurationText:SetText(
                        ""
                    )
                end
            end
        end

        --------------------------------------------------
        -- BUFF TIMERS
        --------------------------------------------------

        for i = 1, MAX_BUFFS do
            local button =
                BuffButtons[i]

            if button:IsShown() then
                if button.expirationTime
                    and button.expirationTime > 0 then
                    local remaining =
                        button.expirationTime - now

                    if remaining > 0 then
                        button.DurationText:SetText(
                            FormatDuration(
                                remaining
                            )
                        )
                    else
                        button.DurationText:SetText(
                            ""
                        )
                    end
                else
                    button.DurationText:SetText(
                        ""
                    )
                end
            end
        end
    end
)

--------------------------------------------------
-- EVENTS
--------------------------------------------------

AuraFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

AuraFrame:RegisterEvent(
    "PLAYER_TARGET_CHANGED"
)

AuraFrame:RegisterEvent(
    "UNIT_AURA"
)

--------------------------------------------------
-- EVENT HANDLER
--------------------------------------------------

AuraFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        --------------------------------------------------
        -- TARGET CHANGED
        --------------------------------------------------

        if event ==
            "PLAYER_TARGET_CHANGED" then
            UpdateAuras()

            return
        end

        --------------------------------------------------
        -- ENTER WORLD
        --------------------------------------------------

        if event ==
            "PLAYER_ENTERING_WORLD" then
            UpdateAuras()

            return
        end

        --------------------------------------------------
        -- TARGET AURA CHANGED
        --------------------------------------------------

        if event == "UNIT_AURA"
            and unit == "target" then
            UpdateAuras()
        end
    end
)

--------------------------------------------------
-- INITIAL STATE
--------------------------------------------------

AuraFrame:Hide()
