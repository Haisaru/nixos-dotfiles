local ls = require("luasnip")

local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet

--[[
ls.add_snippets("cpp", {
  s({
    trig = "main",
    descr = "boilerplate",
    priority = 0,
  }, {
    t({
      "#include <algorithm>",
      "#include <array>",
      "#include <bitset>",
      "#include <cassert>",
      "#include <chrono>",
      "#include <climits>",
      "#include <cmath>",
      "#include <complex>",
      "#include <cstring>",
      "#include <functional>",
      "#include <iomanip>",
      "#include <iostream>",
      "#include <map>",
      "#include <numeric>",
      "#include <queue>",
      "#include <random>",
      "#include <set>",
      "#include <vector>",
      "using i64 = long long;",
      "",
      "void solve(){",
      "",
      "  ",
    }),
    i(0, { "" }),
    t({
      "",
      "}",
      "int main(){",
      "",
      "  std::ios_base::sync_with_stdio(false), std::cin.tie(nullptr);",
      "  int tt;",
      "  std::cin >> tt;",
      "  while(tt--){",
      "   solve();",
      "  }",
      "",
      "",
      "return 0;",
      "}",
    }),
  }),
})
--]]
