-- The proof that `prova init plugin` produces a *working* plugin in BOTH its shapes — standalone
-- (core + repo trappings, a repo-ready directory) and local (core only, under the owning package's
-- plugin_root). Black-box throughout: render into a tempdir, inspect the tree, then drive the
-- rendered plugin's own `prova` and `prova plugin lint` exactly as its author would.
--
-- The local variant is exercised by supplying the same switch + answers `prova init` injects
-- (`prova:in-package`, `prova_package_root`, `prova_plugin_root`) — prova's own tests prove the
-- injection itself; this proof owns what the archetype DOES with it.
--
-- The nested run uses `$PROVA_BIN` if set (so a dev can pin the binary under test), else `prova` on
-- PATH — the version a real user would have installed.

local ARCHETYPE = prova.root -- this repo *is* the archetype under test
local PROVA = os.getenv("PROVA_BIN") or "prova"

local standalone = prova.fixture("standalone", Scope.File, function(ctx)
	return archetect.render({
		source = ARCHETYPE,
		answers = { name = "acme", description = "A test plugin" },
		defaults = true, -- org/author take their prompt defaults
		destination = ctx:tempdir(),
	})
end)

local localized = prova.fixture("localized", Scope.File, function(ctx)
	-- The destination stands in for an owning package's root; the switch + answers are exactly what
	-- `prova init` injects when the cwd is inside a package with a declared plugin_root.
	return archetect.render({
		source = ARCHETYPE,
		answers = {
			name = "acme",
			description = "A test plugin",
			prova_package_root = ".",
			prova_plugin_root = ".prova/plugins",
		},
		switches = { "prova:in-package" },
		destination = ctx:tempdir(),
	})
end)

-- Layout + no un-rendered `{{ }}` markers, via the declarative harness on the existing renders.
archetect.verify(standalone, {
	name = "plugin-standalone",
	expected_files = {
		"prova-acme/prova.toml",
		"prova-acme/init.lua",
		"prova-acme/library/acme.lua",
		"prova-acme/proofs/acme_test.lua",
		"prova-acme/README.md",
		"prova-acme/LICENSE",
		"prova-acme/.gitignore",
		"prova-acme/.version-line",
		"prova-acme/.github/workflows/test.yaml",
		"prova-acme/.github/workflows/release.yaml",
	},
})

archetect.verify(localized, {
	name = "plugin-local",
	expected_files = {
		".prova/plugins/acme/prova.toml",
		".prova/plugins/acme/init.lua",
		".prova/plugins/acme/library/acme.lua",
		".prova/plugins/acme/proofs/acme_test.lua",
		".prova/plugins/acme/README.md",
	},
})

--- Run `cmd` in `dir` and return the completed shell result.
local function run_in(dir, cmd)
	return shell.run(cmd, { cwd = dir })
end

prova.describe("the standalone render", function()
	prova.test("keeps the repo trappings out of the core", function(t)
		local tree = t:use(standalone)
		local readme = tree:file("prova-acme/README.md"):read()
		t:expect(readme, "standalone README must carry the consumer pin"):contains("tag = \"v1\"")
	end)

	prova.test("self-test runs green and the plugin lints clean", function(t)
		local tree = t:use(standalone)
		local dir = tree:dir("prova-acme").path
		local r = run_in(dir, PROVA)
		t:expect(r.code, "prova exited non-zero:\n" .. r.stderr .. r.stdout):equals(0)
		local lint = run_in(dir, PROVA .. " plugin lint init.lua")
		t:expect(lint.code, "lint failed:\n" .. lint.stderr .. lint.stdout):equals(0)
	end)
end)

-- A per-test scratch dir for renders that are themselves the assertion (e.g. the error case).
local scratch = prova.fixture("scratch", Scope.Test, function(ctx)
	return { path = ctx:tempdir() }
end)

prova.describe("the local render", function()
	prova.test("carries no repo trappings", function(t)
		local tree = t:use(localized)
		t:expect(tree:file(".prova/plugins/acme/LICENSE")):never():exists()
		t:expect(tree:file(".prova/plugins/acme/.version-line")):never():exists()
		t:expect(tree:dir(".prova/plugins/acme/.github")):never():exists()
		local readme = tree:file(".prova/plugins/acme/README.md"):read()
		t:expect(readme, "local README must not sell a git pin"):never():contains("tag = \"v1\"")
	end)

	prova.test("self-test runs green in place", function(t)
		local tree = t:use(localized)
		local dir = tree:dir(".prova/plugins/acme").path
		local r = run_in(dir, PROVA)
		t:expect(r.code, "prova exited non-zero:\n" .. r.stderr .. r.stdout):equals(0)
	end)

	prova.test("without a plugin_root the render fails with guidance", function(t)
		local dest = t:use(scratch).path
		local ok, err = pcall(function()
			return archetect.render({
				source = ARCHETYPE,
				answers = { name = "acme", description = "A test plugin" },
				switches = { "prova:in-package" }, -- in a package, but no plugin_root answer
				destination = dest,
			})
		end)
		t:expect(ok, "a local render without plugin_root must error"):equals(false)
		t:expect(tostring(err)):contains("plugin_root")
	end)
end)
