---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

GuildBankLayouts:SetSlashTrigger("/gbt", 1)
GuildBankLayouts:EnableHelpCommand()


-- TODO: layout mechanism
-- TODO: set tab as ingore on layout
-- TODO: button to create auctionhouse shopping list based on amount of missing items (https://github.com/Auctionator/Auctionator/blob/090577dd0c4965d601a471bc6b3bc56b335095e3/Source/API/v1/ShoppingLists.lua#L77)
