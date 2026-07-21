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

You're prompted for the plugin name, description, GitHub org, and author. The result is a
`prova-<name>/` directory:

```
prova-<name>/
├── init.lua                      # the plugin: returns a namespace table (a sample greet() to replace)
├── prova.toml                    # one manifest, two hats: [plugin] contract + [run] self-test
├── tests/<name>_test.lua         # hermetic self-test (require the plugin, assert)
├── README.md
├── LICENSE
├── .version-line
└── .github/workflows/
    ├── test.yaml                 # CI: run the self-test + `prova plugin lint`
    └── release.yaml              # CI: tag + GitHub release (repository-release)
```

## Kind-agnostic by design

The scaffold commits to no particular kind of plugin. `init.lua` returns a namespace with a sample
function and carries commented starting points for the two common shapes:

- **A resource** — an ephemeral container the suite talks to (`prova.containerized`, docker-exec).
- **A topology** — a whole environment `prova up` stands up (`[[plugin.topologies]]`), gated on the
  tools it needs.

Flesh out `init.lua`, prove it in `tests/`, then:

```bash
cd prova-<name>
git init && git add -A && git commit -m "Initial plugin"
gh repo create <org>/prova-<name> --public --source=. --push
```

The **Release** workflow (dispatched manually) tags the next version so consumers can pin
`<org>/prova-<name>@vX.Y.Z`; the **Test** workflow runs the self-test on every push.
