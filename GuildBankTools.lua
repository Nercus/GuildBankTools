---@class GuildBankTools : NercUtilsAddon
local GuildBankTools = LibStub("NercUtils"):GetAddon(...)

local version = C_AddOns.GetAddOnMetadata(GuildBankTools.name, "Version")
local numericVersion = tonumber((version:gsub("%.", ""))) or 0
---version number in the format of 100 for 1.0.0 or 302 for 3.0.2
GuildBankTools.version = numericVersion
GuildBankTools.nameVersionString = GuildBankTools.name .. " v" .. version
