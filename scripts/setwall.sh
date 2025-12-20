#!/bin/bash
# Set wallpaper and update dwm colors live
# Usage: setwall.sh [image_path_or_directory]
#        setwall.sh                        - random from default directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_WAL_DIR="$HOME/Pictures/wal"

show_help() {
    echo "Usage: setwall.sh [OPTIONS] [PATH]"
    echo ""
    echo "Set wallpaper and automatically update dwm colors to match (live!)."
    echo ""
    echo "Options:"
    echo "  --help, -h           Show this help message"
    echo ""
    echo "Examples:"
    echo "  setwall.sh /path/to/image.jpg       Set specific wallpaper"
    echo "  setwall.sh ~/Wallpapers             Random from specified directory"
    echo "  setwall.sh                          Random from $DEFAULT_WAL_DIR"
}

# Get a random image from directory
get_random_image() {
    local dir="${1:-$DEFAULT_WAL_DIR}"

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory not found: $dir" >&2
        return 1
    fi

    # Find image files
    local image=$(find "$dir" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.gif" -o \
        -iname "*.bmp" -o \
        -iname "*.webp" \
    \) 2>/dev/null | shuf -n 1)

    if [[ -z "$image" ]]; then
        echo "Error: No images found in $dir" >&2
        return 1
    fi

    echo "$image"
}

# Set wallpaper with feh (same image on all monitors)
set_wallpaper() {
    local image="$1"

    if [[ ! -f "$image" ]]; then
        echo "Error: Image not found: $image" >&2
        return 1
    fi

    echo "Setting wallpaper: $image"
    feh --no-fehbg --bg-fill "$image"
    # Write correct fehbg for future use
    echo "#!/bin/sh" > ~/.fehbg
    echo "feh --no-fehbg --bg-fill '$image'" >> ~/.fehbg
    chmod +x ~/.fehbg
}

# Main function
main() {
    local image=""
    local target=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done

    # Determine image to use
    if [[ -z "$target" ]]; then
        # No argument: random from default directory
        image=$(get_random_image "$DEFAULT_WAL_DIR")
    elif [[ -d "$target" ]]; then
        # Directory given: pick random from it
        image=$(get_random_image "$target")
    elif [[ -f "$target" ]]; then
        # File given: use it directly
        image="$target"
    else
        echo "Error: Path not found: $target" >&2
        exit 1
    fi

    if [[ -z "$image" ]]; then
        exit 1
    fi

    # Set the wallpaper
    set_wallpaper "$image" || exit 1

    # Extract colors and update dwm (live!)
    echo ""
    "$SCRIPT_DIR/wal-colors.sh" "$image"
}

main "$@"
