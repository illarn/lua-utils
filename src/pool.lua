---@class ObjectPool
---@field private _constructor fun(...): any
---@field private _reconstructor fun(obj: any, ...)
---@field private _resetter fun(obj: any, ...)
---@field private _pool any[]
---@field private _pool_size integer
local M = {}
M.mt = {
	__index = M,
	__name = "ObjectPool"
}

---@param constructor fun(...): any
---@param reconstructor? fun(obj: any, ...) executed after the object was taken from the pool
---@param resetter? fun(obj: any) executed after the object is returned
---@return ObjectPool
function M.new(constructor, reconstructor, resetter)
	local t = setmetatable({
		_constructor = constructor,
		_reconstructor = reconstructor,
		_resetter = resetter,
		_pool = {},
		_pool_size = 0
	}, mt)

	return t
end

function M:get(...)
	local obj
	local pool_size = self._pool_size

	if pool_size > 0 then
		obj = self._pool[pool_size]
		self._pool[pool_size] = nil
		self._pool_size = pool_size - 1
		local reconstructor = self._reconstructor
		if reconstructor then
			reconstructor(obj, ...)
		end
	else
		obj = self._constructor(...)
	end

	return obj
end

function M:return_object(obj)
	local pool_size = self._pool_size + 1
	self._pool_size = pool_size
	local resetter = self._resetter
	if resetter then
		resetter(obj)
	end
	self._pool[pool_size] = obj
end

function M:clear()
	self._pool = {}
	self._pool_size = 0
end

return M
