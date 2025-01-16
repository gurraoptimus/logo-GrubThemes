#!/bin/bash

# Set variables
THEME_NAME="gurraoptimus-theme"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
BACKGROUND_IMAGE="background.png"
FONT_FILE="font.pf2"
TTF_FONT="your-font.ttf"  # Ensure this is set to your-font.ttf
ICONS_DIR="icons"

# Create the theme directory
echo "Creating theme directory at $THEME_DIR..."
sudo mkdir -p "$THEME_DIR/$ICONS_DIR"

# Copy assets
echo "Copying assets to $THEME_DIR..."
sudo cp "$BACKGROUND_IMAGE" "$THEME_DIR/"
sudo cp -r "$ICONS_DIR/"* "$THEME_DIR/$ICONS_DIR/"

# Generate font file
if [[ -f "$TTF_FONT" ]]; then
    echo "Generating GRUB font from $TTF_FONT..."
    grub-mkfont -o "$FONT_FILE" "$TTF_FONT"
    sudo mv "$FONT_FILE" "$THEME_DIR/"
else
    echo "Font file $TTF_FONT not found. Skipping font generation."
fi

# Create theme.txt
echo "Creating theme.txt..."
cat <<EOL | sudo tee "$THEME_DIR/theme.txt" > /dev/null
# theme.txt - GRUB Theme Configuration

# Background Image
desktop-image: "$BACKGROUND_IMAGE"

# Fonts
title-font: "$FONT_FILE"
menu-font: "$FONT_FILE"

# Menu Styling
menu {
    horizontal-align: center;
    vertical-align: center;
    width: 50%;
    height: auto;
    item-height: 40;
    margin: 10;
    padding: 5;
    icon-size: 32;
    item-border-width: 1;

    # Colors
    background-color: "black";
    border-color: "gray";
    color: "white";                  # Normal menu item color
    selected-color: "cyan";          # Highlighted menu item color
    selected-background-color: "blue";  # Background for the selected menu item
}

# Icons for Menu Entries
+ boot_menu {
    item {
        name: "Ubuntu";
        icon: "$ICONS_DIR/linux.png";
    }
    item {
        name: "Windows";
        icon: "$ICONS_DIR/windows.png";
    }
    item {
        name: "Recovery";
        icon: "$ICONS_DIR/recovery.png";
    }
}

# Timeout Box
+ timeout_box {
    horizontal-align: center;
    vertical-align: bottom;
    width: 20%;
    height: 50px;
    background-color: "black";
    border-color: "white";
    foreground-color: "cyan";
    text-color: "yellow";
}
EOL

# Configure GRUB to use the theme
echo "Configuring GRUB to use the new theme..."
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null

# Update GRUB
echo "Updating GRUB..."
sudo update-grub

# Completion message
echo "GRUB theme setup complete! Reboot to see the changes."
