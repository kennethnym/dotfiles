-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

config.font = wezterm.font("SF Mono")
config.font_size = 14

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = 0,
	bottom = 0,
}

return config
