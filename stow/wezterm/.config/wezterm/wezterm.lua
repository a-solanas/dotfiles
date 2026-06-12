local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Window size
config.initial_cols = 105
config.initial_rows = 30

-- Shell: on macOS fish lives under Homebrew; on Linux use the login shell (chsh)
if wezterm.target_triple:find('apple') then
  config.default_prog = { '/opt/homebrew/bin/fish' }
end

-- Scrollback
config.scrollback_lines = 10000

-- macOS gets integrated traffic lights; Linux uses RESIZE only (move window with Meta+drag on KDE Wayland)
if wezterm.target_triple:find('apple') then
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
  config.window_decorations = "TITLE | RESIZE"
end

config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"

-- Tab bar
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.tab_bar_at_bottom = true

-- Window frame colors (macOS integrated buttons titlebar)
config.window_frame = {
  active_titlebar_bg = '#282c34',
  inactive_titlebar_bg = '#282c34',
}

config.window_background_opacity = 0.97
config.window_padding = {
  left = 3,
  right = 10,
  top = wezterm.target_triple:find('apple') and 30 or 3,
  bottom = 0,
}

-- Font
config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
config.font_size = 16.0

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Color scheme (One Dark)
config.colors = {
  foreground = '#ffffff',
  background = '#282c34',
  cursor_bg = '#eaeaea',
  cursor_fg = '#282c34',
  cursor_border = '#eaeaea',
  ansi = {
    '#1d1f21', -- black
    '#cc6666', -- red
    '#b5bd68', -- green
    '#f0c674', -- yellow
    '#81a2be', -- blue
    '#b294bb', -- magenta
    '#8abeb7', -- cyan
    '#c5c8c6', -- white
  },
  brights = {
    '#666666', -- bright black
    '#d54e53', -- bright red
    '#b9ca4a', -- bright green
    '#e7c547', -- bright yellow
    '#7aa6da', -- bright blue
    '#c397d8', -- bright magenta
    '#70c0b1', -- bright cyan
    '#eaeaea', -- bright white
  },
  tab_bar = {
    background = '#282c34',
    active_tab = {
      bg_color = '#282c34',
      fg_color = '#ffffff',
    },
    inactive_tab = {
      bg_color = '#282c34',
      fg_color = '#888888',
    },
    inactive_tab_hover = {
      bg_color = '#3e4451',
      fg_color = '#ffffff',
    },
  },
}

-- Tab title: show folder name, or folder › process when something is running
wezterm.on('format-tab-title', function(tab)
  local process = tab.active_pane.foreground_process_name or ''
  process = process:match('([^/]+)$') or process

  local cwd = tab.active_pane.current_working_dir
  local dir = ''
  if cwd then
    local cwd_str = cwd.file_path or tostring(cwd)
    dir = cwd_str:match('([^/]+)/?$') or '~'
  end

  local shells = { fish = true, bash = true, zsh = true, sh = true, nu = true }
  local title = dir
  if process ~= '' and not shells[process] then
    title = dir .. ' › ' .. process
  end

  return string.format(' %d: %s ', tab.tab_index + 1, title)
end)

-- Status line: date/time on the right
wezterm.on('update-right-status', function(window, _pane)
  local date = wezterm.strftime ' %a %b %d  %I:%M %p '
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#eaeaea' } },
    { Text = date },
  })
end)

-- Keybindings
local function smart_split(window, pane)
  local dim = pane:get_dimensions()
  if dim.pixel_width >= dim.pixel_height then
    pane:split { direction = 'Right' }
  else
    pane:split { direction = 'Bottom' }
  end
end

local function toggle_transparency(window, _pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity == 1.0 then
    overrides.window_background_opacity = nil
  else
    overrides.window_background_opacity = 1.0
  end
  window:set_config_overrides(overrides)
end

config.keys = {
  { key = 's',    mods = 'CTRL',       action = wezterm.action_callback(smart_split) },
  { key = 'd',    mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = '\\',   mods = 'CTRL',       action = wezterm.action_callback(toggle_transparency) },
}

-- Mouse bindings
-- Override Up events so selection is never auto-copied to primary or clipboard.
-- Use Ctrl+Shift+C to explicitly copy. Links still open on single click.
config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE', action = wezterm.action.OpenLinkAtMouseCursor },
  { event = { Up = { streak = 2, button = 'Left' } }, mods = 'NONE', action = wezterm.action.Nop },
  { event = { Up = { streak = 3, button = 'Left' } }, mods = 'NONE', action = wezterm.action.Nop },
  { event = { Up = { streak = 1, button = 'Right' } }, mods = 'NONE', action = wezterm.action.PasteFrom 'Clipboard' },
}

-- KDE Wayland reports large scroll deltas causing page-jump behavior; cap to 3 lines per tick.
if not wezterm.target_triple:find('apple') then
  table.insert(config.mouse_bindings, { event = { Down = { streak = 1, button = { WheelUp   = 1 } } }, mods = 'NONE', action = wezterm.action.ScrollByLine(-3) })
  table.insert(config.mouse_bindings, { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = 'NONE', action = wezterm.action.ScrollByLine(3) })
end

return config
