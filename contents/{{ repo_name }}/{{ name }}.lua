-- prova-{{ name }} — a {{ category }} resource plugin for Prova ({{ description }}). A docker-exec
-- plugin: zero native code. It provisions an ephemeral container via `prova.containerized`, waits for
-- readiness, and drives the CLI already in the image via `container:run` — the whole exec-CLI SDK.
--
--   local {{ name }} = require("{{ name }}")
--   local r = {{ name }}.container(ctx)      -- { client, url, container }
--   -- r.client:...   -- drive it (see the methods below)
--   -- r.url          -- the endpoint to hand the app under test

-- Drive the client CLI inside the container. `container:run{argv}` runs it directly (no shell, no
-- quoting) and returns stdout, raising on a non-zero exit. Use `prova.parse.*` on the output:
--   prova.parse.lines(out)          line-oriented CLIs
--   prova.parse.rows(out, sep)      delimited output → rows of columns
--   prova.parse.table(out, sep)     first line is a header → rows keyed by column name
--   prova.parse.json(out)           JSON (incl. one-object-per-line `--json` via lines + json)
local function make_client(container)
  local function cli(...)
    return container:run({ "{{ cli }}", ... })
  end

  local client = {}

  -- TODO: implement the plugin's methods with `cli(...)`. An example placeholder:
  function client:version()
    return cli("--version")
  end

  -- Present for ctx:manage symmetry; the container teardown reaps everything, so this is a no-op.
  function client:close() end

  return client
end

local {{ name }} = prova.containerized{
  name = "{{ name }}",
  image = "{{ image }}", tag = "{{ tag }}",
  port = {{ port }},
  timeout = "60s",
  url = function(host_port)
    return "{{ scheme }}://127.0.0.1:" .. host_port
  end,
  -- Readiness is the container's port wait (above). For a stricter gate, run a real probe here and
  -- raise until it succeeds — prova.retry loops the factory until it holds:
  --   client:version()   -- or a real "is it ready?" call
  client = function(_url, _opts, container)
    return make_client(container)
  end,
}

return {{ name }}
