#!/bin/bash

get_cpu_temp() {
    local temp
    temp=$(sensors 2>/dev/null | awk '/Package id 0/ {print $4}' | tr -d '+°C')
    if [[ -z "$temp" && -f /sys/class/thermal/thermal_zone0/temp ]]; then
        temp=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
    fi
    echo "$temp"
}   

while true; do
    cpu_temp=$(get_cpu_temp)
    if [[ -n "$cpu_temp" ]]; then
        echo "CPU Temperature: ${cpu_temp}°C"
    else
        echo "CPU Temperature: N/A"
    fi
    sleep 5
done

