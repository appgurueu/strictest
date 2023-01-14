# Strictest

## Runtime Strictness for Minetest Mods

*Strictest* consists of two components:

* Lua strictness:
  * Disallows string indexing misses: `("...").something` will throw an error if there is no `string.something` to prevent accidental use of strings where tables are expected
  * Disables string - number coercion where possible
* Minetest strictness: Disallows usage of deprecated APIs & using entity-only or player-only methods on the wrong type of object.

Particularly useful when writing new mods that don't target older Minetest versions.

## Configuration

`strictest.action` can be set to either `error` or `log`:

* `error`: Immediately throw an error on strictness violations.
* `log`: Merely log the error (including a stacktrace).

Potentially partially redundant with the `deprecated_lua_api_handling` setting.

## Usage

Install & enable `strictest`, then **make sure to optionally depend on it** in `mod.conf`.

Note that runtime strictness always comes at a cost. Running `strictest` on production servers under heavy load is thus not advisable.

---

Links: [GitHub](https://github.com/appgurueu/strictest), [ContentDB](https://content.minetest.net/packages/LMD/strictest/), [Minetest Forums](https://forum.minetest.net/viewtopic.php?t=28327)

License: Written by Lars Müller and licensed under the MIT license.
