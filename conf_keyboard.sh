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

echo "Adding Caps Lock for numbers..."
#!/bin/bash

FR_SYMBOLS="/usr/share/X11/xkb/symbols/fr"
# Check only lines 1-9 of the fr file
if ! head -n 9 "$FR_SYMBOLS" | grep -qF 'include "mswindows-capslock"'; then
    echo 'Inserting line include "mswindows-capslock" into fr symbols'
    sed -i '/include "latin"/a\    include "mswindows-capslock"' "$FR_SYMBOLS"
fi

# Génération du fichier
echo "// Replicate a \"feature\" of MS Windows on AZERTY keyboards
// where Caps Lock also acts as a Shift Lock on number keys.
// Include keys <AE01> to <AE10> in the FOUR_LEVEL_ALPHABETIC key type.

partial alphanumeric_keys
xkb_symbols \"basic\" {
    key <AE01>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [ ampersand,          1,          bar,   exclamdown ]	};
    key <AE02>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [    eacute,          2,           at,    oneeighth ]	};
    key <AE03>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [  quotedbl,          3,   numbersign,     sterling ]	};
    key <AE04>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [apostrophe,          4,   onequarter,       dollar ]	};
    key <AE05>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [ parenleft,          5,      onehalf, threeeighths ]	};
    key <AE06>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [   section,          6,  asciicircum,  fiveeighths ]	};
    key <AE07>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [    egrave,          7,    braceleft, seveneighths ]	};
    key <AE08>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [    exclam,          8,  bracketleft,    trademark ]	};
    key <AE09>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [  ccedilla,          9,    braceleft,    plusminus ]	};
    key <AE10>	{ type= \"FOUR_LEVEL_ALPHABETIC\", [    agrave,          0,   braceright,       degree ]	};
};"  >  /usr/share/X11/xkb/symbols/mswindows-capslock;

echo "Caps Lock for numbers added"