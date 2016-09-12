local gears = require("gears")
local naughty = require("naughty")

-- scan directory, and optionally filter outputs
local scandir = function(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

-- set wallpaper
local  wp_set = function(wp_path, wp_files)
    local wp_index = math.random( 1, #wp_files)
    for s = 1, screen.count() do
        gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
    end
end 
-- }}}

-- configuration - edit to your liking
local wp_index = 1
local wp_timeout  = 60*10
local wp_path = "/home/alex/wallpaper/"
local wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
local wp_files = scandir(wp_path, wp_filter)
math.randomseed(os.time())

--first run background
 
-- setup the timer
local wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
 
  -- set wallpaper to current index for all screens
  wp_set(wp_path, wp_files)
 
  -- stop the timer (we don't need multiple instances running at the same time)
  wp_timer:stop()
  
  --restart the timer
  wp_timer.timeout = wp_timeout
  wp_timer:start()
end)


function wallpaper_run()
  wp_timer:start()
  wp_set(wp_path, wp_files)
end


-- initial start when rc.lua is first run
--}}