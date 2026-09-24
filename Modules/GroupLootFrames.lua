BlackoutUI = BlackoutUI or {}
BlackoutUI.GroupLootFrames = BlackoutUI.GroupLootFrames or {}

local GroupLoot = BlackoutUI.GroupLootFrames
local ACCENT = { 0.22, 0.66, 0.92, 1 }
local DARK = { 0.015, 0.015, 0.018, 0.96 }
local MAX_ROLL_FRAMES = 8

local function GetQualityColor(frame)
    local link
    if frame and frame.rollID and GetLootRollItemLink then
        link = GetLootRollItemLink(frame.rollID)
    end
    if link and GetItemInfo then
        local _, _, quality = GetItemInfo(link)
        local c = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
        if c then return c.r, c.g, c.b end
    end
    return ACCENT[1], ACCENT[2], ACCENT[3]
end

local function FindIcon(frame)
    local n = frame and frame.GetName and frame:GetName()
    return frame and (frame.Icon or frame.icon or frame.IconTexture
        or (n and (_G[n .. "IconFrameIcon"] or _G[n .. "Icon"] or _G[n .. "IconTexture"])))
end

local function FindNameText(frame)
    local n = frame and frame.GetName and frame:GetName()
    return frame and (frame.Name or frame.name or frame.ItemName
        or (n and (_G[n .. "Name"] or _G[n .. "NameFrameName"])))
end

local function FindTimer(frame)
    local n = frame and frame.GetName and frame:GetName()
    return frame and (frame.Timer or frame.timer or frame.TimerBar or frame.StatusBar
        or (n and (_G[n .. "Timer"] or _G[n .. "TimerBar"])))
end

local function StyleButton(button, kind)
    if not button or button.BlackoutBorder then return end
    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    border:SetFrameLevel(button:GetFrameLevel() + 2)
    border:EnableMouse(false)
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    if kind == "need" then
        border:SetBackdropBorderColor(0.22, 0.82, 0.35, 1)
    elseif kind == "greed" then
        border:SetBackdropBorderColor(0.95, 0.72, 0.18, 1)
    else
        border:SetBackdropBorderColor(0.65, 0.65, 0.68, 1)
    end
    button.BlackoutBorder = border
    local normal = button.GetNormalTexture and button:GetNormalTexture()
    if normal and normal.SetTexCoord then normal:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    if pushed and pushed.SetTexCoord then pushed:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
end

local function StyleFrame(frame)
    if not frame then return end
    if not frame.BlackoutBackdrop then
        local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        bg:SetAllPoints(frame)
        bg:SetFrameLevel(math.max(0, frame:GetFrameLevel() - 1))
        bg:EnableMouse(false)
        bg:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1
        })
        bg:SetBackdropColor(unpack(DARK))
        frame.BlackoutBackdrop = bg
    end

    local r, g, b = GetQualityColor(frame)
    frame.BlackoutBackdrop:SetBackdropBorderColor(r, g, b, 1)

    local icon = FindIcon(frame)
    if icon and icon.SetTexCoord then icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    if icon and not frame.BlackoutIconBorder then
        local parent = icon.GetParent and icon:GetParent() or frame
        local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        border:SetFrameLevel(parent:GetFrameLevel() + 2)
        border:EnableMouse(false)
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        frame.BlackoutIconBorder = border
    end
    if frame.BlackoutIconBorder then
        frame.BlackoutIconBorder:SetBackdropBorderColor(r, g, b, 1)
    end

    local text = FindNameText(frame)
    if text and text.SetTextColor then text:SetTextColor(0.92, 0.94, 0.96, 1) end

    local timer = FindTimer(frame)
    if timer and timer.SetStatusBarTexture then
        timer:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        if timer.SetStatusBarColor then timer:SetStatusBarColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90) end
    end

    local n = frame.GetName and frame:GetName()
    if n then
        StyleButton(frame.NeedButton or _G[n .. "NeedButton"], "need")
        StyleButton(frame.GreedButton or _G[n .. "GreedButton"], "greed")
        StyleButton(frame.PassButton or _G[n .. "PassButton"], "pass")
        StyleButton(frame.DisenchantButton or _G[n .. "DisenchantButton"], "greed")
    end
end

local function StyleAll()
    for i = 1, MAX_ROLL_FRAMES do StyleFrame(_G["GroupLootFrame" .. i]) end
    if _G.GroupLootContainer and _G.GroupLootContainer.rollFrames then
        for _, frame in ipairs(_G.GroupLootContainer.rollFrames) do StyleFrame(frame) end
    end
end

function GroupLoot:ApplyStyle() StyleAll() end

local function Refresh()
    StyleAll()
    C_Timer.After(0.05, StyleAll)
end

if type(_G.GroupLootFrame_OpenNewFrame) == "function" then
    hooksecurefunc("GroupLootFrame_OpenNewFrame", Refresh)
end
if type(_G.GroupLootFrame_Update) == "function" then
    hooksecurefunc("GroupLootFrame_Update", Refresh)
end

local Events = CreateFrame("Frame")
Events:RegisterEvent("PLAYER_LOGIN")
Events:RegisterEvent("START_LOOT_ROLL")
Events:RegisterEvent("CANCEL_LOOT_ROLL")
Events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" or event == "START_LOOT_ROLL" then Refresh() else StyleAll() end
end)

C_Timer.After(0, StyleAll)
