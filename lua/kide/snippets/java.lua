local ls = require("luasnip")

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

ls.add_snippets("java", {
  s("sout", {
    t({ "System.out.println(" }),
    i(1),
    t({ ");" }),
  }),
  s("main", {
    t({ "public static void main(String[] args) {" }),
    t({ "", "\t" }),
    i(0),
    t({ "", "}" }),
  }),
  s("field", {
    c(1, {
      t("private"),
      t("public"),
      t("protected"),
    }),
    t(" "),
    c(2, {
      t(""),
      t({ "static " }),
      t({ "final static " }),
    }),
    i(3, "String"),
    t(" "),
    i(4, "name"),
    t({ ";" }),
  }),
  s("fn", {
    c(1, {
      t("public"),
      t("protected"),
      t("private"),
    }),
    t(" "),
    c(2, {
      t(""),
      t({ "static " }),
      t({ "final static " }),
    }),
    i(3, "void"),
    t(" "),
    i(4, "name"),
    t("()"),
    c(5, {
      t(""),
      sn(nil, {
        t({ " throws " }),
        i(1, "Exception"),
      }),
    }),
    t(" {"),
    t({ "", "\t" }),
    i(0),
    t({ "", "}" }),
  }),
})
