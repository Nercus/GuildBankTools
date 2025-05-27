---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

-- Note:
-- available layout restock options:
-- 1. Include bag in restock
-- 2. Set storage tab
-- 3. Use storage tab and fallback to bag
-- Ignore tab in layout

---@class LayoutEditor
---@field frame GuildBankLayoutsLayoutEditorMixin
local LayoutEditor = GuildBankLayouts:GetModule("LayoutEditor")
local ItemMover = GuildBankLayouts:GetModule("ItemMover")

---@class GuildBankLayoutsLayoutEditorLeftContainer : Frame
---@field scrollBox ScrollBoxListMixin
---@field scrollBar ScrollBarBaseTemplate
---@field searchBox EditBox


---@class GuildBankLayoutsLayoutEditorRightContainer : Frame
---@field layoutTitle EditBox
---@field itemSearchBox EditBox
---@field tabContainer GuildBankLayoutsLayoutEditorTabBarMixin
---@field infoText FontString
---@field itemButtonContainer GuildBankLayoutsItemGridMixin
---@field deleteButton Button
---@field strategyDropdown DropdownButton
---@field importButton Button

---@class GuildBankLayoutsLayoutEditorMixin : PortraitFrameMixin,Frame
---@field leftContainer GuildBankLayoutsLayoutEditorLeftContainer
---@field rightContainer GuildBankLayoutsLayoutEditorRightContainer
---@field TitleContainer Frame
---@field dataProvider DataProviderMixin
GuildBankLayoutsLayoutEditorMixin = {}



local function GetRestockTabSubmenu()
    local tabMenu = {
        {
            type = "title",
            label = "Select restock/fallback tab"
        }
    }

    local tabsNum = #LayoutEditor.activeLayout.bankLayout
    for i = 1, tabsNum do
        local tabName = "Tab " .. i
        local tabData = {
            type = "radio",
            label = tabName,
            data = i,
            isSelected = function()
                return i == LayoutEditor.activeLayout.restockTab
            end,
            setSelected = function()
                if LayoutEditor.activeLayout then
                    LayoutEditor.activeLayout.restockTab = i
                    GuildBankLayouts:SetVar("layouts", LayoutEditor.activeLayout.id, LayoutEditor.activeLayout)
                end
            end,
        }
        table.insert(tabMenu, tabData)
    end

    return tabMenu
end

function GuildBankLayoutsLayoutEditorMixin:UpdateStrategyDropdown()
    if not LayoutEditor.activeLayout then
        return
    end



    ---@type AnyMenuEntry[]
    local baseMenu = {
        {
            type = "radio",
            label = "Use bag for restock",
            data = "bag",
            isSelected = function()
                local layout = LayoutEditor.activeLayout
                return layout and layout.restockStrategy == "bag"
            end,
            setSelected = function()
                local layout = LayoutEditor.activeLayout
                if layout then
                    layout.restockStrategy = "bag"
                    GuildBankLayouts:SetVar("layouts", layout.id, layout)
                    self:UpdateStrategyDropdown()
                end
            end,
        },
        {
            type = "radio",
            label = "Use bag for restock and fallback to bank",
            data = "bag-fallback",
            isSelected = function()
                local layout = LayoutEditor.activeLayout
                return layout and layout.restockStrategy == "bag-fallback"
            end,
            setSelected = function()
                local layout = LayoutEditor.activeLayout
                if layout then
                    layout.restockStrategy = "bag-fallback"
                    GuildBankLayouts:SetVar("layouts", layout.id, layout)
                    self:UpdateStrategyDropdown()
                end
            end,
        },
        {
            type = "radio",
            label = "Use storage tab for restock",
            data = "storage",
            isSelected = function()
                local layout = LayoutEditor.activeLayout
                return layout and layout.restockStrategy == "storage"
            end,
            setSelected = function()
                local layout = LayoutEditor.activeLayout
                if layout then
                    layout.restockStrategy = "storage"
                    GuildBankLayouts:SetVar("layouts", layout.id, layout)
                    self:UpdateStrategyDropdown()
                end
            end,
        },
        {
            type = "radio",
            label = "Use storage tab for restock and fallback to bag",
            data = "storage-fallback",
            isSelected = function()
                local layout = LayoutEditor.activeLayout
                return layout and layout.restockStrategy == "storage-fallback"
            end,
            setSelected = function()
                local layout = LayoutEditor.activeLayout
                if layout then
                    layout.restockStrategy = "storage-fallback"
                    GuildBankLayouts:SetVar("layouts", layout.id, layout)
                    self:UpdateStrategyDropdown()
                end
            end,
        }

    }

    local activeStrategy = LayoutEditor.activeLayout.restockStrategy
    if activeStrategy ~= "bag" then
        table.insert(baseMenu, {
            type = "divider"
        })
        table.insert(baseMenu, {
            type = "submenu",
            entry = {
                type = "button",
                label = "Select restock tab",
            },
            entries = GetRestockTabSubmenu(),
        })
    end

    local generatorFunction = GuildBankLayouts:GetGeneratorFunction(baseMenu)

    self.rightContainer.strategyDropdown:SetupMenu(generatorFunction)
end

function GuildBankLayoutsLayoutEditorMixin:UpdateLayoutList()
    ---@type Layout[]
    local layouts = GuildBankLayouts:GetVar("layouts")
    if not layouts then
        GuildBankLayouts:SetVar("layouts", {})
        ---@type Layout[]
        layouts = GuildBankLayouts:GetVar("layouts")
    end
    self.dataProvider = CreateDataProvider();
    self.dataProvider:SetSortComparator(function(a, b)
        return a.index < b.index;
    end)
    self.leftContainer.scrollBox:SetDataProvider(self.dataProvider)
    local searchText = self.leftContainer.searchBox:GetText()
    for _, layout in pairs(layouts) do
        if layout.name:lower():find(searchText:lower(), 1, true) then
            self.dataProvider:Insert(layout);
        end
    end
end

function GuildBankLayoutsLayoutEditorMixin:InitScrollBox()
    local view = CreateScrollBoxListLinearView();
    ScrollUtil.InitScrollBoxListWithScrollBar(self.leftContainer.scrollBox, self.leftContainer.scrollBar, view);

    ---@param frame GuildBankLayoutsLayoutEditorTabMixin
    ---@param messageInfo Layout
    local function Initializer(frame, messageInfo)
        frame:SetSize(1, 40)
        frame:SetPoint("LEFT", 0, 0)
        frame:SetPoint("RIGHT", 0, 0)
        frame:SetText(messageInfo.name)
        frame.layoutInfo = messageInfo
        frame:SetScript("OnClick", function()
            self:SetActiveLayout(frame)
        end)
    end
    view:SetElementExtent(40)
    view:SetElementInitializer("GuildBankLayoutsLayoutEditorTabTemplate", Initializer)
end

function GuildBankLayoutsLayoutEditorMixin:SearchTextChanged()
    self:UpdateLayoutList()
end

function GuildBankLayoutsLayoutEditorMixin:OnLoad()
    self:SetTitle(GuildBankLayouts.name .. " - Layout Editor");
    self:RegisterForDrag("LeftButton")
    self:SetPortraitTextureRaw("Interface\\AddOns\\GuildBankLayouts\\assets\\icon.blp");
    table.insert(UISpecialFrames, self:GetName());
    self:InitScrollBox();
    self:UpdateStrategyDropdown();
    self.rightContainer.importButton:SetEnabled(false)
    self.leftContainer.searchBox:HookScript("OnTextChanged", function()
        self:UpdateLayoutList()
    end);
    LayoutEditor.frame = self

    GuildBankLayouts:RegisterEvent("PLAYER_ENTERING_WORLD", function(isLogin)
        self:UpdateLayoutList()
    end)

    GuildBankLayouts:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", function()
        self:UpdateImportButtonEnabledState()
    end)
    GuildBankLayouts:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(_, interactionType)
        if interactionType == Enum.PlayerInteractionType.GuildBanker then
            self:UpdateImportButtonEnabledState()
        end
    end)
    GuildBankLayouts:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(_, interactionType)
        if interactionType == Enum.PlayerInteractionType.GuildBanker then
            self:UpdateImportButtonEnabledState()
        end
    end)

    self.rightContainer.layoutTitle:SetScript("OnTextChanged", function(editBox)
        if not self.activeLayout then
            return
        end
        ---@type string
        local newName = editBox:GetText();
        if newName and newName ~= "" then
            self.activeLayout.layoutInfo.name = newName;
            GuildBankLayouts:SetVar("layouts", self.activeLayout.layoutInfo.id, self.activeLayout.layoutInfo);
            self.activeLayout:SetText(newName);
        end
    end)

    StaticPopupDialogs["GUILD_BANK_LAYOUTS_DELETE_LAYOUT"] = {
        text = "Are you sure you want to delete this layout?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            self:DeleteLayout()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function GuildBankLayoutsLayoutEditorMixin:OnMouseDown()
    if (not self.TitleContainer:IsMouseOver()) then
        return
    end
    self:StartMoving()
end

function GuildBankLayoutsLayoutEditorMixin:OnMouseUp()
    self:StopMovingOrSizing()
end

function GuildBankLayoutsLayoutEditorMixin:OnDragStop()
    self:StopMovingOrSizing()
end

function GuildBankLayoutsLayoutEditorMixin:Open()
    self:Show()
end

function GuildBankLayoutsLayoutEditorMixin:Close()
    self:Hide()
end

function GuildBankLayoutsLayoutEditorMixin:AddLayout()
    local newID = GuildBankLayouts:GenerateUUID('layout');
    local newLayout = {
        name = "New Layout",
        id = newID,
        index = self.dataProvider:GetSize() + 1,
        restockStrategy = "bag", -- default restock strategy
    }
    self.dataProvider:Insert(newLayout);

    -- set created button as active
    ---@type GuildBankLayoutsLayoutEditorTabMixin
    local layoutButton = self.leftContainer.scrollBox:FindFrameByPredicate(function(frame)
        return frame.layoutInfo and frame.layoutInfo.id == newID
    end)
    if layoutButton then
        self:SetActiveLayout(layoutButton);
    end

    GuildBankLayouts:SetVar("layouts", newID, newLayout)
end

function GuildBankLayoutsLayoutEditorMixin:DeleteLayout()
    if not self.activeLayout then
        return
    end

    -- remove from data provider and from saved variables
    self.dataProvider:Remove(self.activeLayout.layoutInfo);
    GuildBankLayouts:DeleteVar("layouts", self.activeLayout.layoutInfo.id);
    self:SetRightContainerChildrenVisibility(false)
end

function GuildBankLayoutsLayoutEditorMixin:SetRightContainerChildrenVisibility(show)
    if show then
        self.rightContainer.layoutTitle:Show()
        self.rightContainer.itemSearchBox:Show()
        self.rightContainer.tabContainer:Show()
        self.rightContainer.itemButtonContainer:Show()
        self.rightContainer.deleteButton:Show()
        self.rightContainer.strategyDropdown:Show()
        self.rightContainer.importButton:Show()
        self.rightContainer.infoText:Hide()
    else
        self.rightContainer.layoutTitle:Hide()
        self.rightContainer.itemSearchBox:Hide()
        self.rightContainer.tabContainer:Hide()
        self.rightContainer.itemButtonContainer:Hide()
        self.rightContainer.deleteButton:Hide()
        self.rightContainer.strategyDropdown:Hide()
        self.rightContainer.importButton:Hide()
        self.rightContainer.infoText:Show()
    end
end

---@param layoutButton GuildBankLayoutsLayoutEditorTabMixin
function GuildBankLayoutsLayoutEditorMixin:SetActiveLayout(layoutButton)
    self:SetRightContainerChildrenVisibility(true)
    if (self.activeLayout) then
        self.activeLayout:SetInactive();
    end
    self.activeLayout = layoutButton;
    LayoutEditor.activeLayout = layoutButton.layoutInfo;
    layoutButton:SetActive();
    self.rightContainer.layoutTitle:SetText(layoutButton.layoutInfo.name);
    self.rightContainer.tabContainer:Update()
    self:UpdateStrategyDropdown();
end

function LayoutEditor:Toggle()
    if (self.frame:IsShown()) then
        self.frame:Close()
    else
        self.frame:Open()
    end
end

function LayoutEditor:ImportLayoutFromBank()
    if not ItemMover.tabsQueried or not GuildBankFrame:IsVisible() then
        return
    end
    if not self.activeLayout then
        GuildBankLayouts:Print("No active layout selected. Please select a layout to import items into.")
        return
    end
    local layout = self.activeLayout
    local currentLayout = ItemMover:GetCurrentLayout()
    self.activeLayout.bankLayout = currentLayout
    GuildBankLayouts:SetVar("layouts", layout.id, layout)
    GuildBankLayouts:Print("Imported items from guild bank into layout: " .. layout.name)
end

function GuildBankLayoutsLayoutEditorMixin:ImportLayoutFromBank()
    LayoutEditor:ImportLayoutFromBank()
    self.rightContainer.itemButtonContainer:UpdateButtons()
    self.rightContainer.tabContainer:Update()
end

function GuildBankLayoutsLayoutEditorMixin:UpdateImportButtonEnabledState()
    local enabled = ItemMover.tabsQueried and GuildBankFrame:IsVisible()
    self.rightContainer.importButton:SetEnabled(enabled)
end

GuildBankLayouts:SetDefaultAction(function()
    LayoutEditor:Toggle()
end)

C_Timer.After(1, function()
    LayoutEditor:Toggle()
end)
