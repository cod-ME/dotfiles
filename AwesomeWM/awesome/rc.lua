--[[

     Awesome WM configuration template
     https://github.com/awesomeWM

     Freedesktop : https://github.com/lcpz/awesome-freedesktop

     Copycats themes : https://github.com/lcpz/awesome-copycats

     lain : https://github.com/lcpz/lain

--]]

-- ########|||||<<<<<<<|||||||########         Required libraries        #########||||||>>>>>>>>>>>>|||||||#########

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type
local gears         = require("gears") --Utilities such as color parsing and objects
local awful         = require("awful") --Everything related to window managment
                      require("awful.autofocus")
                      require("collision")()
local wibox         = require("wibox") -- Widget and layout library
local beautiful     = require("beautiful") -- Theme handling library
local naughty       = require("naughty") -- Notification library
naughty.config.defaults['icon_size'] = 100
local menubar       = require("menubar")
local lain          = require("lain")
local os = os
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget -- Enable hotkeys help widget for VIM and other apps
                      require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi           = require("beautiful.xresources").apply_dpi


-- ########|||||<<<<<<<|||||||########         Error handling        #########||||||>>>>>>>>>>>>|||||||#########

    -- Check if awesome encountered an error during startup and fell back to
    -- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
    -- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

    -- Autostart windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "unclutter -root" }) -- entries must be comma-separated


-- ########|||||<<<<<<<|||||||########      Themes       #########||||||>>>>>>>>>>>>|||||||#########

    -- keep themes in alfabetical order for ATT
local themes = {
    "blackburn",        -- 1
    "copland",          -- 2
    "ME",               -- 3
    "multicolor",       -- 4
    "powerarrow",       -- 5
    "powerarrow-blue",  -- 6
    "powerarrow-dark",  -- 7
}
local chosen_theme = themes[3] -- choose your theme here
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)


-- ########|||||<<<<<<<|||||||########       Variable definitions        #########||||||>>>>>>>>>>>>|||||||#########


    -- modkey or mod4 = super key
local modkey       = "Mod4"
local altkey       = "Mod1"
local modkey1      = "Control"

    -- personal variables
local browser1          = "firedragon"
local browser2          = "vivaldi-stable"
local browser3          = "chromium -no-default-browser-check"
local editor            = os.getenv("EDITOR") or "nano"
local editorgui         = "notepadqq"
local filemanager       = "nemo"
local mailclient        = "evolution"
local mediaplayer       = "spotify"
local terminal          = "kitty"
local virtualmachine    = "virtualbox"
local screen2           = 2     --change the value to 1 or 2, depending on the number of screens

    -- awesome variables
awful.util.terminal = terminal
    -- Use this : https://fontawesome.com/cheatsheet
--awful.util.tagnames = {  "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }
--awful.util.tagnames = { "⠐", "⠡", "⠲", "⠵", "⠻", "⠿" }
--awful.util.tagnames = { "⌘", "♐", "⌥", "ℵ" }
--awful.util.tagnames = { "www", "edit", "gimp", "inkscape", "music" }
awful.util.tagnames = { " ", " ", " ", "", " ", " ", "", "", "" }
awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center,
}
awful.util.taglist_buttons = my_table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)
awful.util.tasklist_buttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = dpi(250)}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))


-- ########|||||<<<<<<<|||||||########        Awesome Menu        #########||||||>>>>>>>>>>>>|||||||#########

local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e 'man awesome'" },
    { "edit config", "emacsclient -c -a emacs ~/.config/awesome/rc.lua" },
    { "arandr", "arandr" },
    { "restart", awesome.restart },
}
awful.util.mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        --{ "Atom", "atom" },
        -- other triads can be put here
    },
    after = {
        { "Terminal", terminal },
        { "Log out", function() awesome.quit() end },
        { "Sleep", "systemctl suspend" },
        { "Restart", "systemctl reboot" },
        { "Shutdown", "systemctl poweroff" },
        -- other triads can be put here
    }
})
        -- hide menu when mouse leaves it
--awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}



-- ########|||||<<<<<<<|||||||########        Screen       #########||||||>>>>>>>>>>>>|||||||#########

screen.connect_signal("property::geometry", function(s)
        -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

    -- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 2
        else
            c.border_width = beautiful.border_width
        end
    end
end)
    -- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s)
    s.systray = wibox.widget.systray()
    s.systray.visible = true
 end)


-- ########|||||<<<<<<<|||||||########        Mouse Binding        #########||||||>>>>>>>>>>>>|||||||#########

root.buttons(my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))


    --control floating windows with mouse
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

    -- Fíx window snapping
--awful.mouse.snap.edge_enabled = false


-- ########|||||<<<<<<<|||||||########        Keyboard Binding        #########||||||>>>>>>>>>>>>|||||||#########

globalkeys = my_table.join(

    -- #######################           Function keys            #########################################

    awful.key({ }, "F12", function () awful.util.spawn( "xfce4-terminal --drop-down" ) end,
        {description = "dropdown terminal" , group = "APPs"}),

    -- #######################        Super + Function keys            #########################################

    awful.key({ modkey }, "F1", function () awful.util.spawn( browser1 ) end,
        {description = browser1, group = "APPs"}),
    awful.key({ modkey }, "F2", function () awful.util.spawn( editorgui ) end,
        {description = editorgui , group = "APPs" }),
    --awful.key({ modkey }, "F3", function () awful.util.spawn( "inkscape" ) end,
        --{description = "inkscape" ,group = "APPs" }),
    --awful.key({ modkey }, "F4", function () awful.util.spawn( "gimp" ) end,
       -- {description = "gimp" , group = "APPs" }),
    awful.key({ modkey }, "F5", function () awful.util.spawn( "meld" ) end,
        {description = "meld" , group = "APPs" }),
    awful.key({ modkey }, "F6", function () awful.util.spawn( "vlc --video-on-top" ) end,
        {description = "vlc" , group = "APPs" }),
    --awful.key({ modkey }, "F7", function () awful.util.spawn( "virtualbox" ) end,
       -- {description = virtualmachine , group = "APPs" }),
    --awful.key({ modkey }, "F8", function () awful.util.spawn( filemanager ) end,
       -- {description = filemanager , group = "APPs" }),
    awful.key({ modkey }, "F9", function () awful.util.spawn( mailclient ) end,
        {description = mailclient , group = "APPs" }),
    --awful.key({ modkey }, "F10", function () awful.util.spawn( mediaplayer ) end,
       -- {description = mediaplayer , group = "APPs" }),
    awful.key({ modkey }, "F11", function () awful.util.spawn( "rofi -theme-str 'window {width: 100%;height: 100%;}' -show drun" ) end,
        {description = "rofi fullscreen" , group = "launcher" }),
    
    -- #######################            SUPER                ############################################

    awful.key({ modkey }, "e", function () awful.util.spawn( filemanager ) end,
        {description = "filemanager", group = "APPs"}),
    awful.key({ modkey }, "h", function () awful.util.spawn( "alacritty -T 'htop task manager' -e htop" ) end,
        {description = "htop", group = "UTiL"}),
    awful.key({ modkey }, "r", function () awful.util.spawn( "rofi-theme-selector" ) end,
        {description = "rofi theme selector", group = "launcher"}),
    awful.key({ modkey }, "space", function () awful.util.spawn( "rofi -show drun" ) end,
        {description = "rofi" , group = "launcher" }),
    awful.key({ modkey }, "o", function () awful.spawn.with_shell( "rofi -no-lazy-grab -show drun -modi run,drun,window -theme $HOME/.config/rofi/launcher/style -drun-icon-theme \"candy-icons\"" ) end,
        {description = "rofi launcher", group = "launcher"}),
    awful.key({ modkey }, "t", function () awful.util.spawn( terminal ) end,
        {description = "terminal", group = "UTiL"}),
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
             {description = terminal, group = "UTiL"}),
    awful.key({ modkey }, "v", function () awful.util.spawn( "pavucontrol" ) end,
        {description = "pulseaudio control", group = "UTiL"}),
    --awful.key({ modkey }, "u", function () awful.screen.focused().mypromptbox:run() end,
          --{description = "run prompt", group = "UTiL"}),
    --awful.key({ modkey }, "Escape", function () awful.util.spawn( "xkill" ) end,
        --{description = "Kill proces", group = "UTiL"}),
    awful.key({ modkey }, "w", function () awful.util.spawn( browser1 ) end,
        {description = browser1, group = "APPs"}),

        -- Hotkeys Awesome
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
        {description = "show help", group="awesome"}),

        -- Tag browsing with modkey
    awful.key({ modkey,           }, "KP_Up",   awful.tag.viewprev,
       {description = "view previous", group = "tag/WORKSPACE"}),
    awful.key({ modkey,           }, "KP_Down",  awful.tag.viewnext,
        {description = "view next", group = "tag/WORKSPACE"}),

        -- Tag browsing modkey + tab
    awful.key({ modkey,           }, "Tab",   awful.tag.viewnext,
        {description = "view next", group = "tag/WORKSPACE"}),
    awful.key({ modkey, "Shift"   }, "Tab",  awful.tag.viewprev,
        {description = "view previous", group = "tag/WORKSPACE"}),

    -- #######################            SUPER + SHIFT                 ############################################

    --awful.key({ modkey, "Shift"   }, "Return", function() awful.util.spawn( filemanager ) end
        --{description = "filemanager", group = "APPs"}),
    awful.key({ modkey, "Shift"   }, "d",
        function ()
            awful.spawn(string.format("dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn NotoMonoRegular:bold:pixelsize=14",
            beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
        end,
        {description = "show dmenu", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- awful.key({ modkey, "Shift"   }, "x", awesome.quit,
    --          {description = "quit awesome", group = "awesome"}),

    -- #######################            CTRL + SHIFT                 ############################################

    awful.key({ modkey1, "Shift"  }, "Escape", function() awful.util.spawn("xfce4-taskmanager") end),

    -- #######################            CTRL + ALT                ############################################

    awful.key({ modkey1, altkey   }, "space", function () awful.util.spawn( "krunner" ) end,
        {description = "krunner" , group = "launcher" }),
    awful.key({ modkey1, altkey   }, "Escape", function () awful.spawn.with_shell( "xkill" ) end,
        {description = "Kill proces", group = "UTiL"}),
    awful.key({ modkey1, altkey   }, "w", function() awful.util.spawn( "arcolinux-welcome-app" ) end,
        {description = "ArcoLinux Welcome App", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "e", function() awful.util.spawn( "archlinux-tweak-tool" ) end,
        {description = "ArcoLinux Tweak Tool", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "a", function() awful.util.spawn( "xfce4-appfinder" ) end,
        {description = "Xfce appfinder", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "b", function() awful.util.spawn( filemanager ) end,
        {description = filemanager, group = "APPs"}),
    awful.key({ modkey1, altkey   }, "c", function() awful.util.spawn("catfish") end,
        {description = "catfish", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "f", function() awful.util.spawn( browser2 ) end,
        {description = browser2, group = "APPs"}),
    awful.key({ modkey1, altkey   }, "g", function() awful.util.spawn( browser3 ) end,
        {description = browser3, group = "APPs"}),
    awful.key({ modkey1, altkey   }, "i", function() awful.util.spawn("nitrogen") end,
        {description = nitrogen, group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "k", function() awful.util.spawn( "archlinux-logout" ) end,
        {description = scrlocker, group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "l", function() awful.util.spawn( "archlinux-logout" ) end,
        {description = scrlocker, group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "o", function() awful.spawn.with_shell("$HOME/.config/awesome/scripts/picom-toggle.sh") end,
        {description = "Picom toggle", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "s", function() awful.util.spawn( mediaplayer ) end,
        {description = mediaplayer, group = "APPs"}),
    awful.key({ modkey1, altkey   }, "t", function() awful.util.spawn( terminal ) end,
        {description = terminal, group = "UTiL"}),
    awful.key({ modkey1, altkey   }, "u", function() awful.util.spawn( "pavucontrol" ) end,
        {description = "pulseaudio control", group = "UTiL"}),
    awful.key({ modkey1, altkey   }, "v", function() awful.util.spawn( browser1 ) end,
        {description = browser1, group = "APPs"}),
    awful.key({ modkey1, altkey   }, "Return", function() awful.util.spawn(terminal) end,
        {description = terminal, group = "UTiL"}),
    awful.key({ modkey1, altkey   }, "m", function() awful.util.spawn( "xfce4-settings-manager" ) end,
        {description = "Xfce settings manager", group = "Unique TOOLs"}),
    awful.key({ modkey1, altkey   }, "p", function() awful.util.spawn( "pamac-manager" ) end,
        {description = "Pamac Manager", group = "UTiL"}),
    awful.key({ altkey, "Control" }, "Delete",  function () awful.util.spawn( "archlinux-logout" ) end,
      {description = "exit", group = "UTiL"}),

    -- #######################            ALT                ############################################

    --awful.key({ altkey, "Shift"   }, "t", function () awful.spawn.with_shell( "variety -t  && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&" ) end,
       -- {description = "Pywal Wallpaper trash", group = "altkey"}),
    --awful.key({ altkey, "Shift"   }, "n", function () awful.spawn.with_shell( "variety -n  && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&" ) end,
       -- {description = "Pywal Wallpaper next", group = "altkey"}),
    --awful.key({ altkey, "Shift"   }, "u", function () awful.spawn.with_shell( "wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&" ) end,
       -- {description = "Pywal Wallpaper update", group = "altkey"}),
    --awful.key({ altkey, "Shift"   }, "p", function () awful.spawn.with_shell( "variety -p  && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&" ) end,
       -- {description = "Pywal Wallpaper previous", group = "altkey"}),
    --awful.key({ altkey }, "t", function () awful.util.spawn( "variety -t" ) end,
       -- {description = "Wallpaper trash", group = "altkey"}),
    --awful.key({ altkey }, "n", function () awful.util.spawn( "variety -n" ) end,
       -- {description = "Wallpaper next", group = "altkey"}),
    --awful.key({ altkey }, "p", function () awful.util.spawn( "variety -p" ) end,
       -- {description = "Wallpaper previous", group = "altkey"}),
    --awful.key({ altkey }, "f", function () awful.util.spawn( "variety -f" ) end,
       -- {description = "Wallpaper favorite", group = "altkey"}),
    --awful.key({ altkey }, "Left", function () awful.util.spawn( "variety -p" ) end,
       -- {description = "Wallpaper previous", group = "altkey"}),
    --awful.key({ altkey }, "Right", function () awful.util.spawn( "variety -n" ) end,
       -- {description = "Wallpaper next", group = "altkey"}),
    --awful.key({ altkey }, "Up", function () awful.util.spawn( "variety --pause" ) end,
       -- {description = "Wallpaper pause", group = "altkey"}),
    --awful.key({ altkey }, "Down", function () awful.util.spawn( "variety --resume" ) end,
       -- {description = "Wallpaper resume", group = "altkey"}),
    awful.key({ altkey }, "F2", function () awful.util.spawn( "xfce4-appfinder --collapsed" ) end,
        {description = "Xfce appfinder (collaosed)", group = "Unique TOOLs"}),
    awful.key({ altkey }, "F3", function () awful.util.spawn( "xfce4-appfinder" ) end,
        {description = "Xfce appfinder", group = "Unique TOOLs"}),
    -- awful.key({ altkey }, "F5", function () awful.spawn.with_shell( "xlunch --config ~/.config/xlunch/default.conf --input ~/.config/xlunch/entries.dsv" ) end,
    --    {description = "Xlunch app launcher", group = "altkey"}),
    awful.key({ altkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag/WORKSPACE"}),

            -- Tag browsing alt + tab
    awful.key({ altkey,           }, "Tab",   awful.tag.viewnext,
        {description = "view next", group = "tag/WORKSPACE"}),
    awful.key({ altkey, "Shift"   }, "Tab",  awful.tag.viewprev,
        {description = "view previous", group = "tag/WORKSPACE"}),

    -- #######################            MiSC                ############################################

        -- screenshots
    awful.key({ }, "Print", function () awful.util.spawn("scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'") end,
        {description = "Scrot", group = "screenshots"}),
    awful.key({ modkey1           }, "Print", function () awful.util.spawn( "xfce4-screenshooter" ) end,
        {description = "Xfce screenshot", group = "screenshots"}),
    awful.key({ modkey1, "Shift"  }, "Print", function() awful.util.spawn("gnome-screenshot -i") end,
        {description = "Gnome screenshot", group = "screenshots"}),

        -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),
--[[
        -- Show/Hide Systray
    awful.key({ modkey }, "-", function ()
    awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
    end, {description = "Toggle systray visibility", group = "awesome"}),

        -- Show/Hide Systray
    awful.key({ modkey }, "KP_Subtract", function ()
    awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
    end, {description = "Toggle systray visibility", group = "awesome"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),
--]]
    awful.key({ altkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
--[[
        -- Widgets popups
    awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end,
        {description = "show calendar", group = "widgets"}),
    awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
        {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
        --{description = "show weather", group = "widgets"}),

        --Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "super"})
    --]]


    -- #######################            Layout                ############################################

    -- Non-empty tag browsing
    --awful.key({ modkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
        --{description = "view  previous nonempty", group = "tag"}),
   -- awful.key({ modkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
        -- {description = "view  next nonempty", group = "tag"}),

        -- Default client focus
    awful.key({ modkey,           }, "KP_Right",
    --awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "focus"}
    ),
    awful.key({ modkey,           }, "KP_Left",
    --awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "focus"}
    ),

        -- By direction client focus with NUM-arrows
    awful.key({ modkey1, modkey }, "KP_Down",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "focus"}),
    awful.key({ modkey1, modkey }, "KP_Up",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "focus"}),
    awful.key({ modkey1, modkey }, "KP_Left",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "focus"}),
    awful.key({ modkey1, modkey }, "KP_Right",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "focus"}),

        -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "KP_Down", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "KP_Up", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "KP_Add", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "KP_Subtract", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey1,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),


    
    -- #######################            GAPS                ############################################


        -- On the fly useless gaps change
    awful.key({ modkey1, "Shift" }, "Down", function () lain.util.useless_gaps_resize(1) end,
              {description = "increment useless gaps", group = "gaps"}),
    awful.key({ modkey1, "Shift" }, "Up", function () lain.util.useless_gaps_resize(-1) end,
              {description = "decrement useless gaps", group = "gaps"}),

        -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
        {description = "add new tag", group = "tag/WORKSPACE"}),
    awful.key({ modkey, "Shift" }, "y", function () lain.util.delete_tag() end,
        {description = "delete tag", group = "tag/WORKSPACE"}),
    --awful.key({ modkey, "Control" }, "r", function () lain.util.rename_tag() end,
        --{description = "rename tag", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
        --{description = "move tag to the left", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
        --{description = "move tag to the right", group = "tag"}),

        -- Layout Manupilation
    awful.key({ modkey, "Shift"   }, "KP_Add",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "KP_Subtract",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ altkey, "Control"   }, "KP_Right",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ altkey, "Control"   }, "KP_Left",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ altkey, "Control" }, "KP_Up",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ altkey, "Control" }, "KP_Down",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    --awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        -- {description = "select next", group = "layout"}),
    --awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        -- {description = "select previous", group = "layout"}),
    --awful.key({ modkey, altkey }, "KP_Up", function ()
        --if c.floating then
            --c:relative_move(0,0,0,-10)
        --else
            --awful.client.incmwfact(0.025)
        --end
    --end,
    --{description = "Floating resize Vertical -", group = "client"}),

    --awful.key({ modkey, altkey }, "KP_Down", function ()
        --if c.floating then
            --c:relative_move(0,0,0,10)
        --else
            --awful.client.incmwfact(-0.025)
        --end
    --end,
    --{description = "Floating resize Vertical +", group = "client"}),

    --awful.key({ modkey, altkey }, "KP_Right", function (s)
        --if c.floating then
            --c:relative_move(0,0,10,0)
        --else
            --awful.client.incmwfact(0.025)
        --end
    --end,
    --{description = "Floating resize Horizontal +", group = "client"}),

    --awful.key({ modkey, altkey }, "KP_Left", function ()
        --if c.floating then
            --c:relative_move(0,0,-10,0)
        --else
            --awful.client.incmwfact(-0.025)
        --end
    --end,
    --{description = "Floating resize Vertical +", group = "client"}),


    -- #######################          Brightness keys          #############################################
    --awful.key({ }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end,
      --        {description = "+10%", group = "hotkeys"}),
    --awful.key({ }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end,
      --        {description = "-10%", group = "hotkeys"}),


    -- #######################        ALSA volume control           ##############################################
    --awful.key({ modkey1 }, "Up",
    --awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn.with_shell( "amixer -q sset Master 1%+" ) end,
    awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn.with_shell( "pactl set-sink-volume 0 +1%" ) end,
            {description = "Vol 1+" , group = "volume keys" }),
        --function () os.execute(string.format("amixer -q sset Master 1%+", beautiful.volume.channel))
            --beautiful.volume.update()
        --end),
    --awful.key({ modkey1 }, "Down",
    --awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn.with_shell( "amixer -q sset Master 1%-" ) end,
    awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn.with_shell( "pactl set-sink-volume 0 -1%" ) end,
        {description = "Vol 1-" , group = "volume keys" }),
        --function () os.execute(string.format("amixer -q sset Master 1%-", beautiful.volume.channel))
            --beautiful.volume.update()
        --end),
    --awful.key({ }, "XF86AudioMute", function() awful.spawn.with_shell( "amixer -q sset Master toggle" ) end,
    awful.key({ }, "XF86AudioMute", function() awful.spawn.with_shell( "pactl set-sink-mute 0 toggle" ) end,
        {description = "Vol Mute/unMute" , group = "volume keys" }),
        --function () os.execute(string.format("amixer -q set Master toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
            --beautiful.volume.update()
        --end),
    --awful.key({ modkey }, "KP_Add", function() awful.spawn.with_shell( "amixer -q sset Master 100%" ) end,
    awful.key({ modkey }, "KP_Add", function() awful.spawn.with_shell( "pactl set-sink-volume 0 100%" ) end,
        {description = "Vol 100%" , group = "volume keys" }),
        --function () os.execute(string.format("amixer -q set Master 100%", beautiful.volume.channel))
            --beautiful.volume.update()
        --end),
    --awful.key({ modkey }, "KP_Subtract", function() awful.spawn.with_shell( "amixer -q sset Master 0%" ) end,
    awful.key({ modkey }, "KP_Subtract", function() awful.spawn.with_shell( "pactl set-sink-volume 0 0%" ) end,
        {description = "Vol 0%" , group = "volume keys" }),
        --function () os.execute(string.format("amixer -q set Master 0%", beautiful.volume.channel))
            --beautiful.volume.update()
        --end),

    -- #######################          Media Key               ##############################################
    awful.key({}, "XF86AudioPlay", function() awful.util.spawn("playerctl play-pause", false) end),
    awful.key({}, "XF86AudioNext", function() awful.util.spawn("playerctl next", false) end),
    awful.key({}, "XF86AudioPrev", function() awful.util.spawn("playerctl previous", false) end),
    awful.key({}, "XF86AudioStop", function() awful.util.spawn("playerctl stop", false) end)
--[[
        --Media keys supported by mpd.
    awful.key({ modkey1, "Shift" }, "s",
        function ()
            local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
            if beautiful.mpd.timer.started then
                beautiful.mpd.timer:stop()
                common.text = common.text .. lain.util.markup.bold("OFF")
            else
                beautiful.mpd.timer:start()
                common.text = common.text .. lain.util.markup.bold("ON")
            end
            naughty.notify(common)
        end,
        {description = "mpc on/off", group = "widgets"})

    awful.key({}, "XF86AudioPlay", function () awful.util.spawn("mpc toggle") end),
    awful.key({}, "XF86AudioNext", function () awful.util.spawn("mpc next") end),
    awful.key({}, "XF86AudioPrev", function () awful.util.spawn("mpc prev") end),
    awful.key({}, "XF86AudioStop", function () awful.util.spawn("mpc stop") end),

        -- MPD control
    awful.key({ modkey1, "Shift" }, "Up",
        function ()
            os.execute("mpc toggle")
            beautiful.mpd.update()
       end,
        {description = "mpc toggle", group = "widgets"}),
    awful.key({ modkey1, "Shift" }, "Down",
        function ()
            os.execute("mpc stop")
            beautiful.mpd.update()
        end,
        {description = "mpc stop", group = "widgets"}),
    awful.key({ modkey1, "Shift" }, "Left",
        function ()
            os.execute("mpc prev")
            beautiful.mpd.update()
        end,
        {description = "mpc prev", group = "widgets"}),
    awful.key({ modkey1, "Shift" }, "Right",
        function ()
            os.execute("mpc next")
           beautiful.mpd.update()
        end,
        {description = "mpc next", group = "widgets"}),
--]]

) --global key


--[[
        -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
        {description = "copy terminal to gtk", group = "hotkeys"}),
        --Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
        {description = "copy gtk to terminal", group = "hotkeys"}),
--]]


-- #######################          Applications/ Clients           ##############################################

clientkeys = my_table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
        {description = "magnify client", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
        {description = "close", group = "UTiL"}),
    awful.key({ modkey, },           "q",      function (c) c:kill()                         end,
        {description = "close", group = "UTiL"}),
    awful.key({ modkey, "Shift" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move client to master", group = "client"}),
    awful.key({ modkey, "Shift"   }, "KP_Left",   function (c) c:move_to_screen()               end,
        {description = "move client to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "KP_Right",  function (c) c:move_to_screen()               end,
        {description = "move client to screen", group = "client"}),    
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              --{description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)


-- #######################          Workspace/ tags           ##############################################

    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag/WORKSPACE"}
        descr_toggle = {description = "toggle tag #", group = "tag/WORKSPACE"}
        descr_move = {description = "move focused client to tag #", group = "tag/WORKSPACE"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag/WORKSPACE"}
    end
    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                              tag:view_only()
                          end
                     end
                  end,
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end

    -- Set keys
root.keys(globalkeys)


-- ##########|||||<<<<<<<|||||||########         Rules              #########||||||>>>>>>>>>>>>|||||||#########

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     --size_hints_honor = false
     }
    },

    -- #######################          Application FLOATiNG Rules         ##############################################

    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Arcolinux-welcome-app.py",
          "Blueberry",
          "Galculator",
          "Gnome-font-viewer",
          "Gpick",
          "Imagewriter",
          "Font-manager",
          "Kruler",
          "MessageWin",  -- kalarm.
          "archlinux-logout",
          "Peek",
          "Zoom",
          "System-config-printer.py",
          "Sxiv",
          "Unetbootin.elf",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "Xfce4-terminal",
          "krunner",
          "gnome-calculator"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          "Preferences",
          "setup",
        }
      }, properties = { floating = true }},

              -- Titlebars
    { rule_any = { type = { "normal", "dialog" } },
      properties = { titlebars_enabled = false } },

 -- ##############       Application forced to screen 1 (eDP-1)     #######################################
    
    -- find class or role via xprop | grep WM_CLASS command

          -------- Set applications to always map on tag 1.----------------
    { rule_any = { class = {
                    --"thunderbird"
                    "firedragon"
                    }},
        properties = { screen = 1, tag = awful.util.tagnames[1], switchtotag = true } },

          -------- Set applications to always map on tag 2.--------
    
    { rule_any = { class = {
                    --"thunderbird"
                     "FreeTube",
                    "LibreWolf",
                    "waterfox"
                    }},
        properties = { screen = 1, tag = awful.util.tagnames[2], switchtotag = true } },

          -------- Set applications to always map on tag 3.--------

    { rule_any = { class = {
                    "thunderbird",
                    "Brave"
                    }},
        properties = { screen = 1, tag = awful.util.tagnames[3], switchtotag = true } },

          -------- Set applications to always map on tag 4.--------

    { rule_any = { class = {
                    "Subl",
                    "stacer",
                    "firefox"
                    }},
        properties = { screen = 1, tag = awful.util.tagnames[4], switchtotag = true } },

          -------- Set applications to always map on tag 5.--------

    { rule_any = { class = {
                    "KeePassXC" 
                }},
        properties = { screen = 1, tag = awful.util.tagnames[5], switchtotag = true } },

          -------- Set applications to always map on tag 6.--------

    { rule_any = { class = {
                    "discord",
                    "whatsapp-nativefier-d40211",
                    "TelegramDesktop",
                    "Evolution",
                    "Vivaldi-stable",
                    "Chromium"
                }},
        properties = { screen = 1, tag = awful.util.tagnames[6], switchtotag = true } },

          -------- Set applications to always map on tag 8.--------

    { rule_any = { class = {
                    "Spotify",
                    "Deezer",
                    "GLava"
                }},
        properties = { screen = 1, tag = awful.util.tagnames[8], switchtotag = true } },

           -------- Set applications to always map on tag 9.--------

        { rule_any = { class = {
                    "Epiphany",
                    "qutebrowser"
                }},
        properties = { screen = 1, tag = awful.util.tagnames[9], switchtotag = true } },



    -- #######################          Application Window Rules         ##############################################

          -- Forced Maximize
    { rule_any = { class = {
                editorgui,
                "Geany",
                "Gnome-disks",
                "inkscape",
                mediaplayer,
                "VirtualBox Manager",
                "VirtualBox Machine",
                "Gimp"
            }},
        properties = { maximized = true } },

          -- Floating clients but centered in screen
    { rule_any = { class = {
            "Polkit-gnome-authentication-agent-1",
            "Arcolinux-calamares-tool.py" } },
        properties = { floating = true },
            callback = function (c)
              awful.placement.centered(c,nil)
            end },

          -- No Maximizing
    { rule_any = { class = {
                "Vivaldi-stable",
                filemanager,
                "Chromium",
                "waterfox",
                "LibreWolf",
                "KeePassXC"
            }},
        properties = { callback = function (c) c.maximized = false end } },

          -- No Floating
    { rule_any = { class = {
                "Xfce4-settings-manager"
            }},
        properties = { floating = false } },

          -- Both No Maximizing & No Floating
    { rule_any = { class = {
                "nemo"
            }},
       properties = { maximized = false, floating = false } }
}

-- ########|||||<<<<<<<|||||||########       Signal         #########||||||>>>>>>>>>>>>|||||||#########
    
    -- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- ######|||||<<<<<|||||||########     Application Titlebar       ########||||||>>>>>>>>>|||||||#######

    -- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
        -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

        -- Default
    -- buttons for the titlebar
    local buttons = my_table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = dpi(21)}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)


-- ##########|||||<<<<<<<|||||||########            Mouse Focus           #########||||||>>>>>>>>>>>>|||||||#########

    -- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)


-- ##########|||||<<<<<<<|||||||########            Autostart           #########||||||>>>>>>>>>>>>|||||||#########

awful.spawn.with_shell("~/.config/awesome/autostart.sh")
awful.spawn.with_shell("picom -b --config  $HOME/.config/awesome/picom.conf")

