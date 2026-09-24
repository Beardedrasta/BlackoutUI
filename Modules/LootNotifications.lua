------------------------------------------------------------
-- BLACKOUT UI
-- Modules/LootNotifications.lua
-- Loot / Roll Results - Step 2
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.LootNotifications =
    BlackoutUI.LootNotifications or {}

local LootNotifications =
    BlackoutUI.LootNotifications

local DEFAULTS = {
    enabled = true,
    width = 360,
    height = 34,
    textSize = 10,
    duration = 4.5,
    maxVisible = 5,
    spacing = 4,
}

local BG = { 0.018, 0.018, 0.018, 0.94 }
local BORDER = { 0.12, 0.12, 0.12, 1 }
local ACCENT = { 0.22, 0.66, 0.92, 1 }

local function GetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.LootNotifications =
        BlackoutUIDB.Config.LootNotifications or {}

    local db = BlackoutUIDB.Config.LootNotifications

    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end

    return db
end

local Anchor =
    CreateFrame(
        "Frame",
        "BlackoutUI_LootNotificationAnchor",
        UIParent,
        "BackdropTemplate"
    )

Anchor:SetSize(360, 34)
Anchor:SetPoint("TOP", UIParent, "TOP", 0, -165)
Anchor:SetFrameStrata("HIGH")
Anchor:Hide()

Anchor:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})

Anchor:SetBackdropColor(0.02, 0.02, 0.02, 0.92)
Anchor:SetBackdropBorderColor(unpack(ACCENT))

local AnchorText =
    Anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")

AnchorText:SetPoint("CENTER")
AnchorText:SetText("LOOT / ROLL NOTIFICATIONS")
AnchorText:SetTextColor(0.92, 0.94, 0.96, 1)

LootNotifications.Anchor = Anchor

local Notices = {}
local Serial = 0

local function SetFontSize(fontString, size)
    if not fontString then return end

    local font, _, flags = fontString:GetFont()

    if font then
        fontString:SetFont(font, size, flags)
    end
end

local function GetItemQualityFromMessage(message)
    if not message then return nil end

    local link =
        string.match(
            message,
            "(|c%x+|Hitem:.-|h%[.-%]|h|r)"
        )

    if not link then
        link =
            string.match(
                message,
                "(|Hitem:.-|h%[.-%]|h)"
            )
    end

    if link and GetItemInfo then
        local _, _, quality = GetItemInfo(link)
        return quality
    end

    return nil
end

local function GetBorderColor(message)
    local quality = GetItemQualityFromMessage(message)

    if quality
        and ITEM_QUALITY_COLORS
        and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        return c.r, c.g, c.b, 1
    end

    return ACCENT[1], ACCENT[2], ACCENT[3], ACCENT[4]
end

local function CreateNotice(index)
    local frame =
        CreateFrame(
            "Frame",
            "BlackoutUI_LootNotice" .. index,
            UIParent,
            "BackdropTemplate"
        )

    frame:SetFrameStrata("HIGH")
    frame:EnableMouse(false)

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    frame:SetBackdropColor(unpack(BG))
    frame:SetBackdropBorderColor(unpack(BORDER))

    frame.Text =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )

    frame.Text:SetPoint("LEFT", frame, "LEFT", 10, 0)
    frame.Text:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetWordWrap(false)

    frame:Hide()

    return frame
end

local function EnsureNoticeCount()
    local db = GetConfig()

    for i = 1, db.maxVisible do
        if not Notices[i] then
            Notices[i] = CreateNotice(i)
        end
    end

    for i = db.maxVisible + 1, #Notices do
        if Notices[i] then
            Notices[i]:Hide()
        end
    end
end

local function ApplyDimensions()
    local db = GetConfig()

    Anchor:SetSize(db.width, db.height)

    EnsureNoticeCount()

    for i = 1, #Notices do
        local notice = Notices[i]

        notice:SetSize(db.width, db.height)
        SetFontSize(notice.Text, db.textSize)
    end
end

local function LayoutNotices()
    local db = GetConfig()
    local visibleIndex = 0

    for i = 1, #Notices do
        local notice = Notices[i]

        if notice:IsShown()
            and i <= db.maxVisible then
            visibleIndex = visibleIndex + 1

            notice:ClearAllPoints()

            notice:SetPoint(
                "TOP",
                Anchor,
                "BOTTOM",
                0,
                -(
                    (visibleIndex - 1)
                    * (db.height + db.spacing)
                )
            )
        end
    end
end

local function HideNotice(frame)
    if not frame then return end

    frame:Hide()
    frame.message = nil
    frame.serial = nil

    LayoutNotices()
end

local function HideAll()
    for i = 1, #Notices do
        HideNotice(Notices[i])
    end
end

local function ShowNotice(message)
    local db = GetConfig()

    if not db.enabled
        or not message
        or message == "" then
        return
    end

    ApplyDimensions()

    Serial = Serial + 1

    local frame = nil

    for i = 1, db.maxVisible do
        if Notices[i]
            and not Notices[i]:IsShown() then
            frame = Notices[i]
            break
        end
    end

    if not frame then
        frame = Notices[1]

        for i = 2, db.maxVisible do
            if Notices[i]
                and (Notices[i].serial or 0)
                < (frame.serial or 0) then
                frame = Notices[i]
            end
        end
    end

    if not frame then return end

    frame.message = message
    frame.serial = Serial
    frame.Text:SetText(message)

    local r, g, b, a = GetBorderColor(message)

    frame:SetBackdropBorderColor(r, g, b, a)
    frame:SetAlpha(1)
    frame:Show()

    LayoutNotices()

    local thisSerial = Serial
    local duration = db.duration

    C_Timer.After(
        duration,
        function()
            if frame
                and frame.serial == thisSerial then
                HideNotice(frame)
            end
        end
    )
end

local function UpdateMover()
    ApplyDimensions()

    if BlackoutUI.MoveMode then
        Anchor:Show()
    else
        Anchor:Hide()
    end
end

if BlackoutUI.RegisterMovableFrame then
    BlackoutUI:RegisterMovableFrame(
        Anchor,
        "LootNotifications",
        "LOOT / ROLL NOTIFICATIONS"
    )
end

local Events = CreateFrame("Frame")

Events:RegisterEvent("CHAT_MSG_LOOT")
Events:RegisterEvent("CHAT_MSG_MONEY")
Events:RegisterEvent("CHAT_MSG_CURRENCY")
Events:RegisterEvent("CHAT_MSG_SYSTEM")
Events:RegisterEvent("PLAYER_ENTERING_WORLD")

Events:SetScript(
    "OnEvent",
    function(_, event, message)
        if event == "PLAYER_ENTERING_WORLD" then
            UpdateMover()
            return
        end

        if event == "CHAT_MSG_LOOT"
            or event == "CHAT_MSG_MONEY"
            or event == "CHAT_MSG_CURRENCY" then
            ShowNotice(message)
            return
        end

        if event == "CHAT_MSG_SYSTEM"
            and message then
            local lower = string.lower(message)

            if string.find(lower, "roll")
                or string.find(lower, "need")
                or string.find(lower, "greed")
                or string.find(lower, "won") then
                ShowNotice(message)
            end
        end
    end
)

function LootNotifications:ApplyConfig()
    local db = GetConfig()

    ApplyDimensions()

    if not db.enabled then
        HideAll()
    end

    LayoutNotices()
    UpdateMover()
end

LootNotifications.ApplyStyle =
    LootNotifications.ApplyConfig

function LootNotifications:ResetConfig()
    BlackoutUIDB = BlackoutUIDB or {}
    BlackoutUIDB.Config = BlackoutUIDB.Config or {}
    BlackoutUIDB.Config.LootNotifications = nil

    GetConfig()
    self:ApplyConfig()
end

function LootNotifications:Test()
    ShowNotice(
        "|cff0070dd[BlackoutUI Test Item]|r added to your inventory."
    )

    C_Timer.After(
        0.35,
        function()
            ShowNotice(
                "You won the roll for |cff1eff00[BlackoutUI Test Loot]|r."
            )
        end
    )
end

SLASH_BLACKOUTUILOOTTEST1 = "/builoottest"

SlashCmdList.BLACKOUTUILOOTTEST =
    function()
        LootNotifications:Test()
    end

C_Timer.After(
    0,
    function()
        LootNotifications:ApplyConfig()
    end
)
