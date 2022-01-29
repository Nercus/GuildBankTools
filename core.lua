local GuildBankTools = LibStub("AceAddon-3.0"):NewAddon("GuildBankTools", "AceConsole-3.0", "AceEvent-3.0",
    "AceTimer-3.0")

local ItemsPerTab = 98
local recipeReagents = {
    --  Cooking
    [172043] = {{173036, 10}, -- Spinefin Piranha
    {173034, 10}, -- Silvergill Pike
    {172053, 10}, -- Tenebrous Ribs
    {172055, 10}, -- Phantasmal Haunch
    {173037, 5}, -- Elysian Thade
    {172058, 5}, -- Smuggled Azerothian Produce
    {172059, 5}, -- Rich Grazer Milk
    {178786, 5} -- Lusterwheat Flour
    }, -- Feast of Gluttonous Hedonism
    [172041] = {{173036, 3}, -- Spinefin Piranha
    {173033, 3}, -- Iridescent Amberjack
    {172058, 4}, -- Smuggled Azerothian Produce
    {172057, 2} -- Inconceivably Aged Vinegar
    }, -- Spinefin Souffle and Fries
    [172049] = {{173033, 3}, -- Iridescent Amberjack
    {173032, 3}, -- Lost Sole
    {172058, 3}, -- Smuggled Azerothian Produce
    {178786, 2}, -- Lusterwheat Flour
    {172057, 1} -- Inconceivably Aged Vinegar
    }, -- Iridescent Ravioli with Apple Sauce
    [172051] = {{179315, 3}, -- Shadowy Shank
    {172054, 3}, -- Raw Seraphic Wing
    {172059, 2}, -- Rich Grazer Milk
    {172056, 2}, -- Medley of Transplanar Spices
    {172057, 2} -- Inconceivably Aged Vinegar
    }, -- Steak a la Mode
    [172045] = {{172053, 3}, -- Tenebrous Ribs
    {179314, 3}, -- Creeping Crawler Meat
    {172056, 4}, -- Medley of Transplanar Spices
    {172059, 2} -- Rich Grazer Milk
    }, -- Tenebrous Crown Roast Aspic
    --  Alchemy
    [171351] = {{180732, 1}, -- Rune Etched Vial
    {168583, 3}, -- Widowbloom
    {170554, 3} -- Vigil's Torch
    }, -- Potion of Deathly Fixation
    [171275] = {{180732, 1}, -- Rune Etched Vial
    {168586, 5} -- Rising Glory
    }, -- Potion of Spectral Strength
    [171270] = {{180732, 1}, -- Rune Etched Vial
    {168583, 5} -- Widowbloom
    }, -- Potion of Spectral Agility
    [171273] = {{180732, 1}, -- Rune Etched Vial
    {168589, 5} -- Marrowroot
    }, -- Potion of Spectral Intellect
    [171349] = {{180732, 1}, -- Rune Etched Vial
    {168589, 3}, -- Marrowroot
    {168586, 3} -- Rising Glory
    }, -- Potion of Phantom Fire
    [171272] = {{180732, 1}, -- Rune Etched Vial
    {170554, 5} -- Vigil's Torch
    }, -- Potion of Spiritual Clarity
    [171267] = {{180732, 1}, -- Rune Etched Vial
    {169701, 2} -- Death Blossom
    }, -- Spiritual Healing Potion
    [171268] = {{180732, 1}, -- Rune Etched Vial
    {169701, 2} -- Death Blossom
    }, -- Spiritual Mana Potion
    [171276] = {{180732, 1}, -- Rune Etched Vial
    {171315, 3}, -- Nightshade
    {168586, 4}, -- Rising Glory
    {168589, 4}, -- Marrowroot
    {168583, 4}, -- Widowbloom
    {170554, 4} -- Vigil's Torch
    }, -- Spectral Flask of Power
    [171286] = {{180732, 1}, -- Rune Etched Vial
    {169701, 2} -- Death Blossom
    }, -- Embalmer's Oil
    [171285] = {{180732, 1}, -- Rune Etched Vial
    {169701, 2} -- Death Blossom
    }, -- Shadowcore Oil
    [180457] = {{171287, 5}, -- Ground Death Blossom
    {171288, 2}, -- Ground Vigil's Torch
    {171289, 2}, -- Ground Widowbloom
    {171290, 2}, -- Ground Marrowroot
    {171291, 2} -- Ground Rising Glory
    }, -- Shadestone
    [171266] = {{180732, 1}, -- Rune Etched Vial
    {169701, 2}, -- Death Blossom
    {168586, 3} -- Rising Glory
    }, -- Potion of the Hidden Spirit
    --  Engineering
    [132514] = {{123918, 20}, -- Leystone Ore
    {136637, 10}, -- Oversized Blasting Cap
    {136633, 1} -- Loose Trigger
    }, -- Auto-Hammer
    [109076] = {{109119, 8}, -- True Iron Ore
    {111557, 5} -- Sumptuous Fur
    }, -- Goblin Glider Kit
    --  Inscription
    [173049] = {{173059, 3}, -- Luminous Ink
    {173058, 3}, -- Umbral Ink
    {175886, 25} -- Dark Parchment
    }, -- Tome of the Still Mind
    --  Leatherworking
    [172347] = {{172096, 8}, -- Heavy Desolate Leather
    {177062, 4} -- Penumbra Thread
    }, -- Heavy Desolate Armor Kit
    [172233] = {{172096, 3}, -- Heavy Desolate Leather
    {172092, 3}, -- Pallid Bone
    {177062, 1} -- Penumbra Thread
    } -- Drums of Deathly Ferocity
}

local vendorReagents = {
    [177062] = 90000, -- Penumbra Thread
    [175886] = 1000, -- Dark Parchment
    [136633] = 25000, -- Loose Trigger
    [136637] = 10000, -- Oversized Blasting Cap
    [180732] = 500, -- Rune Etched Vial
    [172056] = 5000, -- Medley of Transplanar Spices
    [172059] = 4250, -- Rich Grazer Milk
    [178786] = 3500, -- Lusterwheat Flour
    [172058] = 4500, -- Smuggled Azerothian Produce
    [172057] = 3750 -- Inconceivably Aged Vinegar
}
local LDBIcon = LibStub("LibDBIcon-1.0")

local vendorItems = {}
local boughtVendorItems = {}
local queriedTabs = {}
local gbankScanned = false

local GBankItems = {}
local shoppinglist = {}

local itemtobuy = {}

local itemprice = 0

local itemspurchased = {}

local initialQuery
local lastQuery
local auctions = {}

-- FIXME: If Materials are in Bag craft the item instead of buying it
-- FIXME: adjust crafting recipes for count of crafted item i.e Foodx3
-- FIXME: Count Materials in GBank
-- FIXME: add optional crafting steps (10 desolate leather to 1 heavy desolate leather)

local defaults = {
    profile = {
        minimap = {
            hide = false
        },
        slpositon = {
            x = 0,
            y = 0
        },
        prices = {},
        desiredItems = {
            [171439] = 70, -- Shaded Weightstone
            [172051] = 140, -- Steak a la Mode
            [172045] = 140, -- Tenebrous Crown Roast Aspic
            [172049] = 140, -- Iridescent Ravioli with Apple Sauce
            [172041] = 140, -- Spinefin Souffle and Fries
            [171270] = 210, -- Potion of Spectral Agility
            [176811] = 40, -- Potion of Sacrificial Anima
            [172347] = 84, -- Heavy Desolate Armor Kit
            [181468] = 420, -- Veiled Augment Rune
            [171351] = 70, -- Potion of Deathly Fixation
            [172233] = 28, -- Drums of Deathly Ferocity
            [171276] = 108, -- Spectral Flask of Power
            [109076] = 140, -- Goblin Glider Kit
            [171286] = 70, -- Embalmer's Oil
            [171267] = 840, -- Spiritual Healing Potion
            [171268] = 120, -- Spiritual Mana Potion
            [171273] = 210, -- Potion of Spectral Intellect
            [171266] = 21, -- Potion of the Hidden Spirit
            [171349] = 140, -- Potion of Phantom Fire
            [132514] = 14, -- Auto-Hammer
            [171285] = 70, -- Shadowcore Oil
            [171272] = 40, -- Potion of Spiritual Clarity
            [171275] = 210, -- Potion of Spectral Strength
            [173049] = 56, -- Tome of the Still Mind
            [186662] = 49, -- Vantus Rune: Sanctum of Domination
            [171437] = 70, -- Shaded Sharpening Stone
            [180457] = 20, -- Shadestone
            [172043] = 100 -- Feast of Gluttonous Hedonism
        }
    }
}

-- Broker
GuildBankToolsBroker = LibStub("LibDataBroker-1.1"):NewDataObject("GuildBankTools", {
    type = "data source",
    text = "GuildBankTools",
    icon = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
    OnClick = function(_, button)
        if button == "LeftButton" then
            GuildBankTools:ToggleShoppingListFrame()
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Left-Click to open shopping list")
    end
})

function GuildBankTools:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildBankToolsDB", defaults, true)

    LDBIcon:Register("GuildBankTools", GuildBankToolsBroker, self.db.profile.minimap)

    local GBT_Frame = CreateFrame("Frame", nil, UIParent)
    GBT_Frame:SetFrameStrata("BACKGROUND")
    GBT_Frame:SetWidth(235)
    GBT_Frame:SetHeight(500)
    local x = GuildBankTools.db.profile.slpositon.x
    local y = GuildBankTools.db.profile.slpositon.y - 500
    GBT_Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    GBT_Frame:SetClampedToScreen(true)
    GBT_Frame:Hide()
    self.ShoppingListFrame = GBT_Frame

    local tex = GBT_Frame:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.5)
    GBT_Frame.movetexture = tex
    GBT_Frame.movetexture:Hide()

    local GBT_ObjectiveTrackerHeader = CreateFrame("frame", "GBT_ObjectiveTrackerHeader", GBT_Frame)
    GBT_ObjectiveTrackerHeader:SetPoint("TOPLEFT", GBT_Frame, "TOPLEFT", 0, 0)
    GBT_ObjectiveTrackerHeader:SetSize(235, 25)

    local GBT_ObjectiveTrackerHeaderTexture = GBT_Frame:CreateTexture(nil, "ARTWORK")
    GBT_ObjectiveTrackerHeaderTexture:SetSize(235, 25)
    GBT_ObjectiveTrackerHeaderTexture:SetAtlas('pvpqueue-button-up')
    GBT_ObjectiveTrackerHeaderTexture:SetPoint("TOPLEFT", GBT_ObjectiveTrackerHeader, "TOPLEFT", 0, 0)

    local GBT_ObjectiveTrackerHeaderText = GBT_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    GBT_ObjectiveTrackerHeaderText:SetPoint("TOPLEFT", GBT_ObjectiveTrackerHeader, "TOPLEFT", 15, -5)
    GBT_ObjectiveTrackerHeaderText:SetText("Shoppinglist")

    local minimizeButton = CreateFrame("button", "GBT_QuestsHeaderMinimizeButton", GBT_Frame, "BackdropTemplate")
    local minimizeButtonText = minimizeButton:CreateFontString(nil, "overlay", "GameFontNormal")
    minimizeButtonText:SetPoint("right", minimizeButton, "left", -3, 1)
    minimizeButtonText:Hide()
    minimizeButton:SetSize(25, 25)
    minimizeButton:SetPoint("topright", GBT_ObjectiveTrackerHeader, "topright", 0, 0)
    minimizeButton:SetScript("OnClick", function()
        GBT_Frame:Hide()
    end)
    minimizeButton:SetNormalAtlas("soulbinds_collection_categoryheader_collapse")
    minimizeButton:SetHighlightAtlas("128-redbutton-refresh-highlight")
    minimizeButton:SetFrameStrata("LOW")

    local MoverButton = CreateFrame("button", "GBT_QuestsHeaderMoverButton", GBT_Frame, "BackdropTemplate")
    local MoverButtonText = MoverButton:CreateFontString(nil, "overlay", "GameFontNormal")
    MoverButtonText:SetText("Map Pins")
    MoverButtonText:SetPoint("right", MoverButton, "left", 0, 1)
    MoverButtonText:Hide()

    MoverButton:SetSize(25, 25)
    MoverButton:SetPoint("right", minimizeButton, "left", 0, 0)
    MoverButton:SetScript("OnClick", function()
        if GBT_Frame.movetexture:IsShown() then
            x, y = GBT_Frame:GetLeft(), GBT_Frame:GetTop()
            GBT_Frame:ClearAllPoints()
            GBT_Frame:SetMovable(false)
            GBT_Frame:EnableMouse(false)
            if GuildBankTools.db.profile.slpositon.x ~= x then
                GuildBankTools.db.profile.slpositon.x = x
            end
            if GuildBankTools.db.profile.slpositon.y ~= y then
                GuildBankTools.db.profile.slpositon.y = y
            end
            x = GuildBankTools.db.profile.slpositon.x
            y = GuildBankTools.db.profile.slpositon.y - 500
            GBT_Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
            GBT_Frame.movetexture:Hide()
        else
            GBT_Frame:SetMovable(true)
            GBT_Frame:EnableMouse(true)
            GBT_Frame:RegisterForDrag("LeftButton")
            GBT_Frame:SetScript("OnDragStart", GBT_Frame.StartMoving)
            GBT_Frame:SetScript("OnDragStop", GBT_Frame.StopMovingOrSizing)
            GBT_Frame.movetexture:Show()
        end
    end)
    MoverButton:SetNormalAtlas("soulbinds_collection_categoryheader_expand")
    MoverButton:SetHighlightAtlas("128-redbutton-refresh-highlight")
    MoverButton:SetFrameStrata("LOW")

    GBT_ObjectiveTrackerHeader:ClearAllPoints()
    GBT_ObjectiveTrackerHeader:SetPoint("bottom", GBT_Frame, "top", 0, -20)
    GBT_ObjectiveTrackerHeader:Show()

    function self:ToggleShoppingListFrame()
        if GBT_Frame:IsShown() then
            GBT_Frame:Hide()
        else
            GBT_Frame:Show()
        end
    end
end

local function isCraftingCheaper(itemID)
    if not itemID then
        return
    end
    local recipe = recipeReagents[itemID]
    if not recipe then
        return
    end
    local itemBuyPrice = GuildBankTools.db.profile.prices[itemID] or 0
    if itemBuyPrice == 0 then
        print("Alert: itemBuyPrice is 0 for" .. itemID)
        return
    end
    local craftingPrice = 0
    for index, reagent in ipairs(recipe) do
        local price = vendorReagents[reagent[1]] or GuildBankTools.db.profile.prices[reagent[1]] or 0
        craftingPrice = craftingPrice + price * reagent[2]
    end
    return craftingPrice < itemBuyPrice, craftingPrice, recipe
end

function ShowTooltipLine(tooltip)
    if not GuildBankTools.db.profile.prices then
        return
    end
    local _, itemLink = GameTooltip:GetItem()
    if itemLink then
        local itemID = GetItemInfoFromHyperlink(itemLink)
        if itemID then
            local gt = tooltip or GameTooltip
            if GuildBankTools.db.profile.prices[itemID] then
                gt:AddLine("AH Price:  " .. GetCoinTextureString(GuildBankTools.db.profile.prices[itemID]), 1, 1, 1, 1,
                    1, 1)
                if recipeReagents[itemID] then
                    local isCheaper, pricePerItem, recipe = isCraftingCheaper(itemID)
                    if pricePerItem then
                        gt:AddLine("Crafting Price:  " .. GetCoinTextureString(pricePerItem), 1, 1, 1, 1, 1, 1)
                    end
                end
            end
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", function(self)
    ShowTooltipLine(self)
end)

local function ScanAuctions()
    local itemList = {}
    for i, _ in pairs(GuildBankTools.db.profile.desiredItems) do
        itemList[i] = true
    end
    for i, j in pairs(recipeReagents) do
        for _, l in ipairs(j) do
            itemList[l[1]] = true
        end
        itemList[i] = true
    end
    wipe(auctions)

    local numReplicates = C_AuctionHouse.GetNumReplicateItems() - 1
    local chunks = 20
    local lastStart = 1
    local iterationIndex = 1
    C_Timer.NewTicker(0.2, function()
        for i = lastStart, (numReplicates / chunks) * iterationIndex do
            local item = {C_AuctionHouse.GetReplicateItemInfo(i)}
            if item[17] then
                if itemList[item[17]] then
                    if not auctions[item[17]] then
                        auctions[item[17]] = item[10] / item[3]
                    else
                        if auctions[item[17]] > item[10] / item[3] then
                            auctions[item[17]] = item[10] / item[3]
                        end
                    end
                end
            end
            lastStart = i
        end
        iterationIndex = iterationIndex + 1
        if lastStart == numReplicates then
            GuildBankTools.db.profile.prices = auctions
            print("Auctionhouse Scan complete")
            lastQuery = GetTime()
        end
    end, chunks)

end

local TextEditBox

local function TextEditBox_Show(text)
    if not TextEditBox then
        local f = CreateFrame("Frame", "TextEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", --  this one is neat
            edgeSize = 16,
            insets = {
                left = 8,
                right = 6,
                top = 8,
                bottom = 8
            }
        })
        f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

        --  Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)

        --  ScrollFrame
        local sf = CreateFrame("ScrollFrame", "TextEditBoxScrollFrame", TextEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)

        --  EditBox
        local eb = CreateFrame("EditBox", "TextEditBoxEditBox", TextEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) --  dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function()
            f:Hide()
        end)
        sf:SetScrollChild(eb)

        --  Resizable
        f:SetResizable(true)
        f:SetMinResize(150, 100)

        local rb = CreateFrame("Button", "TextEditBoxResizeButton", TextEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)

        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() --  more noticeable
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end

    if text then
        TextEditBoxEditBox:SetText(text)
    end
    TextEditBox:Show()
end

local function isItemLinkinGB(itemID)
    if not GBankItems then
        return
    end
    for link, _ in pairs(GBankItems) do
        if link:match(itemID) then
            return true
        end
    end
end

local function createShoppingList()
    local addedItems = {}
    vendorItems = {}
    shoppinglist = {}
    itemtobuy = {}
    boughtVendorItems = {}
    for gbitem, gbcount in pairs(GBankItems) do
        local itemID = GetItemInfoInstant(gbitem)
        if GuildBankTools.db.profile.desiredItems[itemID] then
            if (GuildBankTools.db.profile.desiredItems[itemID] - gbcount - GetItemCount(itemID, false)) > 0 then
                local isCheaper, pricePerItem, recipe = isCraftingCheaper(itemID)
                if isCheaper then
                    print("Crafting " ..
                              (GuildBankTools.db.profile.desiredItems[itemID] - gbcount - GetItemCount(itemID, false)) ..
                              " of " .. gbitem .. " is cheaper!")
                    for index, reagent in ipairs(recipe) do
                        local reagentCount = reagent[2] * (GuildBankTools.db.profile.desiredItems[itemID] - gbcount) -
                                                 GetItemCount(reagent[1], false)
                        if reagentCount < 0 then
                            reagentCount = 0
                        end
                        local reagentID = reagent[1]
                        if reagentCount > 0 then
                            if not vendorReagents[reagentID] then
                                shoppinglist[reagentID] = (shoppinglist[reagentID] or 0) + reagentCount
                                local itemLink = select(2, GetItemInfo(reagentID))
                                if itemLink then
                                    print("Added " .. reagentCount .. " of " .. itemLink .. " to shopping list")
                                else
                                    local item = Item:CreateFromItemID(reagentID)
                                    item:ContinueOnItemLoad(function()
                                        local l = item:GetItemLink()
                                        print("Added " .. reagentCount .. " of " .. l .. " to shopping list")
                                    end)
                                end
                            else
                                vendorItems[reagentID] = (vendorItems[reagentID] or 0) + reagentCount
                            end
                        end
                    end
                else
                    shoppinglist[itemID] =
                        (shoppinglist[itemID] or 0) + GuildBankTools.db.profile.desiredItems[itemID] - gbcount -
                            GetItemCount(itemID, false)
                    addedItems[itemID] = true
                    print("Added " .. GuildBankTools.db.profile.desiredItems[itemID] - gbcount .. " of " .. gbitem ..
                              " to shopping list")
                end
            end
        end
    end
    for item, count in pairs(GuildBankTools.db.profile.desiredItems) do
        if not addedItems[item] and not isItemLinkinGB(item) then
            local totalCount = count - GetItemCount(item, false)
            if totalCount > 0 then
                shoppinglist[item] = (shoppinglist[item] or 0) + totalCount
                local itemName = GetItemInfo(item)
                if itemName then
                    print("Added " .. count .. " of " .. itemName .. " to shopping list")
                else
                    local itemframe = Item:CreateFromItemID(item)
                    itemframe:ContinueOnItemLoad(function()
                        local link = itemframe:GetItemLink()
                        print("Added " .. count .. " of " .. link .. " to shopping list")
                    end)
                end
            end
        end
    end

    for item, count in pairs(vendorItems) do
        local itemLink = select(2, GetItemInfo(item))
        if itemLink then
            print("Buy " .. count .. " of " .. itemLink .. " from vendor")
        else
            local item = Item:CreateFromItemID(item)
            item:ContinueOnItemLoad(function()
                local l = item:GetItemLink()
                print("Buy " .. count .. " of " .. l .. " from vendor")
            end)
        end
    end
    GuildBankTools:TogglePinTrackerWindow()
end

local function CreateGBScannedText()
    local frame = CreateFrame("Frame", "GuildBankTools_ScannedText", UIParent)
    frame:SetSize(200, 50)
    frame:SetPoint("BOTTOMLEFT", GuildBankFrame, "BOTTOMLEFT", 0, 15)
    frame:SetFrameStrata("HIGH")
    frame:Hide()

    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    text:SetPoint("CENTER", frame, "CENTER")
    text:SetText("Scanned |A:Capacitance-General-WorkOrderCheckmark:19:19|a")

    local shopbutton = CreateFrame("Button", "GuildBankTools_ShopButton", UIParent)
    shopbutton:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 40, -15)
    shopbutton:SetWidth(20)
    shopbutton:SetHeight(20)
    shopbutton:SetFrameStrata("HIGH")
    shopbutton:SetText("|A:banker:19:19|a")
    shopbutton:SetNormalFontObject("GameFontNormalSmall")

    shopbutton:SetNormalTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\icon.tga")
    shopbutton:SetPushedTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\pushed.tga")
    shopbutton:SetHighlightTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\highlight.tga")
    shopbutton:SetScript('OnClick', createShoppingList)
    GuildBankTools.GBButtonShop = shopbutton
    GuildBankTools.GBScannedTextFrame = frame
end

function GuildBankTools:UpdateItemsInGB()
    local numTabs = GetNumGuildBankTabs()
    for index = 1, numTabs do
        if not queriedTabs[index] then
            QueryGuildBankTab(index)
            queriedTabs[index] = true
        end
    end
    C_Timer.After(1, function()
        GBankItems = {}
        for i = 1, numTabs, 1 do
            for k = 1, ItemsPerTab, 1 do
                local _, itemCount = GetGuildBankItemInfo(i, k)
                local itemLink = GetGuildBankItemLink(i, k)
                if itemLink then
                    if not GBankItems[itemLink] then
                        GBankItems[itemLink] = itemCount
                    else
                        GBankItems[itemLink] = GBankItems[itemLink] + itemCount
                    end
                end
            end
        end
        gbankScanned = true
        if gbankScanned then
            if not GuildBankTools.GBScannedTextFrame then
                CreateGBScannedText()
            end
            GuildBankTools.GBScannedTextFrame:Show()
            GuildBankTools.GBButtonShop:Show()
        end
    end)

end

local function getTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

local function getItemFromShoppingList(list)
    if getTableLength(list) == 0 then
        return
    end
    for item, count in pairs(list) do
        list[item] = nil
        return item, count
    end
end

local hooked = false

local function UpdateAuctionHouseBuyButton()
    if not hooked then
        hooksecurefunc(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox, "inputChangedCallback",
            function(a, b, c)
                local text = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox:GetText()
                text = tonumber(text)
                if text == itemtobuy.count then
                    GuildBankTools.GBBuyCount:SetText(itemtobuy.count ..
                                                          " |A:Capacitance-General-WorkOrderCheckmark:19:19|a")
                else
                    GuildBankTools.GBBuyCount:SetText(itemtobuy.count)
                end
            end)
        hooked = true
    end
    if not GuildBankTools.GBButtonBuy then
        local buybutton = CreateFrame("Button", "GuildBankTools_BuyButton", UIParent)
        buybutton:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPLEFT", 40, -15)
        buybutton:SetWidth(20)
        buybutton:SetHeight(20)
        buybutton:SetFrameStrata("HIGH")
        buybutton:SetText("|A:auctioneer:19:19|a")
        buybutton:SetNormalFontObject("GameFontNormalSmall")

        buybutton:SetNormalTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\icon.tga")
        buybutton:SetPushedTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\pushed.tga")
        buybutton:SetHighlightTexture("Interface\\AddOns\\ElvUI_PowerToys\\media\\highlight.tga")
        buybutton:SetScript('OnClick', function()
            local item, count = getItemFromShoppingList(shoppinglist)
            if item and count then
                item = tonumber(item)
                itemtobuy.itemID = item
                itemtobuy.count = count
                local itemframe = Item:CreateFromItemID(item)
                itemframe:ContinueOnItemLoad(function()
                    local name = itemframe:GetItemName()
                    AuctionHouseFrame:SetSearchText(name)
                    AuctionHouseFrame.SearchBar.SearchButton:Click()
                end)
            end

        end)
        GuildBankTools.GBButtonBuy = buybutton
    end
    if getTableLength(shoppinglist) == 0 then
        GuildBankTools.GBButtonBuy:Hide()
    else
        GuildBankTools.GBButtonBuy:Show()
    end

    if not GuildBankTools.GBBuyCount then
        local frame = CreateFrame("Frame", "GuildBankTools_ScannedText",
            AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput)
        frame:SetSize(200, 50)
        frame:SetPoint("LEFT", AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput, "RIGHT", 10, 0)
        frame:SetFrameStrata("HIGH")

        local text = frame:CreateFontString(nil, "OVERLAY")
        text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        text:SetPoint("CENTER", frame, "CENTER")
        text:Hide()
        GuildBankTools.GBBuyCount = text
    end
end

GuildBankTools:RegisterEvent('GUILDBANKFRAME_OPENED', function()
    GuildBankTools:UpdateItemsInGB()
end)

GuildBankTools:RegisterEvent('GUILDBANKFRAME_CLOSED', function()
    gbankScanned = false
    GuildBankTools.GBButtonShop:Hide()
    GuildBankTools.GBScannedTextFrame:Hide()
end)

GuildBankTools:RegisterEvent('AUCTION_HOUSE_SHOW', function()
    if lastQuery then
        local diff = GetTime() - lastQuery
        if diff > 900 then
            C_AuctionHouse.ReplicateItems()
            initialQuery = true
        else
            local minutes = math.floor(diff / 60)
            local seconds = diff % 60
            print("Next Auction Scan can be done in " .. minutes .. " minutes and " .. seconds .. " seconds")
        end
    else
        C_AuctionHouse.ReplicateItems()
        initialQuery = true
    end

    UpdateAuctionHouseBuyButton()
end)

GuildBankTools:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE", function()
    if initialQuery then
        ScanAuctions()
        initialQuery = false
    end
end)

local lastupdate

GuildBankTools:RegisterEvent('AUCTION_HOUSE_CLOSED', function()
    GuildBankTools.GBButtonBuy:Hide()
    if not lastupdate or lastupdate < GetTime() - 1 then
        lastupdate = GetTime()
        local count = 0
        for i, j in pairs(itemspurchased) do
            local itemName = GetItemInfo(i)
            count = count + 1
            if not itemName then
                itemName = "UnknownName with id: " .. i
            end
            print("Bought " .. j.count .. " of " .. itemName .. " for " .. GetCoinTextureString(j.price))
        end

        local totalGoldSpent = 0
        for i, j in pairs(itemspurchased) do
            totalGoldSpent = totalGoldSpent + j.price
        end
        if count > 0 then
            print("Total gold spent: " .. GetCoinTextureString(totalGoldSpent) .. " on " .. date())
        end

        local exportText = ""
        for i, j in pairs(itemspurchased) do
            local itemName = GetItemInfo(i)
            local price = ("%d,%d,%d"):format(j.price / 100 / 100, (j.price / 100) % 100, j.price % 100)
            exportText = exportText .. itemName .. "," .. j.count .. "," .. price .. "," .. date() .. "\n"
        end
        if exportText ~= "" then
            TextEditBox_Show(exportText)
        end
    end
    itemspurchased = {}
end)

GuildBankTools:RegisterEvent('AUCTION_HOUSE_THROTTLED_SYSTEM_READY', function()
    if AuctionHouseFrame.CommoditiesBuyFrame:GetItemID() == itemtobuy.itemID then
        GuildBankTools.GBBuyCount:SetText(itemtobuy.count)
        GuildBankTools.GBBuyCount:Show()
    else
        GuildBankTools.GBBuyCount:Hide()
    end
end)

GuildBankTools:RegisterEvent('COMMODITY_PURCHASE_SUCCEEDED', function()
    itemspurchased[itemtobuy.itemID] = {
        count = itemtobuy.count,
        price = itemprice
    }
    itemtobuy = {}
    if getTableLength(shoppinglist) == 0 then
        GuildBankTools.GBButtonBuy:Hide()
        GuildBankTools.GBBuyCount:Hide()
    else
        GuildBankTools.GBButtonBuy:Show()
        GuildBankTools.GBBuyCount:Show()
    end

end)

GuildBankTools:RegisterEvent('COMMODITY_PRICE_UPDATED', function(event, peritem, total)
    itemprice = total
end)

GuildBankTools:RegisterEvent('MERCHANT_SHOW', function()
    for i = 1, GetMerchantNumItems() do
        local itemID = GetMerchantItemID(i)
        if vendorItems[itemID] then
            BuyMerchantItem(i, vendorItems[itemID])
            boughtVendorItems[itemID] = {(select(3, GetMerchantItemInfo(i)) * vendorItems[itemID]), vendorItems[itemID]}
            vendorItems[itemID] = nil
        end
    end
end)

GuildBankTools:RegisterEvent("MERCHANT_CLOSED", function()
    local exportText = ""
    for i, info in pairs(boughtVendorItems) do
        local itemName = GetItemInfo(i)
        local price = ("%d,%d,%d"):format(info[1] / 100 / 100, (info[1] / 100) % 100, info[1] % 100)
        exportText = exportText .. itemName .. "," .. info[2] .. "," .. price .. "," .. date() .. "\n"
    end
    if exportText ~= "" then
        TextEditBox_Show(exportText)
    end
    boughtVendorItems = {}
end)
