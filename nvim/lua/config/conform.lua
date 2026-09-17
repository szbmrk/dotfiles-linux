local M = {}

local prettier_config_files = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.yml",
	".prettierrc.yaml",
	".prettierrc.json5",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.ts",
	".prettierrc.cts",
	".prettierrc.mts",
	".prettierrc.toml",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
	"prettier.config.cts",
	"prettier.config.mts",
}

local oxfmt_config_files = {
	".oxfmtrc.json",
	".oxfmtrc.jsonc",
	"oxfmt.config.ts",
	"vite.config.ts",
	"vite.config.js",
}

local function package_has_prettier(path)
	local file = io.open(vim.fs.joinpath(path, "package.json"), "r")
	if not file then
		return false
	end

	local content = file:read("*a")
	file:close()

	local ok, package = pcall(vim.json.decode, content)
	return ok and type(package) == "table" and package.prettier ~= nil
end

local function project_has_prettier_config(bufnr)
	return vim.fs.root(vim.api.nvim_buf_get_name(bufnr), function(name, path)
		return vim.tbl_contains(prettier_config_files, name) or (name == "package.json" and package_has_prettier(path))
	end) ~= nil
end

local function project_has_oxfmt_config(bufnr)
	return vim.fs.root(vim.api.nvim_buf_get_name(bufnr), oxfmt_config_files) ~= nil
end

local function prettier_args(_, ctx)
	local args = { "--ignore-path", ".gitignore", "--ignore-path", ".prettierignore" }
	if not project_has_prettier_config(ctx.buf) then
		vim.list_extend(args, { "--tab-width", "4", "--use-tabs" })
	end

	return args
end

local function js_formatter(bufnr)
	if project_has_prettier_config(bufnr) or not project_has_oxfmt_config(bufnr) then
		return { "prettier" }
	end

	return { "oxfmt" }
end

function M.setup()
	local conform = require("conform")

	conform.setup({
		formatters_by_ft = {
			python = { "black", "ruff" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			ocaml = { "ocamlformat" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			cs = { "dotnet-format" },

			html = js_formatter,
			css = js_formatter,
			scss = js_formatter,
			javascript = js_formatter,
			javascriptreact = js_formatter,
			typescript = js_formatter,
			typescriptreact = js_formatter,
			json = js_formatter,
			jsonc = js_formatter,

			php = { "php-cs-fixer" },
			lua = { "stylua" },
		},

		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},

		formatters = {
			prettier = {
				prepend_args = prettier_args,
			},
		},
	})
end

return M
