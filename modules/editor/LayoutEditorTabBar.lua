---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class GuildBankLayoutsLayoutEditorTabBarMixin : Frame
---@field framePool FramePool<GuildBankLayoutsLayoutEditorTabMixin>
GuildBankLayoutsLayoutEditorTabBarMixin = {}

---@class LayoutEditor
---@field activeTab number
local LayoutEditor = GuildBankLayouts:GetModule("LayoutEditor")

local MAX_TABS = 8

function GuildBankLayoutsLayoutEditorTabBarMixin:PersistTabs()
    local activeLayout = LayoutEditor.activeLayout;
    if not activeLayout then
        return;
    end
    local tabAmount = self.dataProvider:GetSize();
    if tabAmount > MAX_TABS then
        tabAmount = MAX_TABS;
    end
    for i = 1, MAX_TABS do
        if i > tabAmount then
            activeLayout.bankLayout[i] = nil;
        else
            if activeLayout.bankLayout[i] == nil then
                activeLayout.bankLayout[i] = {};
            end
        end
    end
    GuildBankLayouts:SetVar("layouts", activeLayout.id, activeLayout)
    LayoutEditor.frame:UpdateStrategyDropdown()
end

function GuildBankLayoutsLayoutEditorTabBarMixin:UpdateAddButton()
    if self.dataProvider:GetSize() >= MAX_TABS then
        self.addButton:Hide();
    else
        self.addButton:Show();
    end

    ---@type GuildBankLayoutsLayoutEditorTabMixin
    local lastTab = self.dataProvider:Find(self.dataProvider:GetSize())
    if lastTab then
        self.addButton:SetPoint("LEFT", lastTab, "RIGHT", 0, 0);
    else
        self.addButton:SetPoint("LEFT", self, "LEFT", 0, 0);
    end
end

function GuildBankLayoutsLayoutEditorTabBarMixin:DeleteTab(button)
    self.dataProvider:RemoveIndex(button.index)
    self.framePool:Release(button);
    self:UpdateTabsPositions();
    self:PersistTabs();
    -- set the first tab as active if it exists
    if self.dataProvider:GetSize() > 0 then
        ---@type GuildBankLayoutsLayoutEditorTabMixin
        local firstTab = self.dataProvider:Find(1)
        if firstTab then
            self:SetActiveTab(firstTab);
        end
    else
        ---@type GuildBankLayoutsLayoutEditorRightContainer
        local parent = self:GetParent();
        parent.itemButtonContainer:Hide()
    end
end

function GuildBankLayoutsLayoutEditorTabBarMixin:UpdateTabsPositions()
    ---@type GuildBankLayoutsLayoutEditorTabMixin[]
    local tabs = self.dataProvider:GetCollection()
    ---@type GuildBankLayoutsLayoutEditorTabMixin | nil
    local lastTab
    for index, tab in ipairs(tabs) do
        tab.index = index;
        tab:SetText("Tab " .. index);
        if lastTab then
            tab:SetPoint("LEFT", lastTab, "RIGHT", 0, 0);
        else
            tab:SetPoint("LEFT", self, "LEFT", 0, 0);
        end
        if self.dataProvider:GetSize() > 4 then
            local totalWidth = self:GetWidth();
            local buttonWidth = (totalWidth - (self.dataProvider:GetSize() < MAX_TABS and 80 or 0)) /
                self.dataProvider:GetSize(); -- 80 for the add button
            tab:SetWidth(buttonWidth);
        end
        lastTab = tab;
        lastTab.deleteButton:Hide()
    end
    -- if only one tab is left, don't show the delete button
    if lastTab and self.dataProvider:GetSize() > 1 then
        lastTab.deleteButton:Show()
    end
    self:UpdateAddButton();
end

---@param setActive boolean?
function GuildBankLayoutsLayoutEditorTabBarMixin:AddTab(setActive)
    if self.dataProvider:GetSize() >= MAX_TABS then
        return;
    end
    local button = self.framePool:Acquire();


    button:SetSize(150, 25);
    button:Show()

    self.dataProvider:Insert(button);
    button.index = self.dataProvider:GetSize()

    if setActive then
        self:SetActiveTab(button);
    end

    button.deleteButton:SetScript("OnClick", function()
        self:DeleteTab(button);
    end)

    button:SetScript("OnClick", function()
        self:SetActiveTab(button);
    end)

    self:UpdateTabsPositions()
end

function GuildBankLayoutsLayoutEditorTabBarMixin:OnLoad()
    self.dataProvider = CreateDataProvider()
    self.framePool = CreateFramePool("Button", self, "GuildBankLayoutsLayoutEditorTabTemplate")

    self.addButton = CreateFrame("Button", nil, self, "GuildBankLayoutsLayoutEditorTabTemplate");
    self.addButton:SetText("+ Add Tab")
    self.addButton:SetPoint("LEFT", self, "LEFT", 0, 0);
    self.addButton:SetSize(80, 25);
    self.addButton:Show()

    self.addButton:SetScript("OnClick", function()
        self:AddTab(true);
        self:PersistTabs();
    end)
    self:UpdateAddButton()
end

---@param tab GuildBankLayoutsLayoutEditorTabMixin
function GuildBankLayoutsLayoutEditorTabBarMixin:SetActiveTab(tab)
    if self.activeTab then
        self.activeTab:SetInactive();
    end
    tab:SetActive();
    self.activeTab = tab;
    LayoutEditor.activeTab = tab.index;
    ---@type GuildBankLayoutsLayoutEditorRightContainer
    local parent = self:GetParent();
    parent.itemButtonContainer:UpdateButtons();
end

function GuildBankLayoutsLayoutEditorTabBarMixin:Update()
    local activeLayout = LayoutEditor.activeLayout;
    if not activeLayout then
        return;
    end
    if not activeLayout.bankLayout then
        activeLayout.bankLayout = {};
    end
    local layout = activeLayout.bankLayout
    if not layout then
        return;
    end


    self.dataProvider:Flush()
    self.framePool:ReleaseAll();

    if #layout == 0 then
        self:AddTab(true)
        return
    end

    for _ = 1, #layout do
        self:AddTab()
    end
    ---@type GuildBankLayoutsLayoutEditorTabMixin
    local firstTab = self.dataProvider:Find(1)
    if firstTab then
        self:SetActiveTab(firstTab);
    end
    ---@type GuildBankLayoutsLayoutEditorRightContainer
    local parent = self:GetParent();
    parent.itemButtonContainer:UpdateButtons()
end
