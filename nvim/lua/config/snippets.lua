local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("javascriptreact", {
	s("rfc", {
		t("export default function "),
		i(1, "Component"),
		t("() {"),
		t({ "", "  return <" }),
		i(0),
		t({ "></>", "}" }),
	}),
})

ls.add_snippets("typescriptreact", {
	s("rfc", {
		t("export default function "),
		i(1, "Component"),
		t("() {"),
		t({ "", "  return <" }),
		i(0),
		t({ "></>", "}" }),
	}),
})

ls.add_snippets("javascriptreact", {
	s("rfca", {
		t("export default async function "),
		i(1, "Component"),
		t("() {"),
		t({ "", "  return <" }),
		i(0),
		t({ "></>", "}" }),
	}),
})

ls.add_snippets("typescriptreact", {
	s("rfca", {
		t("export default async function "),
		i(1, "Component"),
		t("() {"),
		t({ "", "  return <" }),
		i(0),
		t({ "></>", "}" }),
	}),
})
