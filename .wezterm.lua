-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

function on_dark_mode(overrides)
	overrides.colors = {
		tab_bar = {
			background = "#232136",
			active_tab = {
				bg_color = "#ea9a97",
				fg_color = "#232136",
			},
			inactive_tab = {
				bg_color = "#6e6a86",
				fg_color = "#e0def4",
			},
			new_tab = {
				bg_color = "#2a273f",
				fg_color = "#e0def4",
			},
		},
	}
end

function on_light_mode(overrides)
	overrides.colors = {
		tab_bar = {
			background = "#faf4ed",
			active_tab = {
				bg_color = "#d7827e",
				fg_color = "#e0def4",
			},
			inactive_tab = {
				bg_color = "#9893a5",
				fg_color = "#f2e9e1",
			},
			new_tab = {
				bg_color = "#fffaf3",
				fg_color = "#575279",
			},
		},
	}
end

function scheme_for_appearance(appearance, overrides)
	if appearance:find("Dark") then
		on_dark_mode(overrides)
		return "rose-pine-moon"
	else
		on_light_mode(overrides)
		return "rose-pine-dawn"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance, overrides)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

config.font = wezterm.font("Fira Code")
config.font_size = 14

config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = 0,
	bottom = 0,
}
config.window_decorations = "RESIZE"

return config
