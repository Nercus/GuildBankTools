---@type string
local AddOnName = ...
---@class GuildBankTools : NercLibAddon
local GuildBankTools = LibStub("NercLib"):GetAddon(AddOnName)

---@class ItemSearch
local ItemSearch = GuildBankTools:GetModule("ItemSearch")
