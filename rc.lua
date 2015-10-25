-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")
require("utility")
require("awful/widget/calendar2")
--require("blingbling")
--require("weather")
require("volume")
os.setlocale('ru_RU.UTF-8') --}}}



-- {{{ Error handling
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
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = "subl"--os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating, --1
    awful.layout.suit.tile, --2
    awful.layout.suit.tile.left, --3
    awful.layout.suit.tile.bottom, --4
    awful.layout.suit.tile.top, --5
    awful.layout.suit.fair, --6
    awful.layout.suit.fair.horizontal, --7
    awful.layout.suit.spiral, --8
    awful.layout.suit.spiral.dwindle, --9
    awful.layout.suit.max, --10
    awful.layout.suit.max.fullscreen, --11
    awful.layout.suit.magnifier --12
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" }, s, layouts[1])
end

awful.layout.set(layouts[10], tags[1][1])
awful.layout.set(layouts[10], tags[1][2])
awful.layout.set(layouts[10], tags[1][3])

-- }}}

---{{{ get path to img of application
function get_path(app)
  return "/usr/share/icons/hicolor/24x24/apps/"..app..".png"
end
---}}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "lock", "slock"},
   { "reboot" , "/usr/bin/dbus-send --system --print-reply --dest='org.freedesktop.ConsoleKit' /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart"},
   { "shutdown" , "/usr/bin/dbus-send --system --print-reply --dest='org.freedesktop.ConsoleKit' /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop"},
   { "suspend",   "/usr/bin/dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Suspend"}

}

application = {
   { "google-chrome", "google-chrome", get_path("google-chrome") },
   { "skype", "skype", get_path("skype")},
   --{ "PyCharm", "spyder"},
   --{ "pidgin" , "pidgin", get_path("pidgin")},
   --{ "thunderbird","thunderbird"},
   --{ "krusader","krusader","/usr/share/icons/hicolor/22x22/apps/krusader_shield.png"},
   { "system monitor", "gnome-system-monitor"}
}


mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
              			    { "application", application},
                                    { "Debian menu", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}



-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, "%a %d %b %Y, %H:%M")
calendar2.addCalendarToWidget(mytextclock, "<span color='red'>%s</span>")
--{{{Splitter (разделитель)
sp = widget({ type = "textbox" })
sp.text = " | "
--Splitter (разделитель)}}}

--lang
kbdwidget = widget({type = "textbox", name = "kbdwidget"})
kbdwidget.border_color = beautiful.fg_normal
kbdwidget.text = "Eng"
dbus.request_name("session", "ru.gentoo.kbdd") 
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'") 
dbus.add_signal("ru.gentoo.kbdd", function(...) 
    local data = {...} 
    local layout = data[2] 
    lts = {[0] = "Eng", [1] = "Рус"} 
    kbdwidget.text = " "..lts[layout].." " 
    end 
) 
--end lang

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

--{-------------------------------------------------------------------------------------------------------------------------------------------
-- Volume widget
--}-------------------------------------------------------------------------------------------------------------------------------------------

--{-------------------------------------------------------------------------------------------------------------------------------------------
--weather
--weatherwidget = widget({ type = "textbox" })
--imgweaterwidget = widget({ type = "imagebox" })
--weather.addWeather(weatherwidget, "voronezh", 3600)
--weather.addWeather(imgweaterwidget, "voronezh", 3600)

--}-------------------------------------------------------------------------------------------------------------------------------------------

--{-------------------------------------------------------------------------------------------------------------------------------------------
--battery
--mybattmon = widget({ type = "textbox", name = "mybattmon", align = "right" })
--function battery_status ()
--    local output={} --output buffer
--    local fd=io.popen("acpitool -b", "r") --list present batteries
--    local line=fd:read()
--    while line do --there might be several batteries.
--        --local battery_num = string.match(line, "Battery \#(%d+)")
--        local battery_load = string.match(line,"(%d+\.%d+)")
        --local time_rem = string.match(line, "(%d+\:%d+)\:%d+")
--        local discharging
--        if string.match(line, "Discharging")=="Discharging" then --discharging: always red
 --               discharging="<span color=\"#FF0000\"> BAT "
--        else --charging
--                discharging="<span color=\"#008000\"> AC "
--        end
--            table.insert(output,discharging..battery_load.."%</span>")
--        line=fd:read() --read next line
--    end
--    return table.concat(output," ") --FIXME: better separation for several batteries. maybe a pipe?
--end
--mybattmon.text = " " .. battery_status() .. " "
--my_battmon_timer=timer({timeout=30})
--my_battmon_timer:add_signal("timeout", function()
    --mytextbox.text = " " .. os.date() .. " "
--    mybattmon.text = " " .. battery_status() .. " "
--end)
--my_battmon_timer:start()

--}-------------------------------------------------------------------------------------------------------------------------------------------

--{-------------------------------------------------------------------------------------------------------------------------------------------

--}-------------------------------------------------------------------------------------------------------------------------------------------



for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imathunderbirdgebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
    						
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)
	
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
     mywibox[s].widgets = {
        {
            mylauncher, 
            mytaglist[s], sp,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright,
        }, 
        mylayoutbox[s], sp,
        kbdwidget ,sp,
        mytextclock, sp,
        volume_widget,sp,
	      volume_widget_front,sp,
        --weatherwidget, imgweaterwidget ,sp,
--        my_volume.widget,volume_label,sp,
        --mybattmon, sp,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

k ="#45"  r="#27" q="#24" l="#46"    
b ="#56"  f="#41" c="#54" o="#32"   
w ="#25"  s="#39" x="#53" r="#27"
j ="#44"  n="#57" g="#42" h="#43"
u ="#30"  t="#28" m="#58"


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, b,
       function ()
           if mywibox[mouse.screen].screen == nil then
               mywibox[mouse.screen].screen = mouse.screen
           else
               mywibox[mouse.screen].screen = nil
           end
       end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, j,
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, k,
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, w, function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, j, function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, k, function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, j, function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, k, function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, u, awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ modkey,           }, "F1", function () naughty.notify({ 
      text=[[
google -- Mod+G
PyCharm -- Mod+D
Skype -- Mod+S
Scroll Lock -- Mod+Ctrl+S
Background -- Mod+Ctrl+N
Front off -- Mod+Ctrl+0
Master +25% -- Mod+Ctrl+=
Master -25% -- Mod+Ctrl+-
]],
      timeout = 5 }) end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, r, awesome.restart),
    awful.key({ modkey, "Shift"   }, q, awesome.quit),

    awful.key({ modkey,           }, l,     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, h,     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, h,     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, l,     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, h,     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, l,     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, n, awful.client.restore),
    
    
    awful.key({ modkey}, g, function () awful.util.spawn("google-chrome") end),
	awful.key({ modkey, "Control"}, s, function () awful.util.spawn("xset led named 'Scroll Lock'") end),
        
	awful.key({ modkey}, d, function () awful.util.spawn("~/pycharm-community-4.5.4/bin/pycharm.sh") end),
    awful.key({ modkey}, s, function () awful.util.spawn("skype") end),
    awful.key({modkey, "Control"}, n, function() awful.util.spawn("awsetbg -r /home/alex/wallpaper/") end),
    -- Prompt
    awful.key({ modkey },r,function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, x,
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
	--volume control 
 	awful.key({ modkey, "Control" }, "#21", function () -- =
	       awful.util.spawn("amixer set Master 25%+") end),
  awful.key({ modkey, "Control" }, "#20", function () -- -
          awful.util.spawn("amixer set Master 25%-") end),
	awful.key({ modkey, "Control" }, "#19", function () -- 0
       		awful.util.spawn("amixer set Front 0%") end),
  
  awful.key({ }, "XF86AudioRaiseVolume", function ()
         awful.util.spawn("amixer set Front 7%+") end),
  awful.key({ }, "XF86AudioLowerVolume", function ()
          awful.util.spawn("amixer set Front 7%-") end),
awful.key({}, "Print", function() awful.util.spawn("scrot '~/screenshots/%Y-%m-%d-%H-%M-%S.png'") end ),
-- скриншот активного окна
awful.key({"Shift"}, "Print", function() awful.util.spawn("scrot -u '~/screenshots/window_%Y-%m-%d-%H-%M-S.png'") end )
	
	--brightness control
    --awful.key({ }, "XF86MonBrightnessDown", function ()
      --  awful.util.spawn("xbacklight -dec 15") end),
    --awful.key({ }, "XF86MonBrightnessUp", function ()
       -- awful.util.spawn("xbacklight -inc 15") end)
   
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, f,      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, c,      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, o,      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, r,      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, t,      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, n,
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, m,
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Google-chrome" }, 
       properties = { tag = tags[1][1] },
       callback = awful.titlebar.add  },
    { rule = { class = "Spyder" }, 
       properties = { tag = tags[1][3] } },
    { rule = { class = "Pidgin" },
       properties = { tag = tags[1][4] } },
    { rule = { class = "Skype" },
       properties = { tag = tags[1][4] } },
    { rule = { class = "PyCharm Community Edition 3.4.1" },
       properties = { tag = tags[1][4] } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    awful.titlebar.add(c, { modkey = modkey })
    if c.titlebar then 
	awful.titlebar.remove(c)
    else 
    	awful.titlebar.add(c, {modkey = modkey, height=18})
    end    
    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) 
						c.border_color = beautiful.border_focus 
						c.opacity = 1 
					end )
client.add_signal("unfocus", function(c) 
						c.border_color = beautiful.border_normal 
						--c.opacity = 0.8 
					end )
-- }}}

--{{---|wallpaper|----------


--{{---| run_once |---------------------------------------------------------------------------------
function run_once(prg)
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")") end
--{{---|autorun |----------------------------------------------------------------------------
function run(prg)
	awful.util.spawn_with_shell(prg) end

--run_once("kbdd")
run_once("nm-applet")
run_once("xcompmgr")
--run_once("numlockx on")
run_once("gnome-settings-daemon")

--run_once("xmodmap .xmodmaprc")
awful.util.spawn_with_shell("awsetbg -r ~/wallpaper/")
--awful.util.spawn_with_shell("kbdd")
--awful.util.spawn_with_shell("setxkbmap -layout 'us,ru'")

