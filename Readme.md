# Strictest

## Runtime Strictness for Minetest Mods

*Strictest* consists of two components:

* Lua strictness: Will disallow string indexing and string - number coercion.
* Minetest strictness: Disallows usage of deprecated APIs & using entity-only or player-only methods on the wrong type of object.

Particularly useful when writing new mods that don't target older Minetest versions.

## Configuration

`strictest.action` can be set to either `error` or `log`:

* `error`: Immediately throw an error on strictness violations.
* `log`: Merely log the error (including a stacktrace).

Potentially partially redundant with the `deprecated_lua_api_handling` setting.

## Usage

Simply install, enable & configure the mod and you're good to go.

### `mod.conf`

Consider optionally depending on `__strictest` to ensure that runtime strictness is available at load-time.

Currently this isn't necessary since the leading double underscores (`__`) already ensure that `__strictest` loads first,
but it might become necessary in the future if mod load order is changed to not use reverse alphabetical order.

## License

Written by Lars Müller and licensed under the MIT license.
