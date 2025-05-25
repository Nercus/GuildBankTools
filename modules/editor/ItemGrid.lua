---@class GuildBankLayoutsItemGridMixin : Frame
---@field buttons GuildBankLayoutsItemButtonMixin[]
GuildBankLayoutsItemGridMixin = {}


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
    for _, button in ipairs(self.buttons) do
        button:Update();
    end
end

function GuildBankLayoutsItemGridMixin:OnLoad()
    self.buttons = {}
    self:CreateItemButtons()
end
