# prova-{{ name }}

A plugin for [Prova](https://github.com/prova-rs/prova) — {{ description }}.

In Prova a **package** is one `prova.toml`-rooted unit; it can act as a **plugin** (exports a
namespace) and a **suite** (runs its own proofs). This {% if standalone %}repo{% else %}directory{% endif %} is such a package — author the plugin in
`init.lua`, prove it in `proofs/`, ship both.

## Use it

{% if standalone %}
Declare it in your project's `prova.toml`, pinned to a released tag:

```toml
[plugins]
{{ name }} = { git = "https://github.com/{{ org }}/prova-{{ name }}", tag = "v1" }
```

Then `require` it in a test:
{% else %}
This directory lives under the owning project's `plugin_root`, so there is nothing to declare —
`require("{{ name }}")` resolves from any proof in the project:
{% endif %}

```lua
local {{ name }} = require("{{ name }}")

prova.test("does the thing", function(t)
  t:expect({{ name }}.greet("world")):equals("hello, world")
end)
```

## What to build

The generated `init.lua` returns a table whose fields are the API. Two common shapes it can grow into:

- **A resource** — an ephemeral container the suite talks to (`prova.containerized`, docker-exec, zero
  native code); a consumer does `require("{{ name }}").container(ctx)`.
- **A topology** — a whole environment `prova up` can stand up, advertised via `[[plugin.topologies]]`
  in `prova.toml` and gated on the tools it needs.

`init.lua` carries commented starting points for both.

## Develop

```bash
prova                        # run the self-test in proofs/ (hermetic by default)
prova plugin lint init.lua   # check the plugin conforms to the namespacing grammar
```

{% if standalone %}
The **Test** workflow runs the self-test on every push; the **Release** workflow (dispatched
manually) tags the next version so consumers can pin `{{ org }}/prova-{{ name }}@vX.Y.Z`.

MIT licensed.
{% else %}
Run both from inside this directory — the plugin is its own package, so its proofs stay separate
from the owning project's suite. Graduating it to a shared repo later is `prova init plugin -s
standalone` in a fresh directory plus moving `init.lua`, `library/`, and `proofs/` across.
{% endif %}
