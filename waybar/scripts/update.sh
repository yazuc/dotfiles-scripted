#!/usr/bin/env bash

# Only run on Arch
[ ! -f /etc/arch-release ] && exit 0

# Detect AUR helper
if command -v yay >/dev/null 2>&1; then
  aurhlpr="yay"
elif command -v paru >/dev/null 2>&1; then
  aurhlpr="paru"
else
  echo "No AUR helper found"
  exit 1
fi

pkg_installed() {
  pacman -Qi "$1" >/dev/null 2>&1
}

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
temp_file="$RUNTIME_DIR/update_info"

fpk_exup="pkg_installed flatpak && flatpak update"

# Upgrade mode
if [ "$1" == "up" ]; then
  if [ -f "$temp_file" ]; then
    trap 'pkill -RTMIN+20 waybar' EXIT

    source "$temp_file"

    command="
        fastfetch
        printf '[Official] %-10s\n[AUR]      %-10s\n[Flatpak]  %-10s\n' '$OFFICIAL_UPDATES' '$AUR_UPDATES' '$FLATPAK_UPDATES'
        ${aurhlpr} -Syu
        $fpk_exup
        read -n 1 -p 'Press any key to continue...'
        "

    kitty --title systemupdate sh -c "${command}"
  else
    echo "Run script once before upgrading."
  fi
  exit 0
fi

# Count AUR updates
aur=$(${aurhlpr} -Qua 2>/dev/null | wc -l)

# Count official updates
temp_db=$(mktemp -u)
CHECKUPDATES_DB="$temp_db" checkupdates 2>/dev/null | wc -l >/tmp/ofc_count
ofc=$(cat /tmp/ofc_count)
rm -f /tmp/ofc_count

# Count flatpak
if pkg_installed flatpak; then
  fpk=$(flatpak remote-ls --updates | wc -l)
  fpk_disp="\n󰏓 Flatpak $fpk"
else
  fpk=0
  fpk_disp=""
fi

# Total
upd=$((ofc + aur + fpk))

# Save state
cat <<EOF >"$temp_file"
OFFICIAL_UPDATES=$ofc
AUR_UPDATES=$aur
FLATPAK_UPDATES=$fpk
EOF

# Output for Waybar
if [ "$upd" -eq 0 ]; then
  echo "{\"text\":\" \", \"tooltip\":\" Packages are up to date\"}"
else
  echo "{\"text\":\"󰮯 $upd\", \"tooltip\":\"󱓽 Official $ofc\n󱓾 AUR $aur$fpk_disp\"}"
fi
