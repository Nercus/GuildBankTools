local GuildBankTools = LibStub("AceAddon-3.0"):NewAddon("GuildBankTools", "AceConsole-3.0", "AceEvent-3.0",
    "AceTimer-3.0")

local ItemsPerTab = 98

local LDBIcon = LibStub("LibDBIcon-1.0")
local LibAddonUtils = LibStub("LibAddonUtils-1.0")

local boughtItems = {}
local queriedTabs = {}
local gbankScanned = false
local GBankItems = {}
local shoppinglist = {}
local itemtobuy = {}
local itemprice = 0
local itemspurchased = {}
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
        desiredItems = false
    }
}

-- TFDtUnmiqyy4tuLmmZWpxIUQR9Pi3F1yZlPwXmQXvrkTQErZSa7hOaFqYCy(J535J3F76FXwrAfTvSwj1k5wP0k1wjmrfNaqbKcqfWkawaTqHbHeRtX1Xry(Y1pWpIFSpoXpIFuh)(r6Vi9xK(lYWpIVmn(9f6pPpXq)j8)JGVGVGVGVGVY4xXtXt7Z04P4P4P4P4P4z4z4z4z4z9Lo8m8m8m8m8s4LWlHxcVeEP(Eb8szM3sXfI(0wc(e8z4ZWNHpdFwhYKP3Y9TEm6ZWNHVaFb(c8f4lm6l4vWR03lJxbVkEv8Q4vXRIxfVkEv8QnVL9FBdybtdltG32C(6cBT6rdxHAqwwY(XPRvaDy8AZdSn)945TXdX)bbWw94jUw9pFetEnxFnoshYEnu8AO6D6WKxd(X0w18EXhoME3lkENG9vU9(geVguVgEE3KoUduVPf1BXu9wmvVfZN4PdJ7aZB3sYBTBZbkopW(tyCEqV5PK380MdLg)a)FoLs)D8LSp69(9duE0R5B1V)lnZ2brSLL0BNbC8S)oO46S9XVvFhKSM3oEqEhKUcD8793bzRzQZViGteZoJyN)U0Z0aPH0zA4mnCMgAPHlZZF(

-- Tp9YTrmiuyy0kksHxxGMWRYAxft)RKio0f3fZ8V7iBdFVL3FEF83Zx)9REM2z6NzCM4mZZSoZ(mLVTCkGkKkOkSkWk0k4k8Q8Q3NlEvEvEvEvEvEvEvEnEnET7lkVgVgVgVgVgVgVoVoVoV(9lhVoVoVoVoVoVbVbVbVbVX9OG3G3G3G3GxWl4f8cEbV4E2Yl4f8cEtEtEtEtEtEtEZ7LfEtEtElElElElElElElER7TpElEBEBEBEBEBEBEBEBE7J3N)lGSgYAiRHtn0YAiRHSgud9SgYAiRb1WiRHSgYAqneznK1qwdNA4Z77V

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

local function printProgressBar(min, max, type)
    local length = 20    -- length of the bar
    local barChar = "||" -- character to use for the bar
    local percent = math.floor((min / max) * length)
    local bar = ""
    for i = 1, length do
        if i <= percent then
            bar = bar .. "\124cFF00FF00" .. barChar .. "\124r"
        else
            bar = bar .. "\124cFF000000" .. barChar .. "\124r"
        end
    end
    -- add percent
    bar = "[" .. bar .. string.format("] %s%%", math.floor((min / max) * 100))
    bar = type .. bar
    print(bar)
end


function GBTLogWindow_Show(text)
    if not GBTLogWindow then
        local f = CreateFrame("Frame", "GBTLogWindow", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)

        f:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        f:SetBackdropBorderColor(0, 0, 0, 1) -- black
        f:SetBackdropColor(0, 0, 0, 0.5)     -- transparent black
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
        local sf = CreateFrame("ScrollFrame", "GBTLogWindowScrollFrame", GBTLogWindow, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", GBTLogWindowButton, "TOP", 0, 0)

        -- EditBox
        local eb = CreateFrame("EditBox", "GBTLogWindowEditBox", GBTLogWindowScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)

        f:Show()
    end

    if text then
        GBTLogWindowEditBox:SetText(text)
    end
    GBTLogWindow:Show()
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
    GBT_ObjectiveTrackerHeader:SetSize(300, 70)

    local GBT_ObjectiveTrackerHeaderTexture = GBT_ObjectiveTrackerHeader:CreateTexture(nil, "ARTWORK")
    GBT_ObjectiveTrackerHeaderTexture:SetSize(300, 70)
    GBT_ObjectiveTrackerHeaderTexture:SetAtlas('dragonflight-landingpage-renownbutton-locked')
    GBT_ObjectiveTrackerHeaderTexture:SetPoint("TOPLEFT", GBT_ObjectiveTrackerHeader, "TOPLEFT", 0, 0)
    GBT_ObjectiveTrackerHeaderTexture:SetPoint("BOTTOMRIGHT", GBT_ObjectiveTrackerHeader, "BOTTOMRIGHT", 0, 0)

    local GBT_ObjectiveTrackerHeaderText = GBT_ObjectiveTrackerHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    GBT_ObjectiveTrackerHeaderText:SetPoint("TOP", GBT_ObjectiveTrackerHeaderTexture, "TOP", 0, -14)
    GBT_ObjectiveTrackerHeaderText:SetText("Shoppinglist")
    GBT_ObjectiveTrackerHeaderText:SetJustifyH("LEFT")
    GBT_ObjectiveTrackerHeaderText:SetJustifyV("TOP")

    local minimizeButton = CreateFrame("button", "GBT_QuestsHeaderMinimizeButton", GBT_ObjectiveTrackerHeader,
        "BackdropTemplate")
    minimizeButton:SetSize(20, 20)
    minimizeButton:SetPoint("LEFT", GBT_ObjectiveTrackerHeaderText, "RIGHT", 66, -2)
    minimizeButton:SetScript("OnClick", function()
        startShopping = false
        GBT_Frame:Hide()
    end)
    minimizeButton:SetNormalAtlas("RedButton-Exit")
    minimizeButton:SetPushedAtlas("RedButton-exit-pressed")
    minimizeButton:SetHighlightAtlas("RedButton-Highlight")
    minimizeButton:SetFrameStrata("LOW")

    local MoverButton = CreateFrame("button", "GBT_QuestsHeaderMoverButton", GBT_ObjectiveTrackerHeader,
        "SharedButtonSmallTemplate")
    MoverButton:SetSize(70, 20)
    MoverButton:SetText("Move")
    MoverButton:SetPoint("BOTTOMRIGHT", GBT_ObjectiveTrackerHeader, "BOTTOMRIGHT", -25, 15)
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

    MoverButton:SetFrameStrata("LOW")

    local ExportButton = CreateFrame("button", "GBT_QuestsHeaderExportButton", GBT_ObjectiveTrackerHeader,
        "SharedButtonSmallTemplate")
    ExportButton:SetSize(70, 20)
    ExportButton:SetText("Log")
    ExportButton:SetPoint("BOTTOMLEFT", GBT_ObjectiveTrackerHeader, "BOTTOMLEFT", 25, 15)
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
            GBTLogWindow_Show(exportText)
        end
    end)
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
        f:SetSize(250, 20)
        f:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        f.itemID = itemID
        f.countnum = countnum
        f.maxStack = select(8, GetItemInfo(itemID))

        f:SetScript("OnClick", function(self, click)
            if click == "LeftButton" then
                if shoppinglist[f.itemID] and AuctionHouseFrame then
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
                if shoppinglist[f.itemID] and AuctionHouseFrame then
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

function GuildBankTools:updateShoppingListFrame()
    if GuildBankTools.ShoppingListEntries then
        for i, v in ipairs(GuildBankTools.ShoppingListEntries) do
            v:Hide()
            table.insert(framePool, v)
        end
    end
    GuildBankTools.ShoppingListEntries = {}
    local index = 0
    for itemID, v in pairs(shoppinglist) do
        local f = createShoppingListEntry(itemID, v.count)
        f:SetPoint("TOP", self.ShoppingListFrame, "TOP", 0, -(index * 20) - 10)
        table.insert(GuildBankTools.ShoppingListEntries, f)
        index = index + 1
        f:Show()
    end
    self.ShoppingListFrame:Show()
end

function GuildBankTools:setShoppingList()
    if not startShopping then
        return
    end
    if getTableLength(GBankItems) == 0 and not gbankScanned then
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
    for i, v in pairs(shoppinglist) do
        if v.count <= 0 then
            shoppinglist[i] = nil
        end
    end

    GuildBankTools:updateShoppingListFrame()
end

local function getFreeSpaceSlot()
    if not GuildBankTools.freeSpace then
        return
    end
    if #GuildBankTools.freeSpace > 0 then
        return table.remove(GuildBankTools.freeSpace, 1), "bag"
    end
end

function GuildBankTools:getItemFromBag(itemID)
    -- gets item from bag
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId == itemID then
                local bagSlotItemInfo = C_Container.GetContainerItemInfo(bag, slot)
                local bagSlotItemCount = bagSlotItemInfo.stackCount
                table.insert(self.freeSpace, { bag, slot }) -- after we get the item, we add the slot to the free space list
                if self.bagSlotUsedCount[bag .. ":" .. slot] then
                    bagSlotItemCount = bagSlotItemCount - self.bagSlotUsedCount[bag .. ":" .. slot]
                end
                if bagSlotItemCount > 0 then
                    return bag, slot, bagSlotItemCount, "bag"
                end
            end
        end
    end
end

function GuildBankTools:MoveIn(tabIndex)
    local layout = GuildBankTools.db.profile.layoutEditor.layout
    local tabData = layout[tabIndex]
    local moves = {}
    self.bagSlotUsedCount = {}
    self.freeSpace = {}

    -- slotData has 3 possible values:
    -- -1: free space
    -- b: blocked space
    -- { itemID, count }: item in slot

    for bag = 0, NUM_BAG_SLOTS do
        for bagSlot = 1, C_Container.GetContainerNumSlots(bag) do
            if not C_Container.GetContainerItemID(bag, bagSlot) then
                table.insert(self.freeSpace, { bag, bagSlot })
            end
        end
    end

    for slotIndex, slotData in ipairs(tabData) do
        local existingItemLink = GetGuildBankItemLink(tabIndex, slotIndex)
        local existingItemId
        if existingItemLink then
            existingItemId = GetItemInfoFromHyperlink(existingItemLink)
        end
        local _, existingtItemCount = GetGuildBankItemInfo(tabIndex, slotIndex)

        local desiredSlotItemId
        local desiredSlotItemCount
        if type(slotData) == "table" then
            desiredSlotItemId = slotData[1]
            desiredSlotItemCount = slotData[2]
        end

        if existingItemId == nil and desiredSlotItemId then -- slot is empty and should contain item
            -- move from bag
            local sourceBag, sourceSlot, sourceCount, sourceType = self:getItemFromBag(
                desiredSlotItemId)
            if sourceBag and sourceSlot and sourceCount and sourceType then
                local diff = sourceCount - desiredSlotItemCount
                local moveCount = desiredSlotItemCount
                if diff < 0 then
                    -- not enough items in bag -> move all available
                    moveCount = sourceCount
                end
                if self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] then
                    self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] =
                        self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] + moveCount
                else
                    self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] = moveCount
                end

                table.insert(moves, {
                    ["source"] = { sourceBag, sourceSlot, sourceType },
                    ["destination"] = { tabIndex, slotIndex, "bank" },
                    ["count"] = moveCount
                })
            end
        elseif existingItemId and existingItemId == desiredSlotItemId then -- slot contains this item
            local diff = existingtItemCount - desiredSlotItemCount
            if diff > 0 then                                               -- too many items in slot
                -- too many -> move to bag only move to free space if no bag space
                local freeSpaceSlot, freeSlotType = getFreeSpaceSlot()
                if freeSpaceSlot then
                    table.insert(moves, {
                        ["source"] = { tabIndex, slotIndex, "bank" },
                        ["destination"] = { freeSpaceSlot[1], freeSpaceSlot[2], freeSlotType },
                        ["count"] = diff
                    })
                end
            elseif diff < 0 then -- too few items in slot
                -- too few -> move from bag
                local sourceBag, sourceSlot, sourceCount, sourceType = self:getItemFromBag(
                    desiredSlotItemId)
                if sourceBag and sourceSlot and sourceCount and sourceType then
                    local sourceDiff = sourceCount - desiredSlotItemCount
                    local moveCount = desiredSlotItemCount
                    if sourceDiff < 0 then
                        -- not enough items in bag -> move all available
                        moveCount = sourceCount
                    end
                    if self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] then
                        self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] =
                            self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] + moveCount
                    else
                        self.bagSlotUsedCount[sourceBag .. ":" .. sourceSlot] = moveCount
                    end
                    table.insert(moves, {
                        ["source"] = { sourceBag, sourceSlot, sourceType },
                        ["destination"] = { tabIndex, slotIndex, "bank" },
                        ["count"] = moveCount
                    })
                end
            end
        elseif existingItemId and existingItemId ~= desiredSlotItemId then -- slot contains another item
            -- wrong item -> move to bag only move to free space if no bag space -> get correct item in next iteration -> also moves if slot should be empty
            local freeSpaceSlot, freeSlotType = getFreeSpaceSlot()
            if freeSpaceSlot then
                table.insert(moves, {
                    ["source"] = { tabIndex, slotIndex, "bank" },
                    ["destination"] = { freeSpaceSlot[1], freeSpaceSlot[2], freeSlotType },
                    ["count"] = existingtItemCount
                })
            end
        end
    end

    return moves
end

function GuildBankTools:getBagItemSlotForCount(itemID, count)
    -- gets item from bag
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId == itemID then
                local bagSlotItemInfo = C_Container.GetContainerItemInfo(bag, slot)
                local bagSlotItemCount = bagSlotItemInfo.stackCount or 0
                local maxStackSize = select(8, GetItemInfo(itemID)) or 1
                local bonusCount = self.bagSlotBonusCount[bag .. ":" .. slot] or
                    0 -- use bonus count to track previous moves
                if (bagSlotItemCount + count + bonusCount) <= maxStackSize then
                    self.bagSlotBonusCount[bag .. ":" .. slot] = count
                    return bag, slot, bagSlotItemCount, "bag"
                end
            end
        end
    end
end

function GuildBankTools:MoveOut(tabIndex)
    local layout = GuildBankTools.db.profile.layoutEditor.layout
    local tabData = layout[tabIndex]
    local moves = {}
    self.freeSpace = {}
    self.bagSlotBonusCount = {}
    -- slotData has 3 possible values:
    -- -1: free space
    -- b: blocked space
    -- { itemID, count }: item in slot

    for bag = 0, NUM_BAG_SLOTS do
        for bagSlot = 1, C_Container.GetContainerNumSlots(bag) do
            if not C_Container.GetContainerItemID(bag, bagSlot) then
                table.insert(self.freeSpace, { bag, bagSlot })
            end
        end
    end
    for slotIndex, slotData in ipairs(tabData) do
        local existingItemLink = GetGuildBankItemLink(tabIndex, slotIndex)
        local existingItemId
        if existingItemLink then
            existingItemId = GetItemInfoFromHyperlink(existingItemLink)
        end
        local _, existingtItemCount = GetGuildBankItemInfo(tabIndex, slotIndex)
        -- move to bag
        if existingItemId then
            -- check if item is already in bag getItemFromBag
            local sourceBag, sourceSlot, sourceCount, sourceType = self:getBagItemSlotForCount(existingItemId,
                existingtItemCount)
            if sourceBag and sourceSlot and sourceCount and sourceType then
                local maxStackSize = select(8, GetItemInfo(existingItemId)) -- max stack size
                local bagSlotSpace = maxStackSize - sourceCount             -- number of avaiable stacks of that item
                local diff = bagSlotSpace -
                    existingtItemCount                                      -- number of stacks that need to be moved -> negative if too many items want to be moved
                local moveCount = existingtItemCount                        -- number of items to move
                if diff < 0 then                                            -- not enough space in bag -> move all available stacks
                    moveCount = bagSlotSpace
                end
                -- move to bag
                table.insert(moves, {
                    ["source"] = { tabIndex, slotIndex, "bank" },
                    ["destination"] = { sourceBag, sourceSlot, sourceType },
                    ["count"] = moveCount
                })
            else
                local freeSpaceSlot, freeSlotType = getFreeSpaceSlot()
                if freeSpaceSlot then
                    table.insert(moves, {
                        ["source"] = { tabIndex, slotIndex, "bank" },
                        ["destination"] = { freeSpaceSlot[1], freeSpaceSlot[2], freeSlotType },
                        ["count"] = existingtItemCount
                    })
                end
            end
        end
    end
    return moves
end

local isMoving = false

function GuildBankTools:DoMove(moves, mode)
    local move = moves[GuildBankTools.moveCounter]
    if move then
        local source = move["source"]
        local target = move["destination"]
        local count = move["count"]
        local from = source[3]
        local to = target[3]

        if not source[1] or not source[2] or not target[1] or not target[2] or not count or not from or not to or
            not GuildBankTools.moveCounter then
            GuildBankTools:Print("Error: Missing move data", source[1], source[2], target[1], target[2], count, from,
                to, GuildBankTools.moveCounter)
            return
        end
        -- print(string.format("Moving %d from %s (%s, %s) to %s (%s, %s) - Move %s from %s", count, from, source[1],
        --     source[2], to, target[1], target[2], GuildBankTools.moveCounter, #moves))
        printProgressBar(GuildBankTools.moveCounter, #moves, mode == "in" and "Moving in" or "Moving out")


        ClearCursor() -- Clear Cursor before moving item
        if from == "bank" then
            SplitGuildBankItem(source[1], source[2], count)
            if to == "bag" then
                C_Container.PickupContainerItem(target[1], target[2])
            elseif to == "bank" then
                PickupGuildBankItem(target[1], target[2])
            else
                print("ERROR: Could not move item from bank")
            end
        elseif from == "bag" then
            C_Container.SplitContainerItem(source[1], source[2], count)
            if to == "bank" then
                PickupGuildBankItem(target[1], target[2])
                -- open that tab
            else
                print("ERROR: Could not move item from bag")
            end
        end

        if self.moveCounter == #moves then
            isMoving = false
            self:SortGuildBank()
            return
        end
        self.moveCounter = self.moveCounter + 1
    end
end

local maxIterations = 10
local numIterations = 0

function GuildBankTools:SortGuildBank(mode)
    if InCombatLockdown() then
        return
    end
    GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
    -- Set Items Based on layout
    local moves = {}
    local tabIndex = GetCurrentGuildBankTab()
    if mode == "in" then
        moves = GuildBankTools:MoveIn(tabIndex)
    elseif mode == "out" then
        moves = GuildBankTools:MoveOut(tabIndex)
    end
    numIterations = numIterations + 1
    isMoving = true
    GuildBankTools.moveCounter = 1
    GuildBankTools.moveTimer = GuildBankTools:ScheduleRepeatingTimer("DoMove", 0.5, moves, mode)
    -- Move Items and reduce moves table
    if #moves == 0 and numIterations > maxIterations then
        GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
        isMoving = false
        numIterations = 0
        return
    end
end

StaticPopupDialogs["GBT_CONFIRM_MOVE_OUT"] = {
    text = "GuildBankTools will try to move all items from the open gbank tab to your bags! Are you sure to continue?",
    button1 = "Accept",
    button2 = "Cancel",
    OnAccept = function()
        numIterations = 0
        GuildBankTools:SortGuildBank("out")
    end,
    timeout = 0,
    hideOnEscape = true,
    preferredIndex = 3
}


StaticPopupDialogs["GBT_CONFIRM_MOVE_IN"] = {
    text =
    "GuildBankTools will try to sort all items from your bag to the appropriate slot in the current open gbank tab! Are you sure to continue?",
    button1 = "Accept",
    button2 = "Cancel",
    OnAccept = function()
        numIterations = 0
        GuildBankTools:SortGuildBank("in")
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

        shopButton:SetNormalAtlas("groupfinder-button-cover")
        shopButton:SetPushedAtlas("groupfinder-button-cover-down")
        shopButton:SetHighlightAtlas("groupfinder-button-highlight")

        shopButton:SetScript('OnClick', function()
            boughtItems = {}
            itemspurchased = {}
            itemtobuy = {}
            startShopping = true
            GuildBankTools.db.profile.lastQuery = GetTime() - 901
            GuildBankTools:setShoppingList()
        end)
        GuildBankTools.GBButtonShop = shopButton

        local moveOutButton = CreateFrame("Button", "GuildBankTools_moveOutButton", GuildBankFrame)
        moveOutButton:SetPoint("LEFT", shopButton, "RIGHT", 30, 0)
        moveOutButton:SetWidth(60)
        moveOutButton:SetHeight(27)
        moveOutButton:SetFrameStrata("HIGH")
        moveOutButton:SetText("Move Out")
        moveOutButton:SetNormalFontObject("GameFontNormalSmall")


        moveOutButton:SetNormalAtlas("groupfinder-button-cover")
        moveOutButton:SetPushedAtlas("groupfinder-button-cover-down")
        moveOutButton:SetHighlightAtlas("groupfinder-button-highlight")

        moveOutButton:SetScript('OnClick', function()
            StaticPopup_Show("GBT_CONFIRM_MOVE_OUT")
        end)

        local moveInButton = CreateFrame("Button", "GuildBankTools_moveInButton", GuildBankFrame)
        moveInButton:SetPoint("LEFT", moveOutButton, "RIGHT", 10, 0)
        moveInButton:SetWidth(60)
        moveInButton:SetHeight(27)
        moveInButton:SetFrameStrata("HIGH")
        moveInButton:SetText("Move In")
        moveInButton:SetNormalFontObject("GameFontNormalSmall")


        moveInButton:SetNormalAtlas("groupfinder-button-cover")
        moveInButton:SetPushedAtlas("groupfinder-button-cover-down")
        moveInButton:SetHighlightAtlas("groupfinder-button-highlight")

        moveInButton:SetScript('OnClick', function()
            StaticPopup_Show("GBT_CONFIRM_MOVE_IN")
        end)
    end
end

local lastUpdate
function GuildBankTools:UpdateItemsInGB()
    if not lastUpdate or lastUpdate < GetTime() - 1 then
        lastUpdate = GetTime()

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
end

GuildBankTools:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function(self, arg1)
    if arg1 == 10 then
        GuildBankTools:UpdateItemsInGB()
        return
    else
        return
    end
end)

GuildBankTools:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function(self, arg1)
    if arg1 ~= 10 then return end
    GuildBankTools.moveCounter = 1
    if GuildBankTools:TimeLeft(GuildBankTools.moveTimer) > 0 then
        print("|cFFFF0000GuildBankTools: Stopped moving items!|r")
    end
    GuildBankTools:CancelTimer(GuildBankTools.moveTimer)
    isMoving = false
    gbankScanned = false
    GuildBankTools.GBButtonShop:Hide()
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
    else
        GuildBankTools:ToggleOptions()
    end
end
