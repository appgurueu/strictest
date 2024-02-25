-- Minetest strictness

local action = ...

-- Helpers

local function deprecated(method_table, prefix, deprecations)
	for method_name, recommended in pairs(deprecations) do
		local original_method = method_table[method_name]
		method_table[method_name] = function(...)
			action(("deprecated, use `%s%s` instead"):format(prefix, recommended))
			return original_method(...)
		end
	end
end

local function only_def_expected(method_table, method_name, def_name)
	local method = method_table[method_name]
	method_table[method_name] = function(...)
		if select("#", ...) ~= 1 then
			action(("only %s expected"):format(def_name))
		end
		return method(...)
	end
end

-- Enforce deprecation of indexing `minetest` with `env` as key

assert(not getmetatable(minetest))
setmetatable(minetest, {__index = function(_, key)
	if key == "env" then
		action"`minetest.env.*` is deprecated, use just `minetest.*` instead"
	end
	return nil
end})

-- Throw when calling player-only methods on entities or calling entity-only methods on players

local ObjRef
local player_only = {
	"get_player_name",
	"get_player_velocity",
	"add_player_velocity",
	"get_look_dir",
	"get_look_vertical",
	"get_look_horizontal",
	"set_look_vertical",
	"set_look_horizontal",
	"get_look_pitch",
	"get_look_yaw",
	"set_look_pitch",
	"set_look_yaw",
	"get_breath",
	"set_breath",
	"set_fov",
	"get_fov",
	"set_attribute",
	"get_attribute",
	"get_meta",
	"set_inventory_formspec",
	"get_inventory_formspec",
	"set_formspec_prepend",
	"get_formspec_prepend",
	"get_player_control",
	"get_player_control_bits",
	"set_physics_override",
	"get_physics_override",
	"hud_add",
	"hud_remove",
	"hud_change",
	"hud_get",
	"hud_set_flags",
	"hud_get_flags",
	"hud_set_hotbar_itemcount",
	"hud_set_hotbar_image",
	"hud_set_hotbar_selected_image",
	"set_minimap_modes",
	"set_sky",
	"set_sky",
	"set_sky",
	"get_sky",
	"set_sky",
	"get_sky_color",
	"get_sky",
	"set_sun",
	"get_sun",
	"set_moon",
	"get_moon",
	"set_stars",
	"get_stars",
	"set_clouds",
	"get_clouds",
	"override_day_night_ratio",
	"get_day_night_ratio",
	"set_local_animation",
	"get_local_animation",
	"set_eye_offset",
	"get_eye_offset",
	"send_mapblock",
	"set_lighting",
	"get_lighting",
	"respawn",
}
local entity_only = {
	"remove",
	"set_velocity",
	"set_acceleration",
	"get_acceleration",
	"set_rotation",
	"get_rotation",
	"set_yaw",
	"get_yaw",
	"set_texture_mod",
	"get_texture_mod",
	"set_sprite",
	"get_entity_name",
	"get_luaentity",
}
minetest.register_on_joinplayer(function(player)
	-- TODO implement `textures = {itemname}` deprecation for `wielditem` drawtype
	if ObjRef then return end
	ObjRef = getmetatable(player)
	-- (get|add)_player_velocity are deliberately not included here as their deprecation is still somewhat recent
	deprecated(ObjRef, "player:", {
		get_look_pitch = "get_look_vertical()",
		set_look_pitch = "set_look_vertical(radians)",
		get_look_yaw = "get_look_horizontal()",
		set_look_yaw = "set_look_horizontal(radians)",
		get_attribute = "get_meta()",
		set_attribute = "get_meta()",
		get_sky_color = "get_sky(as_table)"
	})
	local ObjRef_set_sky = ObjRef.set_sky
	function ObjRef:set_sky(...)
		if select("#", ...) ~= 1 then
			action("wrong number of arguments, expected exactly 1")
		end
		return ObjRef_set_sky(self, ...)
	end
	local ObjRef_get_sky = ObjRef.get_sky
	function ObjRef:get_sky(as_table)
		if not as_table then
			action"deprecated call `player:get_sky(false or nil)`, use `player:get_sky(true)` instead"
		end
		return ObjRef_get_sky(self, deprecated)
	end
	for _, method in pairs(player_only) do
		local original_method = ObjRef[method]
		ObjRef[method] = function(self, ...)
			if self:is_player() then
				return original_method(self, ...)
			end
			action"player-only method called on entity"
		end
	end
	function ObjRef.get_entity_name()
		action"`object:get_entity_name()` is deprecated, use `object:get_luaentity().name` instead"
	end
	for _, method in pairs(entity_only) do
		local original_method = ObjRef[method]
		ObjRef[method] = function(self, ...)
			if self:is_player() then
				action"entity-only method called on player"
			end
			return original_method(self, ...)
		end
	end
end)

local vector_new = vector.new
function vector.new(...)
	local n_args = select("#", ...)
	if n_args == 1 then
		if type(...) ~= "number" then
			action"number expected"
		end
	elseif n_args == 3 then
		for i = 1, 3 do
			if type(select(i, ...)) ~= "number" then
				action"3 numbers expected"
			end
		end
	else
		action"1 or 3 args expected"
	end
	return vector_new(...)
end

-- Schur product/quotient deprecation is not implemented for good reason

only_def_expected(_G, "PerlinNoise", "noiseparams")

only_def_expected(minetest, "get_perlin", "noiseparams")

only_def_expected(minetest, "add_particle", "particle def")

only_def_expected(minetest, "add_particlespawner", "particle spawner def")


deprecated(minetest, "minetest.", {
	register_on_auth_fail = "register_on_authplayer(name, ip, is_success)",
	get_mapgen_params = "get_mapgen_setting(name)",
	set_mapgen_params = "set_mapgen_setting(name, value, override)",
	item_place_object = "add_item",
	get_node_group = "get_item_group(name, group)"
})

local ItemStackMT = getmetatable(ItemStack())

deprecated(ItemStackMT, "stack:", {
	get_metadata = "get_meta()",
	set_metadata = "get_meta()",
})

local set_player_privs = minetest.set_player_privs
function minetest.set_player_privs(name, privs)
	assert(type(privs) == "table", "privs should be a table")
	for _, v in pairs(privs) do
		if v == false then
			action"`false` value in `privs`, this is almost certainly a bug granting a privilege rather than revoking it"
		elseif v ~= true then
			action"non-`true` value in `privs` set" -- code smell
		end
	end
	return set_player_privs(name, privs)
end

--[[
	TODO: implement the following deprecations:
	- Tile def `image` field (replaced by `name`)
	- HTTPRequest `post_data` field (replaced by `data`)
	- Item filtering by string matching (groups should be used instead)
	- The mapgen alias "mapgen_lava_source" (replaced by mapgen liquid params)
]]
