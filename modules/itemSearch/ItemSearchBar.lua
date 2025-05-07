---@class GuildBankTools : NercUtilsAddon
local GuildBankTools = LibStub("NercUtils"):GetAddon(...)

---@class ItemSearch
local ItemSearch = GuildBankTools:GetModule("ItemSearch")

---@class GuildBankToolsItemSearchBarMixin : EditBox
---@field ClearButton Button
GuildBankToolsItemSearchBarMixin = {}



function GuildBankToolsItemSearchBarMixin:OnChar()
    local text = self:GetText()
    if text == "" then
        self.ClearButton:Hide()
    else
        self.ClearButton:Show()
    end
end

function GuildBankToolsItemSearchBarMixin:GLOBAL_MOUSE_DOWN()
    if (self:IsMouseOver() or self.ClearButton:IsMouseOver()) then
        return
    end
    self:SetText("")
    self.ClearButton:Hide()
    self:ClearFocus()
end

function GuildBankToolsItemSearchBarMixin:OnEvent(event)
    if event == "GLOBAL_MOUSE_DOWN" then
        self:GLOBAL_MOUSE_DOWN()
    end
end
