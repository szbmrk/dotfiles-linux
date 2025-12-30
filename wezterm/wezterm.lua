local wezterm = require 'wezterm'
-- local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').main

return {
    default_prog = { '/usr/bin/fish' },

    term = "xterm-256color",

    -- Font and color scheme
    font = wezterm.font("JetBrainsMono Nerd Font Propo"),
    harfbuzz_features = { 'calt = 0', 'clig = 0', 'liga = 0' },
    font_size = 14,
    -- color_scheme = "Rosé Pine",
    color_scheme = "Catppuccin Mocha",

    colors = {
        tab_bar = {
            inactive_tab_edge = '#313244',

            active_tab = {
                bg_color = '#89b4fa',
                fg_color = '#11111b',
            },

            inactive_tab = {
                bg_color = '#313244',
                fg_color = '#cdd6f4',
            },
        },
    },

    window_frame = {
        active_titlebar_bg = '#1e1e2e',
        inactive_titlebar_bg = '#1e1e2e',
    },

    -- colors = theme.colors(),
    -- window_frame = theme.window_frame(),

    hide_tab_bar_if_only_one_tab = true,
    window_background_opacity = 0.9,
    automatically_reload_config = true,

    -- Key bindings
    keys = { -- Custom bindings
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = wezterm.action.CopyTo "ClipboardAndPrimarySelection"
    }, {
        key = "v",
        mods = "CTRL",
        action = wezterm.action.PasteFrom "Clipboard"
    }, {
        key = "f",
        mods = "CTRL|SHIFT",
        action = wezterm.action.Search "CurrentSelectionOrEmptyString"
    }, {
        key = "w",
        mods = "ALT",
        action = wezterm.action.CloseCurrentPane {
            confirm = true
        }
    }, {
        key = "w",
        mods = "CTRL",
        action = wezterm.action.CloseCurrentPane {
            confirm = true
        }
    }, {
        key = "t",
        mods = "CTRL",
        action = wezterm.action.SpawnTab "DefaultDomain"
    }, -- Switch tabs
    {
        key = "1",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(0)
    }, {
        key = "2",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(1)
    }, {
        key = "3",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(2)
    }, {
        key = "4",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(3)
    }, {
        key = "5",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(4)
    }, {
        key = "6",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(5)
    }, {
        key = "7",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(6)
    }, {
        key = "8",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(7)
    }, {
        key = "9",
        mods = "CTRL",
        action = wezterm.action.ActivateTab(-1)
    } -- Last tab
    }
}
