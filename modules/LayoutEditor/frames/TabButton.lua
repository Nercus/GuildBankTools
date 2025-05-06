GuildBankToolsLayoutEditorTabMixin = {}


function GuildBankToolsLayoutEditorTabMixin:SetActive()
    self.isActive = true
    self.active:Show()
end

function GuildBankToolsLayoutEditorTabMixin:SetInactive()
    self.isActive = false
    self.active:Hide()
end
