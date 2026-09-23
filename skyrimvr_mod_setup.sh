#!/bin/bash

SKYRIM_VR_APP_ID=611670
TMP_DIR="/tmp/skyrim_mod_setup_script"
MOD_ORG_2_REPO="ModOrganizer2/modorganizer"
DEFAULT_STEAM_DIR="$HOME/.steam/steam"
SKYRIM_VR_BIN_DIR="$DEFAULT_STEAM_DIR/steamapps/common/SkyrimVR"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_DIR="$SCRIPT_DIR/files"

if which dpkg >/dev/null 2>&1; then
    echo "- Found Debian/Ubuntu based distro"
    if ! dpkg -s protontricks >/dev/null 2>&1; then
        echo "> Installing protontricks..."
        sudo apt install protontricks
    else
        echo "- Protontricks is already installed"
    fi
elif which dnf >/dev/null 2>&1; then
    echo "Found Fedora/RHEL/CentOS based distro"
    if ! dnf list installed protontricks >/dev/null 2>&1; then
        echo "> Installing protontricks..."
        sudo dnf install protontricks
    sudo dnf install p7zip p7zip-plugins
    else
        echo "- Protontricks is already installed"
    fi
elif [ 1 -eq 2 ]; then
    echo "- Skipped dependencie collection..."
else
    echo "~ Unsupported distro"
    echo "- Please feel free to adjust the script by your needs (:"
    exit 1
fi

echo "> Creating temp dir at $TMP_DIR. It will be removed after the operation!"
rm -rf $TMP_DIR #deleted temp dir if already exists
mkdir $TMP_DIR

mod_org_2_version=$(curl -s "https://api.github.com/repos/$MOD_ORG_2_REPO/releases/latest" | jq -r '.tag_name')
echo "> Downloading latest version ($mod_org_2_version) ModOrganizer2 from github"
#mod_org_2_url=$(curl -s "https://api.github.com/repos/$MOD_ORG_2_REPO/releases/latest" | grep "browser_download_url.*.exe" | cut -d '"' -f 4)
mo_2_exe_file="Mod.Organizer-${mod_org_2_version#v}.exe"
mod_org_2_url="https://github.com/ModOrganizer2/modorganizer/releases/download/$mod_org_2_version/$mo_2_exe_file"

if ! curl -L -o "$TMP_DIR/$mo_2_exe_file" "$mod_org_2_url"; then
    echo "~ Failed to downloaind MO2. Exiting..."
    exit 1
fi

echo "- Download done!"
echo "> retrieveing skyrim vr steam dir..."

if [[ ! -d "$DEFAULT_STEAM_DIR" ]]; then
    echo "~ Default steam dir at $DEFAULT_STEAM_DIR does not exists. Please re-definde the DEFAULT_STEAM_DIR constant!"
    exit 1
fi

skyrim_vr_prefix_drive="$DEFAULT_STEAM_DIR/steamapps/compatdata/$SKYRIM_VR_APP_ID/pfx/drive_c"

if [[ ! -d "$skyrim_vr_prefix_drive" ]]; then
    echo "~ Could not find proton prefix of Skyrim VR. Please make sure you have installed it over steam!"
    exit 1
fi

echo -e "\033[0;33m!Important: Set C:\ModOrganizer2 as the ModOrganizer2 instalation directory...\033[0m"
sleep 5
echo -e "\n> launching MO2 wizard. Please continue in the wizard GUI"
sleep 2

if ! protontricks-launch --appid "$SKYRIM_VR_APP_ID" "$TMP_DIR/$mo_2_exe_file"; then
    echo "~ Unexpected error while lauching MO2 wizard"
    exit 1
fi

mo2_exe="$skyrim_vr_prefix_drive/ModOrganizer2/ModOrganizer.exe"

if [[ ! -f "$mo2_exe" ]]; then
    echo -e "\n~ ModOrgnizer2 could not be started initially. Please make shure you've installed it at C:\ModOrganizer2!"
    exit 1
fi

echo -e "\n\n- ModOrganizer2 successfully installed"

skse_url=$(curl -s "https://skse.silverlock.org/" | grep -o 'href="[^"]*sksevr_[^"]*\.7z"' | head -1 | cut -d'"' -f2)
echo -e "\n> Downloading skse for vr..."
if ! curl -L -o "$TMP_DIR/sksevr_latest.7z" "$skse_url"; then
    echo "~ Failed to downloaind SKSE VR. Exiting..."
    exit 1
fi

echo "> Installing SKSE VR..."
chmod 764 "$TMP_DIR/sksevr_latest.7z" >/dev/null 2>&1
skse_archive_dir="$TMP_DIR/sksevr_latest"
7z x "$TMP_DIR/sksevr_latest.7z" -o"$skse_archive_dir" >/dev/null 2>&1
skse_root_dir="$skse_archive_dir/$(7z l -ba "$TMP_DIR/sksevr_latest.7z" | awk 'NR==1 {print $6}')"
if ! cp -r --update=none $skse_root_dir/* "$SKYRIM_VR_BIN_DIR"; then

    echo "~ Unexpected error while installing skse! Please verify sksevr_latest.7z|$skse_root_dir and that SkyrimVR is installed correctly!"
    exit 1
fi

mkdir -p "$SKYRIM_VR_BIN_DIR/Data/SKSE/Plugins"
cp "$FILE_DIR/SKSE.ini" "$SKYRIM_VR_BIN_DIR/Data/SKSE/"
mv "$SKYRIM_VR_BIN_DIR/SkyrimVR.exe" "$SKYRIM_VR_BIN_DIR/SkyrimVRGame.exe"
chmod 764 "$SKYRIM_VR_BIN_DIR/sksevr_loader.exe"
mv "$SKYRIM_VR_BIN_DIR/sksevr_loader.exe" "$SKYRIM_VR_BIN_DIR/SkyrimVR.exe"
#ln -s "$SKYRIM_VR_BIN_DIR/sksevr_loader.exe" "$SKYRIM_VR_BIN_DIR/SkyrimVR.exe"
echo -e "- SKSEVR successfully installed"

echo -e "- Press return to create a new MO2 intance... [Return]"; read -rsn1

protontricks-launch --appid "$SKYRIM_VR_APP_ID" "$mo2_exe"
echo -e "#/bin/bash\nprotontricks-launch --appid $SKYRIM_VR_APP_ID $mo2_exe" > $SKYRIM_VR_BIN_DIR/ModOrganizer2.sh
chmod 764 $SKYRIM_VR_BIN_DIR/ModOrganizer2.sh
