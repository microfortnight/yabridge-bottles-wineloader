#!/bin/bash
YQ=$(command -v yq)
if [ -z "$YQ" ]; then
  echo "Error: yq is not installed." >&2
  exit 1
fi

SYSTEM_WINE=$(command -v wine)
if [ -z "$SYSTEM_WINE" ]; then
  echo "Error: wine is not installed." >&2
  exit 1
fi

# If bottle.yml exists in the prefix, use the "runner" specified there
if [[ -e "${WINEPREFIX}/bottle.yml" ]]; then
    # Parse runner from bottle.yml
    RUNNER=$(yq -r ".Runner" "${WINEPREFIX}/bottle.yml")

    # Bottles uses "sys-*" (e.g. "sys-wine-9.0") internally to refer to system wine
    # Also fall back to system wine if runner is empty.
    if [[ -z "$RUNNER" || "$RUNNER" == sys-* ]]; then
        # Use system wine 
        exec "$SYSTEM_WINE" "$@"

    else
        # Bottles root directory is two directories up
        BOTTLES_ROOT="$(dirname "$(dirname "$WINEPREFIX")")"
        exec "$BOTTLES_ROOT/runners/$RUNNER/bin/wine" "$@"

    fi

# Uncomment below, to assign a custom wine version to this wineprefix
#elif [ "$WINEPREFIX" == "/path/to/your/wineprefix" ]; then
#    exec /path/to/your/bin/wine "$@"

else
    exec "$SYSTEM_WINE" "$@"

fi

