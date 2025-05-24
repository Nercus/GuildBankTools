---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

local version = C_AddOns.GetAddOnMetadata(GuildBankLayouts.name, "Version")
local numericVersion = tonumber((version:gsub("%.", ""))) or 0
---version number in the format of 100 for 1.0.0 or 302 for 3.0.2
GuildBankLayouts.version = numericVersion
GuildBankLayouts.nameVersionString = GuildBankLayouts.name .. " v" .. version
