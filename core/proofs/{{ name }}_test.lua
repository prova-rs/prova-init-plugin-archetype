-- Self-test for prova-{{ name }}. `require("{{ name }}")` resolves to THIS plugin — prova.toml
-- declares it as a path plugin at "." — so the suite proves the plugin exactly the way a consumer
-- uses it. Hermetic by default (no docker, no network): the bar the plugin must always clear.
--
-- As you grow the plugin, gate the tests that touch a real resource with `{ requires = { "docker" } }`
-- (or the tool your topology needs), so they skip cleanly where it's absent instead of failing.
local {{ name }} = require("{{ name }}")

prova.test("greets by name", function(t)
  t:expect({{ name }}.greet("world")):equals("hello, world")
end)
