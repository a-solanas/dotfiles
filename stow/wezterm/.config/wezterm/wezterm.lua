-- WezTerm Terminal Configuration
-- Place your WezTerm configuration here
-- This file will be symlinked to ~/.config/wezterm/wezterm.lua

local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Smart split direction based on pane dimensions
-- Splits along the longest dimension for balanced panes
local function get_smart_split_direction(pane)
  local pane_info = pane:get_dimensions()
  local width = pane_info.pixel_width
  local height = pane_info.pixel_height
  
  -- If wider than tall, split horizontally (left/right)
  -- If taller than wide, split vertically (top/bottom)
  if width >= height then
    return 'Horizontal'  -- Split left/right
  else
    return 'Vertical'  -- Split top/bottom
  end
end

-- Window size (columns x rows)
-- Adjusted to fit fastfetch output comfortably
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
  config.window_decorations = "RESIZE"
end

-- Pane proportional resizing - maintains equal splits when window resizes
config.adjust_window_size_when_changing_font_size = false

-- Disable close confirmation
config.window_close_confirmation = "NeverPrompt"

-- Always show tab bar
config.hide_tab_bar_if_only_one_tab = false

-- Tab bar styling - use retro style for better customization
config.use_fancy_tab_bar = false
config.tab_max_width = 32  -- Allow tabs to grow wider to fit names

-- Tab bar position at bottom
config.tab_bar_at_bottom = true

-- Window frame colors (used by macOS integrated buttons titlebar)
config.window_frame = {
  active_titlebar_bg = '#282c34',
  inactive_titlebar_bg = '#282c34',
}

-- Window background opacity
config.window_background_opacity = 0.97
-- Window padding: macOS needs top=30 to clear the integrated traffic light buttons
config.window_padding = {
  left = 3,
  right = 10,
  top = wezterm.target_triple:find('apple') and 30 or 3,
  bottom = 0,
}

-- Keybindings
local function smart_split(window, pane)
  local direction = get_smart_split_direction(pane)
  if direction == 'Horizontal' then
    pane:split { direction = 'Right' }
  else
    pane:split { direction = 'Bottom' }
  end
end

local function close_pane_if_not_last(window, pane)
  local tab = window:active_tab()
  local panes = tab:panes()
  if #panes > 1 then
    pane:activate()
    window:perform_action(wezterm.action.CloseCurrentPane { confirm = false }, pane)
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

local mac_keys = {
  { key = '=',      mods = 'CMD',       action = wezterm.action.IncreaseFontSize },
  { key = '+',      mods = 'CMD',       action = wezterm.action.IncreaseFontSize },
  { key = '=',      mods = 'CMD|SHIFT', action = wezterm.action.IncreaseFontSize },
  { key = '-',      mods = 'CMD',       action = wezterm.action.DecreaseFontSize },
  { key = '0',      mods = 'CMD',       action = wezterm.action.ResetFontSize },
  { key = 'r',      mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  { key = 'l',      mods = 'CMD|SHIFT', action = wezterm.action.ShowDebugOverlay },
  { key = 'd',      mods = 'CMD',       action = wezterm.action_callback(smart_split) },
  { key = 'd',      mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd',      mods = 'CMD|OPT',   action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's',      mods = 'CMD',       action = wezterm.action_callback(close_pane_if_not_last) },
  { key = 'x',      mods = 'CMD|SHIFT', action = wezterm.action.ActivateCopyMode },
  { key = 't',      mods = 'CMD|SHIFT', action = wezterm.action_callback(toggle_transparency) },
  { key = 'h',      mods = 'CMD|SHIFT', action = wezterm.action.SpawnCommandInNewTab { args = { 'fish', '-c', 'cheat' } } },
  { key = 'Return', mods = 'SHIFT',     action = wezterm.action.SendString('\x1b[13;2u') },
}

-- Linux: Super+D conflicts with KDE show-desktop; font size and close-pane use native terminal bindings
-- (Ctrl+=/- for font, Ctrl+D EOF for close). CTRL+S overrides legacy XOFF — see ADR-0004.
local linux_keys = {
  { key = 'r',      mods = 'CTRL|SHIFT', action = wezterm.action.ReloadConfiguration },
  { key = 'l',      mods = 'CMD|SHIFT', action = wezterm.action.ShowDebugOverlay },
  { key = 's',      mods = 'CTRL',      action = wezterm.action_callback(smart_split) },
  { key = 'x',      mods = 'CMD|SHIFT', action = wezterm.action.ActivateCopyMode },
  { key = 't',      mods = 'CMD|SHIFT', action = wezterm.action_callback(toggle_transparency) },
  { key = 'h',      mods = 'CMD|SHIFT', action = wezterm.action.SpawnCommandInNewTab { args = { 'fish', '-c', 'cheat' } } },
  { key = 'Return', mods = 'SHIFT',     action = wezterm.action.SendString('\x1b[13;2u') },
}

if wezterm.target_triple:find('apple') then
  config.keys = mac_keys
else
  config.keys = linux_keys
end

-- Mouse bindings
config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Right' } }, mods = 'NONE', action = wezterm.action.PasteFrom 'Clipboard' },
}

-- Fixed scroll speed on Linux (Wayland can report huge scroll deltas)
if not wezterm.target_triple:find('apple') then
  table.insert(config.mouse_bindings, { event = { Down = { streak = 1, button = { WheelUp   = 1 } } }, mods = 'NONE', action = wezterm.action.ScrollByLine(-3) })
  table.insert(config.mouse_bindings, { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = 'NONE', action = wezterm.action.ScrollByLine(3) })
end

-- Font and color scheme
config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
config.font_size = 16.0

-- Cursor configuration
config.default_cursor_style = 'BlinkingBlock'  -- Options: 'SteadyBlock', 'BlinkingBlock', 'SteadyBar', 'BlinkingBar', 'SteadyUnderline', 'BlinkingUnderline'
config.cursor_blink_rate = 600  -- Blink rate in milliseconds (800ms = slower blink, 500ms = faster blink)
config.cursor_blink_ease_in = 'Constant'  -- Easing function for blink in
config.cursor_blink_ease_out = 'Constant'  -- Easing function for blink out

-- Color scheme (One Dark palette)
config.colors = {
  foreground = '#ffffff',
  background = '#282c34',
  
  -- Cursor colors
  cursor_bg = '#eaeaea',
  cursor_fg = '#282c34',
  cursor_border = '#eaeaea',
  
  -- ANSI colors (palette 0-15 from Ghostty)
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

-- Tab title: show folder name or running process
wezterm.on('format-tab-title', function(tab)
  -- Get the foreground process name (e.g. nvim, git, fish)
  local process = tab.active_pane.foreground_process_name or ''
  process = process:match('([^/]+)$') or process  -- strip path, keep binary name

  -- Get the current working directory name
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

  local index = tab.tab_index + 1
  return string.format(' %d: %s ', index, title)
end)

-- Status line - show date/time on the right side of the tab bar
wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime ' %a %b %d  %I:%M %p '
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#eaeaea' } },
    { Text = date },
  })
end)

return config
