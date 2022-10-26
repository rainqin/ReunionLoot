
function Reunionloot_GetItem(bag, slot)
  -- GetContainerItemInfo.
  local texture, quantity, _, quality, _, lootable, link, _, noValue, id = GetContainerItemInfo(bag, slot)
  if id == nil then return nil end

  -- GetItemInfo.
  local name, _, _, itemLevel, _, _, _, _, invType, _, price, classId, subclassId = GetItemInfo(link)
  if name == nil then
    name, _, _, itemLevel, _, _, _, _, invType, _, price, classId, subclassId = GetItemInfo(id)
    if name == nil then return nil end
  end

  -- Build item.
  return {
    bag = bag,
    slot = slot,
    -- GetContainerItemInfo.
    texture = texture,
    quantity = quantity,
    quality = quality,
    lootable = lootable,
    link = link,
    noValue = noValue,
    id = id,
    -- GetItemInfo.
    name = name,
    itemLevel = GetDetailedItemLevelInfo(link) or itemLevel,
    invType = invType,
    price = price,
    classId = classId,
    subclassId = subclassId,
    -- Other.
    isBound = C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot))
  }
end

function Reunionloot_GetItemInfo(item_id)
  local _, link, quality, itemLevel, _, _, _, _, _, texture, _, _, _, _, _, _, _ = GetItemInfo(item_id)
  return {
    link = link,
    quality = quality,
    itemLevel = itemLevel,
    texture = texture
  } 
end

function Reunionloot_split (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function  Reunionloot_tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end