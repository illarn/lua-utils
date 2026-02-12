local class_types = {
	table = true,
	userdata = true
}

---@param obj any
---@return string
local function class_name(obj)
	local type = type(obj)
	if not class_types[type] then return type end
	local mt = getmetatable(obj)
	if not mt then return type end
	if type == "userdata" and not mt.__index then return type end
	return (mt.__name or mt.__cname) or type
end

return class_name
