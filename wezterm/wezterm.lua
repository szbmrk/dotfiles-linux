local wezterm = require 'wezterm'
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').main

return {
    term = "xterm-256color",

    -- Font and color scheme
    font = wezterm.font("JetBrainsMono Nerd Font Propo"),
    font_size = 14,
    color_scheme = "Rosé Pine",

    colors = theme.colors(),
    window_frame = theme.window_frame(),

    hide_tab_bar_if_only_one_tab = true,
    window_background_opacity = 0.97,
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
