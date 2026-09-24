------------------------------------------------------------
-- BLACKOUT UI
-- Modules/ReadyCheck.lua
-- Ready Check - Step 1
--
-- Restyles Blizzard's Classic ready-check prompt while
-- preserving Blizzard's native ready-check functionality.
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.ReadyCheck = BlackoutUI.ReadyCheck or {}
local ReadyCheck = BlackoutUI.ReadyCheck

local ACCENT = { 0.22, 0.66, 0.92, 1 }
local DARK = { 0.015, 0.015, 0.018, 0.97 }
local TEXT = { 0.92, 0.94, 0.96, 1 }
local MUTED = { 0.58, 0.62, 0.66, 1 }

local styled = false

local function HideTexture(texture)
    if texture and texture.Hide then
        texture:Hide()
    end
end

local function StyleButton(button, r, g, b)
    if not button or button.BlackoutStyled then
        return
    end

    button.BlackoutStyled = true

    local normal = button.GetNormalTexture and button:GetNormalTexture()
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    local disabled = button.GetDisabledTexture and button:GetDisabledTexture()

    HideTexture(normal)
    HideTexture(pushed)
    HideTexture(disabled)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.025, 0.025, 0.028, 1)
    button.BlackoutBackground = bg

    local border =
        CreateFrame(
            "Frame",
            nil,
            button,
            "BackdropTemplate"
        )

    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    border:SetFrameLevel(button:GetFrameLevel() + 2)
    border:EnableMouse(false)

    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    border:SetBackdropBorderColor(r, g, b, 1)
    button.BlackoutBorder = border

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", 1, -1)
    highlight:SetPoint("BOTTOMRIGHT", -1, 1)
    highlight:SetColorTexture(r, g, b, 0.16)
    button:SetHighlightTexture(highlight)

    local text =
        button.GetFontString
        and button:GetFontString()

    if text then
        text:SetTextColor(TEXT[1], TEXT[2], TEXT[3], TEXT[4])
    end
end

local function FindText(frame)
    if not frame then
        return nil
    end

    return frame.Text
        or frame.text
        or frame.Title
        or frame.title
        or frame.Message
        or frame.message
        or _G.ReadyCheckFrameText
        or _G.ReadyCheckText
end

local function ApplyStyle()
    local frame = _G.ReadyCheckFrame

    if not frame then
        return
    end

    if not styled then
        styled = true

        -- Hide the common Blizzard artwork pieces when present.
        HideTexture(_G.ReadyCheckFrameBackground)
        HideTexture(_G.ReadyCheckFrameBorder)
        HideTexture(_G.ReadyCheckFramePortrait)
        HideTexture(_G.ReadyCheckFrameBg)

        if frame.NineSlice then
            frame.NineSlice:Hide()
        end

        if frame.Border then
            frame.Border:Hide()
        end

        if frame.Background then
            HideTexture(frame.Background)
        end

        local backdrop =
            CreateFrame(
                "Frame",
                "BlackoutUI_ReadyCheckBackdrop",
                frame,
                "BackdropTemplate"
            )

        backdrop:SetAllPoints(frame)
        backdrop:SetFrameLevel(
            math.max(0, frame:GetFrameLevel() - 1)
        )
        backdrop:EnableMouse(false)

        backdrop:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })

        backdrop:SetBackdropColor(
            DARK[1],
            DARK[2],
            DARK[3],
            DARK[4]
        )

        backdrop:SetBackdropBorderColor(
            ACCENT[1],
            ACCENT[2],
            ACCENT[3],
            ACCENT[4]
        )

        frame.BlackoutBackdrop = backdrop

        local title =
            frame:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontNormal"
            )

        title:SetPoint(
            "TOP",
            frame,
            "TOP",
            0,
            -10
        )

        title:SetText("READY CHECK")
        title:SetTextColor(
            ACCENT[1],
            ACCENT[2],
            ACCENT[3],
            1
        )

        frame.BlackoutTitle = title

        StyleButton(
            frame.YesButton
            or _G.ReadyCheckFrameYesButton,
            0.22, 0.82, 0.35
        )

        StyleButton(
            frame.NoButton
            or _G.ReadyCheckFrameNoButton,
            0.90, 0.25, 0.25
        )
    end

    local text = FindText(frame)

    if text and text.SetTextColor then
        text:SetTextColor(
            TEXT[1],
            TEXT[2],
            TEXT[3],
            TEXT[4]
        )
    end

    if frame.BlackoutBackdrop then
        frame.BlackoutBackdrop:Show()
    end

    if frame.BlackoutTitle then
        frame.BlackoutTitle:Show()
    end
end

function ReadyCheck:ApplyStyle()
    ApplyStyle()
end

local Events = CreateFrame("Frame")

Events:RegisterEvent("PLAYER_LOGIN")
Events:RegisterEvent("READY_CHECK")
Events:RegisterEvent("READY_CHECK_CONFIRM")
Events:RegisterEvent("READY_CHECK_FINISHED")

Events:SetScript(
    "OnEvent",
    function(_, event)
        if event == "PLAYER_LOGIN"
            or event == "READY_CHECK" then
            ApplyStyle()
            C_Timer.After(0, ApplyStyle)
            C_Timer.After(0.05, ApplyStyle)
        end
    end
)

if _G.ReadyCheckFrame
    and _G.ReadyCheckFrame.HookScript then
    _G.ReadyCheckFrame:HookScript(
        "OnShow",
        function()
            ApplyStyle()
        end
    )
end

C_Timer.After(0, ApplyStyle)
