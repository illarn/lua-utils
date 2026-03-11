---@class Callable
---@field private mt table
---@field private _fun fun(...)
---@field private _args any[]
---@field PH table placeholder, assign to values that need to be filled on call
local M = {}
M.mt = {
	__index = M
}
M.PH = {}

---@param fun fun(...)
---@param ... any
function M.new(fun, ...)
	local t = setmetatable({
		_fun = fun,
		_args = {...}
	}, M.mt)

	return t
end

--- calls the function with placeholders replaced by arguments
---@param ... any
function M:call(...)
	local args = self._args
	local call_args

	if select("#", ...) == 0 then
		call_args = args
	else
		call_args = {}
		local i = 1
		local arg_pos = 1
		local arg_count = #args

		while arg_pos <= arg_count do
			local existing_arg = args[arg_pos]
			if existing_arg == M.PH then
				call_args[arg_pos] = select(i, ...)
				i = i + 1
			else
				call_args[arg_pos] = existing_arg
			end
			arg_pos = arg_pos + 1
		end
	end

	self._fun(table.unpack(call_args))
end
M.mt.__call = M.call

return M
