#!/usr/bin/env bash

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
BINDING="<Control><Alt>t"
COMMAND="gnome-terminal --working-directory=$HOME"

# Get existing custom keybindings
EXISTING=$(gsettings get $SCHEMA custom-keybindings)

# Convert to Bash array safely
EXISTING_ARRAY=()
# Remove [ ] and split by comma
for item in ${EXISTING//[\[\]\'\ ]/}; do
    [[ -n "$item" ]] && EXISTING_ARRAY+=("$item")
done

# Add custom0 if not already present
if [[ ! " ${EXISTING_ARRAY[@]} " =~ " ${KEY_PATH} " ]]; then
    EXISTING_ARRAY+=("$KEY_PATH")
fi

# Rebuild GNOME list format
NEW_LIST="["
for item in "${EXISTING_ARRAY[@]}"; do
    NEW_LIST+="'$item', "
done
NEW_LIST="${NEW_LIST%, }]"  # remove trailing comma

# Apply the new list
gsettings set $SCHEMA custom-keybindings "$NEW_LIST"

# Set the shortcut properties
gsettings set $SCHEMA.custom-keybinding:$KEY_PATH name "Terminal"
gsettings set $SCHEMA.custom-keybinding:$KEY_PATH command "$COMMAND"
gsettings set $SCHEMA.custom-keybinding:$KEY_PATH binding "$BINDING"

echo "Ctrl+Alt+T shortcut added"
