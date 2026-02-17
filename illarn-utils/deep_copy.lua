---@param obj any
---@param seen? table
---@return any
local function deep_copy(obj, seen)
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end
	local copy = {}
	if seen then
		seen[obj] = copy
	else
		seen = {[obj] = copy}
	end
	for k, v in pairs(obj) do
		copy[deep_copy(k, seen)] = deep_copy(v, seen)
	end
	return setmetatable(copy, getmetatable(obj))
end

return deep_copy
