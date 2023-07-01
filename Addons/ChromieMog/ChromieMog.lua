local ChromieMog = CreateFrame("Frame")
ChromieMog:RegisterEvent("PLAYER_LOGIN")
ChromieMog:RegisterEvent("UNIT_INVENTORY_CHANGED")

local trackedItems = {}

ChromieMog:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        HOOKTOOLTIP()
        LOADTRACKEDITEMS()
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            CHECKEQUIPPEDITEMS()
            SAVETRACKEDITEMS()
        end
    end
end)

function GETITEMID(itemLink)
    if not itemLink then
        return nil
    end
    local itemID = tonumber(itemLink:match("item:(%d+):"))
    return itemID
end

function CHECKEQUIPPEDITEMS()
    for slot = 1, 19 do -- Check slots 1 to 19 (including bags)
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local itemID = GETITEMID(itemLink)
            if itemID and not trackedItems[itemID] then
                trackedItems[itemID] = true
                print("ItemID: " .. "[".. itemID .. "]" .. " has been added to your ChromieMog vault.")
            end
            if itemID and not IsEquippableItem(itemLink) then
                trackedItems[itemID] = nil
            end
        end
    end
end

function HOOKTOOLTIP()
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local _, itemLink = self:GetItem()
        if itemLink then
            local itemID = GETITEMID(itemLink)
            if itemID and trackedItems[itemID] then
                GameTooltip:AddLine("In Transmog Vault")
            elseif IsEquippableItem(itemLink) then
                GameTooltip:AddLine("Not in Transmog Vault")
            end
            GameTooltip:Show()
        end
    end)

    ItemRefTooltip:HookScript("OnTooltipSetItem", function(self)
        local _, itemLink = self:GetItem()
        if itemLink then
            local itemID = GETITEMID(itemLink)
            if itemID and trackedItems[itemID] then
                self:AddLine("In Transmog Vault")
            elseif IsEquippableItem(itemLink) then
                self:AddLine("Not in Transmog Vault")
            end
            self:Show()
        end
    end)
end

function LOADTRACKEDITEMS()
    if ChromieMog_TrackedItems then
        trackedItems = ChromieMog_TrackedItems
    end
end

function SAVETRACKEDITEMS()
    ChromieMog_TrackedItems = trackedItems
end
