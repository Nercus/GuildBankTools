---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class ItemSearch
local ItemSearch = GuildBankLayouts:GetModule("ItemSearch")

---@class GuildBankLayoutsItemSearchBarMixin : EditBox
---@field ClearButton Button
---@field SearchResults Frame
---@field framePool FramePool<GuildBankLayoutsItemSearchResultsButtonTemplate>
GuildBankLayoutsItemSearchBarMixin = {}


---@class GuildBankLayoutsItemSearchResultsButtonTemplate : Button
---@field text FontString


local DROPDOWN_GAP = 5
local MAX_ENTRIES = 10
local DEFAULT_ENTRY_HEIGHT = 20
local DROPDOWN_INSET = 10

function GuildBankLayoutsItemSearchBarMixin:OnHide()
    self.framePool:ReleaseAll()
end

function GuildBankLayoutsItemSearchBarMixin:PopulateDropdown()
    local dropdown = self.SearchResults
    if not self.results then
        dropdown:Hide()
        return
    end

    self.framePool:ReleaseAll()

    local numResults = #self.results
    local height = 0
    if numResults > 0 then
        for i = 1, numResults do
            local button = self.framePool:Acquire()
            button.text:SetText(self.results[i].name)
            button:SetPoint("TOPLEFT", dropdown, "TOPLEFT", DROPDOWN_INSET,
                -((i - 1) * (DEFAULT_ENTRY_HEIGHT + DROPDOWN_GAP)) - DROPDOWN_INSET)
            button:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT",
                -DROPDOWN_INSET, -((i - 1) * (DEFAULT_ENTRY_HEIGHT + DROPDOWN_GAP)) - DROPDOWN_INSET)
            button:Show()
            button.itemID = self.results[i].id
            height = height + DEFAULT_ENTRY_HEIGHT + DROPDOWN_GAP
            if i == MAX_ENTRIES then
                break
            end
        end
        dropdown:SetHeight(height + DROPDOWN_INSET * 2)
        dropdown:Show()
    else
        dropdown:Hide()
    end
end

function GuildBankLayoutsItemSearchBarMixin:UpdateClearButtonVisibility()
    if self:GetText() == "" then
        self.ClearButton:Hide()
    else
        self.ClearButton:Show()
    end
end

function GuildBankLayoutsItemSearchBarMixin:OnTextChanged()
    local text = self:GetText()
    self:UpdateClearButtonVisibility()

    if text ~= self.lastText and text:len() >= 3 then
        self.lastText = text
        GuildBankLayouts:DebounceChange(function()
            self.results = ItemSearch:SearchForItem(text)
            self:PopulateDropdown()
        end, 0.5)() --[[@as table]]
    else
        self.SearchResults:Hide()
    end
end

function GuildBankLayoutsItemSearchBarMixin:OnChar()
    self:UpdateClearButtonVisibility()
end

function GuildBankLayoutsItemSearchBarMixin:GLOBAL_MOUSE_DOWN()
    if (self:IsMouseOver() or self.ClearButton:IsMouseOver()) then
        return
    end
    self:SetText("")
    self.ClearButton:Hide()
    self:ClearFocus()
end

function GuildBankLayoutsItemSearchBarMixin:OnEvent(event)
    if event == "GLOBAL_MOUSE_DOWN" then
        self:GLOBAL_MOUSE_DOWN()
    end
end

function GuildBankLayoutsItemSearchBarMixin:OnLoad()
    self.framePool = CreateFramePool("BUTTON", self.SearchResults, "GuildBankLayoutsItemSearchResultsButtonTemplate")
end
