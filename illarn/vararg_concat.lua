local t_concat = table.concat

---@param delimeter string?
---@param ... any
---@return string
local function vararg_concat(delimeter, ...)
	local delimeter = delimeter or ""
	local key_pieces = {}
	local size = select("#", ...)

	for i = 1, size do
		key_pieces[#key_pieces+1] = tostring(select(i, ...))
	end

	return t_concat(key_pieces, delimeter)
end

return vararg_concat
