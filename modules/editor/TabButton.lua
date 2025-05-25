---@class GuildBankLayoutsLayoutEditorTabMixin : Button
---@field active Texture
---@field layoutInfo Layout
---@field deleteButton Button
---@field index number
GuildBankLayoutsLayoutEditorTabMixin = {}


function GuildBankLayoutsLayoutEditorTabMixin:SetActive()
    self.isActive = true
    self.active:Show()
end

function GuildBankLayoutsLayoutEditorTabMixin:SetInactive()
    self.isActive = false
    self.active:Hide()
end
