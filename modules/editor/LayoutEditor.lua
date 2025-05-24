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

---@class GuildBankLayoutsLayoutEditorLeftContainer : Frame
---@field scrollBox ScrollBoxBaseTemplate
---@field scrollBar ScrollBarBaseTemplate
---@field searchBox EditBox


---@class GuildBankLayoutsLayoutEditorRightContainer : Frame
---@field layoutTitle EditBox
---@field itemSearchBox EditBox
---@field tabContainer Frame
---@field infoText FontString
---@field itemButtonContainer Frame

---@class GuildBankLayoutsLayoutEditorMixin : PortraitFrameMixin,Frame
---@field leftContainer GuildBankLayoutsLayoutEditorLeftContainer
---@field rightContainer GuildBankLayoutsLayoutEditorRightContainer
---@field TitleContainer Frame
---@field dataProvider DataProviderMixin
GuildBankLayoutsLayoutEditorMixin = {}




function GuildBankLayoutsLayoutEditorMixin:InitScrollBox()
    local view = CreateScrollBoxListLinearView();

    self.dataProvider = CreateDataProvider();
    view:SetDataProvider(self.dataProvider)

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

function GuildBankLayoutsLayoutEditorMixin:CreateItemButtons()
    local firstColButton = nil
    for col = 1, 14 do
        local lastRowButton = nil
        for row = 1, 7 do
            local slot = row + (col - 1) * 7
            local itemButton = CreateFrame("Button", nil, self.rightContainer.itemButtonContainer,
                "GuildBankLayoutsItemButtonTemplate");
            if not lastRowButton then
                if firstColButton then
                    itemButton:SetPoint("TOPLEFT", firstColButton, "TOPRIGHT", col % 2 == 0 and 7 or 12, 0);
                    firstColButton = nil
                else
                    itemButton:SetPoint("TOPLEFT", self.rightContainer.itemButtonContainer, "TOPLEFT", 0, 0);
                end
            else
                itemButton:SetPoint("TOPLEFT", lastRowButton, "BOTTOMLEFT", 0, -7);
            end
            if not firstColButton then
                firstColButton = itemButton;
            end
            lastRowButton = itemButton;
            itemButton.slow = slot
        end
    end
end

function GuildBankLayoutsLayoutEditorMixin:OnLoad()
    self:SetTitle(GuildBankLayouts.name .. " - Layout Editor");
    self:RegisterForDrag("LeftButton")
    self:SetPortraitTextureRaw("Interface\\AddOns\\GuildBankLayouts\\assets\\icon.blp");
    table.insert(UISpecialFrames, self:GetName());
    self:InitScrollBox();
    LayoutEditor.frame = self
    self:CreateItemButtons()
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
    self.dataProvider:Insert({
        name = "New Layout",
        id = newID
    });

    -- set created button as active
    ---@type GuildBankLayoutsLayoutEditorTabMixin
    local layoutButton = self.leftContainer.scrollBox:FindFrameByPredicate(function(frame)
        return frame.layoutInfo and frame.layoutInfo.id == newID
    end)
    if layoutButton then
        self:SetActiveLayout(layoutButton);
    end
end

function GuildBankLayoutsLayoutEditorMixin:ShowRightContainerChildren()
    self.rightContainer.layoutTitle:Show()
    self.rightContainer.itemSearchBox:Show()
    self.rightContainer.tabContainer:Show()
    self.rightContainer.itemButtonContainer:Show()
    self.rightContainer.infoText:Hide()
end

---@param layoutButton GuildBankLayoutsLayoutEditorTabMixin
function GuildBankLayoutsLayoutEditorMixin:SetActiveLayout(layoutButton)
    self:ShowRightContainerChildren()
    if (self.activeLayout) then
        self.activeLayout:SetInactive();
    end
    self.activeLayout = layoutButton;
    layoutButton:SetActive();
    self.rightContainer.layoutTitle:SetText(layoutButton.layoutInfo.name == "New Layout" and
        "Click here to set layout name" or layoutButton.layoutInfo.name);
end

function LayoutEditor:Toggle()
    if (self.frame:IsShown()) then
        self.frame:Close()
    else
        self.frame:Open()
    end
end

GuildBankLayouts:SetDefaultAction(function()
    LayoutEditor:Toggle()
end)


C_Timer.After(1, function()
    LayoutEditor:Toggle()
end)
