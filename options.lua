local GuildBankTools = LibStub("AceAddon-3.0"):GetAddon("GuildBankTools")
local LibAddonUtils = LibStub("LibAddonUtils-1.0")

local AceGUI = LibStub("AceGUI-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

function TextEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = {
                left = 8,
                right = 6,
                top = 8,
                bottom = 8
            }
        })
        f:SetBackdropBorderColor(0, 0, 0, 0.5) -- darkblue

        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)

        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)

        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function()
            f:Hide()
        end)
        sf:SetScrollChild(eb)

        -- Resizable
        f:SetResizable(true)
        f:SetMinResize(150, 100)

        local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)

        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end

    if text then
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
end

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
                    widget:IsBlocked(false)
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
        elseif button == "MiddleButton" then
            if widget.blocked then
                widget:IsBlocked(false)
            else
                widget:IsBlocked(true)
            end
        end
    end

    local function Button_OnDragStart(frame)
        local widget = frame.obj
        if widget.blocked then
            return
        end
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
            widget:IsBlocked(false)
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
        if widget.blocked then
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
        self.blocked = false
        self.clone = nil
        self.frame.blockedOverlay:Hide()
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
                    widget.frame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
                end, itemId)
            else
                self.frame:SetNormalTexture([[Interface\Buttons\UI-Slot-Background]])
                self.frame:GetNormalTexture():SetTexCoord(0, 41 / 64, 0, 41 / 64)
            end
        else
            self.frame:SetNormalTexture([[Interface\Buttons\UI-Slot-Background]])
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

    function methods:IsBlocked(bool)
        if bool then
            self.blocked = true
            self.frame.blockedOverlay:Show()
            self:SetCount(nil)
            self:SetItemId(-1)
        else
            self.blocked = false
            if self.itemId == -1 then
                self:SetItemId(nil)
            end
            self.frame.blockedOverlay:Hide()
        end
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

        local blockedOverlay = frame:CreateTexture(nil, "OVERLAY")
        blockedOverlay:SetAllPoints()
        blockedOverlay:SetAtlas("common-icon-redx")
        blockedOverlay:Hide()
        frame.blockedOverlay = blockedOverlay

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
    local height = 0
    for i = 1, #children do
        local child = children[i]

        local frame = child.frame
        frame:ClearAllPoints()
        frame:Show()
        if i == 1 then
            frame:SetPoint("TOPLEFT", content)
        elseif (i - 1) % 7 == 0 then
            local xOffset = 2
            if (i - 1) % 14 == 0 and i < (#children - 14) then
                xOffset = 8
            end
            frame:SetPoint("TOPLEFT", children[i - 7].frame, "TOPRIGHT", xOffset, 0)
        else
            frame:SetPoint("TOPLEFT", children[i - 1].frame, "BOTTOMLEFT")
        end

        height = frame:GetHeight() * 7
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
    OptionsPanel:SetHeight(600)
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
            elseif type(GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i]) == "string" then
                itemSlot:SetCount(nil)
                itemSlot:SetItemId(nil)
                itemSlot:IsBlocked(true)
            else
                GuildBankTools.db.profile.layoutEditor.layout[tabIndex][i] = -1
                itemSlot:SetCount(nil)
                itemSlot:SetItemId(nil)
            end

            itemSlot:SetIndex(i)
            itemSlot:SetCallback("OnValueChanged", function(frame, event, itemId, count, index)
                if itemId and count and index then
                    GuildBankTools.db.profile.layoutEditor.layout[tabIndex][index] = {itemId, count}
                elseif itemId == -1 then
                    GuildBankTools.db.profile.layoutEditor.layout[tabIndex][index] = "b"
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

        local itemName = AceGUI:Create("EditBox")
        itemName:SetFullWidth(true)
        itemName:SetCallback("OnEnterPressed", function(widget, event, text)
            LibAddonUtils.CacheItem(text, function(itemID)
                local name, link, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
                local itemID = GetItemInfoFromHyperlink(link)
                if not GuildBankTools.db.profile.desiredItems[itemID] then
                    GuildBankTools.db.profile.desiredItems[itemID] = {
                        itemId = itemID,
                        icon = itemTexture,
                        count = 1,
                        link = link,
                        name = name
                    }
                    PickupItem(itemID)
                end
                itemName:SetText("")
            end, text)
        end)
        GuildBankLayoutEditor:AddChild(itemName)

        local GuildBankTabs = AceGUI:Create("TabGroup")
        GuildBankTabs:SetFullWidth(true)
        GuildBankTabs:SetLayout("GBCustom")
        local tabs = {}
        for i, j in pairs(self.db.profile.layoutEditor.gbankslots) do
            table.insert(tabs, {
                text = "|T" .. j.icon .. ":16:16:0:0:64:64:4:60:4:60|t " .. j.name,
                value = "subTab" .. i
            })
        end
        GuildBankTabs:SetTabs(tabs)
        GuildBankTabs:SetCallback("OnGroupSelected", SelectGuildBankTab)
        GuildBankTabs:SelectTab("subTab1")
        GuildBankTabs:SetFullHeight(true)

        GuildBankLayoutEditor:AddChild(GuildBankTabs)

        local infoText = AceGUI:Create("Label")
        infoText:SetFullWidth(true)
        local string1 = "|A:newplayertutorial-icon-mouse-leftbutton:17:13|a to drag"
        local string2 = "Shift + |A:newplayertutorial-icon-mouse-leftbutton:17:13|a to clone"
        local string3 = "Ctrl + |A:newplayertutorial-icon-mouse-leftbutton:17:13|a to clear"
        local string4 = "|A:newplayertutorial-icon-mouse-middlebutton:17:13|a to block/unblock"
        infoText:SetText("|cff00ff00" .. string1 .. "        " .. "|cff00ff00" .. string2 .. "   " .. "|cff00ff00" ..
                             string3 .. "     " .. "|cff00ff00" .. string4 .. "|r")
        infoText:SetFontObject(GameFontHighlight)

        GuildBankLayoutEditor:AddChild(infoText)

        local craftingDiffSlider = AceGUI:Create("Slider")
        craftingDiffSlider:SetLabel("Percentage difference between crafting or buying from auction house")
        craftingDiffSlider:SetSliderValues(0, 1, 0.01)
        craftingDiffSlider:SetIsPercent(true)
        if self.db.profile.craftingDiff then
            craftingDiffSlider:SetValue(self.db.profile.craftingDiff)
        else
            craftingDiffSlider:SetValue(0)
            self.db.profile.craftingDiff = 0
        end
        craftingDiffSlider:SetCallback("OnValueChanged", function(widget, event, value)
            self.db.profile.craftingDiff = value
        end)
        craftingDiffSlider:SetFullWidth(true)
        GuildBankLayoutEditor:AddChild(craftingDiffSlider)

        local buttonGroup = AceGUI:Create("SimpleGroup")
        buttonGroup:SetFullWidth(true)
        buttonGroup:SetLayout("Flow")
        GuildBankLayoutEditor:AddChild(buttonGroup)

        local importLayoutButton = AceGUI:Create("Button")
        importLayoutButton:SetText("Import Layout")
        importLayoutButton:SetRelativeWidth(0.50)
        buttonGroup:AddChild(importLayoutButton)

        local exportLayoutButton = AceGUI:Create("Button")
        exportLayoutButton:SetText("Export Layout")
        exportLayoutButton:SetRelativeWidth(0.50)
        buttonGroup:AddChild(exportLayoutButton)

        local editBox = AceGUI:Create("EditBox")
        editBox:SetFullWidth(true)
        editBox:SetFullHeight(true)
        buttonGroup:AddChild(editBox)

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
