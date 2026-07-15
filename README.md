# prova-plugin-archetype

An [Archetect](https://github.com/archetect/archetect) archetype that generates a
[Prova](https://github.com/prova-rs/prova) resource plugin — a docker-exec plugin (zero native code)
with a README, the plugin script, `prova-plugin.toml` (manifest), `prova.toml` (self-test), a starter
test, and CI to **test** and **release** it.

## Generate a plugin

```bash
archetect render https://github.com/prova-rs/prova-plugin-archetype.git
```

You'll be prompted for the plugin name, description, category, Docker image/tag, port, URL scheme, and
the client CLI in the image. The result is a `prova-<name>/` directory ready to author:

```
prova-<name>/
├── <name>.lua                    # the plugin (a docker-exec skeleton via prova.containerized)
├── prova-plugin.toml             # manifest: entry, requires.prova, metadata
├── prova.toml                    # self-test manifest
├── tests/<name>_test.lua         # starter test
├── README.md
├── LICENSE
├── .version-line
└── .github/workflows/
    ├── test.yaml                 # CI: run the self-test + `prova plugin lint`
    └── release.yaml              # CI: tag + GitHub release (repository-release)
```

Then implement the client methods in `<name>.lua`, and:

```bash
cd prova-<name>
git init && git add -A && git commit -m "Initial plugin"
gh repo create prova-rs/prova-<name> --public --source=. --push
```

The **Release** workflow (dispatched manually) tags the next version so consumers can pin
`prova-rs/prova-<name>@vX.Y.Z`; the **Test** workflow runs the self-test on every push.
