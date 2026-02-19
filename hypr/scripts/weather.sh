#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# DYNAMIC WEATHER SCRIPT FOR WAYBAR WITH ICONS
# ═══════════════════════════════════════════════════════════════════

UNIT_FILE="$HOME/.cache/weather_unit"
CITY_FILE="$HOME/.cache/weather_city"
[ ! -f "$UNIT_FILE" ] && echo "C" > "$UNIT_FILE"
[ ! -f "$CITY_FILE" ] && echo "New_York" > "$CITY_FILE"
UNIT=$(cat "$UNIT_FILE")
CITY=$(cat "$CITY_FILE")

if [ "$1" = "toggle" ]; then
    if [ "$UNIT" = "C" ]; then
        echo "F" > "$UNIT_FILE"
    else
        echo "C" > "$UNIT_FILE"
    fi
    # Signal waybar to update
    pkill -RTMIN+8 waybar
    exit 0
fi

if [ "$1" = "set-city" ]; then
    # Create a list of common cities for autocompletion
    CITIES_LIST="London
New_York
Paris
Tokyo
Sydney
Berlin
Moscow
Beijing
Mumbai
Dubai
Singapore
Hong_Kong
Toronto
Los_Angeles
Buenos_Aires
Sao_Paulo
Mexico_City
Cairo
Lagos
Istanbul
Bangkok
Jakarta
Manila
Seoul
Bangalore
Chennai
Kolkata
Delhi
Kuala_Lumpur
Shanghai
Guangzhou
Shenzhen
Wuhan
Chengdu
Xi'an
Tianjin
Rome
Madrid
Barcelona
Amsterdam
Brussels
Vienna
Prague
Budapest
Warsaw
Stockholm
Oslo
Copenhagen
Helsinki
Athens
Lisbon
Dublin
Manchester
Birmingham
Glasgow
Liverpool
Leeds
Sheffield
Bristol
Cardiff
Edinburgh
Belfast
Perth
Adelaide
Brisbane
Melbourne
Wellington
Auckland
Christchurch
Vancouver
Montreal
Calgary
Ottawa
Quebec_City
Boston
Chicago
Seattle
San_Francisco
Miami
Atlanta
Dallas
Houston
Phoenix
Denver
Las_Vegas
Portland
Austin
Nashville
Memphis
New_Orleans
San_Diego
Santa_Fe
Salt_Lake_City
Kansas_City
Cincinnati
Cleveland
Detroit
Indianapolis
Milwaukee
Minneapolis
St._Louis
Tampa
Orlando
Charlotte
Raleigh
Richmond
Baltimore
Philadelphia
Washington
San_Jose
Sacramento
Portland
Seattle
Anchorage
Honolulu
San_Juan
Montevideo
Santiago
Lima
Quito
Bogota
Caracas
Georgetown
Paramaribo
Cayenne
Fortaleza
Recife
Salvador
Brasilia
Belgrade
Zagreb
Ljubljana
Sofia
Bucharest
Budapest
Prague
Warsaw
Krakow
Gdansk
Wroclaw
Poznan
Lviv
Kiev
Kharkiv
Odessa
Minsk
Riga
Vilnius
Tallinn
Helsinki
Oslo
Stockholm
Copenhagen
Reykjavik
Tallinn
Riga
Vilnius
Minsk
Kiev
Kharkiv
Odessa
Lviv
Tbilisi
Yerevan
Baku
Ankara
Izmir
Bursa
Adana
Gaziantep
Konya
Antalya
Mersin
Kayseri
Eskisehir
Sanliurfa
Diyarbakir
Samsun
Malatya
Van
Gaziantep
Konya
Antalya
Mersin
Kayseri
Eskisehir
Sanliurfa
Diyarbakir
Samsun
Malatya
Van
Trabzon
Erzurum
Elazig
Manisa
Balikesir
Kahramanmaras
Sakarya
Denizli
Batman
Aydin
Kocaeli
Kutahya
Kirikkale
Karabuk
Bartin
Artvin
Ardahan
Igdir
Kars
Agri
Mus
Bitlis
Hakkari
Sirnak
Siirt
Tunceli
Bingol
Erzincan
Gumushane
Bayburt
Kastamonu
Sinop
Corum
Yozgat
Nigde
Nevsehir
Kirsehir
Aksaray
Karaman
Konya
Karaman
Aksaray
Kirsehir
Nevsehir
Nigde
Yozgat
Corum
Sinop
Kastamonu
Bayburt
Gumushane
Erzincan
Bingol
Tunceli
Sirnak
Hakkari
Bitlis
Mus
Agri
Kars
Igdir
Ardahan
Artvin
Bartin
Karabuk
Kirikkale
Kocaeli
Aydin
Batman
Kahramanmaras
Balikesir
Manisa
Elazig
Erzurum
Trabzon
Van
Malatya
Samsun
Diyarbakir
Sanliurfa
Eskisehir
Kayseri
Mersin
Antalya
Konya
Gaziantep
Adana
Bursa
Izmir
Ankara"

    # Prompt for city input using rofi with autocomplete
    NEW_CITY=$(echo "$CITIES_LIST" | rofi -dmenu -p "Enter city name:" -theme-str 'window { width: 600px; } listview { lines: 10; }')
    
    # Exit if user cancelled or input is empty
    if [ -z "$NEW_CITY" ]; then
        exit 0
    fi
    
    # Validate city by testing wttr.in response
    TEST_RESPONSE=$(curl -s "wttr.in/$NEW_CITY?format=%C" --connect-timeout 5)
    if [ "$TEST_RESPONSE" = "Unknown location;" ]; then
        notify-send "Weather" "City '$NEW_CITY' not found. Please try a different city name." -u critical
        exit 1
    elif [ -z "$TEST_RESPONSE" ]; then
        notify-send "Weather" "Server unresponsive, but city saved: '$NEW_CITY'. Weather may appear later." -u normal
    fi
    
    # Save the new city
    echo "$NEW_CITY" > "$CITY_FILE"
    
    # Signal waybar to update with new city
    pkill -RTMIN+8 waybar
    
    # Show confirmation
    notify-send "Weather" "City changed to $NEW_CITY" -u normal
    
    exit 0
fi

# Fetch weather data
if [ "$UNIT" = "C" ]; then
    weather=$(curl -s --max-time 10 "wttr.in/$CITY?format=%c%t&m")
else
    weather=$(curl -s --max-time 10 "wttr.in/$CITY?format=%c%t&u")
fi

if [ -z "$weather" ]; then
    echo "{\"text\": \"N/A\", \"tooltip\": \"Weather unavailable (timeout or service down)\"}"
    exit 0
fi

# Get location info for tooltip (city format)
location_info=$(curl -s --max-time 10 "wttr.in/$CITY?format=%l" 2>/dev/null | sed 's/_/ /g')

# Output JSON for Waybar
echo "{\"text\": \"$weather\", \"tooltip\": \"$location_info\"}"
