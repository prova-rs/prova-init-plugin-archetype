# prova-init-plugin-archetype

An [Archetect](https://github.com/archetect/archetect) archetype that scaffolds a
[Prova](https://github.com/prova-rs/prova) **package** that acts as a **plugin** — in Prova a package
is one `prova.toml`-rooted unit that runs its own proofs and can also export a namespace. It is the
sibling of
[`prova-init-default-archetype`](https://github.com/prova-rs/prova-init-default-archetype): the same
package shape, but its `prova.toml` also wears the `[plugin]` hat and it ships an entry module plus a
self-test.

It's wired into prova's built-in `prova init` catalog, so the usual way to use it is:

```bash
prova init plugin
```

(or `archetect render https://github.com/prova-rs/prova-init-plugin-archetype.git` directly).

## Two shapes, one core

Every plugin gets the same **core** — `init.lua`, the dual-role `prova.toml`, a `library/<name>.lua`
LuaCATS stub, and a `proofs/` self-test. What wraps the core depends on where the render runs:

- **Standalone** (the default outside a package): the core plus repo trappings — LICENSE,
  `.gitignore`, `.version-line`, and CI workflows — rendered into `prova-<name>/`, ready to check in
  and release so consumers can pin it as a git dependency.
- **Local** (the default inside an existing prova package): the core alone, rendered into the
  package's `plugin_root` (e.g. `.prova/plugins/<name>/`), where `require("<name>")` reaches it from
  any proof with zero declaration.

`prova init` decides the variant by *where you run it* — it injects the `prova:in-package` switch and
the package's root/`plugin_root` whenever the cwd is inside a package (its generic state injection;
see prova's docs). Pass `-s standalone` to force the repo shape anywhere. The local variant asks only
for a name and description; the GitHub org/author prompts belong to the standalone shape.

```
prova-<name>/                     # standalone            .prova/plugins/<name>/   # local
├── init.lua                      # the namespace         ├── init.lua
├── prova.toml                    # [plugin] + self-suite ├── prova.toml
├── library/<name>.lua            # the LuaCATS stub      ├── library/<name>.lua
├── proofs/<name>_test.lua        # hermetic self-test    ├── proofs/<name>_test.lua
├── README.md                     │                       └── README.md
├── LICENSE  .gitignore  .version-line
└── .github/workflows/            # test.yaml + release.yaml
```

A local plugin is a real package (its `prova.toml` makes it a nested-package boundary, so its proofs
stay out of the owning project's suite — run them from inside its directory). Graduating it to a
shared repo later is `prova init plugin -s standalone` in a fresh directory plus moving the core
across.

## Kind-agnostic by design

The scaffold commits to no particular kind of plugin. `init.lua` returns a namespace with a sample
function and carries commented starting points for the two common shapes:

- **A resource** — an ephemeral container the suite talks to (`prova.containerized`, docker-exec).
- **A topology** — a whole environment `prova up` stands up (`[[plugin.topologies]]`), gated on the
  tools it needs.

Flesh out `init.lua`, prove it in `proofs/`, and for a standalone plugin:

```bash
cd prova-<name>
git init && git add -A && git commit -m "Initial plugin"
gh repo create <org>/prova-<name> --public --source=. --push
```

The **Release** workflow (dispatched manually) tags the next version so consumers can pin
`<org>/prova-<name>@vX.Y.Z`; the **Test** workflow runs the self-test on every push.

## This repo proves itself

`prova` here renders **both** variants into tempdirs, checks the trees, and drives each rendered
plugin's own suite and `prova plugin lint` (see `proofs/render_test.lua`).
