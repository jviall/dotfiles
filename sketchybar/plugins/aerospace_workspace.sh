#!/usr/bin/env bash

# Get the currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Update the label to show the current workspace
sketchybar --set "$NAME" label="$FOCUSED_WORKSPACE"
