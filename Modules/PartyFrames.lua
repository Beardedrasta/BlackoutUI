--------------------------------------------------
-- BLACKOUT UI
-- Modules/PartyFrames.lua
--
-- Compact Grid-style Party Frames
--------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.PartyFrames = BlackoutUI.PartyFrames or {}
local PartyFrames = BlackoutUI.PartyFrames

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local DEFAULTS = {
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
}

local function EnsureConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.UnitFrames =
        BlackoutUIDB.Config.UnitFrames or {}

    BlackoutUIDB.Config.UnitFrames.party =
        BlackoutUIDB.Config.UnitFrames.party or {}

    local config =
        BlackoutUIDB.Config.UnitFrames.party

    for key, value in pairs(DEFAULTS) do
        if config[key] == nil then
            config[key] = value
        end
    end

    return config
end

local function SetFontSize(fontString, size)
    local font, _, flags = fontString:GetFont()
    if font then
        fontString:SetFont(font, size, flags)
    end
end

--------------------------------------------------
-- CONTAINER
--------------------------------------------------

local Container =
    CreateFrame(
        "Frame",
        "BlackoutUI_PartyFrames",
        UIParent
    )

Container:SetPoint("LEFT", UIParent, "LEFT", 28, 70)
Container:SetSize(125, 204)
Container:SetClampedToScreen(true)

--------------------------------------------------
-- PREVIEW
--------------------------------------------------

local PreviewEnabled = false

local PreviewData = {
    { name = "Hunter",       health = 100, class = "WARRIOR", hot = true },
    { name = "Brittany",     health = 78, class = "PRIEST", hot = true },
    { name = "Asher",        health = 56, class = "ROGUE", debuff = true },
    { name = "Party Member 4", health = 32, class = "MAGE", missing = true },
}

--------------------------------------------------
-- AURA HELPERS
--------------------------------------------------

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
-- CREATE GRID CELL
--------------------------------------------------

local Frames = {}

local function CreateIndicator(parent, point, x, y)
    local holder =
        CreateFrame("Frame", nil, parent)

    holder:SetSize(14, 14)
    holder:SetPoint(point, parent, point, x, y)

    local icon =
        holder:CreateTexture(nil, "OVERLAY")

    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    holder.Icon = icon

    local time =
        BlackoutUI:CreateFont(holder, 7)

    time:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
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

local function CreatePartyCell(index)
    local unit =
        index == 1
        and "player"
        or ("party" .. (index - 1))

    local frame =
        CreateFrame(
            "Button",
            "BlackoutUI_PartyFrame" .. index,
            Container,
            "SecureUnitButtonTemplate"
        )

    frame.unit = unit
    frame:RegisterForClicks("AnyUp")
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("type1", "target")
    frame:SetAttribute("type2", "togglemenu")
    frame:SetSize(DEFAULTS.width, DEFAULTS.height)

    local bg =
        frame:CreateTexture(nil, "BACKGROUND")

    bg:SetAllPoints()
    bg:SetColorTexture(0.025, 0.025, 0.025, 0.96)
    frame.Background = bg

    BlackoutUI:CreateBorder(
        frame,
        1,
        "borderBright"
    )

    --------------------------------------------------
    -- HEALTH IS THE ENTIRE CELL
    --------------------------------------------------

    local health =
        CreateFrame("StatusBar", nil, frame)

    health:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    health:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    health:SetHeight(DEFAULTS.height - 4)
    health:SetStatusBarTexture(
        "Interface\\Buttons\\WHITE8x8"
    )

    health:SetMinMaxValues(0, 1)
    health:SetValue(1)
    frame.Health = health

    local healthBG =
        health:CreateTexture(nil, "BACKGROUND")

    healthBG:SetAllPoints()
    healthBG:SetColorTexture(0.035, 0.035, 0.035, 1)

    --------------------------------------------------
    -- INCOMING HEAL PREDICTION
    --------------------------------------------------

    local incomingHeal =
        health:CreateTexture(nil, "ARTWORK")

    incomingHeal:SetTexture(
        "Interface\\Buttons\\WHITE8x8"
    )
    incomingHeal:SetPoint("TOP", health, "TOP", 0, 0)
    incomingHeal:SetPoint("BOTTOM", health, "BOTTOM", 0, 0)
    incomingHeal:SetColorTexture(
        0.25, 1.00, 0.35,
        DEFAULTS.incomingHealAlpha
    )
    incomingHeal:Hide()
    frame.IncomingHeal = incomingHeal

    --------------------------------------------------
    -- NAME
    --------------------------------------------------

    local name =
        BlackoutUI:CreateFont(
            health,
            DEFAULTS.nameSize
        )

    name:SetPoint("CENTER", health, "CENTER", 0, 7)
    name:SetWidth(DEFAULTS.width - 44)
    name:SetJustifyH("CENTER")
    name:SetWordWrap(false)
    frame.NameText = name

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
        -4
    )

    levelText:SetJustifyH("LEFT")
    frame.LevelText = levelText

    --------------------------------------------------
    -- HEALTH %
    --------------------------------------------------

    local percent =
        BlackoutUI:CreateFont(
            health,
            DEFAULTS.healthTextSize
        )

    percent:SetPoint(
        "CENTER",
        health,
        "CENTER",
        0,
        -8
    )

    frame.HealthPercent = percent

    --------------------------------------------------
    -- SLIM RESOURCE BAR
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

    resource:SetHeight(
        DEFAULTS.resourceHeight
    )

    resource:SetMinMaxValues(0, 1)
    resource:SetValue(1)

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
        0.95
    )

    frame.Resource = resource

    --------------------------------------------------
    -- INDICATORS
    --------------------------------------------------

    frame.HotIndicators = {}

    frame.HotIndicators[1] =
        CreateIndicator(
            health,
            "TOPRIGHT",
            -4,
            -4
        )

    frame.HotIndicators[2] =
        CreateIndicator(
            health,
            "TOPRIGHT",
            -22,
            -4
        )

    -- Compatibility alias while the config system is evolving.
    frame.MyBuffIndicator =
        frame.HotIndicators[1]

    frame.DebuffIndicator =
        CreateIndicator(
            health,
            "BOTTOMRIGHT",
            -4,
            4
        )

    frame.ClassBuffIndicators = {}

    for slot = 1, 3 do
        frame.ClassBuffIndicators[slot] =
            CreateIndicator(
                health,
                "BOTTOMLEFT",
                4 + ((slot - 1) * 18),
                4
            )
    end

    -- Compatibility aliases while Config/Raid sharing is being built.
    frame.ClassBuffIndicator =
        frame.ClassBuffIndicators[1]

    frame.MissingBuffIndicator =
        frame.ClassBuffIndicators[1]

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

    Frames[index] = frame
    return frame
end

for i = 1, 5 do
    CreatePartyCell(i)
end

--------------------------------------------------
-- CLASS COLOR
--------------------------------------------------

local function SetClassHealthColor(frame, unit, previewClass)
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
-- INDICATORS
--------------------------------------------------

local function SetClassBuffIndicator(holder, state)
    if not holder then
        return
    end

    holder.OwnerDot:Hide()
    holder:SetAlpha(1)

    if not state
        or not state.applicable then
        holder:Hide()
        return
    end

    local aura =
        state.mine
        or state.other

    if aura then
        SetIndicator(holder, aura)

        if state.mine then
            -- You supplied this class buff.
            holder:SetAlpha(1.0)
            holder.OwnerDot:SetColorTexture(
                0.25,
                1.00,
                0.35,
                1
            )
        else
            -- Another player supplied a buff you could provide.
            holder:SetAlpha(0.60)
            holder.OwnerDot:SetColorTexture(
                1.00,
                0.82,
                0.20,
                1
            )
        end

        holder.OwnerDot:Show()
        return
    end

    -- Relevant buff is genuinely missing.
    holder.Icon:SetTexture(
        "Interface\\\\Buttons\\\\UI-GroupLoot-Pass-Up"
    )
    holder.Time:SetText("!")
    holder:SetAlpha(1)
    holder.OwnerDot:SetColorTexture(
        1.00,
        0.25,
        0.20,
        1
    )
    holder.OwnerDot:Show()
    holder:Show()
end

local function UpdateIndicators(frame)
    local config = EnsureConfig()

    if not config.showAuraIndicators then
        for _, holder
        in ipairs(frame.HotIndicators) do
            holder:Hide()
        end
        frame.DebuffIndicator:Hide()

        for _, holder
        in ipairs(frame.ClassBuffIndicators) do
            holder:Hide()
        end

        return
    end

    if config.showMyBuffs then
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

    if config.showDispellableDebuffs then
        SetIndicator(
            frame.DebuffIndicator,
            FindDispellableDebuff(frame.unit)
        )
    else
        frame.DebuffIndicator:Hide()
    end

    for _, holder
    in ipairs(frame.ClassBuffIndicators) do
        holder:Hide()
    end

    if config.showMissingClassBuff then
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
end

--------------------------------------------------
-- RESOURCE BAR
--------------------------------------------------

local RESOURCE_COLORS = {
    [0] = { 0.10, 0.42, 0.88, 1 }, -- Mana
    [1] = { 0.88, 0.16, 0.12, 1 }, -- Rage
    [2] = { 0.82, 0.58, 0.12, 1 }, -- Focus
    [3] = { 0.88, 0.78, 0.18, 1 }, -- Energy
}

local function UpdateResource(frame, unit)
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

    local color =
        RESOURCE_COLORS[powerType]
        or RESOURCE_COLORS[0]

    frame.Resource:SetStatusBarColor(
        unpack(color)
    )

    frame.Resource:Show()
end

--------------------------------------------------
-- PREVIEW CELL
--------------------------------------------------

local function ApplyPreview(frame, index)
    local data = PreviewData[index]

    frame:Show()

    frame.NameText:SetText(data.name)
    frame.LevelText:SetText(
        index == 4 and "58" or "60"
    )
    frame.Health:SetMinMaxValues(0, 100)
    frame.Health:SetValue(data.health)
    frame.HealthPercent:SetText(data.health .. "%")

    local config = EnsureConfig()

    if config.showResourceBar then
        frame.Resource:Show()
        frame.Resource:SetMinMaxValues(0, 100)
        frame.Resource:SetValue(
            index == 1 and 68
            or index == 2 and 82
            or index == 3 and 100
            or 54
        )

        local previewPowerType =
            index == 1 and 1
            or index == 3 and 3
            or 0

        frame.Resource:SetStatusBarColor(
            unpack(
                RESOURCE_COLORS[previewPowerType]
                or RESOURCE_COLORS[0]
            )
        )
    else
        frame.Resource:Hide()
    end

    SetClassHealthColor(
        frame,
        frame.unit,
        data.class
    )

    for _, holder
    in ipairs(frame.HotIndicators) do
        holder:Hide()
        holder.OwnerDot:Hide()
        holder:SetAlpha(1)
    end

    frame.DebuffIndicator:SetShown(data.debuff or false)

    for _, holder
    in ipairs(frame.ClassBuffIndicators) do
        holder:Hide()
        holder.OwnerDot:Hide()
        holder:SetAlpha(1)
    end

    -- Preview three independent buff families:
    -- green = mine, yellow = another player's, red = missing.
    if index == 1 then
        local first =
            frame.ClassBuffIndicators[1]

        first.Icon:SetTexture(
            "Interface\\Icons\\Spell_Holy_WordFortitude"
        )
        first.Time:SetText("28m")
        first.OwnerDot:SetColorTexture(
            0.25, 1.00, 0.35, 1
        )
        first.OwnerDot:Show()
        first:Show()

        local second =
            frame.ClassBuffIndicators[2]

        second.Icon:SetTexture(
            "Interface\\Icons\\Spell_Holy_DivineSpirit"
        )
        second.Time:SetText("24m")
        second:SetAlpha(0.60)
        second.OwnerDot:SetColorTexture(
            1.00, 0.82, 0.20, 1
        )
        second.OwnerDot:Show()
        second:Show()

        local third =
            frame.ClassBuffIndicators[3]

        third.Icon:SetTexture(
            "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
        )
        third.Time:SetText("!")
        third.OwnerDot:SetColorTexture(
            1.00, 0.25, 0.20, 1
        )
        third.OwnerDot:Show()
        third:Show()
    elseif index == 2 then
        local first =
            frame.ClassBuffIndicators[1]

        first.Icon:SetTexture(
            "Interface\\Icons\\Spell_Holy_WordFortitude"
        )
        first.Time:SetText("18m")
        first:SetAlpha(0.60)
        first.OwnerDot:SetColorTexture(
            1.00, 0.82, 0.20, 1
        )
        first.OwnerDot:Show()
        first:Show()
    elseif index == 4 then
        local first =
            frame.ClassBuffIndicators[1]

        first.Icon:SetTexture(
            "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
        )
        first.Time:SetText("!")
        first.OwnerDot:SetColorTexture(
            1.00, 0.25, 0.20, 1
        )
        first.OwnerDot:Show()
        first:Show()
    end

    if data.hot then
        local holder =
            frame.HotIndicators[1]

        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Nature_Rejuvenation"
        )
        holder.Time:SetText("12")
        holder:SetAlpha(
            index == 2 and 0.55 or 1
        )

        if index == 2 then
            holder.OwnerDot:SetColorTexture(
                1.00, 0.82, 0.20, 1
            )
        else
            holder.OwnerDot:SetColorTexture(
                0.25, 1.00, 0.35, 1
            )
        end

        holder.OwnerDot:Show()
        holder:Show()
    end

    -- Show a second HoT slot on one preview unit.
    if index == 1
        and frame.HotIndicators[2] then
        local holder =
            frame.HotIndicators[2]

        holder.Icon:SetTexture(
            "Interface\\Icons\\Spell_Nature_ResistNature"
        )
        holder.Time:SetText("7")
        holder:SetAlpha(0.55)
        holder.OwnerDot:SetColorTexture(
            1.00, 0.82, 0.20, 1
        )
        holder.OwnerDot:Show()
        holder:Show()
    end

    if data.debuff then
        frame.DebuffIndicator.Icon:SetTexture(
            "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
        )
        frame.DebuffIndicator.Time:SetText("6")
    end
end

--------------------------------------------------
-- HEAL PREDICTION
--------------------------------------------------

local function UpdateIncomingHeal(frame, unit)
    local config = EnsureConfig()

    if not config.showIncomingHeals
        or not UnitExists(unit)
        or UnitIsDeadOrGhost(unit)
        or not UnitIsConnected(unit) then
        frame.IncomingHeal:Hide()
        return
    end

    local maximum = UnitHealthMax(unit) or 0
    local current = UnitHealth(unit) or 0

    if maximum <= 0 or current >= maximum then
        frame.IncomingHeal:Hide()
        return
    end

    local incoming =
        UnitGetIncomingHeals
        and (UnitGetIncomingHeals(unit) or 0)
        or 0

    local effective =
        math.min(
            incoming,
            maximum - current
        )

    if effective <= 0 then
        frame.IncomingHeal:Hide()
        return
    end

    local width = frame.Health:GetWidth()

    if not width or width <= 0 then
        frame.IncomingHeal:Hide()
        return
    end

    local currentFraction = current / maximum
    local healFraction = effective / maximum

    frame.IncomingHeal:ClearAllPoints()
    frame.IncomingHeal:SetPoint(
        "TOPLEFT",
        frame.Health,
        "TOPLEFT",
        width * currentFraction,
        0
    )
    frame.IncomingHeal:SetPoint(
        "BOTTOMLEFT",
        frame.Health,
        "BOTTOMLEFT",
        width * currentFraction,
        0
    )
    frame.IncomingHeal:SetWidth(
        math.max(
            1,
            width * healFraction
        )
    )
    frame.IncomingHeal:SetColorTexture(
        0.25,
        1.00,
        0.35,
        config.incomingHealAlpha or 0.45
    )
    frame.IncomingHeal:Show()
end

--------------------------------------------------
-- AGGRO / THREAT
--------------------------------------------------

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

--------------------------------------------------
-- LIVE UNIT UPDATE
--------------------------------------------------

local function ShouldShowPartyFrame(frame)
    local config = EnsureConfig()
    return not (
        frame.unit == "player"
        and not config.showPlayer
    )
end

local function ApplyPartyStatus(frame, unit)
    local config = EnsureConfig()

    if not UnitIsConnected(unit) then
        if config.showStatusText then
            frame.HealthPercent:SetText("OFFLINE")
        end
        frame:SetAlpha(config.offlineAlpha or 0.35)
        return
    end

    if UnitIsDeadOrGhost(unit) then
        if config.showStatusText then
            frame.HealthPercent:SetText(
                UnitIsGhost(unit) and "GHOST" or "DEAD"
            )
        end
        frame:SetAlpha(config.deadAlpha or 0.55)
        return
    end

    if not config.rangeFading or unit == "player" then
        frame:SetAlpha(1)
        return
    end

    local inRange = UnitInRange(unit)
    frame:SetAlpha(
        inRange == false
        and (config.outOfRangeAlpha or 0.45)
        or 1
    )
end

local function UpdateFrame(frame, index)
    local config = EnsureConfig()

    if PreviewEnabled then
        if frame.unit == "player" then
            -- Reuse the first preview style for the player's own cell.
            ApplyPreview(frame, 1)
            frame.NameText:SetText(
                UnitName("player") or "YOU"
            )
            frame:Show()
        else
            -- Party1..party4 use the four existing preview samples.
            ApplyPreview(frame, index - 1)
        end

        return
    end

    if not config.enabled
        or not UnitExists(frame.unit)
        or not ShouldShowPartyFrame(frame) then
        frame:Hide()
        return
    end

    frame:Show()

    local unit = frame.unit

    frame.NameText:SetText(
        UnitName(unit) or ""
    )

    local level =
        UnitLevel(unit)

    if level and level > 0 then
        frame.LevelText:SetText(level)
    else
        frame.LevelText:SetText("??")
    end

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
                current / maximum * 100
                + 0.5
            )
    end

    frame.HealthPercent:SetText(
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

    UpdateIndicators(frame)

    UpdateIncomingHeal(
        frame,
        unit
    )

    UpdateThreat(
        frame,
        unit
    )

    ApplyPartyStatus(
        frame,
        unit
    )
end

local function UpdateAll()
    for index, frame in ipairs(Frames) do
        UpdateFrame(frame, index)
    end
end

--------------------------------------------------
-- LAYOUT
--------------------------------------------------

local function ApplyLayout()
    local config = EnsureConfig()

    Container:SetScale(config.scale)

    local resourceExtra =
        config.showResourceBar
        and ((config.resourceHeight or 5) + 1)
        or 0

    local totalHeight =
        config.height + resourceExtra

    local visibleSlot = 0
    local visibleCount =
        config.showPlayer and 5 or 4

    if config.growthDirection == "HORIZONTAL" then
        Container:SetSize(
            (config.width * visibleCount)
            + (config.spacing * math.max(0, visibleCount - 1)),
            totalHeight
        )
    else
        Container:SetSize(
            config.width,
            (totalHeight * visibleCount)
            + (config.spacing * math.max(0, visibleCount - 1))
        )
    end

    for index, frame in ipairs(Frames) do
        frame:ClearAllPoints()

        local layoutVisible =
            frame.unit ~= "player"
            or config.showPlayer

        if layoutVisible then
            visibleSlot = visibleSlot + 1

            if config.growthDirection == "HORIZONTAL" then
                frame:SetPoint(
                    "TOPLEFT",
                    Container,
                    "TOPLEFT",
                    (visibleSlot - 1)
                    * (config.width + config.spacing),
                    0
                )
            else
                frame:SetPoint(
                    "TOPLEFT",
                    Container,
                    "TOPLEFT",
                    0,
                    -((visibleSlot - 1)
                        * (totalHeight + config.spacing))
                )
            end
        end

        frame:SetSize(
            config.width,
            totalHeight
        )

        frame.Health:SetHeight(
            math.max(
                12,
                config.height - 4
            )
        )

        SetFontSize(
            frame.NameText,
            config.nameSize
        )

        SetFontSize(
            frame.LevelText,
            config.levelSize or 8
        )

        SetFontSize(
            frame.HealthPercent,
            config.healthTextSize
        )

        frame.NameText:SetShown(
            config.showName
        )

        frame.HealthPercent:SetShown(
            config.showHealthPercent
        )

        frame.NameText:SetWidth(
            math.max(
                20,
                config.width - 44
            )
        )

        frame.Resource:SetHeight(
            config.resourceHeight or 5
        )

        frame.Resource:SetShown(
            config.showResourceBar
        )

        local auraSize =
            config.auraIconSize or 14

        for _, holder
        in ipairs(frame.HotIndicators) do
            holder:SetSize(
                auraSize,
                auraSize
            )
        end

        if frame.HotIndicators[2] then
            frame.HotIndicators[2]:ClearAllPoints()
            frame.HotIndicators[2]:SetPoint(
                "TOPRIGHT",
                frame.Health,
                "TOPRIGHT",
                -(auraSize + 8),
                -4
            )
        end

        frame.DebuffIndicator:SetSize(auraSize, auraSize)

        for slot, holder
        in ipairs(frame.ClassBuffIndicators) do
            holder:SetSize(
                auraSize,
                auraSize
            )

            holder:ClearAllPoints()

            holder:SetPoint(
                "BOTTOMLEFT",
                frame.Health,
                "BOTTOMLEFT",
                4 + ((slot - 1) * (auraSize + 4)),
                4
            )
        end
    end

    UpdateAll()
end

--------------------------------------------------
-- PUBLIC API
--------------------------------------------------

function PartyFrames:ApplyConfig()
    ApplyLayout()
end

function PartyFrames:ResetConfig()
    BlackoutUIDB.Config.UnitFrames.party = nil
    EnsureConfig()
    ApplyLayout()
end

function PartyFrames:SetPreview(enabled)
    PreviewEnabled =
        enabled and true or false

    ApplyLayout()
end

function PartyFrames:IsPreviewEnabled()
    return PreviewEnabled
end

function PartyFrames:SetGrowthDirection(direction)
    local config = EnsureConfig()

    if direction ~= "HORIZONTAL" then
        direction = "VERTICAL"
    end

    config.growthDirection = direction
    ApplyLayout()
end

--------------------------------------------------
-- RANGE UPDATE
--------------------------------------------------

local RangeElapsed = 0

Container:SetScript(
    "OnUpdate",
    function(self, elapsed)
        RangeElapsed = RangeElapsed + elapsed

        if RangeElapsed < 0.20 then return end
        RangeElapsed = 0

        for _, frame in ipairs(Frames) do
            if frame:IsShown()
                and UnitExists(frame.unit) then
                ApplyPartyStatus(frame, frame.unit)
            end
        end
    end
)

--------------------------------------------------
-- EVENTS
--------------------------------------------------

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:RegisterEvent("UNIT_HEALTH")
EventFrame:RegisterEvent("UNIT_MAXHEALTH")
EventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
EventFrame:RegisterEvent("UNIT_POWER_UPDATE")
EventFrame:RegisterEvent("UNIT_MAXPOWER")
EventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
EventFrame:RegisterEvent("UNIT_NAME_UPDATE")
EventFrame:RegisterEvent("UNIT_LEVEL")
EventFrame:RegisterEvent("UNIT_AURA")
EventFrame:RegisterEvent("UNIT_CONNECTION")
EventFrame:RegisterEvent("UNIT_FLAGS")
EventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")

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
                "^party[1-4]$"
            ) then
            for index, frame in ipairs(Frames) do
                if frame.unit == unit then
                    UpdateFrame(frame, index)
                    break
                end
            end
        end
    end
)

--------------------------------------------------
-- MOVER
--------------------------------------------------

BlackoutUI:RegisterMovableFrame(
    Container,
    "PartyFrames",
    "PARTY FRAMES"
)

--------------------------------------------------
-- INITIALIZE
--------------------------------------------------

EnsureConfig()
ApplyLayout()
