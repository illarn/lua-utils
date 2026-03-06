local t_insert, t_concat = table.insert, table.concat
local s_format, s_rep = string.format, string.rep

---@alias StringifierFormatConfig {start: string, end: string, delimeter: string, array_start: string, array_end: string, kv_start: string, kv_end: string, kv_delimeter: string, array_value_format: string, key_format: string, value_format: string, newline: string, space: string}

---@class Stringifier
---@field compact boolean
---@field tab_size number
---@field format StringifierFormat
---@field Format table<string, number>
---@field private _s_format_configs table<StringifierFormat, StringifierFormatConfig>
local M = {}
M.mt = {
	__index = M
}

function M:_spaces(n, format_config)
	return s_rep(format_config.space, n * (self.tab_size or 2))
end

---@enum StringifierFormat
M.Format = {
	DEFAULT = 1,
	JSON = 2,
	YAML = 3,
	TOML = 4
}

M._s_format_configs = {
	[M.Format.DEFAULT] = {
		["start"] = "<table: ",
		["end"] = ">",
		["delimeter"] = ", ",
		["array_start"] = "[",
		["array_end"] = "]",
		["kv_start"] = "{",
		["kv_end"] = "}",
		["kv_delimeter"] = ": ",
		["key_format"] = "%s",
		["value_format"] = "%s",
		["array_value_format"] = "%s",
		["space"] = " ",
		["newline"] = "\n",
	},
	[M.Format.JSON] = {
		["start"] = "{",
		["end"] = "}",
		["delimeter"] = ", ",
		["array_start"] = "\"array_part\": [",
		["array_end"] = "]",
		["kv_start"] = "\"kv_part\": {",
		["kv_end"] = "}",
		["kv_delimeter"] = ": ",
		["key_format"] = "\"%s\"",
		["value_format"] = "\"%s\"",
		["array_value_format"] = "\"%s\"",
		["space"] = " ",
		["newline"] = "\n",
	},
}

---@param compact? boolean if true will return tables on one line. default false
---@param tab_size? number indentation size in spaces. default 2
---@param format? StringifierFormat formatting of the result (tables only)
---@return table
function M.new(compact, tab_size, format)
	local t = setmetatable({
		compact = compact or false,
		tab_size = tab_size or 2,
		format = format or M.Format.DEFAULT
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
		return "nil"
	elseif obj_type == "boolean" or obj_type == "number" then
		return tostring(obj)
	elseif obj_type == "string" then
		return obj
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
		local compact = self.compact

		local format_config = M._s_format_configs[self.format] or M._s_format_configs[M.Format.DEFAULT]
		if _seen[obj] then
			return "!circular reference!"
		end

		_seen[obj] = true

		local mt = getmetatable(obj)
		if mt and mt.__tostring then
			local str = tostring(obj)
			_seen[obj] = nil
			return str
		end

		local result = {format_config.start}
		if not compact then
			t_insert(result, format_config.newline)
			_current_indent = _current_indent + 1
			t_insert(result, self:_spaces(_current_indent, format_config))
		end
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
			t_insert(result, format_config.array_start)
			for i = 1, max_index do
				if not first then
					t_insert(result, format_config.delimeter)
				else
					first = false
				end
				if not compact then
					t_insert(result, format_config.newline)
					t_insert(result, self:_spaces(_current_indent + 1, format_config))
				end
				t_insert(result, s_format(format_config.array_value_format, self:get(obj[i], _seen, _indent, _current_indent + 1)))
			end
			if max_index > 0 and not compact then
				t_insert(result, format_config.newline)
				t_insert(result, self:_spaces(_current_indent, format_config))
			end
			t_insert(result, format_config.array_end)
		else
			t_insert(result, format_config.kv_start)
			for k, v in pairs(obj) do
				if not first then
					t_insert(result, format_config.delimeter)
				else
					first = false
				end
				if not compact then
					t_insert(result, format_config.newline)
					t_insert(result, self:_spaces(_current_indent + 1, format_config))
				end
				t_insert(result, s_format(format_config.key_format, self:get(k, _seen, _indent, _current_indent + 1)))
				t_insert(result, format_config.kv_delimeter)
				t_insert(result, s_format(format_config.value_format, self:get(v, _seen, _indent, _current_indent + 1)))
			end
			if next(obj) ~= nil and not compact then
				t_insert(result, format_config.newline)
				t_insert(result, self:_spaces(_current_indent, format_config))
			end
			t_insert(result, format_config.kv_end)
		end

		_seen[obj] = nil
		if not compact then
			t_insert(result, format_config.newline)
		end
		t_insert(result, format_config["end"])
		return t_concat(result)
	else
		return tostring(obj)
	end
end

M.mt.__call = M.get

return M
