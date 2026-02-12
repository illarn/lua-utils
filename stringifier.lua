local t_insert, t_concat = table.insert, table.concat
local s_format, s_rep = string.format, string.rep

---@class Stringifier
---@field compact boolean
---@field tab_size number
local M = {}
M.mt = {
	__index = M
}

function M:spaces(n)
	return s_rep(" ", n * self.tab_size)
end

---@param compact? boolean if true will return tables on one line. default false
---@param tab_size? number indentation size in spaces. default 2
---@return table
function M.new(compact, tab_size)
	local t = setmetatable({
		compact = compact or false,
		tab_size = tab_size or 2
	}, M.mt)

	return t
end

---@param obj any
---@param _seen? table for internal usage
---@param _indent? integer for internal usage
---@param _current_indent? integer for internal usage
---@return string
function M:get(obj, _seen, _indent, _current_indent)
	_indent = _indent or 0
	_current_indent = _current_indent or 0
	_seen = _seen or {}

	local obj_type = type(obj)

	if obj_type == "nil" then
		return "null"
	elseif obj_type == "boolean" or obj_type == "number" then
		return tostring(obj)
	elseif obj_type == "string" then
		return s_format("%q", obj)
	elseif obj_type == "function" then
		return s_format("<function: %p>", obj)
	elseif obj_type == "thread" then
		return s_format("<thread: %p>", obj)
	elseif obj_type == "userdata" then
		local mt = getmetatable(obj)
		if mt and mt.__tostring then
			return tostring(obj)
		else
			return s_format("<userdata: %p>", obj)
		end
	elseif obj_type == "table" then
		if _seen[obj] then
			return "<circular reference>"
		end

		_seen[obj] = true

		local mt = getmetatable(obj)
		if mt and mt.__tostring then
			local str = tostring(obj)
			_seen[obj] = nil
			return str
		end

		local result = {"<table: "}
		local first = true

		local max_index = 0
		local is_array = true
		for k in pairs(obj) do
			if type(k) == "number" and k > 0 and math.floor(k) == k then
				max_index = math.max(max_index, k)
			else
				is_array = false
			end
		end

		if is_array and max_index == #obj then
			-- array format
			t_insert(result, "[")
			for i = 1, max_index do
				if not first then
					t_insert(result, ",")
				else
					first = false
				end
				if not self.compact then
					t_insert(result, "\n")
					t_insert(result, self:spaces(_current_indent + 1))
				end
				t_insert(result, self:get(obj[i], _seen, _indent, _current_indent + 1))
			end
			if max_index > 0 and not self.compact then
				t_insert(result, "\n")
				t_insert(result, self:spaces(_current_indent))
			end
			t_insert(result, "]")
		else
			t_insert(result, "{")
			for k, v in pairs(obj) do
				if not first then
					t_insert(result, ",")
				else
					first = false
				end
				if not self.compact then
					t_insert(result, "\n")
					t_insert(result, self:spaces(_current_indent + 1))
				end
				t_insert(result, self:get(k, _seen, _indent, _current_indent + 1))
				t_insert(result, ": ")
				t_insert(result, self:get(v, _seen, _indent, _current_indent + 1))
			end
			if next(obj) ~= nil and not self.compact then
				t_insert(result, "\n")
				t_insert(result, self:spaces(_current_indent))
			end
			t_insert(result, "}")
		end

		_seen[obj] = nil
		t_insert(result, ">")
		return t_concat(result)
	else
		return tostring(obj)
	end
end

M.mt.__call = M.get

return M
