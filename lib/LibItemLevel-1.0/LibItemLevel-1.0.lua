local lib, oldMinor = LibStub:NewLibrary("LibItemLevel-1.0", 1)
if not lib then return end

local scanningTooltip, anchor
local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
local scaledItemLevelPattern =  _G.ITEM_LEVEL_ALT:gsub("[()]", "%%%1"):gsub("%%d", "(%%d+)")
local cache = {}

local needsTooltipScan = {
    [LE_ITEM_CLASS_WEAPON] = true,
    [LE_ITEM_CLASS_ARMOR] = true,
}

--[[
Given a reference to an item, return its item level

Accepted arguments:
 * "itemLink"
 * itemId
 * bagId, slotId
 * "inventorySlot"
 * "inventorySlot", "unit"

Returns: number or nil
--]]
lib.GetItemLevel = function(itemLink, bagSlot)
    local bagId, invSlotId
    local unit = "player"
    if not itemLink then return end
    if type(itemLink) == "string" and not itemLink:match("item:%d+") then
        -- SlotName path!
        invSlotId = GetInventorySlotInfo(itemLink)
        unit = bagSlot or unit
        itemLink = GetInventoryItemLink(unit, invSlotId)
    elseif bagSlot then
        if type(bagSlot) == "string" then
            invSlotId = itemLink
            unit = bagSlot
            itemLink = GetInventoryItemLink(unit, invSlotId)
        else
            bagId = itemLink
            itemLink = select(7, GetContainerItemInfo(bagId, bagSlot))
            if bagId == BANK_CONTAINER then
                invSlotId = BankButtonIDToInvSlotID(bagSlot)
            elseif bagId == REAGENTBANK_CONTAINER then
                invSlotId = ReagentBankButtonIDToInvSlotID(bagSlot)
            end
        end
    end
    if not itemLink then return end
    if not cache[itemLink] then
        local itemClass = select(6, GetItemInfoInstant(itemLink))
        if type(itemLink) == "number" or not needsTooltipScan[itemClass] then
            -- All we *can* know is the API response
            -- Or: it's not an item-type whose level varies
            cache[itemLink] = (select(4, GetItemInfo(itemLink)))
        else
            if not scanningTooltip then
                anchor = CreateFrame("Frame")
                anchor:Hide()
                scanningTooltip = _G.CreateFrame("GameTooltip", "LibItemLevelScanTooltip", nil, "GameTooltipTemplate")
            end
            GameTooltip_SetDefaultAnchor(scanningTooltip, anchor)
            local status, err
            if invSlotId then
                -- print("scanning: inventoryitem", unit, invSlotId)
                status, err = pcall(scanningTooltip.SetInventoryItem, scanningTooltip, unit, invSlotId)
            elseif bagId then
                -- print("scanning: bagitem", bagId, bagSlot)
                status, err = pcall(scanningTooltip.SetBagItem, scanningTooltip, bagId, bagSlot)
            else
                -- print("scanning: link", itemLink)
                status, err = pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
            end
            if not status then return (select(4, GetItemInfo(itemLink))) end
            for i = 2, 5 do
                local left = _G["LibItemLevelScanTooltipTextLeft" .. i]
                if left then
                    local text = left:GetText()
                    if text then
                        local levelScaled, level = text:match(scaledItemLevelPattern)
                        if not level then
                            level = text:match(itemLevelPattern)
                        end
                        level = tonumber(level)
                        if level then
                            cache[itemLink] = level
                            break
                        end
                    end
                end
            end
            scanningTooltip:Hide()
        end
    end
    return cache[itemLink] or (select(4, GetItemInfo(itemLink)))
end

lib.ClearCache = function()
    wipe(cache)
end
