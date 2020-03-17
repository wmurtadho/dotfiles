local wibox = require("wibox")
local awful = require("awful")
local mat = require("util.mat")
local gtable = require("gears.table")
local widget = require("util.widgets")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local font = require("util.font")

-- opacity state for button dark theme
-- https://material.io/design/color/dark-theme.html#states
local o = { bg = {} }
o["bg"]["none"] = "00" -- 0%
o["bg"]["hovered"] = "0A" -- 4%
o["bg"]["focused"] = "1F" -- 12%

local mat_button = class()

-- opacity color on dark theme
-- https://material.io/design/iconography/system-icons.html#color
local mat_mode = { text = {}, contained = {}, outlined = {} }
mat_mode.text.margin = { right = 8, left = 8 }
mat_mode.text.fg = { disabled = 60, hovered = 87 , focused = 100 }
mat_mode.contained.margin = { right = 16, left = 16 }
mat_mode.contained.fg = { disabled = 90, hovered = 95 , focused = 100 }
mat_mode.outlined.margin = { right = 16, left = 16 }
mat_mode.outlined.fg = { disabled = 60, hovered = 87 , focused = 100 }

function mat_button:init(args)
  -- options
  self.font_text = args.font_text or beautiful.font_button or "Iosevka Term Medium 14"
  self.font_icon = args.font_icon or beautiful.font_h1 or "Iosevka Light 60"
  self.icon = args.icon or ""  
  self.text = args.text or ""
  self.fg_text = args.fg_text or beautiful.on_surface
  self.fg_icon = args.fg_icon or beautiful.on_surface
  self.bg = args.bg or beautiful.surface
  self.layout = args.layout or "vertical"
  self.rrect = args.rrect or 10
  self.width = args.width or nil
  self.height = args.height or nil -- default height 36
  self.spacing = args.spacing or 0
  self.command = args.command or nil
  self.overlay = args.overlay or beautiful.on_primary
  -- button mode https://material.io/components/buttons/#
  self.mode = args.mode or 'text' -- mode are: contained , outlined or text
  -- widgets
  self.wicon = widget.create_text(self.icon, self.fg_icon, self.font_icon)
  self.wtext = args.wtext or font.button(self.text, self.fg_text)
  self.background = wibox.widget {
    bg = self.bg,
    shape = helpers.rrect(self.rrect),
    widget = wibox.container.background
  }
  self.bgoverlay = wibox.widget {
    bg = self.overlay .. o.bg.none,
    shape = helpers.rrect(self.rrect),
    widget = wibox.container.background
  }
  self.margin = wibox.widget {
    top = 1, bottom = 1,
    left = mat_mode[self.mode].margin.left,
    right = mat_mode[self.mode].margin.right,
    forced_height = self.height,
    forced_width = self.width,
    widget = wibox.container.margin
  }
  self.w = self:make_widget()
end

function mat_button:make_widget()
  if self.mode == "contained" then
    return wibox.widget {
      {
        {
          {
            self.wicon,
            self.wtext,
            layout = wibox.layout.fixed[self.layout],
          },
          widget = self.margin
        },
        {
          {
            image = nil,
            widget = wibox.widget.imagebox
          },
          widget = self.bgoverlay
        },
        spacing = dpi(self.spacing),
        layout = wibox.layout.stack
      },
      widget = self.background
    }
  else
    return wibox.widget {
      {
        {
          self.wicon,
          self.wtext,
          layout = wibox.layout.fixed[self.layout],
        },
        widget = self.margin
      },
      widget = self.bgoverlay
    }
  end
end

function mat_button:add_action()
  self.w:buttons(gtable.join(
    awful.button({}, 1, function() 
      self.command()
    end)
  ))
end

function mat_button:hover()
  self.wicon.markup = helpers.colorize_text(self.icon, self.fg_icon, mat_mode[self.mode].fg.disabled)
  self.wtext.markup = helpers.colorize_text(self.text, self.fg_text, mat_mode[self.mode].fg.disabled)
  self.bgoverlay.bg = self.overlay .. o.bg.none

  self.w:connect_signal("mouse::leave", function() 
    self.wicon.markup = helpers.colorize_text(self.icon, self.fg_icon, mat_mode[self.mode].fg.disabled)
    self.wtext.markup = helpers.colorize_text(self.text, self.fg_text, mat_mode[self.mode].fg.disabled)
    self.bgoverlay.bg = self.overlay .. o.bg.none
  end)
  self.w:connect_signal("mouse::enter", function() 
    self.wicon.markup = helpers.colorize_text(self.icon, self.fg_icon, mat_mode[self.mode].fg.focused)
    self.wtext.markup = helpers.colorize_text(self.text, self.fg_text, mat_mode[self.mode].fg.focused)
    self.bgoverlay.bg = self.overlay .. o.bg.hovered
  end)
  self.w:connect_signal("button::release", function() 
    self.wicon.markup = helpers.colorize_text(self.icon, self.fg_icon, mat_mode[self.mode].fg.hovered)
    self.wtext.markup = helpers.colorize_text(self.text, self.fg_text, mat_mode[self.mode].fg.hovered)
    self.bgoverlay.bg = self.overlay .. o.bg.hovered
  end)
  self.w:connect_signal("button::press", function()
    self.wicon.markup = helpers.colorize_text(self.icon, self.fg_icon)
    self.wtext.markup = helpers.colorize_text(self.text, self.fg_text)
    self.bgoverlay.bg = self.overlay .. o.bg.focused
  end)
end

local new_button = class(mat_button)

function new_button:init(args)
  mat_button.init(self, args)
  mat_button.add_action(self)
  mat_button.hover(self)
  return self.w
end

return new_button