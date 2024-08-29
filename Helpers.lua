---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

Data.Helpers =  {}

---comment
---@param rangeA table
---@param rangeB table
---@return boolean
function Data.Helpers.AreOverlappingRanges(rangeA, rangeB)
    if rangeA.min > rangeB.max then return false end
    if rangeA.max < rangeB.min then return false end

    return true
end
---comment
---@param number number
---@param range table
---@return boolean
function Data.Helpers.NumberIsInRange(number, range)
    if number < range.min then return false end
    if number > range.max then return false end

    return true
end

---@param aura AuraData
---@return string
function Data.Helpers.getFilterFromAuraInfo(aura)
	return aura.isHarmful and "HARMFUL" or "HELPFUL"
end