#!/bin/bash

APPPATH="${HOME}/.local/share/applications/"
updated=false

get_setting(){
    key=$1
    confFile=$2

    echo $(grep "^${key}=" "${confFile}" | sed "s/${key}.*=//")
}

for file in $( ls "${APPPATH}" | grep -i "chrom" ) ; do
    
    desktopFile="${APPPATH}/${file}"

    echo "$file"

    appName=$(get_setting "Name" "${desktopFile}")
    echo " # App Name: ${appName}"

    icon=$(get_setting "Icon" "${desktopFile}")
    echo "  - Icon: $icon"

    if [[ "$icon" == /* ]]; then
        iconName=$(basename "$icon" .png)
    else
        iconName="$icon"
    fi

    wmClass=$(get_setting "StartupWMClass" "${desktopFile}")
    echo "  - Window Class: $wmClass"

    fileUpdated=false

    # Normalize Icon field if it's currently a full path
    if [[ "$icon" != "$iconName" ]]; then
        echo "  -> Normalizing Icon to $iconName"
        sed -i "s|^Icon=.*|Icon=$iconName|" "${desktopFile}"
        fileUpdated=true
    fi

    # Align StartupWMClass with icon name
    if [[ "$iconName" != "$wmClass" ]]; then
        echo "  -> Updating StartupWMClass to $iconName"
        sed -i "s|^StartupWMClass=.*|StartupWMClass=$iconName|" "${desktopFile}"
        fileUpdated=true
    fi

    if [ "$fileUpdated" = true ]; then
        updated=true
    else
        echo "  !! No Update Needed"
    fi

done

# Refresh desktop database and icon cache only if changes were made
if [ "$updated" = true ]; then
    echo "Updates detected. Refreshing desktop database and icon cache..."
    update-desktop-database "${APPPATH}"
    gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor"
    echo "Done!"
else
    echo "No desktop files changed. Skipping database refresh."
fi
