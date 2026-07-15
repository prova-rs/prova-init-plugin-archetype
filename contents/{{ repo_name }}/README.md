# prova-{{ name }}

A {{ category }} resource plugin for [Prova](https://github.com/prova-rs/prova) — {{ description }}.

A **docker-exec** plugin: zero native code. It provisions an ephemeral `{{ image }}` container, waits
for readiness, and drives the CLI already in the image (`{{ cli }}`) — all through Prova's
`prova.containerized` + `container:run` SDK.

## Use it

Declare the plugin in your `prova.toml`:

```toml
[plugins]
{{ name }} = "prova-rs/prova-{{ name }}@v1"   # org/repo shorthand (fetched, pinned, cached)
```

Then in a test:

```lua
local {{ name }} = require("{{ name }}")

local resource = prova.fixture("{{ name }}", Scope.File, function(ctx)
  return {{ name }}.container(ctx)          -- provisions, waits, attaches a client, ties teardown
end)

prova.group("example", { requires = { "docker" } }, function(g)
  g:test("does the thing", function(t)
    local r = t:use(resource)
    -- r.client:...   -- drive it
    t:expect(r.url):matches("^{{ scheme }}://")
  end)
end)
```

Hand `r.url` (a `{{ scheme }}://…` endpoint) to the app under test via its env, and assert the effect
either through the app's API (black-box) or directly with the client here.

## API

`{{ name }}.container(ctx, opts?)` → `{ client, url, container }`

- `url` — `{{ scheme }}://127.0.0.1:<port>`, the endpoint for the app under test.
- `container` — the Docker handle (`:host_port`, `:run`, `:logs`, …).
- `client` — the docker-exec client (implement its methods in `{{ name }}.lua`).

`opts`: `image`, `tag` (default `{{ tag }}`), `timeout` — the `prova.containerized` options.

## Requirements

Docker at test time. Gate tests with `requires = { "docker" }` so they skip cleanly where the daemon
is absent.

## Develop

```bash
prova                       # runs tests/ against ./{{ name }}.lua (needs Docker)
prova plugin lint {{ name }}.lua
```

MIT licensed.
