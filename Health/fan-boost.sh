#!/bin/bash

# 0. Safety Check: Must be root
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: You must run this with sudo."
  exit 1
fi

FAN_FILE="/proc/acpi/ibm/fan"

# 1. Unlock Check (Only runs if needed)
if ! echo "level auto" 2>/dev/null > "$FAN_FILE"; then
    if [ ! -f "/etc/modprobe.d/thinkpad_acpi.conf" ]; then
        echo "options thinkpad_acpi fan_control=1" > "/etc/modprobe.d/thinkpad_acpi.conf"
    fi
    modprobe -r thinkpad_acpi 2>/dev/null
    modprobe thinkpad_acpi
    sleep 1
fi

# 2. Get Actual Speed
CURRENT_RPM=$(awk '/speed:/ {print $2}' "$FAN_FILE")
# Fallback to 0 if empty
CURRENT_RPM=${CURRENT_RPM:-0}

echo "📊 Current RPM: $CURRENT_RPM"

# 3. Toggle based on RPM
# If fan is screaming (>5000 RPM), turn it down.
# If fan is normal (<5000 RPM), turn it up.
if [ "$CURRENT_RPM" -gt 5000 ]; then
    echo "level auto" > "$FAN_FILE"
    echo "✅ Fan High ($CURRENT_RPM RPM) -> Switching to AUTO (Silent/BIOS)."
else
    echo "level disengaged" > "$FAN_FILE"
    echo "🚀 Fan Low ($CURRENT_RPM RPM) -> Switching to DISENGAGED (Max Speed)."
fi

# 4. Verify
sleep 0.5
NEW_SPEED=$(awk '/speed:/ {print $2}' "$FAN_FILE")
echo "   New RPM: $NEW_SPEED (It takes a few seconds to spin up/down)"
