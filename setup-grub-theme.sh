#!/bin/bash

# Set variables
THEME_NAME="gurraoptimus-theme"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
BACKGROUND_IMAGE="background.png"
FONT_FILE="font.pf2"
TTF_FONT="Jersey15-Regular.ttf"
ICONS_DIR="icons"

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

# Check for required files
if [[ ! -f "$BACKGROUND_IMAGE" ]]; then
    echo "Error: Background image '$BACKGROUND_IMAGE' not found."
    exit 1
fi

if [[ ! -f "$TTF_FONT" ]]; then
    echo "Error: Font file '$TTF_FONT' not found."
    exit 1
fi

if [[ ! -d "$ICONS_DIR" ]]; then
    echo "Error: Icons directory '$ICONS_DIR' not found."
    exit 1
fi

# Create the theme directory
echo "Creating theme directory at $THEME_DIR..."
mkdir -p "$THEME_DIR/$ICONS_DIR"

# Copy assets
echo "Copying assets to $THEME_DIR..."
cp "$BACKGROUND_IMAGE" "$THEME_DIR/"
cp -r "$ICONS_DIR/"* "$THEME_DIR/$ICONS_DIR/"

# Generate font file
echo "Generating GRUB font from $TTF_FONT..."
grub-mkfont -o "$FONT_FILE" "$TTF_FONT"
mv "$FONT_FILE" "$THEME_DIR/"

# Create theme.txt
echo "Creating theme.txt..."
cat <<EOL > "$THEME_DIR/theme.txt"
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
sed -i '/^GRUB_THEME=/d' /etc/default/grub || true
echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" >> /etc/default/grub

# Update GRUB
echo "Updating GRUB..."
update-grub

# Completion message
echo "GRUB theme setup complete! Reboot to see the changes."
