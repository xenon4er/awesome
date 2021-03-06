
local json = require( "../lib/JSON")  
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")


--http://api.openweathermap.org/data/2.5/weather?q=Voronezh,ru&APPID=0000000000&units=metric

--local lua_value = json:decode(sample_response)
--naughty.notify({text=lua_value.main.temp})

local function set_new_weather(city, appid)
	--naughty.notify({text="set weather"}) 
	
	--get weather from api.openweathermap.org
    local request = "http://api.openweathermap.org/data/2.5/weather?q="..city.."&APPID="..appid.."&units=metric"
	local last_weather_string =	awful.util.pread("curl connect-timeout 1 -fsm 3 '"..request.."'")
	local last_weather_json = json:decode(last_weather_string)

	if last_weather_json then
		last_weather_json.last_update_time = os.time()		
		local last_weather_string = json:encode(last_weather_json)

		--write to file
		local f = io.open (".config/awesome/weather/weather_params.txt", "w")
		io.output(f)
		io.write(last_weather_string)
		io.close(f)
		return last_weather_json 
	else
		return false
	end
	
end

local function get_weather(city, appid, forse)
	local cur_time = os.time()
	local last_weather_string = ""
	local last_weather_json = 0

	local f = io.open (".config/awesome/weather/weather_params.txt", "r")
	for line in f:lines() do last_weather_string = last_weather_string .. line end
	io.close(f)

	if last_weather_string ~= "" and not forse then
		last_weather_json = json:decode(last_weather_string)
		--naughty.notify({text="if != '' "..last_weather_json.last_update_time .. " " .. cur_time}) 
		if os.difftime (cur_time, last_weather_json.last_update_time) >= 10*60 then 
			last_weather_json = set_new_weather(city, appid) 
		end
	else
		last_weather_json = set_new_weather(city, appid) 
		--naughty.notify({text="if == '' "..last_weather_json.last_update_time .. " " .. cur_time}) 
	end

	
	return last_weather_json
end


function weather_widget_run(city, appid)
	local weather_widget = wibox.widget.textbox(t1)
	local t1 = "NA C<sup>o</sup>"

	weather_widget:set_align("right")
	weather_widget:buttons(awful.util.table.join(
	    awful.button({ }, 1, function()
	    	local cur_weather = get_weather(city, appid, true)
			if cur_weather and cur_weather.main then
				t1 = cur_weather.main.temp .. " C<sup>o</sup>"
			else
				t1 = "NA"
			end
			weather_widget:set_markup(t1)	    	
	    end)
	--    awful.button({ }, 5, function()   end)
	))

	local cur_weather = get_weather(city, appid, false)
	if  cur_weather and cur_weather.main then 
		t1 = cur_weather.main.temp .. " C<sup>o</sup>"
	end
	weather_widget:set_markup(t1)

	local mytimer = timer({ timeout = 5*60 })
	mytimer:connect_signal("timeout", function ()
		local cur_weather = get_weather(city, appid, false)
		if  cur_weather and cur_weather.main then 
			t1 = cur_weather.main.temp .. " C<sup>o</sup>"
		else
			t1 = "NA"
		end
		weather_widget:set_markup(t1)
	end)
	mytimer:start()

	return weather_widget

end
--"Voronezh,ru",""

