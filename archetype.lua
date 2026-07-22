-- prova-init-plugin-archetype — scaffolds a Prova package that acts as a plugin, in one of two
-- shapes sharing a single core (init.lua + dual-role prova.toml + library stub + self-test):
--
--   • STANDALONE (its own repo): core + repo trappings (LICENSE, CI workflows, .gitignore,
--     .version-line), rendered into `prova-<name>/`. Consumers pin it as a git dependency.
--   • LOCAL (inside an existing package): core only, rendered into the package's `plugin_root`;
--     `require("<name>")` reaches it with zero declaration.
--
-- The variant is decided by WHERE the render runs: `prova init` injects the `prova:in-package`
-- switch and the `prova_package_root` / `prova_plugin_root` answers whenever the cwd is inside a
-- prova package (see prova's catalog docs on state injection) — in-package renders default to the
-- local shape. Pass `-s standalone` to force the repo shape anywhere.
--
-- Derivations are done in Lua (ATL evaluates `{{ }}` as Lua-ish expressions and has no case filters),
-- so the templates only interpolate plain variables.

local context = Context.new()

local in_package = archetype.switches.is_enabled("prova:in-package")
local standalone = archetype.switches.is_enabled("standalone") or not in_package

context:prompt_text("Plugin name (the require name, lowercase — e.g. 'parallels'):", "name")
context:prompt_text("One-line description:", "description", { default = "A Prova plugin" })
if standalone then
  context:prompt_text("GitHub org/owner (for the consumer-pin example + README):", "org",
      { default = "prova-rs" })
  context:prompt_text("Author (for LICENSE / README):", "author", { default = "Prova" })
end

-- Template-visible facts. The repo/dir name follows the ecosystem convention `prova-<name>`.
context:set("standalone", standalone)
local name = tostring(context:get("name"))
context:set("repo_name", "prova-" .. name)

local destination
if standalone then
  destination = "prova-" .. name
else
  local plugin_root = context:get("prova_plugin_root")
  if plugin_root == nil then
    error("this package declares no plugin_root — add `plugin_root = \".prova/plugins\"` to [run] "
        .. "in its manifest, or pass `-s standalone` to scaffold a standalone plugin repo instead")
  end
  local package_root = tostring(context:get("prova_package_root") or ".")
  destination = package_root .. "/" .. tostring(plugin_root) .. "/" .. name
end

directory.render("core", context, { destination = destination, if_exists = Existing.Overwrite })
if standalone then
  directory.render("repo", context, { destination = destination, if_exists = Existing.Overwrite })
end

-- The announcement. Column width tracks the name-bearing stub path so the layout survives any name.
local stub = "library/" .. name .. ".lua"
local width = math.max(#stub, #"init.lua") + 3
local function row(path, note)
  output.print(string.format("  %-" .. width .. "s%s", path, note))
end

output.print("")
if standalone then
  output.print("Standalone plugin created in " .. destination .. "/:")
  row("init.lua", "the namespace — author the plugin's API here")
  row(stub, "the LuaCATS stub consumers' editors read")
  row("proofs/", "the self-test; CI runs it via the Test workflow")
  output.print("")
  output.print("Run `prova` inside it to execute the self-test.")
else
  output.print("Local plugin created in " .. destination .. "/:")
  row("init.lua", "the namespace — `require(\"" .. name .. "\")` from any proof")
  row(stub, "the LuaCATS stub your editor reads")
  row("proofs/", "its self-test (run `prova` inside the plugin's directory)")
end
