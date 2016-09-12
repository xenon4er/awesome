local wibox = require("wibox")
local awful = require("awful")



volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")
 
volume_widget_front = wibox.widget.textbox()
volume_widget:set_align("right")


function update_volume(widget, chanel)
   local fd = io.popen("amixer sget " .. chanel)
   local status = fd:read("*all")
   fd:close()
 
   local label = string.sub(chanel,0,1) .. ":"

   -- local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
   local volume = string.match(status, "(%d?%d?%d)%%")
   volume = string.format("% 3d", volume)
 
   status = string.match(status, "%[(o[^%]]*)%]")

   if string.find(status, "on", 1, true) then
       -- For the volume numbers
       volume = volume .. "%"
   else
       -- For the mute button
       volume = volume .. "M"
       
   end
   widget:set_markup(label .. volume)
end

update_volume(volume_widget, "Master")
update_volume(volume_widget_front, "Front")


mytimer = timer({ timeout = 0.2 })
mytimer:connect_signal("timeout", function () update_volume(volume_widget, "Master") update_volume(volume_widget_front, "Front") end)
mytimer:start()

