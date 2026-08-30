---@diagnostic disable: duplicate-set-field
Inventory = Inventory or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "default"
end

---@description Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    return Framework.GetItemInfo(item)
end

---@description Will return boolean if the player has the item.
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(item, requiredCount)
    return Framework.HasItem(item, requiredCount)
end

---@description This will return their count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    return Framework.GetItemCount(item)
end

---@description This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    return Framework.GetPlayerInventory()
end

local PLACEHOLDER_IMAGE = "https://avatars.githubusercontent.com/u/47620135"

local function resourceFileExists(resource, relativePath)
    if GetResourceState(resource) ~= 'started' then return false end
    local ok, content = pcall(LoadResourceFile, resource, relativePath)
    return ok and type(content) == 'string' and content ~= ''
end

---@description Image path for NUI. Silent when missing (no console spam).
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    if not item or item == '' then return PLACEHOLDER_IMAGE end
    item = Inventory.StripPNG(Inventory.StripWebp(item))

    local candidates = {
        { 'concept_fortuna', ('web/public/items/%s.png'):format(item) },
        { 'concept_fortuna', ('web/dist/items/%s.png'):format(item) },
        { 'ox_inventory', ('web/images/%s.png'):format(item) },
        { 'esx_inventoryhud', ('html/img/items/%s.png'):format(item) },
        { 'esx_inventory', ('web/images/%s.png'):format(item) },
        { 'qb-inventory', ('html/images/%s.png'):format(item) },
    }

    for i = 1, #candidates do
        local resource, rel = candidates[i][1], candidates[i][2]
        if resourceFileExists(resource, rel) then
            return ('nui://%s/%s'):format(resource, rel)
        end
    end

    return PLACEHOLDER_IMAGE
end

---@description This will remove the file extension from the item name if present.
---@param item string
---@return string
Inventory.StripPNG = function(item)
    if string.find(item, ".png") then
        item = string.gsub(item, ".png", "")
    end
    return item
end

---@description This will remove the file extension from the item name if present.
---@param item string
---@return string
Inventory.StripWebp = function(item)
    if string.find(item, ".webp") then
        item = string.gsub(item, ".webp", "")
    end
    return item
end

---@description This will return the entire items table from the inventory.
---@return table
Inventory.Items = function()
    if not Framework.Shared or not Framework.Shared.Items then
        local itemList = Framework.ItemList() or { Items = {} }
        return itemList.Items or itemList or {}
    end
    return Framework.Shared.Items
end

return Inventory
