-- prova-init-plugin-archetype — scaffolds a Prova package that acts as a plugin. It is the `default`
-- archetype's sibling: the same package shape, but its prova.toml also wears the `[plugin]` hat and it
-- ships an entry module (init.lua) plus a self-test. Kind-agnostic — flesh it out into a resource, a
-- topology, or a plain library. Wired into prova's built-in `prova init` catalog as `plugin`.
--
-- Derivations are done in Lua (ATL evaluates `{{ }}` as Lua-ish expressions and has no case filters),
-- so the templates only interpolate plain variables.

local context = Context.new()

context:prompt_text("Plugin name (the require name, lowercase — e.g. 'parallels'):", "name")
context:prompt_text("One-line description:", "description", { default = "A Prova plugin" })
context:prompt_text("GitHub org/owner (for the consumer-pin example + README):", "org",
    { default = "prova-rs" })
context:prompt_text("Author (for LICENSE / README):", "author", { default = "Prova" })

-- The repo/dir name follows the ecosystem convention `prova-<name>`.
context:set("repo_name", "prova-" .. tostring(context:get("name")))

directory.render("contents", context, { if_exists = Existing.Overwrite })
