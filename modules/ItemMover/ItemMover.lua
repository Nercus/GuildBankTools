---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class ItemMover
local ItemMover = GuildBankLayouts:GetModule("ItemMover")
ItemMover.tabsQueried = false

local GUILD_BANK_TAB_SLOTS = 98

-- TODO: take withdrawal limit into account

---@type table<number, {name: string, icon: string, isViewable: boolean, canDeposit: boolean, numWithdrawals: number, remainingWithdrawals: number, filtered: boolean}>
local tabInfos = {}
---@type table<number, {containerIndex: number, slotIndex: number, itemInfo: ContainerItemInfo}>
local bagItemInfo = {}
---@type BankLayout
local bankItemInfo = {}

---@type {containerIndex: number, slotIndex: number }[]
local bagFreeSpaceInfo = {}

---@type {containerIndex: number, slotIndex: number }[]
local bankFreeSpaceInfo = {}


---@param tab number
---@param slot number
---@return {id: number, count: number}|nil
local function GetGuildBankSlotItemInfo(tab, slot)
    local link = GetGuildBankItemLink(tab, slot)
    if link then
        return {
            id = C_Item.GetItemIDForItemInfo(link),
            count = select(2, GetGuildBankItemInfo(tab, slot))
        }
    end
end

---@class ItemMoveInfo
---@field itemID number
---@field count number
---@field source {type: 'bag' | 'tab', container: number, slot: number}


---@class ItemCleanupInfo
---@field itemID number?
---@field count number?
---@field source {type: 'bag' | 'tab', container: number, slot: number}


---@param tabStartSlot {tab: number, slot: number}|nil
---@param item number
---@param count number
---@return ItemMoveInfo|nil
local function GetItemFromTab(tabStartSlot, item, count)
    if not tabStartSlot or not bankItemInfo then
        return
    end
    local slotStart = tabStartSlot.slot
    for tab = tabStartSlot.tab, GetNumGuildBankTabs() do
        for slot = slotStart, GUILD_BANK_TAB_SLOTS do
            local itemInfo = bankItemInfo[tab] and bankItemInfo[tab][slot]
            -- item is found
            if itemInfo and itemInfo.id == item then
                if itemInfo.count > count then
                    -- if more items are in the tab than request count, return the item and subtract the count from the tab item
                    itemInfo.count = itemInfo.count - count
                else
                    -- if the count is equal or less than the stack count, remove the item from the tab
                    bankItemInfo[tab][slot] = nil
                end
                return {
                    itemID = itemInfo.id,
                    count = itemInfo.count,
                    source = {
                        type = "tab",
                        container = tab,
                        slot = slot
                    }
                }
            end
        end
        slotStart = 1 -- reset slot start for the next tab
    end
end

---@param item number
---@param count number
---@return ItemMoveInfo|nil
local function GetItemFromBag(item, count)
    if not bagItemInfo then
        return
    end
    for index, bagItem in ipairs(bagItemInfo) do
        if bagItem.itemInfo.itemID == item then
            -- if more items are in the bag than request count, return the item and subtract the count from the bag item
            if bagItem.itemInfo.stackCount > count then
                bagItem.itemInfo.stackCount = bagItem.itemInfo.stackCount - count
            else
                -- if the count is equal or less than the stack count, remove the item from the bag
                table.remove(bagItemInfo, index)
            end
            return {
                itemID = bagItem.itemInfo.itemID,
                count = bagItem.itemInfo.stackCount,
                source = {
                    type = "bag",
                    container = bagItem.containerIndex,
                    slot = bagItem.slotIndex
                }
            }
        end
    end
end

---@param item number
---@param count number
---@return ItemCleanupInfo|nil
local function GetCleanupSlotFromBag(item, count)
    -- check if there is an incomplete stack where the item could fit
    for _, bagItem in ipairs(bagItemInfo) do
        if bagItem.itemInfo.itemID == item then
            local maxStackSize = C_Item.GetItemMaxStackSizeByID(bagItem.itemInfo.itemID)
            if (maxStackSize - bagItem.itemInfo.stackCount) >= count then
                -- found an incomplete stack that can be filled
                return {
                    itemID = bagItem.itemInfo.itemID,
                    count = bagItem.itemInfo.stackCount,
                    source = {
                        type = "bag",
                        container = bagItem.containerIndex,
                        slot = bagItem.slotIndex
                    },
                }
            end
        end
    end
    -- no incomplete stack found, return a free slot
    ---@type {containerIndex: number, slotIndex: number }|nil
    local freeSlot = table.remove(bagFreeSpaceInfo)
    if freeSlot then
        return {
            source = {
                type = "bag",
                container = freeSlot.containerIndex,
                slot = freeSlot.slotIndex
            }
        }
    end
end


---@param item number
---@param count number
---@param restockTab number
---@return ItemCleanupInfo|nil
local function GetCleanupSlotFromBank(item, count, restockTab)
    if not restockTab or not bankItemInfo then
        return
    end

    for slot = 1, GUILD_BANK_TAB_SLOTS do
        local itemInfo = GetGuildBankSlotItemInfo(restockTab, slot)
        if itemInfo and itemInfo.id == item then
            local maxStackSize = C_Item.GetItemMaxStackSizeByID(itemInfo.id)
            if (maxStackSize - itemInfo.count) >= count then
                -- found an incomplete stack that can be filled
                return {
                    itemID = itemInfo.id,
                    count = itemInfo.count,
                    source = {
                        type = "tab",
                        tabIndex = restockTab,
                        slotIndex = slot
                    }
                }
            end
        end
    end
    -- no incomplete stack found, return a free slot
    ---@type {tabIndex: number, slotIndex: number }|nil
    local freeSlot = table.remove(bankFreeSpaceInfo)
    if freeSlot then
        return {
            source = {
                type = "tab",
                tabIndex = freeSlot.tabIndex,
                slotIndex = freeSlot.slotIndex
            }
        }
    end
end



---@param restockStrategy RestockStrategy
---@param item number
---@param count number
---@param restockTab number|nil
---@return ItemCleanupInfo|nil
local function GetCleanupSlot(restockStrategy, item, count, restockTab)
    -- check if there is an incomplete stack where the item could fit -> based on strategy
    -- get a free slot -> based on strategy
    if restockStrategy == "bag" then
        return GetCleanupSlotFromBag(item, count)
    elseif restockStrategy == "bag-fallback" and restockTab then
        local bagSlot = GetCleanupSlotFromBag(item, count)
        if bagSlot then
            return bagSlot
        end
        return GetCleanupSlotFromBank(item, count, restockTab)
    elseif restockStrategy == "storage" and restockTab then
        return GetCleanupSlotFromBank(item, count, restockTab)
    elseif restockStrategy == "storage-fallback" and restockTab then
        local bankSlot = GetCleanupSlotFromBank(item, count, restockTab)
        if bankSlot then
            return bankSlot
        end
        return GetCleanupSlotFromBag(item, count)
    end
end


---@param strategy RestockStrategy
---@param item number
---@param count number
---@param tabStartSlot {tab: number, slot: number}|nil
---@return ItemMoveInfo|nil
local function GetItemFromRestock(strategy, item, count, tabStartSlot)
    if strategy == "bag" then
        return GetItemFromBag(item, count)
    elseif strategy == "bag-fallback" then
        local bagItem = GetItemFromBag(item, count)
        if bagItem then
            return bagItem
        end
        if not tabStartSlot then return end
        return GetItemFromTab(tabStartSlot, item, count)
    elseif strategy == "storage" then
        if not tabStartSlot then return end
        return GetItemFromTab(tabStartSlot, item, count)
    elseif strategy == "storage-fallback" then
        if not tabStartSlot then return end
        local tabItem = GetItemFromTab(tabStartSlot, item, count)
        if tabItem then
            return tabItem
        end
        return GetItemFromBag(item, count)
    else
        GuildBankLayouts:Debug("Unknown restock strategy: " .. tostring(strategy))
    end
end

local function SelectTab(index)
    _G["GuildBankTab" .. index].Button:Click()
end

---@alias RestockStrategy
---| 'bag' Uses items and free space in the players bag
---| 'bag-fallback' Uses items and free space in the players bag and falls back to the bank
---| 'storage' Uses a defined storage tab for items and free space
---| 'storage-fallback' Uses a defined storage tab with the bag as a fallback

---@alias BankLayout table<number, table<number, {id: number, count: number}>> a layout with the tab index as the first key and a a dict that uses [slot] = itemID

---@class Layout
---@field id string
---@field name string
---@field index number
---@field restockStrategy RestockStrategy
---@field bankLayout BankLayout
---@field restockTab number|nil
function ItemMover:GetCurrentLayout(restockTab)
    ---@type BankLayout
    local currentLayout = {}
    for tab = 1, #tabInfos do
        local tabInfo = tabInfos[tab]
        if tabInfo.isViewable then
            if not currentLayout[tab] then
                currentLayout[tab] = {}
            end
            for slot = 1, GUILD_BANK_TAB_SLOTS do
                local link = GetGuildBankItemLink(tab, slot)
                if link then
                    currentLayout[tab][slot] = GetGuildBankSlotItemInfo(tab, slot)
                else
                    if tab == restockTab then
                        -- empty slots in the restock tab are tracked in bankFreeSpaceInfo
                        table.insert(bankFreeSpaceInfo, {
                            tabIndex = tab,
                            slotIndex = slot
                        })
                    end
                end
            end
        end
    end
    bankItemInfo = currentLayout
    return currentLayout
end

local function UpdateTabsInfo()
    for i = 1, GetNumGuildBankTabs() do
        local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, filtered = GetGuildBankTabInfo(i)
        tabInfos[i] = {
            name = name,
            icon = icon,
            isViewable = isViewable,
            canDeposit = canDeposit,
            numWithdrawals = numWithdrawals,
            remainingWithdrawals = remainingWithdrawals,
            filtered = filtered
        }
    end
end


local function QueryAllTabs()
    if ItemMover.tabsQueried then return end
    for i = 1, GetNumGuildBankTabs() do
        QueryGuildBankTab(i)
    end
end

local function QueryBag()
    bagItemInfo = {}
    for containerIndex = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
        local slots = C_Container.GetContainerNumSlots(containerIndex);
        if (slots > 0) then
            for slotIndex = 1, slots do
                local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)
                if itemInfo then
                    table.insert(bagItemInfo, {
                        containerIndex = containerIndex,
                        slotIndex = slotIndex,
                        itemInfo = itemInfo,
                    })
                else
                    -- empty slot in bag
                    table.insert(bagFreeSpaceInfo, {
                        containerIndex = containerIndex,
                        slotIndex = slotIndex
                    })
                end
            end
        end
    end
end


---@param targetLayout BankLayout
---@param restockStrategy RestockStrategy
---@param restockTab number|nil
---@return table<{source: ItemMoveInfo|ItemCleanupInfo|nil, target: ItemMoveInfo, id: number, count: number}> moves
local function GetMoves(targetLayout, restockStrategy, restockTab)
    local moves = {}
    -- iterate over all tabs and slots
    for tab = 1, GetNumGuildBankTabs() do
        for slot = 1, GUILD_BANK_TAB_SLOTS do
            local currentItem = GetGuildBankSlotItemInfo(tab, slot)
            local targetItem = targetLayout[tab] and targetLayout[tab][slot]
            if targetItem then
                local searchStartSlot = { tab = tab, slot = slot }
                if slot == GUILD_BANK_TAB_SLOTS then
                    -- if we are at the last slot of the tab, we need to start searching in the next tab
                    searchStartSlot.tab = tab + 1
                    searchStartSlot.slot = 1
                end


                if currentItem == nil then
                    -- bank slot is empty
                    local itemToMove = GetItemFromRestock(restockStrategy, targetItem.id, targetItem.count,
                        searchStartSlot)
                    if itemToMove then
                        -- if we found an item to move, add it to the moves list
                        table.insert(moves, {
                            source = itemToMove.source,
                            target = {
                                type = "tab",
                                tabIndex = tab,
                                slotIndex = slot
                            },
                            id = targetItem.id,
                            count = targetItem.count
                        })
                    end
                elseif currentItem.id ~= targetItem.id then
                    -- has wrong item
                    -- cleanup the slot
                    local cleanupSlot = GetCleanupSlot(restockStrategy, currentItem.id, currentItem.count, restockTab)
                    if cleanupSlot then
                        -- if we found a cleanup slot, add it to the moves list
                        table.insert(moves, {
                            source = {
                                type = "tab",
                                container = tab,
                                slot = slot
                            },
                            target = cleanupSlot,
                            id = currentItem.id,
                            count = currentItem.count
                        })
                    else
                        GuildBankLayouts:Print("Not enough cleanup slots available to apply layout")
                        break
                    end
                    local itemToMove = GetItemFromRestock(restockStrategy, targetItem.id, targetItem.count,
                        searchStartSlot)
                    if itemToMove then
                        -- if we found an item to move, add it to the moves list
                        table.insert(moves, {
                            source = itemToMove.source,
                            target = {
                                type = "tab",
                                tabIndex = tab,
                                slotIndex = slot
                            },
                            id = targetItem.id,
                            count = targetItem.count
                        })
                    end
                elseif currentItem.id == targetItem.id then
                    -- has correct item
                    if currentItem.count < targetItem.count then
                        -- correct item, but not enough
                        ---@type number
                        local countToMove = targetItem.count - currentItem.count
                        -- check with while loop to get as many items as needed
                        while countToMove > 0 do
                            local itemToMove = GetItemFromRestock(restockStrategy, targetItem.id,
                                countToMove, searchStartSlot)
                            if itemToMove then
                                -- if we found an item to move, add it to the moves list
                                table.insert(moves, {
                                    source = itemToMove.source,
                                    target = {
                                        type = "tab",
                                        tabIndex = tab,
                                        slotIndex = slot
                                    },
                                    id = targetItem.id,
                                    count = itemToMove.count
                                })
                                countToMove = countToMove - itemToMove.count
                            else
                                -- no more items to move, break the loop
                                break
                            end
                        end
                    elseif currentItem.count > targetItem.count then
                        -- correct item, but too many
                        local cleanupSlot = GetCleanupSlot(restockStrategy, currentItem.id, currentItem.count, restockTab)
                        -- FIXME: cleaning up a slot should update the tab-slots information when the move is planned and where the items are after to be able to get items from it
                        if cleanupSlot then
                            -- if we found a cleanup slot, add it to the moves list
                            table.insert(moves, {
                                source = {
                                    type = "tab",
                                    container = tab,
                                    slot = slot
                                },
                                target = cleanupSlot,
                                id = currentItem.id,
                                count = currentItem.count - targetItem.count
                            })
                        else
                            GuildBankLayouts:Print("Not enough cleanup slots available to apply layout")
                            break
                        end
                    end
                end
            else
                -- slot should be empty, but has an item
                if currentItem then
                    -- cleanup the slot
                    local cleanupSlot = GetCleanupSlot(restockStrategy, currentItem.id, currentItem.count, restockTab)
                    -- FIXME: cleaning up a slot should update the tab-slots information when the move is planned and where the items are after to be able to get items from it
                    if cleanupSlot then
                        -- if we found a cleanup slot, add it to the moves list
                        table.insert(moves, {
                            source = {
                                type = "tab",
                                container = tab,
                                slot = slot
                            },
                            target = cleanupSlot,
                            id = currentItem.id,
                            count = currentItem.count
                        })
                    else
                        GuildBankLayouts:Print("Not enough cleanup slots available to apply layout")
                        break
                    end
                end
            end
        end
    end
    return moves
end

---@param layout Layout
function ItemMover:ApplyLayout(layout)
    if not ItemMover.tabsQueried then return end
    QueryBag()
    self:GetCurrentLayout(layout.restockTab)
    local moves = GetMoves(layout.bankLayout, layout.restockStrategy, layout.restockTab)
    GuildBankLayouts:Debug(moves)

    -- print out moves in a readable format
    for _, move in ipairs(moves) do
        local source = move.source.type == "tab" and ("Tab %d Slot %d"):format(move.source.container, move.source.slot)
            or ("Bag %d Slot %d"):format(move.source.container, move.source.slot)
        local target = move.target.type == "tab" and
            ("Tab %d Slot %d"):format(move.target.tabIndex, move.target.slotIndex)
            or ("Bag %d Slot %d"):format(move.target.container, move.target.slot)


        local itemName, itemLink = C_Item.GetItemInfo(move.id)
        GuildBankLayouts:Debug(string.format("Move item %s x%d from %s to %s", itemLink, move.count, source, target))
    end
end

local numTabsQueried = 0
GuildBankLayouts:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", function()
    if numTabsQueried == 0 then
        QueryAllTabs()
    end
    numTabsQueried = numTabsQueried + 1
    if numTabsQueried >= GetNumGuildBankTabs() then
        UpdateTabsInfo()
        ItemMover.tabsQueried = true
    end
end)


GuildBankLayoutsTestButtonMixin = {}
function GuildBankLayoutsTestButtonMixin:OnClick()
    local layouts = GuildBankLayouts:GetVar("layouts")
    -- find layout with the name "Test"
    ---@diagnostic disable-next-line: no-unknown, param-type-mismatch
    for _, layout in pairs(layouts) do
        if layout.name == "Test" then
            ItemMover:ApplyLayout(layout)
            return
        end
    end
end
