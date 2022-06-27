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

-- Completely disable string-to-number coercion

local arithmetic_ops = {"add", "sub", "mul", "div", "mod", "pow", "unm"}
for _, op in pairs(arithmetic_ops) do
	str_mt["__" .. op] = function()
		action"attempt to perform arithmetic on a string value"
	end
end

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
