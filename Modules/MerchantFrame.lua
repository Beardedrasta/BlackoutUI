------------------------------------------------------------
-- BLACKOUT UI
-- Modules/MerchantFrame.lua
-- Merchant / Vendor Window - Step 1
--
-- Visual skin only. Blizzard's native merchant, buyback,
-- repair, paging, selling, and tooltip behavior is preserved.
------------------------------------------------------------

local addonName, BlackoutUI = ...

BlackoutUI.MerchantFrame = BlackoutUI.MerchantFrame or {}
local Merchant = BlackoutUI.MerchantFrame

local ACCENT = { 0.22, 0.66, 0.92, 1 }
local DARK = { 0.015, 0.015, 0.018, 0.97 }
local PANEL = { 0.025, 0.025, 0.030, 0.96 }
local TEXT = { 0.92, 0.94, 0.96, 1 }
local MUTED = { 0.58, 0.62, 0.66, 1 }

local styled = false

local function HideRegion(region)
    if region and region.Hide then
        region:Hide()
    end
end

local function HideNamedTextures()
    local names = {
        "MerchantFramePortrait",
        "MerchantFramePortraitFrame",
        "MerchantFramePortraitFrameTexture",
        "MerchantFrameBg",
        "MerchantFrameBackground",
        "MerchantFrameTopBorder",
        "MerchantFrameBottomBorder",
        "MerchantFrameLeftBorder",
        "MerchantFrameRightBorder",
        "MerchantFrameTopLeftCorner",
        "MerchantFrameTopRightCorner",
        "MerchantFrameBottomLeftCorner",
        "MerchantFrameBottomRightCorner",
        "MerchantFrameInsetBg",
        "MerchantFrameTitleBg",
    }

    for _, name in ipairs(names) do
        HideRegion(_G[name])
    end
end

local function StyleStandardButton(button)
    if not button or button.BlackoutStyled then
        return
    end

    button.BlackoutStyled = true

    local normal = button.GetNormalTexture and button:GetNormalTexture()
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    local disabled = button.GetDisabledTexture and button:GetDisabledTexture()

    HideRegion(normal)
    HideRegion(pushed)
    HideRegion(disabled)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(PANEL[1], PANEL[2], PANEL[3], 1)
    button.BlackoutBackground = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetFrameLevel(button:GetFrameLevel() + 2)
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(
        ACCENT[1], ACCENT[2], ACCENT[3], 0.85
    )
    button.BlackoutBorder = border

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", 1, -1)
    highlight:SetPoint("BOTTOMRIGHT", -1, 1)
    highlight:SetColorTexture(
        ACCENT[1], ACCENT[2], ACCENT[3], 0.14
    )
    button:SetHighlightTexture(highlight)

    local fs = button.GetFontString and button:GetFontString()
    if fs then
        fs:SetTextColor(TEXT[1], TEXT[2], TEXT[3], 1)
    end
end

local function StyleTab(tab)
    if not tab or tab.BlackoutStyled then
        return
    end

    tab.BlackoutStyled = true

    local regions = { tab:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.GetObjectType
            and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end

    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 3, -3)
    bg:SetPoint("BOTTOMRIGHT", -3, 3)
    bg:SetColorTexture(PANEL[1], PANEL[2], PANEL[3], 1)

    local border = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    border:SetPoint("TOPLEFT", 3, -3)
    border:SetPoint("BOTTOMRIGHT", -3, 3)
    border:SetFrameLevel(tab:GetFrameLevel() + 2)
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(
        ACCENT[1], ACCENT[2], ACCENT[3], 0.70
    )

    tab.BlackoutBackground = bg
    tab.BlackoutBorder = border
end

local function StyleItemButton(button)
    if not button or button.BlackoutItemStyled then
        return
    end

    button.BlackoutItemStyled = true

    local icon =
        button.icon
        or button.Icon
        or button.IconTexture
        or (button.GetName()
            and _G[button:GetName() .. "IconTexture"])

    if icon and icon.SetTexCoord then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if icon then
        local border =
            CreateFrame("Frame", nil, button, "BackdropTemplate")

        border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        border:SetFrameLevel(button:GetFrameLevel() + 2)
        border:EnableMouse(false)
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        border:SetBackdropBorderColor(
            ACCENT[1], ACCENT[2], ACCENT[3], 0.75
        )
        button.BlackoutIconBorder = border
    end
end

local function StyleMerchantItems()
    for i = 1, 12 do
        local item =
            _G["MerchantItem" .. i]
            or _G["MerchantItem" .. i .. "ItemButton"]

        if item then
            StyleItemButton(
                item.ItemButton
                or _G["MerchantItem" .. i .. "ItemButton"]
                or item
            )

            local name =
                item.Name
                or _G["MerchantItem" .. i .. "Name"]

            if name and name.SetTextColor then
                name:SetTextColor(
                    TEXT[1], TEXT[2], TEXT[3], 1
                )
            end
        end
    end

    for i = 1, 12 do
        local button = _G["MerchantItem" .. i .. "ItemButton"]
        StyleItemButton(button)
    end
end

local function StyleBuybackItems()
    for i = 1, 12 do
        StyleItemButton(
            _G["MerchantItem" .. i .. "ItemButton"]
        )
    end
end

local function HideTextureRegions(frame)
    if not frame then
        return
    end

    local regions = { frame:GetRegions() }

    for _, region in ipairs(regions) do
        if region
            and region.GetObjectType
            and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end
end

local function StylePagingButton(button, symbol)
    if not button then
        return
    end

    if not button.BlackoutPagingStyled then
        button.BlackoutPagingStyled = true

        HideTextureRegions(button)

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(PANEL[1], PANEL[2], PANEL[3], 1)
        button.BlackoutBackground = bg

        local border =
            CreateFrame("Frame", nil, button, "BackdropTemplate")

        border:SetAllPoints()
        border:SetFrameLevel(button:GetFrameLevel() + 2)
        border:EnableMouse(false)
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        border:SetBackdropBorderColor(
            ACCENT[1], ACCENT[2], ACCENT[3], 0.90
        )

        local text =
            button:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontNormal"
            )

        text:SetPoint("CENTER", 0, 0)
        text:SetText(symbol)
        text:SetTextColor(
            ACCENT[1], ACCENT[2], ACCENT[3], 1
        )

        button.BlackoutPagingText = text
    end
end

local function RestoreRepairIcons()
    local buttons = {
        _G.MerchantRepairItemButton,
        _G.MerchantRepairAllButton,
    }

    for _, button in ipairs(buttons) do
        if button then
            local regions = { button:GetRegions() }

            for _, region in ipairs(regions) do
                if region
                    and region.GetObjectType
                    and region:GetObjectType() == "Texture" then
                    local texture = region.GetTexture and region:GetTexture()

                    -- The repair hammer/anvil textures are direct button
                    -- textures on Classic. Restore them after our generic
                    -- button skin has hidden Blizzard button chrome.
                    if texture then
                        region:SetAlpha(1)
                    end
                end
            end

            -- Re-hide only the actual button-state chrome.
            local normal = button.GetNormalTexture and button:GetNormalTexture()
            local pushed = button.GetPushedTexture and button:GetPushedTexture()
            local disabled = button.GetDisabledTexture and button:GetDisabledTexture()

            if normal then normal:SetAlpha(0) end
            if pushed then pushed:SetAlpha(0) end
            if disabled then disabled:SetAlpha(0) end
        end
    end
end

local function StyleRepairArea(frame)
    if not frame then
        return
    end

    if not frame.BlackoutRepairPanel then
        local panel =
            CreateFrame(
                "Frame",
                nil,
                frame,
                "BackdropTemplate"
            )

        panel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 39)
        panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 39)
        panel:SetHeight(86)
        panel:SetFrameLevel(
            math.max(0, frame:GetFrameLevel() - 1)
        )
        panel:EnableMouse(false)

        panel:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })

        panel:SetBackdropColor(
            PANEL[1], PANEL[2], PANEL[3], 0.98
        )

        panel:SetBackdropBorderColor(
            0.12, 0.14, 0.16, 1
        )

        frame.BlackoutRepairPanel = panel
    end

    local repairText =
        _G.MerchantRepairText
        or frame.RepairText

    if repairText and repairText.SetTextColor then
        repairText:SetTextColor(
            TEXT[1], TEXT[2], TEXT[3], 1
        )
    end
end

local function StyleMerchantText(frame)
    local title =
        _G.MerchantFrameTitleText
        or frame.TitleText
        or frame.title

    if title and title.SetTextColor then
        title:SetTextColor(
            TEXT[1], TEXT[2], TEXT[3], 1
        )
    end

    local pageText =
        _G.MerchantPageText
        or frame.PageText

    if pageText and pageText.SetTextColor then
        pageText:SetTextColor(
            ACCENT[1], ACCENT[2], ACCENT[3], 1
        )
    end

    local prevText = _G.MerchantPrevPageButtonText
    local nextText = _G.MerchantNextPageButtonText

    if prevText then
        prevText:SetText("")
        prevText:Hide()
    end

    if nextText then
        nextText:SetText("")
        nextText:Hide()
    end

    for i = 1, 2 do
        local tab = _G["MerchantFrameTab" .. i]

        if tab and tab.GetFontString then
            local fs = tab:GetFontString()

            if fs then
                fs:SetTextColor(
                    TEXT[1], TEXT[2], TEXT[3], 1
                )
            end
        end
    end
end

local function StripBlizzardMerchantArt(frame)
    if not frame then return end

    HideNamedTextures()

    -- Classic MerchantFrame uses many anonymous atlas/textures.
    -- Only strip textures directly owned by the main decorative
    -- containers; item icons/buttons are children and stay intact.
    local containers = {
        frame,
        frame.Inset,
        frame.Border,
        frame.PortraitContainer,
        _G.MerchantFrameInset,
    }

    for _, container in ipairs(containers) do
        if container and container.GetRegions then
            local regions = { container:GetRegions() }
            for _, region in ipairs(regions) do
                if region
                    and region.GetObjectType
                    and region:GetObjectType() == "Texture"
                    and region ~= frame.BlackoutHeaderLine then
                    region:SetAlpha(0)
                end
            end
        end
    end

    if frame.NineSlice then frame.NineSlice:Hide() end
    if frame.Inset and frame.Inset.NineSlice then
        frame.Inset.NineSlice:Hide()
    end
    if frame.PortraitContainer then
        frame.PortraitContainer:Hide()
    end

    -- Common Classic repair / money / tab decorative textures.
    local extra = {
        _G.MerchantRepairTextBackground,
        _G.MerchantMoneyBg,
        _G.MerchantMoneyInset,
        _G.MerchantMoneyFrameBg,
        _G.MerchantExtraCurrencyBg,
    }

    for _, region in ipairs(extra) do
        HideRegion(region)
    end
end

local function StripRemainingMerchantArt(frame)
    if not frame then return end

    -- Money frame: keep the coin text/icons, remove its old gold frame art.
    local moneyFrames = {
        _G.MerchantMoneyFrame,
        frame.MoneyFrame,
        _G.MerchantMoneyInset,
    }

    for _, moneyFrame in ipairs(moneyFrames) do
        if moneyFrame and moneyFrame.GetRegions then
            local regions = { moneyFrame:GetRegions() }
            for _, region in ipairs(regions) do
                if region
                    and region.GetObjectType
                    and region:GetObjectType() == "Texture" then
                    region:SetAlpha(0)
                end
            end
        end
    end

    -- Empty merchant/buyback item buttons can expose their original gold
    -- slot border even after the icon is hidden.
    for i = 1, 12 do
        local button = _G["MerchantItem" .. i .. "ItemButton"]
        if button then
            local normal = button.GetNormalTexture and button:GetNormalTexture()
            if normal then normal:SetAlpha(0) end

            local pushed = button.GetPushedTexture and button:GetPushedTexture()
            if pushed then pushed:SetAlpha(0) end

            local disabled = button.GetDisabledTexture and button:GetDisabledTexture()
            if disabled then disabled:SetAlpha(0) end

            if button.BlackoutIconBorder then
                button.BlackoutIconBorder:SetBackdropBorderColor(
                    ACCENT[1], ACCENT[2], ACCENT[3], 0.70
                )
            end
        end
    end

    -- Blizzard resets these strings to yellow during merchant updates.
    local title =
        _G.MerchantFrameTitleText
        or frame.TitleText
        or frame.title

    if title and title.SetTextColor then
        title:SetTextColor(TEXT[1], TEXT[2], TEXT[3], 1)
    end

    local prevText = _G.MerchantPrevPageButtonText
    local nextText = _G.MerchantNextPageButtonText

    if prevText then
        prevText:SetText("")
        prevText:SetAlpha(0)
    end

    if nextText then
        nextText:SetText("")
        nextText:SetAlpha(0)
    end
end

local function ApplyStyle()
    local frame = _G.MerchantFrame
    if not frame then
        return
    end

    if not styled then
        styled = true

        StripBlizzardMerchantArt(frame)

        if frame.PortraitContainer then
            frame.PortraitContainer:Hide()
        end

        if frame.portrait then
            HideRegion(frame.portrait)
        end

        if frame.Portrait then
            HideRegion(frame.Portrait)
        end

        if frame.NineSlice then
            frame.NineSlice:Hide()
        end

        if frame.Inset then
            if frame.Inset.Bg then
                HideRegion(frame.Inset.Bg)
            end
            if frame.Inset.NineSlice then
                frame.Inset.NineSlice:Hide()
            end
        end

        local backdrop =
            CreateFrame(
                "Frame",
                "BlackoutUI_MerchantBackdrop",
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
            DARK[1], DARK[2], DARK[3], DARK[4]
        )

        backdrop:SetBackdropBorderColor(
            ACCENT[1], ACCENT[2], ACCENT[3], 1
        )

        frame.BlackoutBackdrop = backdrop

        local headerLine =
            frame:CreateTexture(nil, "ARTWORK")

        headerLine:SetPoint(
            "TOPLEFT",
            frame,
            "TOPLEFT",
            8,
            -62
        )

        headerLine:SetPoint(
            "TOPRIGHT",
            frame,
            "TOPRIGHT",
            -8,
            -62
        )

        headerLine:SetHeight(1)
        headerLine:SetColorTexture(
            ACCENT[1], ACCENT[2], ACCENT[3], 0.70
        )

        frame.BlackoutHeaderLine = headerLine

        local inner =
            CreateFrame(
                "Frame",
                "BlackoutUI_MerchantInnerPanel",
                frame,
                "BackdropTemplate"
            )

        inner:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -64)
        inner:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 38)
        inner:SetFrameLevel(
            math.max(0, frame:GetFrameLevel() - 1)
        )
        inner:EnableMouse(false)

        inner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })

        inner:SetBackdropColor(
            PANEL[1], PANEL[2], PANEL[3], PANEL[4]
        )

        inner:SetBackdropBorderColor(
            0.12, 0.14, 0.16, 1
        )

        frame.BlackoutInnerPanel = inner

        StyleStandardButton(
            _G.MerchantRepairItemButton
        )

        StyleStandardButton(
            _G.MerchantRepairAllButton
        )

        StylePagingButton(
            _G.MerchantPrevPageButton,
            "<"
        )

        StylePagingButton(
            _G.MerchantNextPageButton,
            ">"
        )

        StyleTab(_G.MerchantFrameTab1)
        StyleTab(_G.MerchantFrameTab2)

        StyleRepairArea(frame)
        StyleMerchantText(frame)

        if _G.MerchantMoneyFrame and not frame.BlackoutMoneyPanel then
            local moneyPanel =
                CreateFrame(
                    "Frame",
                    nil,
                    frame,
                    "BackdropTemplate"
                )

            moneyPanel:SetPoint(
                "TOPLEFT",
                _G.MerchantMoneyFrame,
                "TOPLEFT",
                -4,
                4
            )

            moneyPanel:SetPoint(
                "BOTTOMRIGHT",
                _G.MerchantMoneyFrame,
                "BOTTOMRIGHT",
                4,
                -4
            )

            moneyPanel:SetFrameLevel(
                math.max(
                    0,
                    _G.MerchantMoneyFrame:GetFrameLevel() - 1
                )
            )

            moneyPanel:EnableMouse(false)

            moneyPanel:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 1,
            })

            moneyPanel:SetBackdropColor(
                PANEL[1], PANEL[2], PANEL[3], 1
            )

            moneyPanel:SetBackdropBorderColor(
                ACCENT[1], ACCENT[2], ACCENT[3], 0.75
            )

            frame.BlackoutMoneyPanel = moneyPanel
        end
    end

    StripBlizzardMerchantArt(frame)
    StripRemainingMerchantArt(frame)
    StyleMerchantItems()
    StyleBuybackItems()
    RestoreRepairIcons()
    StyleMerchantText(frame)
    StyleRepairArea(frame)

    if frame.BlackoutBackdrop then
        frame.BlackoutBackdrop:Show()
    end

    if frame.BlackoutInnerPanel then
        frame.BlackoutInnerPanel:Show()
    end
end

local function LockMerchantTextColors()
    local frame = _G.MerchantFrame
    if not frame then return end

    local title =
        _G.MerchantFrameTitleText
        or frame.TitleText
        or frame.title

    if title and not title.BlackoutColorLocked then
        title.BlackoutColorLocked = true
        hooksecurefunc(title, "SetTextColor", function(self)
            if self.BlackoutColorGuard then return end
            self.BlackoutColorGuard = true
            self:SetTextColor(TEXT[1], TEXT[2], TEXT[3], 1)
            self.BlackoutColorGuard = false
        end)
    end

    local pageText =
        _G.MerchantPageText
        or frame.PageText

    if pageText and not pageText.BlackoutColorLocked then
        pageText.BlackoutColorLocked = true
        hooksecurefunc(pageText, "SetTextColor", function(self)
            if self.BlackoutColorGuard then return end
            self.BlackoutColorGuard = true
            self:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            self.BlackoutColorGuard = false
        end)
    end
end

function Merchant:ApplyStyle()
    LockMerchantTextColors()
    ApplyStyle()
end

local Events = CreateFrame("Frame")

Events:RegisterEvent("PLAYER_LOGIN")
Events:RegisterEvent("MERCHANT_SHOW")
Events:RegisterEvent("MERCHANT_UPDATE")
Events:RegisterEvent("MERCHANT_CLOSED")

Events:SetScript(
    "OnEvent",
    function(_, event)
        if event == "PLAYER_LOGIN"
            or event == "MERCHANT_SHOW"
            or event == "MERCHANT_UPDATE" then
            LockMerchantTextColors()
            ApplyStyle()
            C_Timer.After(0, ApplyStyle)
            C_Timer.After(0.05, ApplyStyle)
        end
    end
)

if _G.MerchantFrame
    and _G.MerchantFrame.HookScript then
    _G.MerchantFrame:HookScript(
        "OnShow",
        function()
            ApplyStyle()
        end
    )
end

C_Timer.After(0, ApplyStyle)
