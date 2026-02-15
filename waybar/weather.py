import json
import requests

# Map wttr.in weather codes to icons
# You can change these icons to match your font (like Font Awesome or Nerd Fonts)
ICON_MAP = {
    "Overcast": "☁️", 
    "Cloudy": "☁️",
    "Fog": "🌫",
    "HeavyRain": "🌧",
    "HeavyShowers": "🌦",
    "HeavySnow": "❄️",
    "LightRain": "🌦",
    "LightShowers": "🌦",
    "LightSleet": "🌧",
    "LightSnow": "🌨",
    "PartlyCloudy": "⛅",
    "Sunny": "☀️",
    "ThunderyHeavyRain": "⛈",
    "ThunderyShowers": "⛈",
    "VeryCloudy": "☁️",
}

try:
    # Change 'New_York' to your city
    data = requests.get("https://wttr.in/New_York?format=j1").json()
    current = data['current_condition'][0]
    temp = current['temp_C']
    
    # Get the weather description and find the icon
    desc = current['weatherDesc'][0]['value'].replace(" ", "")
    icon = ICON_MAP.get(desc, "🌡️") # Defaults to thermometer if code not found

    # Waybar JSON output
    out = {
        "text": f"{icon} {temp}°C",
        "tooltip": f"{current['weatherDesc'][0]['value']} | Feels like {current['FeelsLikeC']}°C"
    }
    print(json.dumps(out))
except Exception as e:
    print(json.dumps({"text": "N/A", "tooltip": str(e)}))
