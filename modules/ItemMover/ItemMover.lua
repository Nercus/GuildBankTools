---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class ItemMover
local ItemMover = GuildBankLayouts:GetModule("ItemMover")

local GUILD_BANK_TAB_SLOTS = 98

-- TODO: take withdrawal limit into account

---@type table<number, {name: string, icon: string, isViewable: boolean, canDeposit: boolean, numWithdrawals: number, remainingWithdrawals: number, filtered: boolean}>
local tabInfos = {}
local tabsQueried = false
local activeLayout = {}
local freeSpace = {}

local function getFreeSpaceSlot()
    if not freeSpace then
        return
    end
    if #freeSpace > 0 then
        return table.remove(freeSpace, 1), "bag"
    end
end



local function GetItemFromBag()
end

local function GetItemFromBankTab(tabIndex)
end

local function GenerateMoves(startLayout, targetLayout)
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

local function GetCurrentLayout()
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
                    currentLayout[tab][slot] = {
                        id = C_Item.GetItemIDForItemInfo(link),
                        count = select(2, GetGuildBankItemInfo(tab, slot))
                    }
                end
            end
        end
    end
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
    if tabsQueried then return end
    for i = 1, GetNumGuildBankTabs() do
        QueryGuildBankTab(i)
    end
end

---@param layout Layout
function ItemMover:ApplyLayout(layout)
    if not tabsQueried then return end
    activeLayout = layout
    freeSpace = {}
    local currentLayout = GetCurrentLayout()
    GuildBankLayouts:Debug(currentLayout)
    GuildBankLayouts:Debug(activeLayout)
end

local numTabsQueried = 0
GuildBankLayouts:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", function()
    if numTabsQueried == 0 then
        QueryAllTabs()
    end
    numTabsQueried = numTabsQueried + 1
    if numTabsQueried >= GetNumGuildBankTabs() then
        UpdateTabsInfo()
        tabsQueried = true
    end
end)
