-- Self-test for prova-{{ name }}: provision the resource and assert its endpoint. Requires docker;
-- skips gracefully otherwise. Extend with real round-trips as you implement the client methods.

local resource = prova.fixture("{{ name }}", Scope.File, function(ctx)
  return require("{{ name }}").container(ctx)
end)

prova.group("{{ name }}", { requires = { "docker" } }, function(g)
  g:test("provisions and exposes an endpoint for the app under test", function(t)
    t:expect(t:use(resource).url):matches("^{{ scheme }}://")
  end)

  -- TODO: assert a real round-trip once the client methods exist, e.g.:
  -- g:test("round-trips", function(t)
  --   local c = t:use(resource).client
  --   c:put("k", "v")
  --   t:expect(c:get("k")):equals("v")
  -- end)
end)
