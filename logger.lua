local Stringifier = require("stringifier")
local stringifier = Stringifier.new(true)
local t_concat = table.concat
local t_insert = table.insert

---@class Logger
---@field level LogLevel
---@field color boolean
---@field private _level_name string
---@field private _level_color string
---@field private _name string
---@field s_main Logger
local M = {}
M.mt = {__index = M}

---@enum LogLevel
M.LogLevel = {
	ERROR = 1,
	WARNING = 2,
	INFO = 3,
	DEBUG = 4,
	VERBOSE = 5
}

local Color = {
	RESET = "\27[0m",
	RED = "\27[31m",
	GREEN = "\27[32m",
	YELLOW = "\27[33m",
	BLUE = "\27[34m"
}

local level_color = {
	Color.RED,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
	Color.RESET
}

local level_name = {
	"ERROR",
	"WARNING",
	"INFO",
	"DEBUG",
	"RESET"
}

function M:_log(level, ...)
	if level > self.level then return end

	local msg_builder = {}
	local arg_amt = select("#", ...)
	for i = 1, arg_amt do
		local arg = select(i, ...)
		t_insert(msg_builder, stringifier(arg))
	end
	local msg = t_concat(msg_builder, ", ")

	local log_builder = {
		"[", os.date("%H:%M:%S" , os.time()), "]", "[", self._name, "]", level_color[self.level], "[", level_name[self.level], "]", Color.RESET, " ", msg
	}

	print(t_concat(log_builder))
end

M.error = function(self, ...) self:_log(1, ...) end
M.warn = function(self, ...) self:_log(2, ...) end
M.info = function(self, ...) self:_log(3, ...) end
M.debug = function(self, ...) self:_log(4, ...) end
M.verbose = function(self, ...) self:_log(5, ...) end

---@param name string
---@param level? LogLevel
function M.new(name, level)
	level = level and level or (DEBUG and M.LogLevel.DEBUG or (VERBOSE and M.LogLevel.VERBOSE or M.LogLevel.INFO))
	local t = setmetatable({
		level = level,
		colored = true,
		_name = name,
	}, M.mt)

	return t
end

M.s_main = M.new("Main")

return M
