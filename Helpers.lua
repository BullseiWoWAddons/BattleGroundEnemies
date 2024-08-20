local AddonName, Data = ...

Data.Helpers =  {}

function Data.Helpers.AreOverlappingRanges(rangeA, rangeB)
    if rangeB.min <= rangeA.max then return true end
    if rangeB.max >= rangeA.min then return true end

    return false
end

function Data.Helpers.NumberIsInRange(number, range)
    if number >= range.min and number <= range.max then return true end

    return false
end