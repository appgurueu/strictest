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

Install & enable `strictest`, then **make sure to optionally depend on it** in `mod.conf`.

## License

Written by Lars Müller and licensed under the MIT license.
