#!/bin/bash

case "$1" in
"reload")
  aerospace reload-config
  sketchybar --set aerospace popup.drawing=off
  ;;
"quit")
  pkill -f "aerospace"
  ;;
*)
  sketchybar --set aerospace popup.drawing=toggle
  ;;
esac
