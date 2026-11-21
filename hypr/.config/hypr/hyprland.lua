require("hyprland-theme")
require("hyprland.env")
require("hyprland.defaults")
require("hyprland.startup")
require("hyprland.keyboard")
require("hyprland.animation")
require("hyprland.general")
require("hyprland.decoration")
require("hyprland.input")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Machine-specific settings (mouse, monitors, ...) live in local.lua, which is
-- not tracked in git.
pcall(require, "local")
