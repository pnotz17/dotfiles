#!/bin/bash
#xclip,dunst,libnotify REQUIRED
selection=$(cat ~/.local/bin/emoji-list | dmenu -l 30)
echo $selection | awk '{print $1}' | tr -d '\n' | xclip -selection clipboard
notify-send "$selection"
