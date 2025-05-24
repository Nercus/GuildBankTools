---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class ItemSearch
local ItemSearch = GuildBankLayouts:GetModule("ItemSearch")




---@param searchString string
---@param max number|nil
---@return table
function ItemSearch:SearchForItem(searchString, max)
    local results = self:Filter(searchString, self.itemData, false)
    GuildBankLayouts:Debug(results)
    local itemResults = {}
    for i = 1, #results do
        local item = results[i]
        -- split line into itemid and item name
        local itemId, itemName = item.line:match("^(%d+),\"(.-)\"$")
        if itemId and itemName then
            local itemData = {
                name = itemName,
                id = itemId,
                score = item.s
            }
            table.insert(itemResults, itemData)
        end
        if max and #itemResults >= max then
            break
        end
    end
    -- sort by position
    table.sort(itemResults, function(a, b)
        return a.score > b.score
    end)
    return itemResults
end
