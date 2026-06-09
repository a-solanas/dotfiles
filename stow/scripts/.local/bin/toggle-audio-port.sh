#!/bin/bash
SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"
CURRENT=$(pactl list sinks | awk "/Name: $SINK/{found=1} found && /Active Port:/{print \$NF; exit}")

if [ "$CURRENT" = "analog-output-headphones" ]; then
    pactl set-sink-port "$SINK" analog-output-lineout
    notify-send -t 1000 -i audio-card "Audio Output" "Line Out"
else
    pactl set-sink-port "$SINK" analog-output-headphones
    notify-send -t 1000 -i audio-card "Audio Output" "Headphones"
fi
