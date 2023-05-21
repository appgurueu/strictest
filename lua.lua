-- Lua strictness

local action = ...

local string = string

-- Don't allow indexing strings to fail, returning `nil`.
-- This may lead to mistakingly treating a string like an empty table.
-- Does still allow indexing the global `string` table as it doesn't use `setmetatable(string, {...})`.

local str_mt = getmetatable""
assert(str_mt.__index == string)
function str_mt.__index(_, key)
	local func = string[key]
	if func == nil then
		action"attempt to index a string value"
	end
	return func
end

-- Disable string-to-number coercion as much as possible

-- Setting the metamethods unfortunately doesn't work - Lua ignores them

-- Override string methods to reject anything that isn't a string
for name, func in pairs(string) do
	if not (name == "char" or name == "dump") then
		string[name] = function(str, ...)
			if type(str) ~= "string" then
				action"string expected as first argument"
			end
			return func(str, ...)
		end
	end
end

local function assert_nums(...)
	for i = 1, select("#", ...) do
		if type(select(i, ...)) ~= "number" then
			action"only numbers expected as arguments"
		end
	end
end

local string_char = string.char
function string.char(...)
	assert_nums(...)
	return string_char(...)
end

-- Number-to-string coercion (f.E. `"x" .. 1`) is commonplace and considered fine

-- Override math methods to reject anything that isn't a number
for name, func in pairs(math) do
	if type(func) == "function" then -- don't override math.pi & math.huge
		math[name] = function(...)
			assert_nums(...)
			return func(...)
		end
	end
end

-- `math.random` strictness

-- Signed 32-bit int check
local function int32(num)
	if num ~= num or math.abs(num) == math.huge then
		action"expected 32-bit signed int, got nan or inf"
	elseif num % 1 ~= 0 then
		action"expected 32-bit signed int, got number with fractional part"
	elseif num >= 2^31 then
		action"expected 32-bit signed int, got too large number"
	elseif num < -2^31 then
		action"expected 32-bit signed int, got too small number"
	end
end

-- PUC Lua uses 32-bit ints internally for math.random calls with intervals:
--[[
	For one argument:

	int u = luaL_checkint(L, 1);
	luaL_argcheck(L, 1<=u, 1, "interval is empty");
	lua_pushnumber(L, floor(r*u)+1);  /* int between 1 and `u' */

	For two arguments:

	int l = luaL_checkint(L, 1);
	int u = luaL_checkint(L, 2);
	luaL_argcheck(L, l<=u, 2, "interval is empty");
	lua_pushnumber(L, floor(r*(u-l+1))+l);  /* int between `l' and `u' */
]]
local math_random = math.random
function math.random(...)
	local n = select("#", ...)
	if n == 0 then
		return math_random()
	elseif n == 1 then
		local a = ...
		int32(a)
		return math_random(a)
	elseif n == 2 then
		local a, b = ...
		assert(a <= b, "interval is empty") -- LuaJIT accepts empty intervals, but PUC Lua 5.1 doesn't
		int32(a); int32(b) -- limits must be inside int32 bounds
		int32(b - a + 1) -- range may not overflow
		return math_random(a, b)
	else
		action"expected at most 2 arguments in call to math.random"
	end
end
