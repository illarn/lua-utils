local s_format = string.format
local Logger = require("illarn.logger")
local log = Logger.new("WeakReference")

---@class WeakReference
---@field _value {value: any}
local M = {}
M.mt = {
	__index = function(self, key)
		local obj = self:get()
		if not obj then
			log:error("Trying to access dead weak reference " .. tostring(self))
		end
		return obj[key]
	end,
	__call = function(self, ...)
		local obj = self:get()
		if not obj then
			log:error("Trying to access dead weak reference " .. tostring(self))
		end
		return obj(...)
	end,
	__tostring = function(self)
		local obj = self:get()
		if obj == nil then
			return "WeakReference<dead>"
		else
			return s_format("WeakReference<%s>", tostring(obj))
		end
	end,
}

--- @return any
function M:get()
	return self._value.value
end

--- @param v any
--- @return WeakReference
function M.new(v)
	if type(v) == "number" or type(v) == "string" or type(v) == "boolean" or v == nil then
		log:error("WeakReference only supports gcable types")
	end

	local t = setmetatable({
		_value = setmetatable({value = v}, {__mode = "v"}),
		get = M.get
	}, M.mt)

	return t
end

return M
