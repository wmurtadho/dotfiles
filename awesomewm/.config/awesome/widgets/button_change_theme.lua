local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local noti = require("util.noti")
local widget = require("util.widgets")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local icons = require("icons.default")
local font = require("util.font")
local bicon = require("util.icon")
local app = require("util.app")
local btext = require("util.mat-button")

-- beautiful vars
local icon = beautiful.widget_change_theme_icon or ''
local icon_reload = beautiful.widget_change_theme_icon_reload or ''
local fg = beautiful.widget_change_theme_fg or M.x.on_background
local bg = beautiful.widget_change_theme_bg or M.x.background
local l = beautiful.widget_change_theme_layout or 'horizontal'
local space = beautiful.widget_spacing or dpi(1)

-- add a little margin to avoid the popup pasted on the wibar
local padding = beautiful.widget_popup_padding or 1

-- button creation
local change = bicon({ icon = icon, fg = fg })
local wi = widget.box(l, { change })

local rld = bicon({ icon = icon_reload, fg = fg })
rld:buttons(gtable.join(
  awful.button({ }, 1, function()
    awesome.restart()
  end)
))

local function make_element(name)
  local change_script = function()
    app.start(
      "~/.config/awesome/widgets/change-theme.sh --change "..name,
      true, "miniterm"
    )
    noti.info("Theme changed, Reload awesome for switch on "..name)
  end
  local element = wibox.widget {
    widget.centered(widget.imagebox(80, icons[name])),
    font.button(name, M.x.on_surface, M.t.medium),
    layout = wibox.layout.fixed.vertical
  }
  local w = btext({
    command = change_script, wtext = element, overlay = "on_surface"
  })
  return w
end

local popup_anonymous = make_element("anonymous")
local popup_connected = make_element("connected")
local popup_miami = make_element("miami")
local popup_machine = make_element("machine")
local popup_morpho = make_element("morpho")
local popup_worker = make_element("worker")

local w_position -- the position of the popup depend of the wibar
w_position = widget.check_popup_position(beautiful.wibar_position)

local popup_widget = wibox.widget {
  {
    {
      {
        {
          nil,
          font.h6("Change theme", M.x.on_surface, M.t.high),
          rld,
          expand = "none",
          layout = wibox.layout.align.horizontal
        },
        forced_height = 48,
        widget = wibox.container.margin
      },
      {
        popup_anonymous,
        popup_connected,
        popup_machine,
        popup_miami,
        popup_morpho,
        popup_worker,
        forced_num_rows = 2,
        forced_num_cols = 3,
        spacing = 10,
        layout = wibox.layout.grid,
      },
      layout = wibox.layout.fixed.vertical
    },
    top = 8, bottom = 8,
    left = 24, right = 24,
    widget = wibox.container.margin
  },
  shape = helpers.rrect(20),
  bg = M.x.on_surface .. M.e.dp01,
  widget = wibox.container.background
}

local w = awful.popup {
  widget = popup_widget,
  visible = false, -- do not show at start
  ontop = true,
  hide_on_right_click = true,
  preferred_positions = w_position,
  offset = { y = padding, x = padding }, -- no pasted on the bar
  bg = M.x.surface
}

-- attach popup to widget
w:bind_to_widget(change)
change:buttons(gtable.join(
awful.button({}, 3, function()
  w.visible = false
end)
))

return wi
