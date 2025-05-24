---@class GuildBankLayouts : NercUtilsAddon
local GuildBankLayouts = LibStub("NercUtils"):GetAddon(...)

---@class LayoutEditor
local LayoutEditor = GuildBankLayouts:GetModule("LayoutEditor")

---@class GuildBankLayoutsItemButtonMixin : Button
---@field count FontString
---@field tier Texture
---@field icon Texture
---@field slot number
GuildBankLayoutsItemButtonMixin = {}


function GuildBankLayoutsItemButtonMixin:SetTier(tier)
    if not tier then
        self.tier:Hide()
        return
    end
    self.tier:SetAtlas("Professions-Icon-Quality-Tier" .. tier)
    self.tier:Show()
end

function GuildBankLayoutsItemButtonMixin:CloneItem()
    if not self.item then return end
    LayoutEditor.cloneCount = self.itemCount or 1
    C_Item.PickupItem(self.item)
end

function GuildBankLayoutsItemButtonMixin:SetCount(count)
    if not self.item then return end
    local maxCount = C_Item.GetItemMaxStackSizeByID(self.item)
    if count > maxCount then
        count = maxCount
    end
    self.itemCount = count
    if count > 1 then
        self.count:SetText(count)
        self.count:Show()
    else
        self.count:Hide()
    end
end

function GuildBankLayoutsItemButtonMixin:IncrementCount()
    local increment = IsShiftKeyDown() and 10 or 1
    if self.itemCount then
        self:SetCount(self.itemCount + increment)
    else
        self:SetCount(1)
    end
end

function GuildBankLayoutsItemButtonMixin:DecrementCount()
    local increment = IsShiftKeyDown() and 10 or 1
    if self.itemCount and self.itemCount > increment then
        self:SetCount(self.itemCount - increment)
    else
        self:SetCount(1)
    end
end

function GuildBankLayoutsItemButtonMixin:SetItem(itemID)
    if self.item == itemID then
        self:IncrementCount()
        return
    end
    self.item = itemID
    local item = Item:CreateFromItemID(itemID)

    item:ContinueOnItemLoad(function()
        local icon = item:GetItemIcon()
        self.icon:SetTexture(icon)
        self:SetCount(1)

        local itemLink = item:GetItemLink()
        if not itemLink then
            self:ResetItem()
            return
        end
        local tier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemLink)
        self:SetTier(tier)
    end)
end

function GuildBankLayoutsItemButtonMixin:ResetItem()
    self.item = nil
    self.itemCount = nil
    self.icon:SetTexture(nil)
    self.count:Hide()
    self.tier:Hide()
end

function GuildBankLayoutsItemButtonMixin:OnMouseWheel(delta)
    if delta > 0 then
        self:IncrementCount()
    else
        self:DecrementCount()
    end
end

function GuildBankLayoutsItemButtonMixin:ShowMenu()
    if not self.item then return end
    local _, itemLink = C_Item.GetItemInfo(self.item)
    -- TODO: add a tooltip with the item
    GuildBankLayouts:GenerateMenu(self, {
        {
            type = "title",
            label = itemLink,

        },
        {
            type = "button",
            label = "Copy [Alt + Click]",
            onClick = function()
                self:CloneItem()
            end,
        },
        {
            type = "button",
            label = "Reset [Ctrl + Click]",
            onClick = function()
                self:ResetItem()
            end,
        },
    })
end

function GuildBankLayoutsItemButtonMixin:OnClick(mouseButton)
    if mouseButton == "RightButton" then
        self:ShowMenu()
        return
    end
    if IsControlKeyDown() then
        self:ResetItem()
        return
    end
    if IsAltKeyDown() and self.item then
        self:CloneItem()
        return
    end
    local infoType, itemID = GetCursorInfo()
    if infoType == "item" then
        self:SetItem(itemID)
    end
    if LayoutEditor.cloneCount then
        self:SetCount(LayoutEditor.cloneCount)
    end
    if not IsAltKeyDown() then
        ClearCursor()
        LayoutEditor.cloneCount = nil
    end
end
