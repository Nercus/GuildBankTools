---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class GuildBankLayoutsItemGridMixin : Frame
---@field buttons GuildBankLayoutsItemButtonMixin[]
---@field disabledText Frame
GuildBankLayoutsItemGridMixin = {}

local LayoutEditor = GuildBankLayouts:GetModule("LayoutEditor")

function GuildBankLayoutsItemGridMixin:CreateItemButtons()
    local firstColButton = nil
    for col = 1, 14 do
        local lastRowButton = nil
        for row = 1, 7 do
            local slot = row + (col - 1) * 7
            local itemButton = CreateFrame("Button", nil, self,
                "GuildBankLayoutsItemButtonTemplate");
            if not lastRowButton then
                if firstColButton then
                    itemButton:SetPoint("TOPLEFT", firstColButton, "TOPRIGHT", col % 2 == 0 and 7 or 12, 0);
                    firstColButton = nil
                else
                    itemButton:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
                end
            else
                itemButton:SetPoint("TOPLEFT", lastRowButton, "BOTTOMLEFT", 0, -7);
            end
            if not firstColButton then
                firstColButton = itemButton;
            end
            lastRowButton = itemButton;
            itemButton.slot = slot
            table.insert(self.buttons, itemButton);
        end
    end
end

function GuildBankLayoutsItemGridMixin:UpdateButtons()
    if not self:IsShown() then
        self:Show()
    end
    if LayoutEditor.activeTab == LayoutEditor.activeLayout.restockTab then
        self.disabledText:Show()
    else
        self.disabledText:Hide()
    end
    for _, button in ipairs(self.buttons) do
        button:Update();
    end
end

function GuildBankLayoutsItemGridMixin:OnLoad()
    self.buttons = {}
    self:CreateItemButtons()
end
