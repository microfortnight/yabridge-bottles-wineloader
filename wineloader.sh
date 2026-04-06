#!/bin/bash
YQ=$(command -v yq)
if [ -z "$YQ" ]; then
  echo "Error: yq is not installed." >&2
  exit 1
fi

SYSTEM_WINE=$(command -v wine)

call_system_wine() {
    if [ -n "$SYSTEM_WINE" ]; then
        exec "$SYSTEM_WINE" "$@"
    else
        echo "Error: system wine is not installed." >&2
        exit 1
    fi
}

# Parses the custom_bottles_path from a data.yml file ($1), returns empty string if missing or null
resolve_custom_bottles_root() {
    yq -r '.custom_bottles_path // ""' "$1" 2>/dev/null || echo ""
}

# Tests if the provided BOTTLES_ROOT path ($1) contains the specific bottle name ($2)
bottle_path_exists() {
    [[ -n "$1" && -d "${1}/${2}" ]]
}

# If bottle.yml exists in the prefix, use the "runner" specified there
if [[ -e "${WINEPREFIX}/bottle.yml" ]]; then
    # Parse runner and path from bottle.yml
    RUNNER=$(yq -r ".Runner" "${WINEPREFIX}/bottle.yml")
    BOTTLE_PATH=$(yq -r ".Path" "${WINEPREFIX}/bottle.yml")
    BOTTLE_PATH=$(basename "$BOTTLE_PATH")

    # Parse custom bottle path from data.yml
    if [[ -e "$HOME/.var/app/com.usebottles.bottles/data/bottles/data.yml" ]]; then
        IS_FLATPAK=true
        CUSTOM_BOTTLES_PATH=$(resolve_custom_bottles_root "$HOME/.var/app/com.usebottles.bottles/data/bottles/data.yml")

    elif [[ -e "$HOME/.local/share/bottles/data.yml" ]]; then
        IS_FLATPAK=false
        CUSTOM_BOTTLES_PATH=$(resolve_custom_bottles_root "$HOME/.local/share/bottles/data.yml")

    else
        CUSTOM_BOTTLES_PATH=""

    fi

    # Locate BOTTLES_ROOT
    if [[ "$IS_FLATPAK" == true ]] && bottle_path_exists "$CUSTOM_BOTTLES_PATH" "$BOTTLE_PATH"; then
        BOTTLES_ROOT="$HOME/.var/app/com.usebottles.bottles/data/bottles/"

    elif [[ "$IS_FLATPAK" == false ]] && bottle_path_exists "$CUSTOM_BOTTLES_PATH" "$BOTTLE_PATH"; then
        BOTTLES_ROOT="$HOME/.local/share/bottles"

    elif bottle_path_exists "$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles" "$BOTTLE_PATH"; then
        BOTTLES_ROOT="$HOME/.var/app/com.usebottles.bottles/data/bottles/"

    elif bottle_path_exists "$HOME/.local/share/bottles/bottles" "$BOTTLE_PATH"; then
        BOTTLES_ROOT="$HOME/.local/share/bottles"

    else
        echo "Error: BOTTLES_ROOT not found." >&2
        exit 1

    fi

    # Bottles uses "sys-*" (e.g. "sys-wine-9.0") internally to refer to system wine
    # Also fall back to system wine if runner is empty.
    if [[ -z "$RUNNER" || "$RUNNER" == sys-* ]]; then
        call_system_wine "$@"

    else
        exec "$BOTTLES_ROOT/runners/$RUNNER/bin/wine" "$@"

    fi

# Uncomment below, to assign a custom wine version to this wineprefix
#elif [ "$WINEPREFIX" == "/path/to/your/wineprefix" ]; then
#    exec /path/to/your/bin/wine "$@"

else
    call_system_wine "$@"

fi

