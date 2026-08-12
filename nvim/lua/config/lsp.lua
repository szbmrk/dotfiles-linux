local function get_python_path()
	local uv_venv = os.getenv("VIRTUAL_ENV")
	if uv_venv then
		return uv_venv .. "/bin/python"
	end
	return "/usr/bin/python"
end

local lsp_configs = {
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
		settings = {
			python = {
				pythonPath = get_python_path(),
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},
	gopls = {
		cmd = { "gopls" },
		filetypes = { "go" },
		root_markers = { "go.mod", ".git" },
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", ".git" },
	},
	clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp", "objc", "objcpp" },
		root_markers = { "compile_commands.json", ".git", ".clang-format" },
	},
	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { "package.json", ".git" },
	},
	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { ".git" },
	},
	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json" },
		root_markers = { ".git" },
	},
	tsserver = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", ".git" },
	},
	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"javascript",
			"javascriptreact",
			"typescriptreact",
		},
		root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json", ".git" },
	},
	prismals = {
		cmd = { "prisma-language-server", "--stdio" },
		filetypes = { "prisma" },
		root_markers = { "schema.prisma", ".git" },
		settings = {
			prisma = {
				enableDiagnostics = true,
			},
		},
	},
	phpactor = {
		cmd = { "phpactor", "language-server" },
		filetypes = { "php" },
		root_markers = { "composer.json", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".git" },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						vim.api.nvim_get_runtime_file("", true),
						"${3rd}/love2d/library",
						"/usr/share/hypr/stubs",
					},
					checkThirdParty = true,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
	qmlls = {
		cmd = { vim.env.QT_BIN_DIR ~= nil and vim.fs.joinpath(vim.env.QT_BIN_DIR, "qmlls") or "qmlls" },
		filetypes = { "qml", "qt" },
		root_markers = { ".git" },
	},
	omnisharp = {
		cmd = { "/home/szobo/.local/bin/omnisharp/run", "--languageserver" },
		filetypes = { "cs", "vb" },
		root_markers = { "project.json", ".sln", ".csproj", ".git" },
		-- settings = {
		-- 	FormattingOptions = {
		-- 		EnableEditorConfigSupport = true,
		-- 	},
		-- 	MsBuild = {
		-- 		LoadProjectsOnDemand = false,
		-- 	},
		-- 	RoslynExtensionsOptions = {
		-- 		EnableAnalyzersSupport = true,
		-- 		EnableImportCompletion = true,
		-- 		LocationPaths = {},
		-- 	},
		-- 	Sdk = {
		-- 		IncludePrereleases = true,
		-- 	},
		-- },
	},
	kotlin_language_server = {
		cmd = { "kotlin-language-server" },
		filetypes = { "kotlin" },
		root_markers = {
			"settings.gradle",
			"settings.gradle.kts",
			"build.gradle",
			"build.gradle.kts",
			"pom.xml",
			".git",
		},
	},
}

for server, config in pairs(lsp_configs) do
	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf)
		end
	end,
})
