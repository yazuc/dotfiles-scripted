#!/bin/bash

device=$(upower -e | grep -i mouse)

if [[ -n "$device" ]]; then
    level=$(upower -i "$device" | awk '/percentage/ {print $2}')
    echo "🖱 $level"
else
    echo "🖱 N/A"
fi

