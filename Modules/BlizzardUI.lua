--------------------------------------------------
-- BLACKOUT UI
-- Modules/BlizzardUI.lua
--------------------------------------------------

local addonName, BlackoutUI = ...

local Hider = CreateFrame("Frame", "BlackoutUI_BlizzardActionBarHider", UIParent)
Hider:Hide()

local function HideFrame(frame)
    if not frame or InCombatLockdown() then return end
    frame:Hide()
    frame:SetParent(Hider)
end

local function HideNamedFrame(name)
    HideFrame(_G[name])
end

local function HideDefaultActionButtons()
    for i = 1, 12 do HideNamedFrame("ActionButton" .. i) end
    local prefixes = {
        "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
        "MultiBarRightButton", "MultiBarLeftButton",
    }
    for _, prefix in ipairs(prefixes) do
        for i = 1, 12 do HideNamedFrame(prefix .. i) end
    end
end

local function HideDefaultActionBarFrames()
    HideNamedFrame("MainActionBar")
    HideNamedFrame("MainMenuBarArtFrame")
    HideNamedFrame("MultiBarBottomLeft")
    HideNamedFrame("MultiBarBottomRight")
    HideNamedFrame("MultiBarRight")
    HideNamedFrame("MultiBarLeft")
end

local function HideDefaultTrackingBars()
    HideNamedFrame("StatusTrackingBarManager")
    HideNamedFrame("MainMenuExpBar")
    HideNamedFrame("ReputationWatchBar")
end

local function ApplyBlizzardCleanup()
    if InCombatLockdown() then return end
    HideDefaultActionButtons()
    HideDefaultActionBarFrames()
    HideDefaultTrackingBars()
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", ApplyBlizzardCleanup)

ApplyBlizzardCleanup()
