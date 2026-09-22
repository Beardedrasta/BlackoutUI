------------------------------------------------------------
-- BlackoutUI
-- Bags.lua
-- Combined inventory - Step 1
------------------------------------------------------------

local addonName, BlackoutUI = ...
BlackoutUI.Bags = BlackoutUI.Bags or {}

local Bags = BlackoutUI.Bags

------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------

-- Physical bag order shown left-to-right in the default UI.
-- Backpack first, then equipped bag slots 1 through 4.
local BAG_IDS = { 0, 1, 2, 3, 4 }

local DEFAULTS = {
    enabled = true,
    columns = 10,
    iconSize = 36,
    spacing = 4,
    scale = 1.0,
    showEmptySlots = true,
}

local QUALITY_COLORS = {
    [0] = { 0.45, 0.45, 0.45 }, -- Poor
    [1] = { 0.72, 0.72, 0.72 }, -- Common
    [2] = { 0.12, 1.00, 0.00 }, -- Uncommon
    [3] = { 0.00, 0.44, 0.87 }, -- Rare
    [4] = { 0.64, 0.21, 0.93 }, -- Epic
    [5] = { 1.00, 0.50, 0.00 }, -- Legendary
}

------------------------------------------------------------
-- DATABASE
------------------------------------------------------------

local function GetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.Bags = BlackoutUIDB.Config.Bags or {}

    local db = BlackoutUIDB.Config.Bags

    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

------------------------------------------------------------
-- API HELPERS
------------------------------------------------------------

local function GetNumSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag) or 0
    end

    if GetContainerNumSlots then
        return GetContainerNumSlots(bag) or 0
    end

    return 0
end

local function GetBagItemData(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)

        if not info then
            return nil
        end

        return {
            icon = info.iconFileID,
            count = info.stackCount or 1,
            locked = info.isLocked,
            quality = info.quality,
            link = info.hyperlink,
            itemID = info.itemID,
            noValue = info.hasNoValue,
        }
    end

    if GetContainerItemInfo then
        local icon, count, locked, quality, _, _, link, _, noValue, itemID =
            GetContainerItemInfo(bag, slot)

        if not icon then
            return nil
        end

        return {
            icon = icon,
            count = count or 1,
            locked = locked,
            quality = quality,
            link = link,
            itemID = itemID,
            noValue = noValue,
        }
    end

    return nil
end

local function PickupItem(bag, slot)
    if C_Container and C_Container.PickupContainerItem then
        C_Container.PickupContainerItem(bag, slot)
    elseif PickupContainerItem then
        PickupContainerItem(bag, slot)
    end
end

local function UseItem(bag, slot)
    if C_Container and C_Container.UseContainerItem then
        C_Container.UseContainerItem(bag, slot)
    elseif UseContainerItem then
        UseContainerItem(bag, slot)
    end
end

local function SplitItem(bag, slot, amount)
    if C_Container and C_Container.SplitContainerItem then
        C_Container.SplitContainerItem(bag, slot, amount)
    elseif SplitContainerItem then
        SplitContainerItem(bag, slot, amount)
    end
end

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------

local Frame =
    CreateFrame(
        "Frame",
        "BlackoutUI_Bags",
        UIParent,
        "BackdropTemplate"
    )

Bags.Frame = Frame

Frame:SetPoint("RIGHT", UIParent, "RIGHT", -34, 0)
Frame:SetFrameStrata("HIGH")
Frame:SetClampedToScreen(true)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:Hide()

Frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})

Frame:SetBackdropColor(0.012, 0.012, 0.012, 0.97)
Frame:SetBackdropBorderColor(0.22, 0.66, 0.92, 1)

Frame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)

Frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local db = GetConfig()
    local point, _, relativePoint, x, y = self:GetPoint(1)

    db.point = point
    db.relativePoint = relativePoint
    db.x = x
    db.y = y
end)

------------------------------------------------------------
-- HEADER
------------------------------------------------------------

local Header =
    CreateFrame(
        "Frame",
        nil,
        Frame,
        "BackdropTemplate"
    )

Header:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
Header:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -1)
Header:SetHeight(34)

Header:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
})

Header:SetBackdropColor(0.025, 0.025, 0.025, 1)

local Title = Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Title:SetPoint("LEFT", Header, "LEFT", 11, 0)
Title:SetText("INVENTORY")
Title:SetTextColor(0.86, 0.88, 0.90, 1)

local Close =
    CreateFrame(
        "Button",
        nil,
        Header,
        "BackdropTemplate"
    )

Close:SetSize(24, 24)
Close:SetPoint("RIGHT", Header, "RIGHT", -6, 0)

Close:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})

Close:SetBackdropColor(0.03, 0.03, 0.03, 1)
Close:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)

local CloseText = Close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
CloseText:SetPoint("CENTER")
CloseText:SetText("×")
CloseText:SetTextColor(0.85, 0.85, 0.85, 1)

Close:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(0.22, 0.66, 0.92, 1)
    CloseText:SetTextColor(0.22, 0.66, 0.92, 1)
end)

Close:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)
    CloseText:SetTextColor(0.85, 0.85, 0.85, 1)
end)

Close:SetScript("OnClick", function()
    Frame:Hide()
end)

------------------------------------------------------------
-- BAG SPACE
------------------------------------------------------------

local SpaceText =
    Header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

SpaceText:SetPoint("RIGHT", Close, "LEFT", -10, 0)
SpaceText:SetTextColor(0.60, 0.62, 0.65, 1)

------------------------------------------------------------
-- MONEY
------------------------------------------------------------

local MoneyText =
    Frame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

MoneyText:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -10, 10)
MoneyText:SetTextColor(0.86, 0.88, 0.90, 1)

local function FormatMoney(copper)
    copper = copper or 0

    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copperOnly = copper % 100

    return string.format(
        "|cffffd700%dg|r  |cffc7c7cf%ds|r  |cffb87333%dc|r",
        gold,
        silver,
        copperOnly
    )
end

------------------------------------------------------------
-- ITEM BUTTONS
------------------------------------------------------------

local Buttons = {}

local function CreateItemButton(index)
    local button =
        CreateFrame(
            "Button",
            "BlackoutUI_BagSlot" .. index,
            Frame,
            "BackdropTemplate"
        )

    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })

    button:SetBackdropColor(0.025, 0.025, 0.025, 1)
    button:SetBackdropBorderColor(0.16, 0.17, 0.18, 1)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.Icon = icon

    local count =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "NumberFontNormalSmall"
        )

    count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    count:SetJustifyH("RIGHT")
    button.Count = count

    local junk = button:CreateTexture(nil, "OVERLAY")
    junk:SetSize(10, 10)
    junk:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    junk:SetColorTexture(0.55, 0.55, 0.55, 0.95)
    junk:Hide()
    button.Junk = junk

    local bagType =
        button:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalSmall"
        )

    bagType:SetPoint(
        "TOP",
        button,
        "TOP",
        0,
        -3
    )
    bagType:SetTextColor(
        0.22,
        0.66,
        0.92,
        1
    )
    bagType:Hide()
    button.BagType = bagType

    button:SetScript("OnEnter", function(self)
        if not self.bag or not self.slot then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetBagItem(self.bag, self.slot)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function(self, mouseButton)
        if not self.bag or not self.slot then
            return
        end

        if mouseButton == "RightButton" then
            UseItem(self.bag, self.slot)
        else
            PickupItem(self.bag, self.slot)
        end
    end)

    button:SetScript("OnDragStart", function(self)
        if self.bag and self.slot then
            PickupItem(self.bag, self.slot)
        end
    end)

    button:SetScript("OnReceiveDrag", function(self)
        if self.bag and self.slot then
            PickupItem(self.bag, self.slot)
        end
    end)

    button:Hide()

    Buttons[index] = button
    return button
end

------------------------------------------------------------
-- BLIZZARD BAG FRAME HIDING
------------------------------------------------------------

local function HideBlizzardBags()
    for index = 1, 13 do
        local container = _G["ContainerFrame" .. index]

        if container and container:IsShown() then
            container:Hide()
        end
    end
end

------------------------------------------------------------
-- BAG TYPES / SPECIALIZED CONTAINERS
------------------------------------------------------------

local function GetBagFamily(bag)
    -- Bag 0 is the backpack and has no specialized family.
    if bag == 0 then
        return 0
    end

    if C_Container and C_Container.GetContainerNumFreeSlots then
        local _, family =
            C_Container.GetContainerNumFreeSlots(bag)

        return family or 0
    end

    if GetContainerNumFreeSlots then
        local _, family =
            GetContainerNumFreeSlots(bag)

        return family or 0
    end

    return 0
end

local function GetBagTypeLabel(family)
    if not family or family == 0 then
        return nil
    end

    -- Classic bag-family masks. We only label families we can identify
    -- confidently; unknown specialized bags still receive SPECIAL BAG.
    if bit and bit.band then
        if bit.band(family, 1) ~= 0
            or bit.band(family, 2) ~= 0 then
            return "AMMO"
        end
    elseif bit32 and bit32.band then
        if bit32.band(family, 1) ~= 0
            or bit32.band(family, 2) ~= 0 then
            return "AMMO"
        end
    end

    return "SPECIAL BAG"
end

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------

local SearchBox =
    CreateFrame(
        "EditBox",
        "BlackoutUI_BagSearch",
        Frame,
        "BackdropTemplate"
    )

SearchBox:SetHeight(24)
SearchBox:SetPoint("TOPLEFT", Frame, "TOPLEFT", 10, -42)
SearchBox:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -10, -42)
SearchBox:SetAutoFocus(false)
SearchBox:SetFontObject("GameFontHighlightSmall")
SearchBox:SetTextInsets(8, 8, 0, 0)

SearchBox:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})

SearchBox:SetBackdropColor(0.018, 0.018, 0.018, 1)
SearchBox:SetBackdropBorderColor(0.14, 0.15, 0.16, 1)

local SearchHint =
    SearchBox:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontDisableSmall"
    )

SearchHint:SetPoint("LEFT", SearchBox, "LEFT", 8, 0)
SearchHint:SetText("Search inventory...")

SearchBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

SearchBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)

local function GetSearchText()
    return string.lower(
        SearchBox:GetText() or ""
    )
end

------------------------------------------------------------
-- REFRESH
------------------------------------------------------------

local function Refresh()
    local db = GetConfig()

    if db.enabled == false then
        Frame:Hide()
        return
    end

    local entries = {}
    local totalSlots = 0
    local usedSlots = 0

    local search = GetSearchText()

    -- Display ordinary inventory first and specialized containers last.
    -- This avoids an ammo/quiver bag in physical slot 1-3 interrupting the
    -- normal inventory flow simply because of where it is equipped.
    local displayBagIDs = {}

    for _, bag in ipairs(BAG_IDS) do
        if GetBagFamily(bag) == 0 then
            displayBagIDs[#displayBagIDs + 1] = bag
        end
    end

    for _, bag in ipairs(BAG_IDS) do
        if GetBagFamily(bag) ~= 0 then
            displayBagIDs[#displayBagIDs + 1] = bag
        end
    end

    for _, bag in ipairs(displayBagIDs) do
        local numSlots = GetNumSlots(bag)
        local family = GetBagFamily(bag)
        local firstVisibleIndex = #entries + 1

        for slot = 1, numSlots do
            totalSlots = totalSlots + 1

            local info = GetBagItemData(bag, slot)

            if info then
                usedSlots = usedSlots + 1
            end

            if info or db.showEmptySlots then
                local include = true

                if search ~= "" then
                    include = false

                    if info and info.itemID then
                        local itemName =
                            _G.GetItemInfo(info.itemID)

                        if itemName
                            and string.find(
                                string.lower(itemName),
                                search,
                                1,
                                true
                            ) then
                            include = true
                        end
                    end
                end

                if include then
                    entries[#entries + 1] = {
                        bag = bag,
                        slot = slot,
                        info = info,
                        family = family,
                        bagStart =
                            (#entries + 1 == firstVisibleIndex),
                    }
                end
            end
        end
    end

    local columns = math.max(4, db.columns or 10)
    local iconSize = db.iconSize or 36
    local spacing = db.spacing or 4
    local padding = 10

    local normalSlotCount = 0
    local specializedSlotCount = 0

    for _, bag in ipairs(displayBagIDs) do
        local count = GetNumSlots(bag)

        if GetBagFamily(bag) == 0 then
            normalSlotCount =
                normalSlotCount + count
        else
            specializedSlotCount =
                specializedSlotCount + count
        end
    end

    local normalRows =
        math.ceil(normalSlotCount / columns)

    local specializedRows =
        math.ceil(specializedSlotCount / columns)

    local rows =
        math.max(
            1,
            normalRows + specializedRows
        )

    local contentWidth =
        (columns * iconSize)
        + ((columns - 1) * spacing)

    local contentHeight =
        (rows * iconSize)
        + ((rows - 1) * spacing)

    Frame:SetScale(db.scale or 1)
    Frame:SetSize(
        contentWidth + (padding * 2),
        64 + 10 + contentHeight + 34
    )

    if db.point then
        Frame:ClearAllPoints()
        Frame:SetPoint(
            db.point,
            UIParent,
            db.relativePoint or db.point,
            db.x or 0,
            db.y or 0
        )
    end

    for index, entry in ipairs(entries) do
        local button =
            Buttons[index]
            or CreateItemButton(index)

        button.bag = entry.bag
        button.slot = entry.slot

        -- Keep the physical bag identity attached to every slot. Specialized
        -- containers (ammo/quiver/etc.) still remain part of this one combined
        -- grid instead of becoming separate Blizzard bag windows.
        button:SetAttribute("bag", entry.bag)
        button:SetAttribute("slot", entry.slot)

        button:SetSize(iconSize, iconSize)
        button:ClearAllPoints()

        -- Normal backpack/bag slots flow together as one continuous grid.
        -- Specialized containers are kept at the end as a separate continuous
        -- section so ammo slots remain visually identifiable.
        local displayIndex = 0

        if entry.family == 0 then
            for _, priorBag in ipairs(displayBagIDs) do
                if GetBagFamily(priorBag) == 0 then
                    if priorBag == entry.bag then
                        displayIndex =
                            displayIndex + entry.slot
                        break
                    end

                    displayIndex =
                        displayIndex + GetNumSlots(priorBag)
                end
            end
        else
            displayIndex = normalRows * columns

            for _, priorBag in ipairs(displayBagIDs) do
                if GetBagFamily(priorBag) ~= 0 then
                    if priorBag == entry.bag then
                        displayIndex =
                            displayIndex + entry.slot
                        break
                    end

                    displayIndex =
                        displayIndex + GetNumSlots(priorBag)
                end
            end
        end

        local zeroIndex =
            math.max(0, displayIndex - 1)

        local column =
            zeroIndex % columns

        local row =
            math.floor(
                zeroIndex / columns
            )

        button:SetPoint(
            "TOPLEFT",
            Frame,
            "TOPLEFT",
            padding + (column * (iconSize + spacing)),
            -(74 + (row * (iconSize + spacing)))
        )

        local bagLabel =
            GetBagTypeLabel(entry.family)

        if bagLabel then
            button.BagType:SetText(
                bagLabel == "AMMO" and "A" or "S"
            )
            button.BagType:Show()

            -- Specialized empty slots get a blue border instead of looking
            -- like ordinary general-purpose empty slots.
            if not entry.info then
                button:SetBackdropBorderColor(
                    0.22,
                    0.66,
                    0.92,
                    1
                )
            end
        else
            button.BagType:Hide()
        end

        local info = entry.info

        if info then
            button.Icon:SetTexture(info.icon)
            button.Icon:SetDesaturated(false)
            button.Icon:SetAlpha(info.locked and 0.45 or 1)

            if info.count and info.count > 1 then
                button.Count:SetText(info.count)
            else
                button.Count:SetText("")
            end

            local quality =
                QUALITY_COLORS[info.quality or 1]
                or QUALITY_COLORS[1]

            button:SetBackdropBorderColor(
                quality[1],
                quality[2],
                quality[3],
                1
            )

            button.Junk:SetShown(
                info.quality == 0
                and not info.noValue
            )
        else
            button.Icon:SetTexture(nil)
            button.Count:SetText("")
            button.Junk:Hide()

            if GetBagTypeLabel(entry.family) then
                button:SetBackdropBorderColor(
                    0.22,
                    0.66,
                    0.92,
                    1
                )
            else
                button:SetBackdropBorderColor(
                    0.13,
                    0.14,
                    0.15,
                    1
                )
            end
        end

        button:Show()
    end

    for index = #entries + 1, #Buttons do
        Buttons[index]:Hide()
    end

    SpaceText:SetFormattedText(
        "%d / %d",
        usedSlots,
        totalSlots
    )

    MoneyText:SetText(
        FormatMoney(GetMoney())
    )
end

Bags.Refresh = Refresh

SearchBox:SetScript("OnTextChanged", function(self)
    SearchHint:SetShown(
        (self:GetText() or "") == ""
    )

    if Frame:IsShown() then
        Refresh()
    end
end)

SearchBox:SetScript("OnEditFocusGained", function(self)
    self:SetBackdropBorderColor(0.22, 0.66, 0.92, 1)
end)

SearchBox:SetScript("OnEditFocusLost", function(self)
    self:SetBackdropBorderColor(0.14, 0.15, 0.16, 1)
end)

------------------------------------------------------------
-- SHOW / HIDE
------------------------------------------------------------

function Bags:Show()
    local db = GetConfig()

    if db.enabled == false then
        return
    end

    HideBlizzardBags()
    Refresh()
    Frame:Show()
end

function Bags:Hide()
    Frame:Hide()
end

function Bags:Toggle()
    if Frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function Bags:ApplyConfig()
    Refresh()
end

------------------------------------------------------------
-- EVENTS
------------------------------------------------------------

local Events = CreateFrame("Frame")

Events:RegisterEvent("PLAYER_LOGIN")
Events:RegisterEvent("BAG_UPDATE")
Events:RegisterEvent("BAG_UPDATE_DELAYED")
Events:RegisterEvent("PLAYER_MONEY")
Events:RegisterEvent("ITEM_LOCK_CHANGED")

Events:SetScript(
    "OnEvent",
    function(self, event)
        if event == "PLAYER_LOGIN" then
            GetConfig()
            return
        end

        if Frame:IsShown() then
            Refresh()
        end
    end
)

------------------------------------------------------------
-- OPEN BAG HOOKS
------------------------------------------------------------

local internalToggle = false

local function HookBagToggle(functionName)
    if not _G[functionName]
        or not hooksecurefunc then
        return
    end

    hooksecurefunc(
        functionName,
        function()
            if internalToggle then
                return
            end

            local db = GetConfig()

            if db.enabled == false then
                return
            end

            internalToggle = true

            C_Timer.After(
                0,
                function()
                    HideBlizzardBags()
                    Bags:Toggle()
                    internalToggle = false
                end
            )
        end
    )
end

-- B / Shift+B commonly route through ToggleAllBags.
HookBagToggle("ToggleAllBags")

-- Clicking the backpack commonly routes through ToggleBackpack.
HookBagToggle("ToggleBackpack")

------------------------------------------------------------
-- SLASH TEST COMMAND
------------------------------------------------------------

SLASH_BLACKOUTUIBAGS1 = "/buibags"

SlashCmdList.BLACKOUTUIBAGS =
    function()
        Bags:Toggle()
    end

------------------------------------------------------------
-- EXPORT
------------------------------------------------------------

BlackoutUI.Bags = Bags
