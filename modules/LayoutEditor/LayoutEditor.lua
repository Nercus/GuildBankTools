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


---@class GuildBankLayoutsLayoutEditorMixin : PortraitFrameMixin,Frame
---@field leftContainer GuildBankLayoutsLayoutEditorLeftContainer
---@field rightContainer Frame
---@field TitleContainer Frame
GuildBankLayoutsLayoutEditorMixin = {}


function GuildBankLayoutsLayoutEditorMixin:InitScrollBox()
    local view = CreateScrollBoxListLinearView();

    local dataProvider = CreateDataProvider();
    view:SetDataProvider(dataProvider)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.leftContainer.scrollBox, self.leftContainer.scrollBar, view);

    ---@param frame Button
    ---@param messageInfo any
    local function Initializer(frame, messageInfo)
        frame:SetSize(1, 40)
        frame:SetPoint("LEFT", 0, 0)
        frame:SetPoint("RIGHT", 0, 0)
        frame:SetText(messageInfo.text)
    end
    view:SetElementExtent(40)
    view:SetElementInitializer("GuildBankLayoutsLayoutEditorTabTemplate", Initializer)
    dataProvider:InsertTable({
        { categoryID = 1,  text = "Layout 1" },
        { categoryID = 2,  text = "Layout 2" },
        { categoryID = 3,  text = "Layout 3" },
        { categoryID = 4,  text = "Layout 4" },
        { categoryID = 5,  text = "Layout 5" },
        { categoryID = 6,  text = "Layout 6" },
        { categoryID = 7,  text = "Layout 7" },
        { categoryID = 8,  text = "Layout 8" },
        { categoryID = 9,  text = "Layout 9" },
        { categoryID = 10, text = "Layout 10" },
        { categoryID = 11, text = "Layout 11" },
        { categoryID = 12, text = "Layout 12" },
        { categoryID = 13, text = "Layout 13" },
        { categoryID = 14, text = "Layout 14" },
        { categoryID = 15, text = "Layout 15" },
        { categoryID = 16, text = "Layout 16" },
        { categoryID = 17, text = "Layout 17" },
    })
end

function GuildBankLayoutsLayoutEditorMixin:OnLoad()
    self:SetTitle(GuildBankLayouts.name .. " - Layout Editor");
    self:RegisterForDrag("LeftButton")
    self:SetPortraitTextureRaw("Interface\\AddOns\\GuildBankLayouts\\assets\\icon.blp");
    table.insert(UISpecialFrames, self:GetName());
    self:InitScrollBox();
    LayoutEditor.frame = self
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
