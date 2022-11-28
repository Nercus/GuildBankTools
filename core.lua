local GuildBankTools = LibStub("AceAddon-3.0"):NewAddon("GuildBankTools", "AceConsole-3.0", "AceEvent-3.0",
    "AceTimer-3.0")

local ItemsPerTab = 98

local craftingCountperItem = {
    [172041] = 3, -- Spinefin Souffle and Fries
    [172049] = 3, -- Iridescent Ravioli with Apple Sauce
    [172051] = 3, -- Steak a la Mode
    [172045] = 3 -- Tenebrous Crown Roast Aspic
}

local recipeReagents = {
    --  Cooking
    [172043] = { { 173036, 10 }, -- Spinefin Piranha
        { 173034, 10 }, -- Silvergill Pike
        { 172053, 10 }, -- Tenebrous Ribs
        { 172055, 10 }, -- Phantasmal Haunch
        { 173037, 5 }, -- Elysian Thade
        { 172058, 5 }, -- Smuggled Azerothian Produce
        { 172059, 5 }, -- Rich Grazer Milk
        { 178786, 5 } -- Lusterwheat Flour
    }, -- Feast of Gluttonous Hedonism
    [187648] = { { 187812, 1 }, -- Empty Kettle
        { 171841, 1 }, -- Shaded Stone
        { 159, 5 } -- Refreshing Spring Water
    }, -- Empty Kettle of Stone Soup
    [172041] = { { 173036, 3 }, -- Spinefin Piranha
        { 173033, 3 }, -- Iridescent Amberjack
        { 172058, 4 }, -- Smuggled Azerothian Produce
        { 172057, 2 } -- Inconceivably Aged Vinegar
    }, -- Spinefin Souffle and Fries
    [172049] = { { 173033, 3 }, -- Iridescent Amberjack
        { 173032, 3 }, -- Lost Sole
        { 172058, 3 }, -- Smuggled Azerothian Produce
        { 178786, 2 }, -- Lusterwheat Flour
        { 172057, 1 } -- Inconceivably Aged Vinegar
    }, -- Iridescent Ravioli with Apple Sauce
    [172051] = { { 179315, 3 }, -- Shadowy Shank
        { 172054, 3 }, -- Raw Seraphic Wing
        { 172059, 2 }, -- Rich Grazer Milk
        { 172056, 2 }, -- Medley of Transplanar Spices
        { 172057, 2 } -- Inconceivably Aged Vinegar
    }, -- Steak a la Mode
    [172045] = { { 172053, 3 }, -- Tenebrous Ribs
        { 179314, 3 }, -- Creeping Crawler Meat
        { 172056, 4 }, -- Medley of Transplanar Spices
        { 172059, 2 } -- Rich Grazer Milk
    }, -- Tenebrous Crown Roast Aspic

    -- --  Alchemy
    -- [171351] = {{180732, 1}, -- Rune Etched Vial
    -- {168583, 3}, -- Widowbloom
    -- {170554, 3} -- Vigil's Torch
    -- }, -- Potion of Deathly Fixation
    -- [171275] = {{180732, 1}, -- Rune Etched Vial
    -- {168586, 5} -- Rising Glory
    -- }, -- Potion of Spectral Strength
    -- [171270] = {{180732, 1}, -- Rune Etched Vial
    -- {168583, 5} -- Widowbloom
    -- }, -- Potion of Spectral Agility
    -- [171273] = {{180732, 1}, -- Rune Etched Vial
    -- {168589, 5} -- Marrowroot
    -- }, -- Potion of Spectral Intellect
    -- [171349] = {{180732, 1}, -- Rune Etched Vial
    -- {168589, 3}, -- Marrowroot
    -- {168586, 3} -- Rising Glory
    -- }, -- Potion of Phantom Fire
    -- [171272] = {{180732, 1}, -- Rune Etched Vial
    -- {170554, 5} -- Vigil's Torch
    -- }, -- Potion of Spiritual Clarity
    -- [171267] = {{180732, 1}, -- Rune Etched Vial
    -- {169701, 2} -- Death Blossom
    -- }, -- Spiritual Healing Potion
    -- [171268] = {{180732, 1}, -- Rune Etched Vial
    -- {169701, 2} -- Death Blossom
    -- }, -- Spiritual Mana Potion
    -- [171276] = {{180732, 1}, -- Rune Etched Vial
    -- {171315, 3}, -- Nightshade
    -- {168586, 4}, -- Rising Glory
    -- {168589, 4}, -- Marrowroot
    -- {168583, 4}, -- Widowbloom
    -- {170554, 4} -- Vigil's Torch
    -- }, -- Spectral Flask of Power
    -- [171286] = {{180732, 1}, -- Rune Etched Vial
    -- {169701, 2} -- Death Blossom
    -- }, -- Embalmer's Oil
    -- [171285] = {{180732, 1}, -- Rune Etched Vial
    -- {169701, 2} -- Death Blossom
    -- }, -- Shadowcore Oil
    -- [171266] = {{180732, 1}, -- Rune Etched Vial
    -- {169701, 2}, -- Death Blossom
    -- {168586, 3} -- Rising Glory
    -- }, -- Potion of the Hidden Spirit

    -- --  Engineering
    -- [132514] = {{123918, 20}, -- Leystone Ore
    -- {136637, 10}, -- Oversized Blasting Cap
    -- {136633, 1} -- Loose Trigger
    -- }, -- Auto-Hammer
    -- [109076] = {{109119, 8}, -- True Iron Ore
    -- {111557, 5} -- Sumptuous Fur
    -- }, -- Goblin Glider Kit
    -- [184308] = {{172937, 1}, -- Wormfed Gear Assembly,
    -- {172936, 1}, -- Mortal Coiled Spring
    -- {172934, 4}, -- Handful of Laestrite Bolts
    -- {183952, 1} -- Machinist's Oil
    -- }, -- Disposable Spectrophasic Reanimator

    -- --  Inscription
    -- [173049] = {{173059, 3}, -- Luminous Ink
    -- {173058, 3}, -- Umbral Ink
    -- {175886, 25} -- Dark Parchment
    -- }, -- Tome of the Still Mind

    --  Leatherworking
    [172347] = { { 172096, 8 }, -- Heavy Desolate Leather
        { 177062, 4 } -- Penumbra Thread
    }, -- Heavy Desolate Armor Kit
    [172233] = { { 172096, 3 }, -- Heavy Desolate Leather
        { 172092, 3 }, -- Pallid Bone
        { 177062, 1 } -- Penumbra Thread
    } -- Drums of Deathly Ferocity

    -- -- Enchanting
    -- [172365] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 3} -- Sacred Shard
    -- }, -- Enchant Weapon - Ascended Vigor
    -- [172366] = {{172231, 2}, -- Sacred Shard
    -- {172230, 4} -- Soul Dust
    -- }, -- Enchant Weapon - Celestial Guidance
    -- [172367] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 3} -- Sacred Shard
    -- }, -- Enchant Weapon - Eternal Grace
    -- [172370] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 3} -- Sacred Shard
    -- }, -- Enchant Weapon - Lightless Force
    -- [172368] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 3} -- Sacred Shard
    -- }, -- Enchant Weapon - Sinful Revelation
    -- [172411] = {{172231, 2}, -- Sacred Shard
    -- {172230, 4} -- Soul Dust
    -- }, -- Enchant Cloak - Fortified Avoidance
    -- [172412] = {{172231, 2}, -- Sacred Shard
    -- {172230, 4} -- Soul Dust
    -- }, -- Enchant Cloak - Fortified Leech
    -- [172410] = {{172231, 2}, -- Sacred Shard
    -- {172230, 4} -- Soul Dust
    -- }, -- Enchant Cloak - Fortified Speed
    -- [172415] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Bracers - Eternal Intellect
    -- [172408] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Gloves - Eternal Strength
    -- [172419] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Boots - Eternal Agility
    -- [172418] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Chest - Eternal Bulwark
    -- [177659] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Chest - Eternal Skirmish
    -- [177962] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Chest - Eternal Stats
    -- [183738] = {{172232, 2}, -- Eternal Crystal
    -- {172231, 2} -- Sacred Shard
    -- }, -- Enchant Chest - Eternal Insight
    -- [172361] = {{172231, 3} -- Sacred Shard
    -- }, -- Enchant Ring - Tenet of Critical Strike
    -- [172362] = {{172231, 3} -- Sacred Shard
    -- }, -- Enchant Ring - Tenet of Haste
    -- [172363] = {{172231, 3} -- Sacred Shard
    -- }, -- Enchant Ring - Tenet of Mastery
    -- [172364] = {{172231, 3} -- Sacred Shard
    -- }, -- Enchant Ring - Tenet of Versatility

    -- -- Jewelcrafting
    -- [173127] = {{173109, 2}, -- Angerseye
    -- {173108, 2}, -- Oriblase
    -- {173168, 1} -- Laestrite Setting
    -- }, -- Deadly Jewel Cluster
    -- [173128] = {{173108, 4}, -- Oriblase
    -- {173168, 1} -- Laestrite Setting
    -- }, -- Quick Jewel Cluster
    -- [173130] = {{173109, 2}, -- Angerseye
    -- {173110, 2}, -- Umbryl
    -- {173168, 1} -- Laestrite Setting
    -- }, -- Masterful Jewel Cluster
    -- [173129] = {{173110, 4}, -- Umbryl
    -- {173168, 1} -- Laestrite Setting
    -- } -- Versatile Jewel Cluster

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
    [172057] = 3750, -- Inconceivably Aged Vinegar
    [173168] = 1000, -- Laestrite Setting
    [183952] = 9000, -- Machinist's Oil
    [159] = 25, -- Refreshing Spring Water
    [187812] = 2500000 -- Empty Kettle
}

local LDBIcon = LibStub("LibDBIcon-1.0")
local LibAddonUtils = LibStub("LibAddonUtils-1.0")

local vendorItems = {}
local boughtItems = {}
local queriedTabs = {}
local gbankScanned = false

local GBankItems = {}
local shoppinglist = {}

local itemtobuy = {}

local itemprice = 0

local itemspurchased = {}

local initialQuery
local auctions = {}
local addedItems = {}

local startShopping = false


local defaults = {
    profile = {
        minimap = {
            hide = false
        },
        lastQuery = 0,
        slpositon = {
            x = 0,
            y = 0
        },
        layoutEditor = {
            gbankslots = {},
            layout = {},
            num = 0
        },
        prices = {},
        desiredItems = false
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
        elseif button == "RightButton" then
            GuildBankTools:ToggleOptions()
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Left-Click to open shopping list")
        tt:AddLine("Right-Click to open item editor")
    end
})

function TextEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = {
                left = 8,
                right = 6,
                top = 8,
                bottom = 8
            }
        })
        f:SetBackdropBorderColor(0, 0, 0, 0.5) -- darkblue

        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)

        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)

        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function()
            f:Hide()
        end)
        sf:SetScrollChild(eb)

        -- Resizable
        f:SetResizable(true)
        f:SetResizeBounds(150, 100)

        local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)

        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable
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
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
end

local function getTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function GuildBankTools:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildBankToolsDB", defaults, true)
    if not self.db.profile.desiredItems then
        self.db.profile.desiredItems = {}
    end
    LDBIcon:Register("GuildBankTools", GuildBankToolsBroker, self.db.profile.minimap)
    GuildBankTools:UpdateMinimapButton()

    local GBT_Frame = CreateFrame("Frame", nil, UIParent)
    GBT_Frame:SetFrameStrata("BACKGROUND")
    GBT_Frame:SetWidth(300)
    GBT_Frame:SetHeight(500)
    local x = GuildBankTools.db.profile.slpositon.x
    local y = GuildBankTools.db.profile.slpositon.y - 500
    GBT_Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    GBT_Frame:SetClampedToScreen(true)
    GBT_Frame:Hide()
    self.ShoppingListFrame = GBT_Frame

    local tex = GBT_Frame:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", GBT_Frame, "TOPLEFT", 0, 0)
    tex:SetSize(GBT_Frame:GetWidth(), GBT_Frame:GetHeight())
    tex:SetColorTexture(0, 0, 0, 0.5)
    GBT_Frame.movetexture = tex
    GBT_Frame.movetexture:Hide()

    local GBT_ObjectiveTrackerHeader = CreateFrame("frame", "GBT_ObjectiveTrackerHeader", GBT_Frame)
    GBT_ObjectiveTrackerHeader:SetSize(300, 25)

    local GBT_ObjectiveTrackerHeaderTexture = GBT_Frame:CreateTexture(nil, "ARTWORK")
    GBT_ObjectiveTrackerHeaderTexture:SetSize(300, 25)
    GBT_ObjectiveTrackerHeaderTexture:SetAtlas('challenges-timerbg')
    GBT_ObjectiveTrackerHeaderTexture:SetPoint("TOPLEFT", GBT_ObjectiveTrackerHeader, "TOPLEFT", 0, 0)

    local GBT_ObjectiveTrackerHeaderText = GBT_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    GBT_ObjectiveTrackerHeaderText:SetPoint("LEFT", GBT_ObjectiveTrackerHeader, "LEFT", 25, 0)
    GBT_ObjectiveTrackerHeaderText:SetText("Shoppinglist")

    local minimizeButton = CreateFrame("button", "GBT_QuestsHeaderMinimizeButton", GBT_Frame, "BackdropTemplate")
    minimizeButton:SetSize(25, 25)
    minimizeButton:SetPoint("RIGHT", GBT_ObjectiveTrackerHeader, "RIGHT", -5, 0)
    minimizeButton:SetScript("OnClick", function()
        startShopping = false
        GBT_Frame:Hide()
    end)
    minimizeButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
    minimizeButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
    minimizeButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
    minimizeButton.innerTexture = minimizeButton:CreateTexture(nil, "ARTWORK")
    minimizeButton.innerTexture:SetTexture([[Interface\Buttons\UI-StopButton]])
    minimizeButton.innerTexture:SetPoint("CENTER", minimizeButton, "CENTER", 0, 0)
    minimizeButton.innerTexture:SetSize(16, 16)
    minimizeButton.innerTexture:SetBlendMode("ADD")
    minimizeButton:SetFrameStrata("LOW")

    local MoverButton = CreateFrame("button", "GBT_QuestsHeaderMoverButton", GBT_Frame, "BackdropTemplate")
    MoverButton:SetSize(25, 25)
    MoverButton:SetPoint("right", minimizeButton, "left", 3, 0)
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
            MoverButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
            GBT_Frame.movetexture:Hide()
        else
            GBT_Frame:SetMovable(true)
            GBT_Frame:EnableMouse(true)
            GBT_Frame:RegisterForDrag("LeftButton")
            GBT_Frame:SetScript("OnDragStart", GBT_Frame.StartMoving)
            GBT_Frame:SetScript("OnDragStop", GBT_Frame.StopMovingOrSizing)
            MoverButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Down]])
            GBT_Frame.movetexture:Show()
        end
    end)
    MoverButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
    MoverButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
    MoverButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
    MoverButton.innerTexture = MoverButton:CreateTexture(nil, "ARTWORK")
    MoverButton.innerTexture:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
    MoverButton.innerTexture:SetPoint("CENTER", MoverButton, "CENTER", 0, 0)
    MoverButton.innerTexture:SetSize(16, 16)
    MoverButton.innerTexture:SetBlendMode("ADD")
    MoverButton:SetFrameStrata("LOW")

    local ExportButton = CreateFrame("button", "GBT_QuestsHeaderExportButton", GBT_Frame, "BackdropTemplate")
    ExportButton:SetSize(25, 25)
    ExportButton:SetPoint("right", MoverButton, "left", -10, 0)
    ExportButton:SetScript("OnClick", function()
        local exportText = ""
        local totalGoldSpent = 0

        -- Vendor
        for i, info in pairs(boughtItems) do
            local itemName = GetItemInfo(i)
            totalGoldSpent = totalGoldSpent + info[1]
            local price = ("%d,%d,%d"):format(info[1] / 100 / 100, (info[1] / 100) % 100, info[1] % 100)
            exportText = exportText .. itemName .. "," .. info[2] .. "," .. price .. "," .. date() .. "\n"
        end

        -- AuctionHouse
        for i, j in pairs(itemspurchased) do
            local itemName = GetItemInfo(i)
            totalGoldSpent = totalGoldSpent + j.price
            local price = ("%d,%d,%d"):format(j.price / 100 / 100, (j.price / 100) % 100, j.price % 100)
            exportText = exportText .. itemName .. "," .. j.count .. "," .. price .. "," .. date() .. "\n"
        end

        exportText = exportText .. "Total spent: " .. GetCoinTextureString(totalGoldSpent)
        if exportText ~= "" then
            TextEditBox_Show(exportText)
        end
    end)
    ExportButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
    ExportButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
    ExportButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
    ExportButton.innerTexture = ExportButton:CreateTexture(nil, "ARTWORK")
    ExportButton.innerTexture:SetTexture([[Interface\Buttons\UI-GuildButton-PublicNote-Up]])
    ExportButton.innerTexture:SetPoint("CENTER", ExportButton, "CENTER", 0, 0)
    ExportButton.innerTexture:SetSize(16, 16)
    ExportButton.innerTexture:SetBlendMode("ADD")
    ExportButton:SetFrameStrata("LOW")

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
    if craftingCountperItem[itemID] then
        craftingPrice = craftingPrice / craftingCountperItem[itemID]
    end
    return (craftingPrice * (1 + GuildBankTools.db.profile.craftingDiff)) < itemBuyPrice,
        (craftingPrice * (1 + GuildBankTools.db.profile.craftingDiff)), recipe
end

function ShowTooltipLine(tooltip)
    if not GuildBankTools.db.profile.prices then
        return
    end
    local _, itemLink = GameTooltip:GetItem()
    if itemLink then
        local itemID = GetItemInfoFromHyperlink(itemLink)
        if itemID then
            if GuildBankTools.db.profile.prices[itemID] then
                local gt = tooltip or GameTooltip
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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self)
    ShowTooltipLine(self)
end)


local function ScanAuctions()
    wipe(auctions)

    local numReplicates = C_AuctionHouse.GetNumReplicateItems() - 1
    local chunks = 20
    local lastStart = 1
    local iterationIndex = 1
    C_Timer.NewTicker(0.2, function()
        for i = lastStart, (numReplicates / chunks) * iterationIndex do
            local item = { C_AuctionHouse.GetReplicateItemInfo(i) }
            if item[17] then

                if not auctions[item[17]] then
                    auctions[item[17]] = item[10] / item[3]
                else
                    if auctions[item[17]] > item[10] / item[3] then
                        auctions[item[17]] = item[10] / item[3]
                    end
                end

            end
            lastStart = i
        end
        iterationIndex = iterationIndex + 1
        if lastStart == numReplicates then
            GuildBankTools.db.profile.prices = auctions
            print("Auctionhouse Scan complete")
            GuildBankTools.db.profile.lastQuery = GetTime()
        end
    end, chunks)

end

local function GetGBankItemCount(itemID)
    if not GBankItems then
        return 0
    end
    for link, count in pairs(GBankItems) do
        if link:match(itemID) then
            return count
        end
    end
end

local framePool = {}

local function createShoppingListEntry(itemID, countnum)
    if #framePool == 0 then

        local f = CreateFrame("Button", nil, GuildBankTools.ShoppingListFrame)
        f:SetSize(300, 20)
        f:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        f.itemID = itemID
        f.countnum = countnum
        f.maxStack = select(8, GetItemInfo(itemID))

        f:SetScript("OnClick", function(self, click)
            if click == "LeftButton" then
                if vendorItems[f.itemID] and MerchantFrame then
                    for i = 1, GetMerchantNumItems() do
                        local itemID = GetMerchantItemID(i)
                        if itemID == f.itemID then
                            local _, _, price, quantity, _, _ = GetMerchantItemInfo(i)
                            local maxStack = select(8, GetItemInfo(itemID))
                            local buyRounds = math.floor(f.countnum / maxStack)
                            local rest = f.countnum % maxStack
                            for k = 1, buyRounds do
                                BuyMerchantItem(i, maxStack)
                            end
                            BuyMerchantItem(i, rest)

                            print("Buying " .. f.countnum .. " of " .. itemID .. " for " ..
                                GetCoinTextureString(price / quantity * f.countnum))
                            boughtItems[f.itemID] = { price / quantity * f.countnum, f.countnum }
                            vendorItems[itemID] = nil
                        end
                    end
                elseif shoppinglist[f.itemID] and AuctionHouseFrame then
                    if AuctionHouseFrame then
                        local slinfo = shoppinglist[f.itemID]
                        if slinfo then
                            itemtobuy.itemID = f.itemID
                            itemtobuy.count = slinfo.count
                            LibAddonUtils.CacheItem(f.itemID, function(i)

                                local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(i)
                                AuctionHouseFrame:SetSearchText(itemName)
                                AuctionHouseFrame.SearchBar.SearchButton:Click()

                            end, f.itemID)
                        end
                    end
                end
            end
            GuildBankTools:setShoppingList()
        end)

        local icon = f:CreateTexture(nil, "ARTWORK")
        icon:SetSize(18, 18)
        icon:SetPoint("LEFT", f, "LEFT", 0, 0)
        f.icon = icon

        local link = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        link:SetPoint("LEFT", icon, "RIGHT", 2, 0)
        f.link = link

        local count = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        count:SetPoint("RIGHT", f, "RIGHT", -3, 0)
        f.count = count

        local indexNumber = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        indexNumber:SetPoint("RIGHT", icon, "LEFT", -3, 0)
        indexNumber:SetText("")
        f.indexNumber = indexNumber

        f:Hide()
        LibAddonUtils.CacheItem(itemID, function(itemID)
            local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
            icon:SetTexture(itemTexture)

            link:SetText(itemLink)
            count:SetText(countnum)
            f:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
            end)
        end, itemID)
        return f
    else
        local f = table.remove(framePool)
        LibAddonUtils.CacheItem(itemID, function(itemID)
            local _, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
            f.icon:SetTexture(itemTexture)
            f.link:SetText(itemLink)
            f.count:SetText(countnum)
            f.indexNumber:SetText("")
            f:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
            end)
        end, itemID)
        f.itemID = itemID
        f.countnum = countnum
        f.maxStack = select(8, GetItemInfo(itemID))

        f:SetScript("OnClick", function(self, click)
            if click == "LeftButton" then
                if vendorItems[f.itemID] and MerchantFrame then
                    for i = 1, GetMerchantNumItems() do
                        local itemID = GetMerchantItemID(i)
                        if itemID == f.itemID then
                            local _, _, price, quantity, _, _ = GetMerchantItemInfo(i)
                            local maxStack = select(8, GetItemInfo(itemID))
                            local buyRounds = math.floor(f.countnum / maxStack)
                            local rest = f.countnum % maxStack
                            for k = 1, buyRounds do
                                BuyMerchantItem(i, maxStack)
                            end
                            BuyMerchantItem(i, rest)

                            print("Buying " .. f.countnum .. " of " .. itemID .. " for " ..
                                GetCoinTextureString(price / quantity * f.countnum))
                            boughtItems[f.itemID] = { price / quantity * f.countnum, f.countnum }
                            if itemID then
                                vendorItems[itemID] = nil
                            end
                        end
                    end
                elseif shoppinglist[f.itemID] and AuctionHouseFrame then
                    if AuctionHouseFrame then

                        local slinfo = shoppinglist[f.itemID]
                        if slinfo then
                            itemtobuy.itemID = f.itemID
                            itemtobuy.count = slinfo.count
                            LibAddonUtils.CacheItem(f.itemID, function(i)
                                local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(i)
                                AuctionHouseFrame:SetSearchText(itemName)
                                AuctionHouseFrame.SearchBar.SearchButton:Click()
                            end, f.itemID)
                        end
                    end
                end
            end
            GuildBankTools:setShoppingList()
        end)
        return f
    end

end

GuildBankTools.SLFEntries = {
    ["crafted"] = {},
    ["buy"] = {},
    ["vendor"] = {}
}

local tooltipGradient = { 'ff0000', 'fe4400', 'f86600', 'ee8200', 'df9b00', 'cdb200', 'b6c700', '98db00', '6fed00',
    '00ff00' }

function GuildBankTools:updateShoppingListFrame()
    if not self.SLFEntries["craftedHeader"] then
        local craftedHeader = CreateFrame("Frame", "GuildBankTools_CraftedHeader", self.ShoppingListFrame)
        craftedHeader:SetSize(self.ShoppingListFrame:GetWidth(), 20)
        craftedHeader.texture = craftedHeader:CreateTexture(nil, "BACKGROUND")
        craftedHeader.texture:SetAllPoints()
        craftedHeader.texture:SetAtlas("adventure-missionend-line")
        self.SLFEntries["craftedHeader"] = craftedHeader
    end
    self.SLFEntries["craftedHeader"]:SetPoint("TOPLEFT", self.ShoppingListFrame, "TOPLEFT", 0, -25)

    if not self.SLFEntries["craftedHeader"].text then
        local craftedHeaderText = self.SLFEntries["craftedHeader"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        craftedHeaderText:SetPoint("LEFT", self.SLFEntries["craftedHeader"], "LEFT", 0, 0)
        craftedHeaderText:SetText("Crafted Items")

        local crafterHeaderInfobutton = CreateFrame("Button", nil, self.SLFEntries["craftedHeader"])
        crafterHeaderInfobutton:SetSize(20, 20)
        crafterHeaderInfobutton:SetPoint("LEFT", craftedHeaderText, "RIGHT", 0, 0)
        crafterHeaderInfobutton:SetNormalAtlas("glueannouncementpopup-icon-info")
        crafterHeaderInfobutton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Materials for Crafted Items")
            local t = {}
            for i, v in pairs(addedItems) do
                if v[2] == "craft" then
                    local reagents = recipeReagents[i]
                    if reagents then
                        for _, l in ipairs(reagents) do
                            t[l[1]] = (t[l[1]] or 0) + math.ceil((l[2] * v[1]) / (craftingCountperItem[i] or 1))
                        end
                    end
                end
            end
            for itemID, count in pairs(t) do
                LibAddonUtils.CacheItem(itemID, function(itemID)
                    local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
                    local gbankCount = GBankItems[itemID] or 0
                    local inventoryCount, extendInventoryCount = GetItemCount(itemID, false), GetItemCount(itemID, true)
                    local bankCount = extendInventoryCount - inventoryCount
                    local totalCount = gbankCount + inventoryCount + bankCount
                    local itemString = string.format("|T%d:16:16:0:0:64:64:4:60:4:60|t %s", itemTexture, itemName)
                    local countString = string.format("GBank: %d, Inventory: %d, Bank: %d, Total: %d / %d", gbankCount,
                        inventoryCount, extendInventoryCount, totalCount, count)
                    local countRatio = totalCount / count
                    local countColor
                    if countRatio >= 1 then
                        countColor = tooltipGradient[10]
                    elseif countRatio == 0 then
                        countColor = tooltipGradient[1]
                    else
                        countColor = tooltipGradient[math.ceil(countRatio * 10)]
                    end
                    countString = string.format("|cff%s%s|r", countColor, countString)
                    GameTooltip:AddDoubleLine(itemString, countString, 1, 1, 1, 1, 1, 1)
                end, itemID)
            end
            GameTooltip:Show()
        end)
        crafterHeaderInfobutton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        self.SLFEntries["craftedHeader"].text = craftedHeaderText
    end

    if not self.SLFEntries["craftedHeader"].minimizeButton then
        local minimizeButton = CreateFrame("Button", "GuildBankTools_GuildBankTools_CraftedHeader_MinimizeButton",
            self.SLFEntries["craftedHeader"])
        minimizeButton:SetSize(20, 20)
        minimizeButton:SetPoint("RIGHT", self.SLFEntries["craftedHeader"], "RIGHT", -5, 0)
        minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
        minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
        minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
        GuildBankTools.CraftedItemsMinimized = false
        minimizeButton:SetScript("OnClick", function(self)
            if GuildBankTools.CraftedItemsMinimized then
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
                GuildBankTools.CraftedItemsMinimized = false
                for i, v in ipairs(GuildBankTools.SLFEntries["crafted"]) do
                    v:Show()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            else
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowdown-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowdown-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowdown-highlight")
                GuildBankTools.CraftedItemsMinimized = true
                for i, v in ipairs(GuildBankTools.SLFEntries["crafted"]) do
                    v:Hide()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            end
        end)
        self.SLFEntries["craftedHeader"].minimizeButton = minimizeButton
    end

    local index = 0
    local lastframeCrafted = nil
    for i, v in ipairs(GuildBankTools.SLFEntries["crafted"]) do
        v:Hide()
        table.insert(framePool, v)
    end
    GuildBankTools.SLFEntries["crafted"] = {}
    for itemID, v in pairs(addedItems) do
        if v[2] == "craft" then
            local f = createShoppingListEntry(itemID, v[1])
            f:SetPoint("TOPLEFT", self.SLFEntries["craftedHeader"], "BOTTOMLEFT", 0, -(index * 20))
            table.insert(GuildBankTools.SLFEntries["crafted"], f)
            if not GuildBankTools.CraftedItemsMinimized then
                f:Show()
            else
                f:Hide()
            end
            index = index + 1
            lastframeCrafted = f
        end
    end

    if #GuildBankTools.SLFEntries["crafted"] == 0 or GuildBankTools.CraftedItemsMinimized then
        lastframeCrafted = self.SLFEntries["craftedHeader"]
    end

    if not self.SLFEntries["buyHeader"] then
        local buyHeader = CreateFrame("Frame", "GuildBankTools_BuyHeader", self.ShoppingListFrame)
        buyHeader:SetSize(self.ShoppingListFrame:GetWidth(), 20)
        buyHeader.texture = buyHeader:CreateTexture(nil, "BACKGROUND")
        buyHeader.texture:SetAllPoints()
        buyHeader.texture:SetAtlas("adventure-missionend-line")
        self.SLFEntries["buyHeader"] = buyHeader
    end
    self.SLFEntries["buyHeader"]:SetPoint("TOPLEFT", lastframeCrafted, "BOTTOMLEFT", 0, -10)

    if not self.SLFEntries["buyHeader"].text then
        local buyHeaderText = self.SLFEntries["buyHeader"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        buyHeaderText:SetPoint("LEFT", self.SLFEntries["buyHeader"], "LEFT", 0, 0)
        buyHeaderText:SetText("Buy Items")
        self.SLFEntries["buyHeader"].text = buyHeaderText
    end

    if not self.SLFEntries["buyHeader"].minimizeButton then
        local minimizeButton = CreateFrame("Button", "GuildBankTools_BuyHeader_MinimizeButton",
            self.SLFEntries["buyHeader"])
        minimizeButton:SetSize(20, 20)
        minimizeButton:SetPoint("RIGHT", self.SLFEntries["buyHeader"], "RIGHT", -5, 0)
        minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
        minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
        minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
        GuildBankTools.BuyItemsMinimized = false
        minimizeButton:SetScript("OnClick", function(self)
            if GuildBankTools.BuyItemsMinimized then
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
                GuildBankTools.BuyItemsMinimized = false
                for i, v in ipairs(GuildBankTools.SLFEntries["buy"]) do
                    v:Show()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            else
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowdown-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowdown-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowdown-highlight")
                GuildBankTools.BuyItemsMinimized = true
                for i, v in ipairs(GuildBankTools.SLFEntries["buy"]) do
                    v:Hide()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            end
        end)
        self.SLFEntries["buyHeader"].minimizeButton = minimizeButton
    end

    index = 0
    local lastFrameBuy = nil
    for i, v in ipairs(GuildBankTools.SLFEntries["buy"]) do
        v:Hide()
        table.insert(framePool, v)
    end
    GuildBankTools.SLFEntries["buy"] = {}
    for itemID, v in pairs(shoppinglist) do
        local f = createShoppingListEntry(itemID, v.count)
        f:SetPoint("TOPLEFT", self.SLFEntries["buyHeader"], "BOTTOMLEFT", 0, -(index * 20))
        table.insert(GuildBankTools.SLFEntries["buy"], f)
        if not GuildBankTools.BuyItemsMinimized then
            f:Show()
        else
            f:Hide()
        end
        index = index + 1
        lastFrameBuy = f
    end
    if #GuildBankTools.SLFEntries["buy"] == 0 or GuildBankTools.BuyItemsMinimized then
        lastFrameBuy = self.SLFEntries["buyHeader"]
    end

    if not self.SLFEntries["vendorHeader"] then
        local vendorHeader = CreateFrame("Frame", "GuildBankTools_VendorHeader", self.ShoppingListFrame)
        vendorHeader:SetSize(self.ShoppingListFrame:GetWidth(), 20)
        vendorHeader.texture = vendorHeader:CreateTexture(nil, "BACKGROUND")
        vendorHeader.texture:SetAllPoints()
        vendorHeader.texture:SetAtlas("adventure-missionend-line")
        self.SLFEntries["vendorHeader"] = vendorHeader
    end
    self.SLFEntries["vendorHeader"]:SetPoint("TOPLEFT", lastFrameBuy, "BOTTOMLEFT", 0, -10)

    if not self.SLFEntries["vendorHeader"].text then
        local vendorHeaderText = self.SLFEntries["vendorHeader"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        vendorHeaderText:SetPoint("LEFT", self.SLFEntries["vendorHeader"], "LEFT", 0, 0)
        vendorHeaderText:SetText("Vendor Items")
        self.SLFEntries["vendorHeader"].text = vendorHeaderText
    end

    if not self.SLFEntries["vendorHeader"].minimizeButton then
        local minimizeButton = CreateFrame("Button", "GuildBankTools_VendorHeader_MinimizeButton",
            self.SLFEntries["vendorHeader"])
        minimizeButton:SetSize(20, 20)
        minimizeButton:SetPoint("RIGHT", self.SLFEntries["vendorHeader"], "RIGHT", -5, 0)
        minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
        minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
        minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
        GuildBankTools.VendorItemsMinimized = false
        minimizeButton:SetScript("OnClick", function(self)
            if GuildBankTools.VendorItemsMinimized then
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowup-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowup-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowup-highlight")
                GuildBankTools.VendorItemsMinimized = false
                for i, v in ipairs(GuildBankTools.SLFEntries["vendor"]) do
                    v:Show()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            else
                minimizeButton:SetNormalAtlas("hud-MainMenuBar-arrowdown-up")
                minimizeButton:SetPushedAtlas("hud-MainMenuBar-arrowdown-down")
                minimizeButton:SetHighlightAtlas("hud-MainMenuBar-arrowdown-highlight")
                GuildBankTools.VendorItemsMinimized = true
                for i, v in ipairs(GuildBankTools.SLFEntries["vendor"]) do
                    v:Hide()
                end
                if GuildBankTools:updateShoppingListFrame() then
                    GuildBankTools:updateShoppingListFrame()
                end
            end
        end)
        self.SLFEntries["vendorHeader"].minimizeButton = minimizeButton
    end

    for i, v in ipairs(GuildBankTools.SLFEntries["vendor"]) do
        v:Hide()
        table.insert(framePool, v)
    end
    GuildBankTools.SLFEntries["vendor"] = {}
    index = 0
    for itemID, count in pairs(vendorItems) do
        local f = createShoppingListEntry(itemID, count)
        f:SetPoint("TOPLEFT", self.SLFEntries["vendorHeader"], "BOTTOMLEFT", 0, -(index * 20))
        table.insert(GuildBankTools.SLFEntries["vendor"], f)
        if not GuildBankTools.VendorItemsMinimized then
            f:Show()
        else
            f:Hide()
        end
        index = index + 1
    end

    local assignedReagents = {}
    for i, entry in ipairs(GuildBankTools.SLFEntries["crafted"]) do
        if recipeReagents[entry.itemID] then
            for _, v in ipairs(recipeReagents[entry.itemID]) do
                if not assignedReagents[v[1]] then
                    assignedReagents[v[1]] = {}
                end
                table.insert(assignedReagents[v[1]], i)
            end
            entry.indexNumber:SetText(i .. " ")
        end
    end
    for i, entry in ipairs(GuildBankTools.SLFEntries["vendor"]) do
        if assignedReagents[entry.itemID] then
            local text = ""
            for _, indexNum in ipairs(assignedReagents[entry.itemID]) do
                text = text .. indexNum .. " "
            end
            entry.indexNumber:SetText(text)
        end
    end

    for i, entry in ipairs(GuildBankTools.SLFEntries["buy"]) do
        if assignedReagents[entry.itemID] then
            local text = ""
            for _, indexNum in ipairs(assignedReagents[entry.itemID]) do
                text = text .. indexNum .. " "
            end
            entry.indexNumber:SetText(text)
        end
    end
    self.ShoppingListFrame:Show()
end

function GuildBankTools:setShoppingList()
    if not startShopping then
        return
    end
    if getTableLength(GBankItems) == 0 then
        print("You need to scan your guild bank before you can start shopping.")
        return
    end

    local desiredItems = {}
    for tab, tabInfo in pairs(GuildBankTools.db.profile.layoutEditor.layout) do
        for slot, slotInfo in pairs(tabInfo) do
            if type(slotInfo) == "table" then
                desiredItems[slotInfo[1]] = (desiredItems[slotInfo[1]] or 0) + slotInfo[2]
            end
        end
    end
    addedItems = {}
    vendorItems = {}
    shoppinglist = {}

    for item, desiredCount in pairs(desiredItems) do
        if not addedItems[item] then
            local gbankItemCount = GetGBankItemCount(item) or 0
            local purchasedCount = 0
            if itemspurchased[item] then
                purchasedCount = itemspurchased[item].count
            end
            local totalCount = desiredCount - GetItemCount(item, false) - purchasedCount - gbankItemCount
            if totalCount > 0 then
                local isCheaper, pricePerItem, recipe = isCraftingCheaper(item)
                if isCheaper then
                    for index, reagent in ipairs(recipe) do
                        local reagentCountPerItem = math.ceil(reagent[2] / (craftingCountperItem[item] or 1))
                        local reagentCount = reagentCountPerItem * totalCount
                        if craftingCountperItem[item] then
                            local countToCraft = totalCount
                            if countToCraft % craftingCountperItem[item] == 0 then
                                reagentCount = reagentCountPerItem * countToCraft
                            else
                                reagentCount = reagentCountPerItem * (countToCraft + craftingCountperItem[item])
                            end
                        end
                        for v, k in pairs(GBankItems) do
                            local itemID = GetItemInfoFromHyperlink(v)
                            if reagent[1] == itemID then
                                reagentCount = reagentCount - k
                                break
                            end
                        end

                        local reagentID = reagent[1]
                        if reagentCount > 0 then
                            local purchasedReagentCount = 0
                            if itemspurchased[reagentID] then
                                purchasedReagentCount = itemspurchased[reagentID].count
                            end
                            if not vendorReagents[reagentID] then
                                local count = 0
                                if not shoppinglist[reagentID] then
                                    shoppinglist[reagentID] = {
                                        count = -(GetItemCount(reagentID, true) + (GBankItems[reagentID] or 0) +
                                            purchasedReagentCount),
                                        type = "reagent"
                                    }
                                end
                                if shoppinglist[reagentID] then
                                    count = shoppinglist[reagentID].count
                                end
                                shoppinglist[reagentID] = {
                                    ["type"] = "reagent",
                                    ["count"] = count + reagentCount
                                }
                            else
                                if not vendorItems[reagentID] then
                                    vendorItems[reagentID] =
                                    -(GetItemCount(reagentID, true) + (GBankItems[reagentID] or 0) +
                                        purchasedReagentCount)
                                end
                                vendorItems[reagentID] = (vendorItems[reagentID] or 0) + reagentCount
                            end
                        end
                    end

                    addedItems[item] = { totalCount, "craft" }
                else
                    local count = 0
                    if shoppinglist[item] then
                        count = shoppinglist[item].count
                    end

                    shoppinglist[item] = {
                        ["type"] = "item",
                        ["count"] = count + totalCount
                    }
                    addedItems[item] = { totalCount, "buy" }
                end

            end
        end
    end
    for i, v in pairs(shoppinglist) do
        if v.count <= 0 then
            shoppinglist[i] = nil
        end
    end
    for i, v in pairs(vendorItems) do
        if v <= 0 then
            vendorItems[i] = nil
        end
    end

    GuildBankTools:updateShoppingListFrame()
end

function GuildBankTools:generateMoves()
    local layout = GuildBankTools.db.profile.layoutEditor.layout
    local moves = {}
    local usedBagSlots = {}
    local freeBagSpace = {}
    local freeSpace = {}
    local itemsInFreeSpace = {}
    for tabIndex, tabData in ipairs(layout) do
        for slotIndex = 1, 98 do
            local slotData = tabData[slotIndex]
            if slotData == -1 and not GetGuildBankItemLink(tabIndex, slotIndex) then
                table.insert(freeSpace, { tabIndex, slotIndex })
            elseif slotData == -1 and GetGuildBankItemLink(tabIndex, slotIndex) then
                local itemID = GetItemInfoFromHyperlink(GetGuildBankItemLink(tabIndex, slotIndex))
                if not itemsInFreeSpace[itemID] then
                    itemsInFreeSpace[itemID] = {}
                end
                local _, freeSpaceItemCount = GetGuildBankItemInfo(tabIndex, slotIndex)
                table.insert(itemsInFreeSpace[itemID], { tabIndex, slotIndex, freeSpaceItemCount })
            end
        end
    end

    for bag = 0, NUM_BAG_SLOTS do
        for bagSlot = 1, C_Container.GetContainerNumSlots(bag) do
            if not C_Container.GetContainerItemID(bag, bagSlot) then
                table.insert(freeBagSpace, { bag, bagSlot })
            end
        end
    end

    local freeSpaceIndex = 0
    for tabIndex, tabData in ipairs(layout) do
        for slotIndex, slotData in ipairs(tabData) do
            local slotItemLink = GetGuildBankItemLink(tabIndex, slotIndex)
            local slotItemId
            if slotItemLink then
                slotItemId = GetItemInfoFromHyperlink(slotItemLink)
            end
            local _, slotItemCount = GetGuildBankItemInfo(tabIndex, slotIndex)

            local desiredSlotItemId
            local desiredSlotItemCount
            if type(slotData) == "table" then
                desiredSlotItemId = slotData[1]
                desiredSlotItemCount = slotData[2]
            end

            if slotItemId and slotItemId == desiredSlotItemId and desiredSlotItemCount then -- Slot is occupied by the correct item
                if slotItemCount > desiredSlotItemCount then -- to many
                    -- pickup difference and put into free space
                    freeSpaceIndex = freeSpaceIndex + 1
                    local freeSpaceSlot
                    if freeSpaceIndex <= #freeSpace then
                        freeSpaceSlot = freeSpace[freeSpaceIndex]
                    end
                    if freeSpaceSlot then
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeSpaceSlot[1], freeSpaceSlot[2] },
                            ["count"] = slotItemCount - desiredSlotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bank"
                        })
                    else
                        -- no freeSpaceSlot available
                        -- moving to bags doesnt need a target
                        local freeBagSpaceSlot = table.remove(freeBagSpace)
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeBagSpaceSlot[1], freeBagSpaceSlot[2] },
                            ["count"] = slotItemCount - desiredSlotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bags"
                        })
                    end
                elseif slotItemCount < desiredSlotItemCount then -- to few
                    local moveSet = false
                    -- iterate over free space and pickup item if possible
                    if itemsInFreeSpace[desiredSlotItemId] and #itemsInFreeSpace[desiredSlotItemId] > 0 then
                        local freeSpaceItemSlotSource = table.remove(itemsInFreeSpace[desiredSlotItemId], 1)
                        if (freeSpaceItemSlotSource[3] - desiredSlotItemCount) > 0 then
                            table.insert(itemsInFreeSpace[desiredSlotItemId], { freeSpaceItemSlotSource[1],
                                freeSpaceItemSlotSource[2],
                                freeSpaceItemSlotSource[3] -
                                    desiredSlotItemCount })
                        elseif (freeSpaceItemSlotSource[3] - desiredSlotItemCount) == 0 then
                            table.insert(freeSpace, { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] })
                        end
                        if freeSpaceItemSlotSource then
                            table.insert(moves, {
                                ["source"] = { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] },
                                ["target"] = { tabIndex, slotIndex },
                                ["count"] = desiredSlotItemCount,
                                ["from"] = "bank",
                                ["to"] = "bank"
                            })
                            moveSet = true
                        end
                    end

                    -- iterate over bag and pickup item if possible
                    if not moveSet then
                        local movedCount = 0
                        for bag = 0, NUM_BAG_SLOTS do
                            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                                if desiredSlotItemId == C_Container.GetContainerItemID(bag, slot) and
                                    not usedBagSlots[bag .. "-" .. slot] then
                                    local _, bagSlotItemCount = C_Container.GetContainerItemInfo(bag, slot).stackCount
                                    if bagSlotItemCount >= desiredSlotItemCount then
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = desiredSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })
                                        movedCount = desiredSlotItemCount
                                    else -- to few items in that bag slot
                                        -- diff to match exact desiredSlotItemCount
                                        if (movedCount + bagSlotItemCount) > desiredSlotItemCount then
                                            bagSlotItemCount = desiredSlotItemCount - movedCount
                                        end
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = bagSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })

                                        movedCount = movedCount + bagSlotItemCount
                                    end

                                    if movedCount == desiredSlotItemCount then
                                        moveSet = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            elseif slotItemId and slotItemId ~= desiredSlotItemId then -- Slot is occupied by the wrong item
                if slotData == "b" then -- slot is blocked
                    freeSpaceIndex = freeSpaceIndex + 1
                    local freeSpaceSlot
                    if freeSpaceIndex <= #freeSpace then
                        freeSpaceSlot = freeSpace[freeSpaceIndex]
                    end
                    if freeSpaceSlot then
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeSpaceSlot[1], freeSpaceSlot[2] },
                            ["count"] = slotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bank"
                        })
                    else
                        -- moving to bags doesnt need a target
                        local freeBagSpaceSlot = table.remove(freeBagSpace)
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeBagSpaceSlot[1], freeBagSpaceSlot[2] },
                            ["count"] = slotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bags"
                        })
                    end
                elseif desiredSlotItemId and desiredSlotItemCount then -- slot has wrong item
                    -- move item to free space
                    freeSpaceIndex = freeSpaceIndex + 1
                    local freeSpaceSlot
                    if freeSpaceIndex <= #freeSpace then
                        freeSpaceSlot = freeSpace[freeSpaceIndex]
                    end
                    if freeSpaceSlot then
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeSpaceSlot[1], freeSpaceSlot[2] },
                            ["count"] = slotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bank"
                        })
                    else
                        -- moving to bags doesnt need a target
                        local freeBagSpaceSlot = table.remove(freeBagSpace)
                        table.insert(moves, {
                            ["source"] = { tabIndex, slotIndex },
                            ["target"] = { freeBagSpaceSlot[1], freeBagSpaceSlot[2] },
                            ["count"] = slotItemCount,
                            ["from"] = "bank",
                            ["to"] = "bags"
                        })
                    end

                    local moveSet = false
                    -- iterate over free space and pickup item if possible
                    if itemsInFreeSpace[desiredSlotItemId] and #itemsInFreeSpace[desiredSlotItemId] > 0 then
                        local freeSpaceItemSlotSource = table.remove(itemsInFreeSpace[desiredSlotItemId], 1)
                        if (freeSpaceItemSlotSource[3] - desiredSlotItemCount) > 0 then
                            table.insert(itemsInFreeSpace[desiredSlotItemId], { freeSpaceItemSlotSource[1],
                                freeSpaceItemSlotSource[2],
                                freeSpaceItemSlotSource[3] -
                                    desiredSlotItemCount })
                        elseif (freeSpaceItemSlotSource[3] - desiredSlotItemCount) == 0 then
                            table.insert(freeSpace, { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] })
                        end
                        if freeSpaceItemSlotSource then
                            table.insert(moves, {
                                ["source"] = { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] },
                                ["target"] = { tabIndex, slotIndex },
                                ["count"] = desiredSlotItemCount,
                                ["from"] = "bank",
                                ["to"] = "bank"
                            })
                            moveSet = true
                        end
                    end

                    -- iterate over bag and pickup item if possible
                    if not moveSet then
                        local movedCount = 0
                        for bag = 0, NUM_BAG_SLOTS do
                            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                                if desiredSlotItemId == C_Container.GetContainerItemID(bag, slot) and
                                    not usedBagSlots[bag .. "-" .. slot] then
                                    local _, bagSlotItemCount = C_Container.GetContainerItemInfo(bag, slot).stackCount
                                    if bagSlotItemCount >= desiredSlotItemCount then
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = desiredSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })
                                        movedCount = desiredSlotItemCount
                                    else -- to few items in that bag slot
                                        -- diff to match exact desiredSlotItemCount
                                        if (movedCount + bagSlotItemCount) > desiredSlotItemCount then
                                            bagSlotItemCount = desiredSlotItemCount - movedCount
                                        end
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = bagSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })

                                        movedCount = movedCount + bagSlotItemCount
                                    end

                                    if movedCount == desiredSlotItemCount then
                                        moveSet = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Slot is empty
            if not slotItemId then
                if desiredSlotItemId and desiredSlotItemCount then -- slot should not be empty
                    local moveSet = false
                    -- iterate over free space and pickup item if possible
                    if itemsInFreeSpace[desiredSlotItemId] and #itemsInFreeSpace[desiredSlotItemId] > 0 then
                        local freeSpaceItemSlotSource = table.remove(itemsInFreeSpace[desiredSlotItemId], 1)
                        if (freeSpaceItemSlotSource[3] - desiredSlotItemCount) > 0 then
                            table.insert(itemsInFreeSpace[desiredSlotItemId], { freeSpaceItemSlotSource[1],
                                freeSpaceItemSlotSource[2],
                                freeSpaceItemSlotSource[3] -
                                    desiredSlotItemCount })
                        elseif (freeSpaceItemSlotSource[3] - desiredSlotItemCount) == 0 then
                            table.insert(freeSpace, { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] })
                        end
                        if freeSpaceItemSlotSource then
                            table.insert(moves, {
                                ["source"] = { freeSpaceItemSlotSource[1], freeSpaceItemSlotSource[2] },
                                ["target"] = { tabIndex, slotIndex },
                                ["count"] = desiredSlotItemCount,
                                ["from"] = "bank",
                                ["to"] = "bank"
                            })
                            moveSet = true
                        end
                    end

                    -- iterate over bag and pickup item if possible
                    if not moveSet then
                        local movedCount = 0
                        for bag = 0, NUM_BAG_SLOTS do
                            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                                if desiredSlotItemId == C_Container.GetContainerItemID(bag, slot) and
                                    not usedBagSlots[bag .. "-" .. slot] then
                                    local _, bagSlotItemCount = C_Container.GetContainerItemInfo(bag, slot).stackCount
                                    if bagSlotItemCount >= desiredSlotItemCount then
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = desiredSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })
                                        movedCount = desiredSlotItemCount
                                    else -- to few items in that bag slot
                                        -- diff to match exact desiredSlotItemCount
                                        if (movedCount + bagSlotItemCount) > desiredSlotItemCount then
                                            bagSlotItemCount = desiredSlotItemCount - movedCount
                                        end
                                        usedBagSlots[bag .. "-" .. slot] = true
                                        table.insert(moves, {
                                            ["source"] = { bag, slot },
                                            ["target"] = { tabIndex, slotIndex },
                                            ["count"] = bagSlotItemCount,
                                            ["from"] = "bags",
                                            ["to"] = "bank"
                                        })

                                        movedCount = movedCount + bagSlotItemCount
                                    end

                                    if movedCount == desiredSlotItemCount then
                                        moveSet = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return moves
end

local isMoving = false

function GuildBankTools:DoMove(moves)
    local move = moves[GuildBankTools.moveCounter]
    if move then
        local source = move["source"]
        local target = move["target"]
        local count = move["count"]
        local from = move["from"]
        local to = move["to"]

        if not source[1] or not source[2] or not target[1] or not target[2] or not count or not from or not to or
            not GuildBankTools.moveCounter then
            GuildBankTools:Print("Error: Missing move data", source[1], source[2], target[1], target[2], count, from,
                to, GuildBankTools.moveCounter)
            return
        end
        print(string.format("Moving %d from %s (%s, %s) to %s (%s, %s) - Move %s from %s", count, from, source[1],
            source[2], to, target[1], target[2], GuildBankTools.moveCounter, #moves))

        ClearCursor() -- Clear Cursor before moving item
        if from == "bank" then
            SplitGuildBankItem(source[1], source[2], count)
            if to == "bags" then
                PickupContainerItem(target[1], target[2])
            elseif to == "bank" then
                PickupGuildBankItem(target[1], target[2])
            else
                print("ERROR: Could not move item from bank")
            end
        elseif from == "bags" then
            SplitContainerItem(source[1], source[2], count)
            if to == "bank" then
                PickupGuildBankItem(target[1], target[2])
            else
                print("ERROR: Could not move item from bag")
            end
        end

        GuildBankTools.moveCounter = GuildBankTools.moveCounter + 1
        print(GuildBankTools.moveCounter == #moves and "Done" or "")
        if GuildBankTools.moveCounter == #moves then
            isMoving = false
            GuildBankTools:SortGuildBank()
            return
        end
    end
end

local maxIterations = 10
local numIterations = 0

function GuildBankTools:SortGuildBank()
    if InCombatLockdown() then
        return
    end
    GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
    -- Set Items Based on layout
    local moves = self:generateMoves()
    numIterations = numIterations + 1
    print("Redo Moving")
    isMoving = true
    GuildBankTools.moveCounter = 1
    GuildBankTools.moveTimer = GuildBankTools:ScheduleRepeatingTimer("DoMove", 0.5, moves)
    -- Move Items and reduce moves table
    if #moves == 0 and numIterations > maxIterations then
        GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
        isMoving = false
        numIterations = 0
        print("Done")
        return
    end
end

StaticPopupDialogs["GBT_CONFIRM_SORT_GBANK"] = {
    text = "Sorting the guild bank will take some time! Are you sure to continue?",
    button1 = "Accept",
    button2 = "Cancel",
    OnAccept = function()
        numIterations = 0
        GuildBankTools:SortGuildBank()

    end,
    timeout = 0,
    hideOnEscape = true,
    preferredIndex = 3
}

local function CreateGBShopButton()
    if GuildBankFrame then
        local shopButton = CreateFrame("Button", "GuildBankTools_ShopButton", GuildBankFrame)
        shopButton:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 40, -15)
        shopButton:SetWidth(60)
        shopButton:SetHeight(27)
        shopButton:SetFrameStrata("HIGH")
        shopButton:SetText("Shop")
        shopButton:SetNormalFontObject("GameFontNormalSmall")

        shopButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
        shopButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
        shopButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])

        shopButton:SetScript('OnClick', function()
            boughtItems = {}
            itemspurchased = {}
            itemtobuy = {}
            startShopping = true
            GuildBankTools.db.profile.lastQuery = GetTime() - 901
            GuildBankTools:setShoppingList()
        end)
        GuildBankTools.GBButtonShop = shopButton

        local sortButton = CreateFrame("Button", "GuildBankTools_SortButton", GuildBankFrame)
        sortButton:SetPoint("LEFT", shopButton, "RIGHT", 10, 0)
        sortButton:SetWidth(60)
        sortButton:SetHeight(27)
        sortButton:SetFrameStrata("HIGH")
        sortButton:SetText("Sort")
        sortButton:SetNormalFontObject("GameFontNormalSmall")

        sortButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
        sortButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
        sortButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])

        sortButton:SetScript('OnClick', function()
            StaticPopup_Show("GBT_CONFIRM_SORT_GBANK")
        end)

    end
end

function GuildBankTools:UpdateItemsInGB()
    local numTabs = GetNumGuildBankTabs()
    self.db.profile.gbankslots = {}
    self.db.profile.layoutEditor.num = numTabs
    for index = 1, numTabs do
        local name, icon = GetGuildBankTabInfo(index)
        self.db.profile.layoutEditor.gbankslots[index] = {
            name = name,
            icon = icon,
            index = index
        }
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
        if gbankScanned and GuildBankFrame then
            if not GuildBankTools.GBButtonShop then
                CreateGBShopButton()
            end
            GuildBankTools.GBButtonShop:Show()
        end
    end)

end

GuildBankTools:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function(self, arg1)
    if arg1 == 10 then
        GuildBankTools:UpdateItemsInGB()
        return
    elseif arg1 == 21 then
        if select(2, GetInstanceInfo()) ~= "none" then
            return
        end
        if GuildBankTools.db.profile.lastQuery then
            local diff = GetTime() - GuildBankTools.db.profile.lastQuery
            if diff > 900 then
                StaticPopup_Show("GBT_ASK_AH_SCAN")
            else
                diff = 900 - diff
                local minutes = math.floor(diff / 60)
                local seconds = Round(diff % 60)
                print("Next Auction Scan can be done in " .. minutes .. " minutes and " .. seconds .. " seconds")
            end

        end
    else
        return
    end
end)

GuildBankTools:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function(self, arg1)
    if arg1 ~= 10 then return end
    GuildBankTools.moveCounter = 1
    GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
    isMoving = false
    gbankScanned = false
    GuildBankTools.GBButtonShop:Hide()
end)

StaticPopupDialogs["GBT_ASK_AH_SCAN"] = {
    text = "Do you want to scan the auction house prices?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        C_AuctionHouse.ReplicateItems()
        initialQuery = true
        print("Scanning auctions...")
    end,
    timeout = 5,
    hideOnEscape = true,
    preferredIndex = 3
}



GuildBankTools:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE", function()
    print("Auction House scan complete")
    if initialQuery then
        ScanAuctions()
        initialQuery = false
    end
end)

GuildBankTools:RegisterEvent('AUCTION_HOUSE_THROTTLED_SYSTEM_READY', function()
    if AuctionHouseFrame.CommoditiesBuyFrame:GetItemID() and AuctionHouseFrame.CommoditiesBuyFrame:GetItemID() ==
        itemtobuy.itemID then
        C_Timer.After(0.2, function()
            AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay:SetQuantitySelected(itemtobuy.count)
        end)
    end
end)

GuildBankTools:RegisterEvent('COMMODITY_PURCHASE_SUCCEEDED', function()
    local boughtItemId = AuctionHouseFrame.CommoditiesBuyFrame:GetItemID()
    local boughtItemCount = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay:GetQuantitySelected()
    -- is bought item on shopping list
    if boughtItemId then
        if shoppinglist[boughtItemId] and itemtobuy == {} then
            itemtobuy = {
                itemId = boughtItemId,
                count = boughtItemCount
            }
        end
    end
    if itemtobuy.itemID then
        itemspurchased[itemtobuy.itemID] = {
            count = itemtobuy.count,
            price = itemprice
        }
        itemtobuy = {}
        GuildBankTools:setShoppingList()
    end
end)

GuildBankTools:RegisterEvent('COMMODITY_PRICE_UPDATED', function(event, peritem, total)
    itemprice = total
end)

GuildBankTools:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", function()
    if not isMoving then
        GuildBankTools:UpdateItemsInGB()
        GuildBankTools:setShoppingList()
    else
        return
    end
end)

GuildBankTools:RegisterEvent("BAG_UPDATE_DELAYED", function()
    GuildBankTools:setShoppingList()
end)

function GuildBankTools:UpdateMinimapButton()
    if (self.db.profile.minimap.hide) then
        LDBIcon:Hide("GuildBankTools")
    else
        LDBIcon:Show("GuildBankTools")
    end
end

function GuildBankTools:ToggleMinimapButton()
    if (self.db.profile.minimap.hide) then
        self.db.profile.minimap.hide = false
    else
        self.db.profile.minimap.hide = true
    end
    GuildBankTools:UpdateMinimapButton()
end

SLASH_GBT1 = "/gbt"
SlashCmdList["GBT"] = function(msg)
    if string.match(msg, "minimap") then
        GuildBankTools:ToggleMinimapButton()
    elseif string.match(msg, "scanah") then
        GuildBankTools.db.profile.lastQuery = GetTime() - 901
    else
        GuildBankTools:ToggleOptions()
    end
end
