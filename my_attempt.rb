require "http"
require "json"
require "active_support/all"

def float_to_percent(input)
input = (input * 100).to_fs(:percentage, { :precision => 0 } )
end


pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_key = ENV.fetch("GMAPS_KEY")

puts "--------------------------
Will you need an umbrella?
--------------------------"
pp "What is your location?"
user_location = gets.capitalize.chomp

#gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + gmaps_key
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"
raw_response = HTTP.get(gmaps_url)
parsed_response = JSON.parse(raw_response)
results = parsed_response.fetch("results")
results_array_to_hash = results.at(0)
geometry = results_array_to_hash.fetch("geometry")
location = geometry.fetch("location")
lat = location.fetch("lat")
lng = location.fetch("lng")
puts "Checking the weather at #{user_location}!"
puts "Location: latitude is #{lat}, longitude is #{lng}"

hourly_array = []
x = 0
umbrella = false
#pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_key + "/" + lat.to_s + "," + lng.to_s
pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{lat},#{lng}"
raw_response = HTTP.get(pirate_weather_url)
parsed_response = JSON.parse(raw_response)
currently_hash = parsed_response.fetch("currently")
current_summary = currently_hash.fetch("summary")
current_rain_chance = currently_hash.fetch("precipProbability")
current_rain_chance = float_to_percent(current_rain_chance)
if current_summary == "Rain"
  puts "It's currently raining!"
else
  puts "Current weather is #{current_summary}, with a #{current_rain_chance} chance of rain."
end
hourly_hash = parsed_response.fetch("hourly")
hourly_data_array = hourly_hash.fetch("data")
13.times {
  hourly_data_array_to_hash = hourly_data_array.at(x)
  hourly_data_rain_chance = hourly_data_array_to_hash.fetch("precipProbability")
  hourly_array.push(hourly_data_rain_chance)
  x = x + 1
}
x = 1
12.times {
  if hourly_array.at(x) > 0.1
    puts "The rain chance is #{float_to_percent(hourly_array.at(x))} in #{x} hour(s)"
    x = x + 1
    umbrella = true
  else
    x = x + 1
  end
}
if umbrella == true
  puts "You should bring an umbrella today!"
else
  puts "No rain within the next 12 hours..."
  puts "You shouldn't need an umbrella today!"
end
