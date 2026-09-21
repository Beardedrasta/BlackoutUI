--------------------------------------------------
-- BLACKOUT UI
-- Modules/RaidFrames.lua
--
-- STEP 1
-- Compact Grid-style Raid Frames
-- 40 units / 8 groups / solo preview
--------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.RaidFrames =
    BlackoutUI.RaidFrames or {}

local RaidFrames = BlackoutUI.RaidFrames

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local DEFAULTS = {
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
}

local function EnsureConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config =
        BlackoutUIDB.Config or {}

    BlackoutUIDB.Config.UnitFrames =
        BlackoutUIDB.Config.UnitFrames or {}

    BlackoutUIDB.Config.UnitFrames.raid =
        BlackoutUIDB.Config.UnitFrames.raid
        or {}

    local config =
        BlackoutUIDB.Config.UnitFrames.raid

    for key, value
    in pairs(DEFAULTS) do
        if config[key] == nil then
            config[key] = value
        end
    end

    return config
end

local function SetFontSize(fontString, size)
    local font, _, flags =
        fontString:GetFont()

    if font then
        fontString:SetFont(
            font,
            size,
            flags
        )
    end
end

--------------------------------------------------
-- CONTAINER
--------------------------------------------------

local Container =
    CreateFrame(
        "Frame",
        "BlackoutUI_RaidFrames",
        UIParent
    )

Container:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    0,
    40
)

Container:SetSize(500, 250)
Container:SetClampedToScreen(true)

--------------------------------------------------
-- STATE
--------------------------------------------------

local Frames = {}
local PreviewEnabled = false
local PreviewSize = 20

--------------------------------------------------
-- RESOURCE COLORS
--------------------------------------------------

local RESOURCE_COLORS = {
    [0] = { 0.10, 0.42, 0.88, 1 },
    [1] = { 0.88, 0.16, 0.12, 1 },
    [2] = { 0.82, 0.58, 0.12, 1 },
    [3] = { 0.88, 0.78, 0.18, 1 },
}

local CLASS_BUFF_FAMILIES = {
    PRIEST = {
        {
            key = "fortitude",
            names = {
                "Power Word: Fortitude",
                "Prayer of Fortitude",
            },
        },
        {
            key = "spirit",
            names = {
                "Divine Spirit",
                "Prayer of Spirit",
            },
        },
        {
            key = "shadow",
            names = {
                "Shadow Protection",
                "Prayer of Shadow Protection",
            },
        },
    },

    MAGE = {
        {
            key = "intellect",
            names = {
                "Arcane Intellect",
                "Arcane Brilliance",
            },
        },
    },

    DRUID = {
        {
            key = "mark",
            names = {
                "Mark of the Wild",
                "Gift of the Wild",
            },
        },
        {
            key = "thorns",
            names = {
                "Thorns",
            },
        },
    },

    PALADIN = {
        {
            key = "might",
            names = {
                "Blessing of Might",
                "Greater Blessing of Might",
            },
        },
        {
            key = "wisdom",
            names = {
                "Blessing of Wisdom",
                "Greater Blessing of Wisdom",
            },
        },
        {
            key = "kings",
            names = {
                "Blessing of Kings",
                "Greater Blessing of Kings",
            },
        },
        {
            key = "salvation",
            names = {
                "Blessing of Salvation",
                "Greater Blessing of Salvation",
            },
        },
        {
            key = "light",
            names = {
                "Blessing of Light",
                "Greater Blessing of Light",
            },
        },
    },
}

-- Only helpful periodic/healing effects the CURRENT CLASS can place.
-- We additionally require sourceUnit == "player", so another healer's HoT
-- does not occupy your personal HoT indicator.
local CLASS_HOTS = {
    PRIEST = {
        { key = "renew", names = { "Renew" } },
    },
    DRUID = {
        { key = "rejuvenation", names = { "Rejuvenation" } },
        { key = "regrowth",     names = { "Regrowth" } },
    },
}

local function NameInList(name, names)
    if not name or not names then
        return false
    end

    for _, wanted in ipairs(names) do
        if name == wanted then
            return true
        end
    end

    return false
end

-- Friendly debuff types the CURRENT CLASS can remove in Classic Era.
local CLASS_DISPELS = {
    PRIEST = {
        Magic = true,
        Disease = true,
    },
    DRUID = {
        Curse = true,
        Poison = true,
    },
    PALADIN = {
        Poison = true,
        Disease = true,
        Magic = true,
    },
    MAGE = {
        Curse = true,
    },
    SHAMAN = {
        Poison = true,
        Disease = true,
    },
}

local function PlayerKnowsSpellByName(spellName)
    if not spellName then
        return false
    end

    if C_Spell
        and C_Spell.GetSpellInfo
        and C_Spell.GetSpellInfo(spellName) then
        return true
    end

    if GetSpellInfo
        and GetSpellInfo(spellName) then
        -- GetSpellInfo alone can resolve spells not learned, so use
        -- IsSpellKnown when we can obtain an ID.
        local _, _, _, _, _, _, spellID =
            GetSpellInfo(spellName)

        if spellID and IsSpellKnown then
            return IsSpellKnown(spellID)
        end
    end

    return true
end

local function ReadAura(unit, index, filter)
    if C_UnitAuras
        and C_UnitAuras.GetAuraDataByIndex then
        local aura =
            C_UnitAuras.GetAuraDataByIndex(
                unit,
                index,
                filter
            )

        if not aura then return nil end

        return {
            name = aura.name,
            icon = aura.icon,
            duration = aura.duration,
            expirationTime = aura.expirationTime,
            sourceUnit = aura.sourceUnit,
            dispelName = aura.dispelName,
        }
    end

    local name, icon, count, debuffType,
    duration, expirationTime, sourceUnit =
        UnitAura(unit, index, filter)

    if not name then return nil end

    return {
        name = name,
        icon = icon,
        duration = duration,
        expirationTime = expirationTime,
        sourceUnit = sourceUnit,
        dispelName = debuffType,
    }
end

local function FindRelevantHots(unit)
    local _, playerClass =
        UnitClass("player")

    local definitions =
        CLASS_HOTS[playerClass]

    local results = {}

    if not definitions then
        return results
    end

    for slot, definition
    in ipairs(definitions) do
        local mine
        local other

        for i = 1, 40 do
            local aura =
                ReadAura(
                    unit,
                    i,
                    "HELPFUL"
                )

            if not aura then
                break
            end

            if NameInList(
                    aura.name,
                    definition.names
                ) and PlayerKnowsSpellByName(
                    aura.name
                ) then
                if aura.sourceUnit == "player" then
                    mine = aura
                else
                    other = other or aura
                end
            end
        end

        results[slot] = {
            definition = definition,
            mine = mine,
            other = other,
        }
    end

    return results
end

local function FindDispellableDebuff(unit)
    local _, playerClass =
        UnitClass("player")

    local allowed =
        CLASS_DISPELS[playerClass]

    if not allowed then
        return nil
    end

    for i = 1, 40 do
        local aura =
            ReadAura(
                unit,
                i,
                "HARMFUL"
            )

        if not aura then
            break
        end

        if aura.dispelName
            and allowed[aura.dispelName] then
            return aura
        end
    end
end

local function FindRelevantClassBuffFamily(unit, family)
    if not family
        or not family.names then
        return {
            applicable = false,
            mine = nil,
            other = nil,
        }
    end

    local applicable = {}

    for _, name in ipairs(family.names) do
        if PlayerKnowsSpellByName(name) then
            applicable[name] = true
        end
    end

    if not next(applicable) then
        return {
            applicable = false,
            mine = nil,
            other = nil,
        }
    end

    local mine
    local other

    for i = 1, 40 do
        local aura =
            ReadAura(
                unit,
                i,
                "HELPFUL"
            )

        if not aura then
            break
        end

        if applicable[aura.name] then
            if aura.sourceUnit == "player" then
                mine = mine or aura
            else
                other = other or aura
            end
        end
    end

    return {
        applicable = true,
        mine = mine,
        other = other,
        family = family,
    }
end

local function SetIndicator(holder, aura)
    if not aura then
        holder:Hide()
        return
    end

    holder.Icon:SetTexture(aura.icon)

    if aura.expirationTime
        and aura.expirationTime > 0 then
        local remaining =
            math.max(
                0,
                aura.expirationTime - GetTime()
            )

        if remaining >= 60 then
            holder.Time:SetText(
                math.floor(remaining / 60) .. "m"
            )
        else
            holder.Time:SetText(
                math.ceil(remaining)
            )
        end
    else
        holder.Time:SetText("")
    end

    holder:Show()
end


local function SetHotIndicator(holder, result)
    if not holder then
        return
    end

    if not result then
        holder:Hide()
        return
    end

    local aura =
        result.mine
        or result.other

    if not aura then
        holder:Hide()
        return
    end

    SetIndicator(holder, aura)

    if result.mine then
        holder:SetAlpha(1.0)
        holder.OwnerDot:SetColorTexture(
            0.25,
            1.00,
            0.35,
            1
        )
    else
        -- Same relevant HoT from another player:
        -- keep it visible, but visually secondary.
        holder:SetAlpha(0.55)
        holder.OwnerDot:SetColorTexture(
            1.00,
            0.82,
            0.20,
            1
        )
    end

    holder.OwnerDot:Show()
end

--------------------------------------------------
-- AURA INDICATOR FRAME
--------------------------------------------------

local function CreateIndicator(parent, point, x, y)
    local holder =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    holder:SetSize(14, 14)

    holder:SetPoint(
        point,
        parent,
        point,
        x,
        y
    )

    local icon =
        holder:CreateTexture(
            nil,
            "OVERLAY"
        )

    icon:SetAllPoints()
    icon:SetTexCoord(
        0.08,
        0.92,
        0.08,
        0.92
    )

    holder.Icon = icon

    local time =
        BlackoutUI:CreateFont(
            holder,
            7
        )

    time:SetPoint(
        "BOTTOM",
        holder,
        "BOTTOM",
        0,
        0
    )

    time:SetText("")
    holder.Time = time

    holder.OwnerDot =
        holder:CreateTexture(
            nil,
            "OVERLAY"
        )

    holder.OwnerDot:SetSize(4, 4)

    holder.OwnerDot:SetPoint(
        "TOPLEFT",
        holder,
        "TOPLEFT",
        1,
        -1
    )

    holder.OwnerDot:SetColorTexture(
        1,
        1,
        1,
        1
    )

    holder.OwnerDot:Hide()
    holder:Hide()

    return holder
end

--------------------------------------------------
-- CREATE GRID CELL
--------------------------------------------------

local function CreateRaidCell(index)
    local unit =
        "raid" .. index

    local frame =
        CreateFrame(
            "Button",
            "BlackoutUI_RaidFrame" .. index,
            Container,
            "SecureUnitButtonTemplate"
        )

    frame.unit = unit
    frame.index = index

    frame:RegisterForClicks("AnyUp")

    frame:SetAttribute(
        "unit",
        unit
    )

    frame:SetAttribute(
        "type1",
        "target"
    )

    frame:SetAttribute(
        "type2",
        "togglemenu"
    )

    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local background =
        frame:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    background:SetColorTexture(
        0.02,
        0.02,
        0.02,
        0.96
    )

    --------------------------------------------------
    -- HEALTH CELL
    --------------------------------------------------

    local health =
        CreateFrame(
            "StatusBar",
            nil,
            frame
        )

    health:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        1,
        -1
    )

    health:SetPoint(
        "TOPRIGHT",
        frame,
        "TOPRIGHT",
        -1,
        -1
    )

    health:SetStatusBarTexture(
        "Interface\\Buttons\\WHITE8x8"
    )

    health:SetMinMaxValues(0, 1)
    health:SetValue(1)

    frame.Health = health

    local healthBG =
        health:CreateTexture(
            nil,
            "BACKGROUND"
        )

    healthBG:SetAllPoints()

    healthBG:SetColorTexture(
        0.035,
        0.035,
        0.035,
        1
    )

    BlackoutUI:CreateBorder(
        health,
        1,
        "borderBright"
    )

    --------------------------------------------------
    -- INCOMING HEAL PREDICTION
    --------------------------------------------------

    local incomingHeal =
        health:CreateTexture(
            nil,
            "ARTWORK"
        )

    incomingHeal:SetTexture(
        "Interface\\Buttons\\WHITE8x8"
    )

    incomingHeal:SetPoint(
        "TOP",
        health,
        "TOP",
        0,
        0
    )

    incomingHeal:SetPoint(
        "BOTTOM",
        health,
        "BOTTOM",
        0,
        0
    )

    incomingHeal:SetColorTexture(
        0.25,
        1.00,
        0.35,
        DEFAULTS.incomingHealAlpha
    )

    incomingHeal:Hide()
    frame.IncomingHeal = incomingHeal

    --------------------------------------------------
    -- THREAT BORDER
    --------------------------------------------------

    frame.ThreatBorder = {}

    for edgeIndex = 1, 4 do
        local edge =
            health:CreateTexture(nil, "OVERLAY")

        edge:SetColorTexture(
            1.00, 0.18, 0.12, 1
        )
        edge:Hide()

        frame.ThreatBorder[edgeIndex] = edge
    end

    frame.ThreatBorder[1]:SetPoint(
        "TOPLEFT", health, "TOPLEFT", 0, 0
    )
    frame.ThreatBorder[1]:SetPoint(
        "TOPRIGHT", health, "TOPRIGHT", 0, 0
    )
    frame.ThreatBorder[1]:SetHeight(2)

    frame.ThreatBorder[2]:SetPoint(
        "BOTTOMLEFT", health, "BOTTOMLEFT", 0, 0
    )
    frame.ThreatBorder[2]:SetPoint(
        "BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0
    )
    frame.ThreatBorder[2]:SetHeight(2)

    frame.ThreatBorder[3]:SetPoint(
        "TOPLEFT", health, "TOPLEFT", 0, 0
    )
    frame.ThreatBorder[3]:SetPoint(
        "BOTTOMLEFT", health, "BOTTOMLEFT", 0, 0
    )
    frame.ThreatBorder[3]:SetWidth(2)

    frame.ThreatBorder[4]:SetPoint(
        "TOPRIGHT", health, "TOPRIGHT", 0, 0
    )
    frame.ThreatBorder[4]:SetPoint(
        "BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0
    )
    frame.ThreatBorder[4]:SetWidth(2)

    --------------------------------------------------
    -- LEVEL - TOP LEFT
    --------------------------------------------------

    local levelText =
        BlackoutUI:CreateFont(
            health,
            DEFAULTS.levelSize
        )

    levelText:SetPoint(
        "TOPLEFT",
        health,
        "TOPLEFT",
        4,
        -3
    )

    levelText:SetJustifyH("LEFT")
    frame.LevelText = levelText

    --------------------------------------------------
    -- NAME - CENTER
    --------------------------------------------------

    local nameText =
        BlackoutUI:CreateFont(
            health,
            DEFAULTS.nameSize
        )

    nameText:SetPoint(
        "CENTER",
        health,
        "CENTER",
        0,
        5
    )

    nameText:SetJustifyH("CENTER")
    nameText:SetWordWrap(false)

    frame.NameText = nameText

    --------------------------------------------------
    -- HEALTH - CENTER LOWER
    --------------------------------------------------

    local healthText =
        BlackoutUI:CreateFont(
            health,
            DEFAULTS.healthTextSize
        )

    healthText:SetPoint(
        "CENTER",
        health,
        "CENTER",
        0,
        -7
    )

    frame.HealthText = healthText

    --------------------------------------------------
    -- RESOURCE BAR BELOW HEALTH
    --------------------------------------------------

    local resource =
        CreateFrame(
            "StatusBar",
            nil,
            frame
        )

    resource:SetStatusBarTexture(
        "Interface\\Buttons\\WHITE8x8"
    )

    resource:SetPoint(
        "TOPLEFT",
        health,
        "BOTTOMLEFT",
        0,
        -1
    )

    resource:SetPoint(
        "TOPRIGHT",
        health,
        "BOTTOMRIGHT",
        0,
        -1
    )

    resource:SetMinMaxValues(0, 1)
    resource:SetValue(1)

    frame.Resource = resource

    local resourceBG =
        resource:CreateTexture(
            nil,
            "BACKGROUND"
        )

    resourceBG:SetAllPoints()

    resourceBG:SetColorTexture(
        0.02,
        0.02,
        0.02,
        1
    )

    --------------------------------------------------
    -- REAL GROUP AURA INDICATORS
    --------------------------------------------------

    -- TOP RIGHT: relevant HoTs
    frame.HotIndicators = {}

    frame.HotIndicators[1] =
        CreateIndicator(
            health,
            "TOPRIGHT",
            -3,
            -3
        )

    frame.HotIndicators[2] =
        CreateIndicator(
            health,
            "TOPRIGHT",
            -17,
            -3
        )

    -- BOTTOM LEFT: separate class-buff families
    frame.ClassBuffIndicators = {}

    for slot = 1, 3 do
        frame.ClassBuffIndicators[slot] =
            CreateIndicator(
                health,
                "BOTTOMLEFT",
                3 + ((slot - 1) * 14),
                3
            )
    end

    -- BOTTOM RIGHT: harmful effect this class can dispel
    frame.DebuffIndicator =
        CreateIndicator(
            health,
            "BOTTOMRIGHT",
            -3,
            3
        )

    Frames[index] = frame
    return frame
end

for index = 1, 40 do
    CreateRaidCell(index)
end

--------------------------------------------------
-- CLASS HEALTH COLOR
--------------------------------------------------

local function SetClassHealthColor(
    frame,
    unit,
    previewClass
)
    local class = previewClass

    if not class then
        local _
        _, class = UnitClass(unit)
    end

    local color =
        class
        and RAID_CLASS_COLORS
        and RAID_CLASS_COLORS[class]

    if color then
        frame.Health:SetStatusBarColor(
            color.r,
            color.g,
            color.b,
            0.88
        )
    else
        frame.Health:SetStatusBarColor(
            0.22,
            0.66,
            0.92,
            0.88
        )
    end
end

--------------------------------------------------
-- RAID AURA UPDATE
--------------------------------------------------

local function UpdateAuraIndicators(frame)
    local config = EnsureConfig()

    if not config.showAuraIndicators then
        for _, holder in ipairs(frame.HotIndicators) do
            holder:Hide()
        end

        for _, holder in ipairs(frame.ClassBuffIndicators) do
            holder:Hide()
        end

        frame.DebuffIndicator:Hide()
        return
    end

    --------------------------------------------------
    -- HOTS
    --------------------------------------------------

    if config.showHots then
        local hots =
            FindRelevantHots(
                frame.unit
            )

        for slot, holder
        in ipairs(frame.HotIndicators) do
            SetHotIndicator(
                holder,
                hots[slot]
            )
        end
    else
        for _, holder
        in ipairs(frame.HotIndicators) do
            holder:Hide()
        end
    end

    --------------------------------------------------
    -- CLASS BUFF FAMILIES
    --------------------------------------------------

    for _, holder
    in ipairs(frame.ClassBuffIndicators) do
        holder:Hide()
    end

    if config.showClassBuffs then
        local _, playerClass =
            UnitClass("player")

        local families =
            CLASS_BUFF_FAMILIES[playerClass]
            or {}

        local visibleSlot = 1

        for _, family
        in ipairs(families) do
            local state =
                FindRelevantClassBuffFamily(
                    frame.unit,
                    family
                )

            if state.applicable
                and visibleSlot <= #frame.ClassBuffIndicators then
                SetClassBuffIndicator(
                    frame.ClassBuffIndicators[visibleSlot],
                    state
                )

                visibleSlot =
                    visibleSlot + 1
            end
        end
    end

    --------------------------------------------------
    -- DISPELLABLE DEBUFF
    --------------------------------------------------

    if config.showDispellableDebuffs then
        SetIndicator(
            frame.DebuffIndicator,
            FindDispellableDebuff(
                frame.unit
            )
        )
    else
        frame.DebuffIndicator:Hide()
    end
end

--------------------------------------------------
-- PREVIEW
--------------------------------------------------

local PREVIEW_CLASSES = {
    "WARRIOR",
    "PRIEST",
    "ROGUE",
    "MAGE",
    "DRUID",
    "HUNTER",
    "WARLOCK",
    "PALADIN",
    "SHAMAN",
}

local function ApplyPreview(frame, index)
    local config = EnsureConfig()

    if index > PreviewSize then
        frame:Hide()
        return
    end

    frame:Show()
    frame:SetAlpha(1)

    local group =
        math.floor(
            (index - 1) / 5
        ) + 1

    local member =
        ((index - 1) % 5) + 1

    frame.NameText:SetText(
        "G" .. group .. " Member " .. member
    )

    frame.LevelText:SetText(
        index % 7 == 0
        and "59"
        or "60"
    )

    local health =
        100 - ((index * 7) % 68)

    frame.Health:SetMinMaxValues(
        0,
        100
    )

    frame.Health:SetValue(health)

    frame.HealthText:SetText(
        health .. "%"
    )

    -- Preview a few real-world raid states.
    frame.IncomingHeal:Hide()

    if index == 3 then
        C_Timer.After(
            0,
            function()
                if not frame:IsShown() then
                    return
                end

                local width =
                    frame.Health:GetWidth()

                frame.IncomingHeal:ClearAllPoints()
                frame.IncomingHeal:SetPoint(
                    "TOPLEFT",
                    frame.Health,
                    "TOPLEFT",
                    width * (health / 100),
                    0
                )
                frame.IncomingHeal:SetPoint(
                    "BOTTOMLEFT",
                    frame.Health,
                    "BOTTOMLEFT",
                    width * (health / 100),
                    0
                )
                frame.IncomingHeal:SetWidth(
                    math.max(
                        1,
                        width * 0.22
                    )
                )
                frame.IncomingHeal:SetColorTexture(
                    0.25,
                    1.00,
                    0.35,
                    config.incomingHealAlpha
                    or 0.45
                )
                frame.IncomingHeal:Show()
            end
        )
    end

    if index == 8 then
        frame.HealthText:SetText("DEAD")
        frame:SetAlpha(
            config.deadAlpha or 0.55
        )
    elseif index == 13 then
        frame.HealthText:SetText("OFFLINE")
        frame:SetAlpha(
            config.offlineAlpha or 0.35
        )
    end

    local class =
        PREVIEW_CLASSES[
        ((index - 1)
            % #PREVIEW_CLASSES) + 1
        ]

    SetClassHealthColor(
        frame,
        frame.unit,
        class
    )

    if config.showResourceBar then
        frame.Resource:Show()
        frame.Resource:SetMinMaxValues(
            0,
            100
        )

        local powerType =
            index % 4

        frame.Resource:SetValue(
            35 + ((index * 11) % 65)
        )

        frame.Resource:SetStatusBarColor(
            unpack(
                RESOURCE_COLORS[powerType]
                or RESOURCE_COLORS[0]
            )
        )
    else
        frame.Resource:Hide()
    end

    -- Preview real aura indicator states.
    for _, holder in ipairs(frame.HotIndicators) do
        holder:Hide()
        holder.OwnerDot:Hide()
        holder:SetAlpha(1)
    end

    for _, holder in ipairs(frame.ClassBuffIndicators) do
        holder:Hide()
        holder.OwnerDot:Hide()
        holder:SetAlpha(1)
    end

    frame.DebuffIndicator:Hide()

    if index % 3 == 0 then
        local holder = frame.HotIndicators[1]
        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Nature_Rejuvenation"
        )
        holder.Time:SetText("12")
        holder.OwnerDot:SetColorTexture(
            0.25, 1.00, 0.35, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    elseif index % 5 == 0 then
        local holder = frame.HotIndicators[1]
        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Nature_Rejuvenation"
        )
        holder.Time:SetText("8")
        holder:SetAlpha(0.55)
        holder.OwnerDot:SetColorTexture(
            1.00, 0.82, 0.20, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    end

    if index % 4 == 0 then
        local holder = frame.ClassBuffIndicators[1]
        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Holy_WordFortitude"
        )
        holder.Time:SetText("28m")
        holder.OwnerDot:SetColorTexture(
            0.25, 1.00, 0.35, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    elseif index % 6 == 0 then
        local holder = frame.ClassBuffIndicators[1]
        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Holy_WordFortitude"
        )
        holder.Time:SetText("24m")
        holder:SetAlpha(0.60)
        holder.OwnerDot:SetColorTexture(
            1.00, 0.82, 0.20, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    elseif index % 7 == 0 then
        local holder = frame.ClassBuffIndicators[1]
        holder.Icon:SetTexture(
            "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
        )
        holder.Time:SetText("!")
        holder.OwnerDot:SetColorTexture(
            1.00, 0.25, 0.20, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    end

    if index % 9 == 0 then
        local holder = frame.DebuffIndicator
        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
        )
        holder.Time:SetText("6")
        holder:Show()
    end
end

--------------------------------------------------
-- DEAD / GHOST / OFFLINE STATE
--------------------------------------------------

local function ApplyUnitStatus(frame, unit)
    local config = EnsureConfig()

    if PreviewEnabled then
        return false
    end

    if not UnitIsConnected(unit) then
        if config.showStatusText then
            frame.HealthText:SetText("OFFLINE")
        end

        frame.Health:SetValue(0)
        frame.Resource:SetValue(0)
        frame:SetAlpha(
            config.offlineAlpha or 0.35
        )

        return true
    end

    if UnitIsDeadOrGhost(unit) then
        if config.showStatusText then
            frame.HealthText:SetText(
                UnitIsGhost(unit)
                and "GHOST"
                or "DEAD"
            )
        end

        frame.Resource:SetValue(0)
        frame:SetAlpha(
            config.deadAlpha or 0.55
        )

        return true
    end

    return false
end

--------------------------------------------------
-- RANGE FADING
--------------------------------------------------

local function ApplyRangeState(frame, unit)
    local config = EnsureConfig()

    if PreviewEnabled then
        frame:SetAlpha(1)
        return
    end

    if not UnitIsConnected(unit) then
        frame:SetAlpha(
            config.offlineAlpha or 0.35
        )
        return
    end

    if UnitIsDeadOrGhost(unit) then
        frame:SetAlpha(
            config.deadAlpha or 0.55
        )
        return
    end

    if not config.rangeFading then
        frame:SetAlpha(1)
        return
    end

    -- UnitInRange is the safest group-frame range check here.
    -- nil means the API cannot determine range, so do not
    -- incorrectly fade the unit.
    local inRange =
        UnitInRange(unit)

    if inRange == false then
        frame:SetAlpha(
            config.outOfRangeAlpha
            or 0.45
        )
    else
        frame:SetAlpha(1)
    end
end

--------------------------------------------------
-- LIVE UNIT
--------------------------------------------------

local function UpdateIncomingHeal(
    frame,
    unit
)
    local config = EnsureConfig()

    if PreviewEnabled
        or not config.showIncomingHeals
        or not UnitExists(unit)
        or UnitIsDeadOrGhost(unit)
        or not UnitIsConnected(unit) then
        frame.IncomingHeal:Hide()
        return
    end

    local maximum =
        UnitHealthMax(unit) or 0

    local current =
        UnitHealth(unit) or 0

    if maximum <= 0 then
        frame.IncomingHeal:Hide()
        return
    end

    local incoming = 0

    if UnitGetIncomingHeals then
        incoming =
            UnitGetIncomingHeals(unit)
            or 0
    end

    if incoming <= 0
        or current >= maximum then
        frame.IncomingHeal:Hide()
        return
    end

    local effective =
        math.min(
            incoming,
            maximum - current
        )

    if effective <= 0 then
        frame.IncomingHeal:Hide()
        return
    end

    local healthWidth =
        frame.Health:GetWidth()

    if not healthWidth
        or healthWidth <= 0 then
        frame.IncomingHeal:Hide()
        return
    end

    local currentFraction =
        math.max(
            0,
            math.min(
                1,
                current / maximum
            )
        )

    local healFraction =
        math.max(
            0,
            math.min(
                1 - currentFraction,
                effective / maximum
            )
        )

    frame.IncomingHeal:ClearAllPoints()

    frame.IncomingHeal:SetPoint(
        "TOPLEFT",
        frame.Health,
        "TOPLEFT",
        healthWidth * currentFraction,
        0
    )

    frame.IncomingHeal:SetPoint(
        "BOTTOMLEFT",
        frame.Health,
        "BOTTOMLEFT",
        healthWidth * currentFraction,
        0
    )

    frame.IncomingHeal:SetWidth(
        math.max(
            1,
            healthWidth * healFraction
        )
    )

    frame.IncomingHeal:SetColorTexture(
        0.25,
        1.00,
        0.35,
        config.incomingHealAlpha
        or 0.45
    )

    frame.IncomingHeal:Show()
end

local function UpdateThreat(frame, unit)
    local config = EnsureConfig()

    local status = 0

    if config.showThreat
        and UnitThreatSituation then
        status =
            UnitThreatSituation(unit)
            or 0
    end

    local show =
        status > 0

    local red, green, blue =
        1.00, 0.82, 0.20

    if status >= 3 then
        red, green, blue =
            1.00, 0.18, 0.12
    elseif status == 2 then
        red, green, blue =
            1.00, 0.48, 0.12
    end

    for _, edge
    in ipairs(frame.ThreatBorder) do
        edge:SetShown(show)

        if show then
            edge:SetColorTexture(
                red, green, blue, 1
            )
        end
    end
end

local function UpdateResource(
    frame,
    unit
)
    local config = EnsureConfig()

    if not config.showResourceBar then
        frame.Resource:Hide()
        return
    end

    local powerType =
        UnitPowerType(unit)

    local current =
        UnitPower(unit) or 0

    local maximum =
        UnitPowerMax(unit) or 0

    frame.Resource:SetMinMaxValues(
        0,
        math.max(1, maximum)
    )

    frame.Resource:SetValue(current)

    frame.Resource:SetStatusBarColor(
        unpack(
            RESOURCE_COLORS[powerType]
            or RESOURCE_COLORS[0]
        )
    )

    frame.Resource:Show()
end

local function UpdateFrame(
    frame,
    index
)
    local config = EnsureConfig()

    if PreviewEnabled then
        ApplyPreview(
            frame,
            index
        )
        return
    end

    if not config.enabled
        or not IsInRaid()
        or not UnitExists(frame.unit) then
        frame:Hide()
        return
    end

    frame:Show()

    local unit =
        frame.unit

    frame.NameText:SetText(
        UnitName(unit) or ""
    )

    local level =
        UnitLevel(unit)

    frame.LevelText:SetText(
        level and level > 0
        and level
        or "??"
    )

    local current =
        UnitHealth(unit) or 0

    local maximum =
        UnitHealthMax(unit) or 0

    frame.Health:SetMinMaxValues(
        0,
        math.max(1, maximum)
    )

    frame.Health:SetValue(current)

    local percent = 0

    if maximum > 0 then
        percent =
            math.floor(
                (current / maximum)
                * 100
                + 0.5
            )
    end

    frame.HealthText:SetText(
        percent .. "%"
    )

    SetClassHealthColor(
        frame,
        unit
    )

    UpdateResource(
        frame,
        unit
    )

    UpdateIncomingHeal(
        frame,
        unit
    )

    UpdateThreat(
        frame,
        unit
    )

    UpdateAuraIndicators(frame)

    ApplyUnitStatus(
        frame,
        unit
    )

    ApplyRangeState(
        frame,
        unit
    )
end

local function UpdateAll()
    for index, frame
    in ipairs(Frames) do
        UpdateFrame(
            frame,
            index
        )
    end
end

--------------------------------------------------
-- LAYOUT
--------------------------------------------------

local function ApplyLayout()
    local config = EnsureConfig()

    Container:SetScale(
        config.scale
    )

    local resourceExtra =
        config.showResourceBar
        and (
            (config.resourceHeight or 4)
            + 1
        )
        or 0

    local totalHeight =
        config.height
        + resourceExtra

    local unitsPerColumn =
        math.max(
            1,
            math.min(
                5,
                config.unitsPerColumn or 5
            )
        )

    local groupsPerRow =
        math.max(
            1,
            math.min(
                8,
                config.groupsPerRow or 4
            )
        )

    local groupWidth =
        config.width

    local groupHeight =
        (totalHeight * unitsPerColumn)
        + (
            config.verticalSpacing
            * (unitsPerColumn - 1)
        )

    local visibleGroups =
        PreviewEnabled
        and math.ceil(PreviewSize / 5)
        or 8

    local rows =
        math.ceil(
            visibleGroups / groupsPerRow
        )

    local columns =
        math.min(
            groupsPerRow,
            visibleGroups
        )

    Container:SetSize(
        (groupWidth * columns)
        + (
            (config.horizontalSpacing or 0)
            * math.max(0, columns - 1)
        ),
        (groupHeight * rows)
        + (
            config.groupSpacing
            * math.max(0, rows - 1)
        )
    )

    for index, frame
    in ipairs(Frames) do
        local group =
            math.floor(
                (index - 1) / 5
            )

        local member =
            (index - 1) % 5

        local groupColumn =
            group % groupsPerRow

        local groupRow =
            math.floor(
                group / groupsPerRow
            )

        frame:ClearAllPoints()

        frame:SetPoint(
            "TOPLEFT",
            Container,
            "TOPLEFT",
            groupColumn
            * (
                groupWidth
                + (config.horizontalSpacing or 0)
            ),
            -(
                groupRow
                * (
                    groupHeight
                    + config.groupSpacing
                )
                + member
                * (
                    totalHeight
                    + config.verticalSpacing
                )
            )
        )

        frame:SetSize(
            config.width,
            totalHeight
        )

        frame.Health:SetHeight(
            math.max(
                16,
                config.height - 2
            )
        )

        frame.Resource:SetHeight(
            config.resourceHeight or 4
        )

        frame.NameText:SetWidth(
            math.max(
                20,
                config.width - 34
            )
        )

        SetFontSize(
            frame.NameText,
            config.nameSize
        )

        SetFontSize(
            frame.LevelText,
            config.levelSize
        )

        SetFontSize(
            frame.HealthText,
            config.healthTextSize
        )

        frame.NameText:SetShown(
            config.showName
        )

        frame.HealthText:SetShown(
            config.showHealthPercent
        )

        local auraSize =
            config.auraIconSize or 11

        for slot, holder
        in ipairs(frame.HotIndicators) do
            holder:SetSize(auraSize, auraSize)
            holder:ClearAllPoints()
            holder:SetPoint(
                "TOPRIGHT",
                frame.Health,
                "TOPRIGHT",
                -3 - ((slot - 1) * (auraSize + 3)),
                -3
            )
        end

        for slot, holder
        in ipairs(frame.ClassBuffIndicators) do
            holder:SetSize(auraSize, auraSize)
            holder:ClearAllPoints()
            holder:SetPoint(
                "BOTTOMLEFT",
                frame.Health,
                "BOTTOMLEFT",
                3 + ((slot - 1) * (auraSize + 3)),
                3
            )
        end

        frame.DebuffIndicator:SetSize(
            auraSize,
            auraSize
        )
    end

    UpdateAll()
end

--------------------------------------------------
-- RANGE UPDATE TICKER
--------------------------------------------------

local RangeElapsed = 0

Container:SetScript(
    "OnUpdate",
    function(self, elapsed)
        RangeElapsed =
            RangeElapsed + elapsed

        if RangeElapsed < 0.20 then
            return
        end

        RangeElapsed = 0

        if PreviewEnabled then
            return
        end

        local config = EnsureConfig()

        if not config.enabled
            or not config.rangeFading
            or not IsInRaid() then
            return
        end

        for _, frame
        in ipairs(Frames) do
            if frame:IsShown()
                and UnitExists(frame.unit) then
                ApplyRangeState(
                    frame,
                    frame.unit
                )
            end
        end
    end
)

--------------------------------------------------
-- PUBLIC API
--------------------------------------------------

function RaidFrames:ApplyConfig()
    ApplyLayout()
end

function RaidFrames:ResetConfig()
    BlackoutUIDB.Config.UnitFrames.raid = nil
    EnsureConfig()
    ApplyLayout()
end

function RaidFrames:SetPreview(enabled)
    PreviewEnabled =
        enabled and true or false

    ApplyLayout()
end

function RaidFrames:IsPreviewEnabled()
    return PreviewEnabled
end

function RaidFrames:SetPreviewSize(size)
    if size ~= 10
        and size ~= 20
        and size ~= 40 then
        size = 20
    end

    PreviewSize = size
    ApplyLayout()
end

function RaidFrames:GetPreviewSize()
    return PreviewSize
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
    "GROUP_ROSTER_UPDATE"
)

EventFrame:RegisterEvent(
    "UNIT_HEALTH"
)

EventFrame:RegisterEvent(
    "UNIT_MAXHEALTH"
)

EventFrame:RegisterEvent(
    "UNIT_HEAL_PREDICTION"
)

EventFrame:RegisterEvent(
    "UNIT_THREAT_SITUATION_UPDATE"
)

EventFrame:RegisterEvent(
    "UNIT_POWER_UPDATE"
)

EventFrame:RegisterEvent(
    "UNIT_MAXPOWER"
)

EventFrame:RegisterEvent(
    "UNIT_DISPLAYPOWER"
)

EventFrame:RegisterEvent(
    "UNIT_NAME_UPDATE"
)

EventFrame:RegisterEvent(
    "UNIT_LEVEL"
)

EventFrame:RegisterEvent(
    "UNIT_AURA"
)

EventFrame:RegisterEvent(
    "UNIT_CONNECTION"
)

EventFrame:RegisterEvent(
    "UNIT_FLAGS"
)

EventFrame:SetScript(
    "OnEvent",
    function(self, event, unit)
        if event == "PLAYER_ENTERING_WORLD"
            or event == "GROUP_ROSTER_UPDATE" then
            ApplyLayout()
            return
        end

        if unit
            and string.match(
                unit,
                "^raid%d+$"
            ) then
            local index =
                tonumber(
                    string.match(
                        unit,
                        "%d+"
                    )
                )

            if index
                and Frames[index] then
                UpdateFrame(
                    Frames[index],
                    index
                )
            end
        end
    end
)

--------------------------------------------------
-- MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    Container,
    "RaidFrames",
    "RAID FRAMES"
)

--------------------------------------------------
-- INITIALIZE
--------------------------------------------------

EnsureConfig()
ApplyLayout()
