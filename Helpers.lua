---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

Data.Helpers =  {}

function Data.Helpers.AreOverlappingRanges(rangeA, rangeB)
    if rangeA.min > rangeB.max then return false end
    if rangeA.max < rangeB.min then return false end

    return true
end

function Data.Helpers.NumberIsInRange(number, range)
    if number < range.min then return false end
    if number > range.max then return false end

    return true
end