---@class GuildBankLayoutsLayoutEditorTabBarMixin : Frame
---@field framePool FramePool<GuildBankLayoutsLayoutEditorTabMixin>
---@field tabs GuildBankLayoutsLayoutEditorTabMixin[]
GuildBankLayoutsLayoutEditorTabBarMixin = {}

local MAX_TABS = 8

function GuildBankLayoutsLayoutEditorTabBarMixin:AddTab()
    local numTabs = #self.tabs;


    if numTabs >= MAX_TABS then
        return;
    end
    local button = self.framePool:Acquire();

    local lastTab = self.tabs and self.tabs[numTabs];
    if lastTab then
        lastTab.deleteButton:Hide()
        button:SetPoint("LEFT", lastTab, "RIGHT", 0, 0);
    else
        button:SetPoint("LEFT", self, "LEFT", 0, 0);
    end


    button.deleteButton:Show()

    button.deleteButton:SetScript("OnClick", function()
        self.framePool:Release(button);
        for i, tab in ipairs(self.tabs) do
            if tab == button then
                table.remove(self.tabs, i);
                break;
            end
        end
        if #self.tabs < MAX_TABS then
            local lastTab = self.tabs[#self.tabs];
            if lastTab then
                self.addButton:SetPoint("LEFT", self.tabs[#self.tabs], "RIGHT", 0, 0);
                lastTab.deleteButton:Show();
            else
                self.addButton:SetPoint("LEFT", self, "LEFT", 0, 0);
            end
            self.addButton:Show();
        end
        if #self.tabs > 4 then
            local totalWidth = self:GetWidth();
            local buttonWidth = (totalWidth - (self.addButton:IsShown() and 40 or 0)) / #self.tabs; -- 40 for the add button
            for _, tab in ipairs(self.tabs) do
                tab:SetWidth(buttonWidth);
            end
        end
    end)
    button:SetSize(150, 25);
    button:SetText("Tab " .. (numTabs + 1));
    button:Show()
    table.insert(self.tabs, button);

    -- add button should always be at the end if there is less than MAX_TABS
    if #self.tabs < MAX_TABS then
        self.addButton:SetPoint("LEFT", button, "RIGHT", 0, 0);
        self.addButton:Show();
    else
        self.addButton:Hide();
    end
    if #self.tabs > 4 then
        local totalWidth = self:GetWidth();
        local buttonWidth = (totalWidth - (self.addButton:IsShown() and 40 or 0)) / #self.tabs; -- 40 for the add button
        for _, tab in ipairs(self.tabs) do
            tab:SetWidth(buttonWidth);
        end
    end

    button:SetScript("OnClick", function()
        self:SetActiveTab(button);
    end)
end

function GuildBankLayoutsLayoutEditorTabBarMixin:OnLoad()
    self.tabs = {};
    self.framePool = CreateFramePool("Button", self, "GuildBankLayoutsLayoutEditorTabTemplate")
    self.addButton = self.framePool:Acquire();
    self.addButton:SetText(" + ")
    self.addButton:SetPoint("LEFT", self, "LEFT", 0, 0);
    self.addButton:SetSize(40, 25);
    self.addButton:Show()

    self.addButton:SetScript("OnClick", function()
        self:AddTab();
    end)
end

---@param tab GuildBankLayoutsLayoutEditorTabMixin
function GuildBankLayoutsLayoutEditorTabBarMixin:SetActiveTab(tab)
    if self.activeTab then
        self.activeTab:SetInactive();
    end
    tab:SetActive();
    self.activeTab = tab;
end
