-- TODO arity checks (does this evolve into a type checker?)

local action_setting = minetest.settings:get("strictest.action") or "log"

local action
if action_setting == "error" then
	function action(message)
		error(message, 2)
	end
else
	assert(action_setting == "log", "invalid value for setting `strictness.action`: expected `error` or `log`")
	function action(message)
		minetest.log("error", debug.traceback(message, 2))
	end
end

local function load_strictness(name)
	return assert(loadfile(minetest.get_modpath(minetest.get_current_modname()) .. ("/%s.lua"):format(name)))(action)
end

load_strictness"lua"
load_strictness"minetest"
