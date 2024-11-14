---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)

Data.Helpers =  {}



--[[
    Generates all permutations of the given input array.
    
    @param inputArr (table) The array for which permutations are to be generated.
    @return (table) A table containing all permutations of the input array.
    
    Example usage:
    local permutations = Data.Helpers.permgen({1, 2, 3})
    -- permutations will be:
    -- {
    --     {1, 2, 3},
    --     {1, 3, 2},
    --     {2, 1, 3},
    --     {2, 3, 1},
    --     {3, 1, 2},
    --     {3, 2, 1}
    -- }
]]
Data.Helpers.permgen = function(inputArr)
    local result = {}

    local function permute(arr, current)
       if #arr == 0 then
          table.insert(result, current)
       else
          for i = 1, #arr do
             local newArr = {}
             for j = 1, #arr do
                if j ~= i then
                   table.insert(newArr, arr[j])
                end
             end
             local newCurrent = {unpack(current)}
             table.insert(newCurrent, arr[i])
             permute(newArr, newCurrent)
          end
       end
    end

    permute(inputArr, {})
    return result
end


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

local oppositeHorizontalPoints = {
    TOPLEFT = "TOPRIGHT",
    LEFT = "RIGHT",
    BOTTOMLEFT = "BOTTOMRIGHT",
    TOPRIGHT = "TOPLEFT",
    RIGHT = "LEFT",
    BOTTOMRIGHT = "BOTTOMLEFT"
}

function Data.Helpers.getOppositeHorizontalPoint(point)
    if oppositeHorizontalPoints[point] then return oppositeHorizontalPoints[point] end
end

local oppositeHorizontalDirections = {
    leftwards = "rightwards",
    rightwards = "leftwards"
}

function Data.Helpers.getOppositeDirection(direction)
    if oppositeHorizontalDirections[direction] then return oppositeHorizontalDirections[direction] end
end


function Data.Helpers.getContainerAnchorPointForConfig(growRightwards, growDownwards)
    local pointX, pointY, offsetDirectionX, offsetDirectionY
    if growRightwards then
        pointX = "LEFT"
        offsetDirectionX = 1
    else
        pointX = "RIGHT"
        offsetDirectionX = -1
    end

    if growDownwards then
        pointY = "TOP"
        offsetDirectionY = -1
    else
        pointY = "BOTTOM"
        offsetDirectionY = 1
    end
    local point = pointY .. pointX

    return point, offsetDirectionX, offsetDirectionY
end