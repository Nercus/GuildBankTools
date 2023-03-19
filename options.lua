local GuildBankTools = LibStub("AceAddon-3.0"):GetAddon("GuildBankTools")
local LibAddonUtils = LibStub("LibAddonUtils-1.0")

local AceGUI = LibStub("AceGUI-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")


do
    local Type, Version = "ItemActionSlot", 1
    local cloneCount = 1

    local function Button_OnClick(frame, button)
        local widget = frame.obj
        if button == "LeftButton" then
            AceGUI:ClearFocus()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)

            if IsControlKeyDown() and not widget.clone then
                widget:SetCount(nil)
                widget:SetItemId(nil)
            else
                local kind, newId = GetCursorInfo()
                if kind == "item" and tonumber(newId) then
                    if widget.clone then
                        PickupItem(widget.itemId)
                    else
                        widget:SetItemId(newId)
                        widget:SetCount(cloneCount)
                        if not IsShiftKeyDown() then
                            ClearCursor()
                            cloneCount = 1
                        end
                    end
                end
            end
        end
    end

    local function Button_OnDragStart(frame)
        local widget = frame.obj
        PickupItem(widget.itemId)
        if widget.clone or IsShiftKeyDown() then
            widget:SetItemId(widget.itemId)
            cloneCount = widget.count
            widget:SetCount(widget.count)
        else
            cloneCount = widget.count
            widget:SetItemId(nil)
            widget:SetCount(nil)
        end
    end

    local function Button_OnReceiveDrag(frame)
        AceGUI:ClearFocus()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)

        local widget = frame.obj

        local kind, newId = GetCursorInfo()
        if kind == "item" and tonumber(newId) then
            if widget.clone then
                PickupItem(widget.itemId)
                widget:SetItemId(widget.itemId)
                widget:SetCount(widget.count)
            else
                widget:SetItemId(newId)
                widget:SetCount(cloneCount)
                if not IsShiftKeyDown() then
                    ClearCursor()
                    cloneCount = 1
                end
            end
        end
    end

    local function Button_OnEnter(frame)
        local widget = frame.obj
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        if widget then
            widget:Fire("OnEnter")
            if frame.obj.itemId then
                local _, link = GetItemInfo(frame.obj.itemId)
                if link then
                    GameTooltip:SetHyperlink(link)
                end
            end
            GameTooltip:Show()
        end
    end

    local function Button_OnLeave(frame)
        local widget = frame.obj
        if widget then
            GameTooltip:Hide()
            widget:Fire("OnLeave")
        end
    end

    local function Button_OnMouseWheel(frame, dir)
        local widget = frame.obj
        if not widget.itemId then
            return
        end
        if widget.clone then
            return
        end
        if dir == 1 then
            if not widget.count then
                widget:SetCount(2)
            elseif widget.maxCount then
                if widget.count < widget.maxCount then
                    widget:SetCount(widget.count + 1)
                end
            end
        elseif dir == -1 then
            if not widget.count or widget.count < 2 then
                widget:SetCount(1)
            else
                widget:SetCount(widget.count - 1)
            end
        end
    end

    local function getItemQualityOverlay(itemIDOrLink)
        local quality = nil;
        local button = {}
        if itemIDOrLink then
            quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemIDOrLink);
            if quality then
                button.isCraftedItem = false;
            else
                quality = C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemIDOrLink);
                button.isCraftedItem = quality ~= nil;
            end

            button.isProfessionItem = quality ~= nil;
        else
            button.isProfessionItem = false;
        end
        button.quality = quality;
        return button;
    end

    local methods = {}

    function methods:OnAcquire()
        self:SetWidth(45)
        self:SetHeight(45)
        self.frame.countText:SetText("")
        self.frame.removeButton:Hide()
    end

    function methods:OnRelease()
        self.itemId = nil
        self.count = nil
        self.maxCount = nil
        self.clone = nil
    end

    function methods:SetClone(clone)
        self.clone = clone
        if clone then
            self:SetWidth(35)
            self:SetHeight(35)
            self.frame.removeButton:Show()
        end
    end

    function methods:SetIndex(index)
        self.index = index
    end

    function methods:SetItemId(itemId)
        if self.clone then
            if not self.count then
                self:SetCount(1)
            end
            self.frame.countText:SetText("")
        end
        self.itemId = itemId
        if itemId then
            if itemId > 0 then
                local widget = self
                LibAddonUtils.CacheItem(itemId, function(itemID)
                    local _, _, _, _, _, _, _, maxCount, _, texture = GetItemInfo(itemID)
                    widget.maxCount = maxCount
                    widget.frame:SetNormalTexture(texture or [[Interface\\Icons\\INV_Misc_QuestionMark]])
                    local qualityInfo = getItemQualityOverlay(itemID)
                    widget.frame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
                    widget.frame.iconOverlay:SetQuality(qualityInfo.quality)
                end, itemId)
            else
                self.frame:SetNormalAtlas("bags-item-slot64")
                self.frame.iconOverlay:SetQuality(nil)
                self.frame:GetNormalTexture():SetTexCoord(0, 41 / 64, 0, 41 / 64)
            end
        else
            self.frame:SetNormalAtlas("bags-item-slot64")
            self.frame.iconOverlay:SetQuality(nil)
            self.frame:GetNormalTexture():SetTexCoord(0, 41 / 64, 0, 41 / 64)
        end
        self:Fire("OnValueChanged", self.itemId, self.count, self.index)
    end

    function methods:SetCount(count)
        self.count = count
        if not count then
            self.frame.countText:SetText("")
        elseif count and count >= 1 then
            self.frame.countText:SetText(count)
        end
        if self.clone then
            self.frame.countText:SetText("")
        end
        self:SetItemId(self.itemId)
    end

    local function Constructor()
        local name = "AceGUI30ItemActionSlot" .. AceGUI:GetNextWidgetNum(Type)
        local frame = CreateFrame("Button", name, UIParent)
        frame:Hide()

        frame:EnableMouse(true)
        frame:EnableMouseWheel(true)
        frame:SetScript("OnMouseDown", function(frame, ...)
            Button_OnClick(frame, ...)
        end)
        frame:SetScript("OnMouseWheel", Button_OnMouseWheel)
        frame:RegisterForDrag("LeftButton", "RightButton")
        frame:SetScript("OnReceiveDrag", Button_OnReceiveDrag)
        frame:SetScript("OnDragStart", Button_OnDragStart)
        frame:SetScript("OnEnter", Button_OnEnter)
        frame:SetScript("OnLeave", Button_OnLeave)

        frame:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD")


        local iconOverlay = frame:CreateTexture(nil, "OVERLAY")
        iconOverlay:SetSize(30, 30)
        iconOverlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        iconOverlay:SetAtlas("Professions-Icon-Quality-Tier" .. 1)
        iconOverlay:Hide()
        iconOverlay.SetQuality = function(self, quality)
            if quality then
                self:SetAtlas("Professions-Icon-Quality-Tier" .. quality)
                self:Show()
            else
                self:Hide()
            end
        end
        frame.iconOverlay = iconOverlay

        local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        countText:SetPoint("BOTTOMRIGHT", -2, 2)
        countText:SetJustifyH("CENTER")
        countText:SetJustifyV("CENTER")
        countText:SetTextColor(1, 1, 1)
        countText:SetText("")
        frame.countText = countText

        local removeButton = CreateFrame("Button", nil, frame)
        removeButton:SetPoint("TOPRIGHT", -2, 2)
        removeButton:SetSize(16, 16)
        removeButton:SetNormalTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
        removeButton:SetPushedTexture([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
        removeButton:SetHighlightTexture([[Interface\Buttons\UI-GroupLoot-Pass-Highlight]])
        removeButton:SetScript("OnClick", function(button)
            local parent = button:GetParent()
            local widget = parent.obj
            if widget and widget.clone then
                if widget.itemId then
                    widget:Fire("OnClose", widget.itemId)
                end
            end
        end)
        removeButton:Hide()
        frame.removeButton = removeButton

        local widget = {
            frame = frame,
            type = Type
        }
        for method, func in pairs(methods) do
            widget[method] = func
        end

        return AceGUI:RegisterAsWidget(widget)
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local xpcall = xpcall

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function safecall(func, ...)
    if func then
        return xpcall(func, errorhandler, ...)
    end
end

AceGUI:RegisterLayout("GBCustom", function(content, children)
    local fullWidth = content.width or content:GetWidth() or 0
    local numDoubleColumns = 7
    local width = fullWidth / (numDoubleColumns * 2)
    if width < 0 then
        width = 0
    end

    local height = 0
    for i = 1, #children do
        local child = children[i]

        local frame = child.frame
        frame:ClearAllPoints()
        frame:Show()
        if i == 1 then
            frame:SetPoint("TOPLEFT", content)
        elseif (i - 1) % 7 == 0 then
            local xOffset = 0
            if (i - 1) % 14 == 0 then
                xOffset = 6
            end
            frame:SetPoint("TOPLEFT", children[i - 7].frame, "TOPRIGHT", xOffset, 0)
        else
            frame:SetPoint("TOPLEFT", children[i - 1].frame, "BOTTOMLEFT")
        end
        height = frame:GetHeight() * 7
        frame:SetWidth(width)
    end
    safecall(content.obj.LayoutFinished, content.obj, nil, height)
end)

function GuildBankTools:CreateOptions()
    local OptionsPanel = AceGUI:Create("Frame")
    OptionsPanel:SetLayout("Flow")
    OptionsPanel:SetTitle("Guild Bank Tools")
    OptionsPanel:SetStatusText("")
    OptionsPanel:EnableResize(false)
    OptionsPanel:SetWidth(780)
    OptionsPanel:SetHeight(565)
    OptionsPanel:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        GuildBankTools.OptionsPanel = nil
    end)

    self.OptionsPanel = OptionsPanel

    local function SelectGuildBankTab(container, event, group)
        local tabIndex = tonumber(string.match(group, "%d+"))
        if not tabIndex then
            return
        end
        if not GuildBankTools.db.profile.layoutEditor.layout[tabIndex] then
            GuildBankTools.db.profile.layoutEditor.layout[tabIndex] = {}
        end
        container:ReleaseChildren()
        for i = 1, 98 do
            local itemSlot = AceGUI:Create("ItemActionSlot")
            itemSlot:SetClone(false)
            if type(GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i]) == "table" then
                itemSlot:SetItemId(GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i][1])
                itemSlot:SetCount(GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i][2])
            else
                GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i] = -1
                itemSlot:SetCount(nil)
                itemSlot:SetItemId(nil)
            end

            itemSlot:SetIndex(i)
            itemSlot:SetCallback("OnValueChanged", function(frame, event, itemId, count, index)
                if itemId and count and index then
                    GuildBankTools.db.profile.layoutEditor.layout[tabIndex][index] = { itemId, count }
                else
                    GuildBankTools.db.profile.layoutEditor.layout[tabIndex][index] = -1
                end
            end)
            container:AddChild(itemSlot)
        end
    end

    if self.db.profile.layoutEditor.num == 0 then
        local alertMessage = AceGUI:Create("Label")
        alertMessage:SetText("You need to set the number of guild bank tabs before you can edit the layout!")
        alertMessage:SetFullWidth(true)
        alertMessage:SetColor(1, 0.82, 0)
        OptionsPanel:AddChild(alertMessage)
    else
        local GuildBankLayoutEditor = AceGUI:Create("SimpleGroup")
        GuildBankLayoutEditor:SetFullWidth(true)
        GuildBankLayoutEditor:SetFullHeight(true)
        GuildBankLayoutEditor:SetLayout("list")
        OptionsPanel:AddChild(GuildBankLayoutEditor)




        local headerGroup = AceGUI:Create("SimpleGroup")
        headerGroup:SetFullWidth(true)
        headerGroup:SetLayout("Flow")

        local itemSearch = AceGUI:Create("EditBox")
        itemSearch:SetRelativeWidth(1)
        itemSearch:SetCallback("OnEnterPressed", function(widget, event, text)
            LibAddonUtils.CacheItem(text, function(itemID)
                local name, link, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
                local itemID = GetItemInfoFromHyperlink(link)
                if not GuildBankTools.db.profile.desiredItems[itemID] and itemID then
                    -- GuildBankTools.db.profile.desiredItems[itemID] = {
                    --     itemId = itemID,
                    --     icon = itemTexture,
                    --     count = 1,
                    --     link = link,
                    --     name = name
                    -- }
                    PickupItem(itemID)
                end
                itemSearch:SetText("")
            end, text)
        end)
        itemSearch:SetLabel("Item Suche (Link, Name oder ItemID)")
        headerGroup:AddChild(itemSearch)
        GuildBankLayoutEditor:AddChild(headerGroup)

        local GuildBankTabs = AceGUI:Create("TabGroup")
        GuildBankTabs:SetFullWidth(true)
        GuildBankTabs:SetLayout("GBCustom")
        local tabsTable = {}
        for i, j in pairs(self.db.profile.layoutEditor.gbankslots) do
            table.insert(tabsTable, {
                text = "|T" .. j.icon .. ":16:16:0:0:64:64:4:60:4:60|t " .. j.name,
                value = "subTab" .. i
            })
        end
        GuildBankTabs:SetTabs(tabsTable)
        GuildBankTabs:SetCallback("OnGroupSelected", SelectGuildBankTab)
        GuildBankTabs:SelectTab("subTab1")
        GuildBankTabs:SetFullHeight(true)
        GuildBankLayoutEditor:AddChild(GuildBankTabs)



        local exportLayoutButton = AceGUI:Create("Button")
        exportLayoutButton:SetText("Export Layout")
        exportLayoutButton:SetFullWidth(true)
        GuildBankLayoutEditor:AddChild(exportLayoutButton)

        local editBox = AceGUI:Create("EditBox")
        editBox:SetFullWidth(true)
        editBox:SetFullHeight(true)
        GuildBankLayoutEditor:AddChild(editBox)

        local importLayoutButton = AceGUI:Create("Button")
        importLayoutButton:SetText("Import Layout")
        importLayoutButton:SetFullWidth(true)
        GuildBankLayoutEditor:AddChild(importLayoutButton)

        exportLayoutButton:SetCallback("OnClick", function()
            if (LibDeflate and LibAceSerializer) then
                local dataSerialized = LibAceSerializer:Serialize(GuildBankTools.db.profile.layoutEditor.layout)
                if (dataSerialized) then
                    local dataCompressed = LibDeflate:CompressDeflate(dataSerialized, {
                        level = 9
                    })
                    if (dataCompressed) then
                        local dataEncoded = LibDeflate:EncodeForPrint(dataCompressed)
                        if dataEncoded then
                            editBox:SetText(dataEncoded)
                        end
                    end
                end
            end
        end)

        importLayoutButton:SetCallback("OnClick", function()
            if (LibDeflate and LibAceSerializer) then
                local serializedText = editBox:GetText()
                if (serializedText) then
                    local dataDecoded = LibDeflate:DecodeForPrint(serializedText)
                    if (dataDecoded) then
                        local dataDecompressed = LibDeflate:DecompressDeflate(dataDecoded)
                        if dataDecompressed then
                            local okay, importedLayout = LibAceSerializer:Deserialize(dataDecompressed)
                            if (okay) then
                                GuildBankTools:ToggleOptions()
                                GuildBankTools.db.profile.layoutEditor.layout = importedLayout
                                GuildBankTools:ToggleOptions()
                                editBox:SetText("")
                            end
                        end
                    end
                end
            end
        end)
    end

    OptionsPanel:Show()
end

function GuildBankTools:ToggleOptions()
    if not self.OptionsPanel then
        self:CreateOptions()
    else
        AceGUI:Release(self.OptionsPanel)
        self.OptionsPanel = nil
    end
end
