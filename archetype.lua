-- Prova Plugin Archetype — generates a Prova resource plugin repo (docker-exec, zero native code):
-- a README, the plugin script, prova-plugin.toml (manifest), prova.toml (self-test), a starter test,
-- and CI to test + release it. Author it, then `git init && git remote add origin … && git push`.
--
-- Derivations are done in Lua (ATL evaluates `{{ }}` as Lua-ish expressions and has no case filters),
-- so the templates only interpolate plain variables the same way the homebrew-tap archetype does.

local context = Context.new()

context:prompt_text("Plugin name (the require name, lowercase — e.g. 'rabbitmq'):", "name")
context:prompt_text("One-line description:", "description",
    { default = "A Prova resource plugin" })
context:prompt_select("Resource category:", "category",
    { "queue", "cache", "database", "blob", "stream", "other" },
    { default = "other" })
context:prompt_text("Docker image (e.g. 'rabbitmq'):", "image")
context:prompt_text("Image tag (e.g. '3-management', '7-alpine', 'latest'):", "tag",
    { default = "latest" })
context:prompt_int("Primary port — readiness + url (e.g. 5672):", "port")
context:prompt_text("URL scheme for the app under test (e.g. 'amqp', 'redis', 'postgres', 'http'):",
    "scheme", { default = "tcp" })
context:prompt_text("Client CLI already in the image (e.g. 'redis-cli', 'rabbitmqadmin'):", "cli",
    { default = "sh" })
context:prompt_text("Author (for LICENSE / README):", "author", { default = "Prova" })

-- The repo/dir name follows the ecosystem convention `prova-<name>`.
context:set("repo_name", "prova-" .. tostring(context:get("name")))

directory.render("contents", context, { if_exists = Existing.Overwrite })
