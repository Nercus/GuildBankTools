---@type string
local AddOnName = ...

---@class GuildBankTools : NercLibAddon
local GuildBankTools = LibStub("NercLib"):CreateAddon(AddOnName, AddOnName .. "DB")

local version = C_AddOns.GetAddOnMetadata(AddOnName, "Version")
local numericVersion = tonumber((version:gsub("%.", ""))) or 0
---version number in the format of 100 for 1.0.0 or 302 for 3.0.2
GuildBankTools.version = numericVersion
GuildBankTools.addonName = AddOnName
GuildBankTools.nameVersionString = GuildBankTools.addonName .. " v" .. version
