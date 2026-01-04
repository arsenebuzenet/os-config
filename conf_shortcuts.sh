#!/bin/bash

# Script to add Ctrl+Alt+T shortcut for opening terminal in Fedora 43
# This configures GNOME's custom keyboard shortcuts

echo "Adding Ctrl+Alt+T keyboard shortcut to open terminal..."

# Get the current list of custom keybindings
CUSTOM_KEYBINDINGS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# Define the new keybinding path
NEW_BINDING="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"

# Check if custom0 already exists in the list
if [[ $CUSTOM_KEYBINDINGS == *"custom0"* ]]; then
    echo "Warning: custom0 keybinding already exists. Using it anyway..."
    # You might want to use a different number like custom1, custom2, etc.
fi

# Add the new binding to the list if not already there
if [[ $CUSTOM_KEYBINDINGS == "@as []" ]] || [[ $CUSTOM_KEYBINDINGS == "[]" ]]; then
    # List is empty
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$NEW_BINDING']"
elif [[ $CUSTOM_KEYBINDINGS != *"$NEW_BINDING"* ]]; then
    # Add to existing list
    NEW_LIST=$(echo $CUSTOM_KEYBINDINGS | sed "s/]/, '$NEW_BINDING']/")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"
fi

# Set the name, command, and binding for the new shortcut
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_BINDING name "Open Terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_BINDING command "ptyxis"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$NEW_BINDING binding "<Primary><Alt>t"

echo "Done! Ctrl+Alt+T is now configured to open the terminal."
echo "The shortcut should work immediately without requiring a logout."