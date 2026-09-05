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

ls.add_snippets("markdown", {
	s({
		trig = "mk",
		namr = "Inline Math",
		dscr = "Inline mathmode",
		snippetType = "autosnippet",
	}, {
		t("$"),
		i(1, ""),
		t("$"),
		i(0),
	}),
	s({
		trig = "dm",
		namr = "Display Math",
		dscr = "Display mathmode",
		snippetType = "autosnippet",
	}, {
		t("$$"),
		i(1, ""),
		t("$$"),
		i(0),
	}),
	s({
		trig = "lr{",
		namr = "Set Brackets",
		dscr = "Left and right set brackets",
		snippetType = "autosnippet",
	}, {
		t("\\{"),
		i(1, ""),
		t("\\}"),
		i(0),
	}),
	s({
		trig = "pd",
		namr = "Partial Derivative",
		dscr = "Partial Derivative of of a function",
	}, {
		t("\\frac{\\partial "),
		i(1, "f"),
		t("}{\\partial "),
		i(2, "x"),
		t("}"),
		i(0),
	}),
	s({
		trig = "//",
		regtrig = true,
		wordtrig = false,
		namr = "fraction",
		dscr = "write a fraction",
		snippetType = "autosnippet",
	}, {
		t("\\frac{"),
		i(1, "a"),
		t("}{"),
		i(2, "b"),
		t("}"),
		i(0),
	}),
})
