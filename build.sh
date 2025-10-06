#!/bin/bash
# ==== build.sh ====
# This script monitors the 'src' directory for changes in Rust files
# and automatically rebuilds the project.
#
# Usage:
#   ./build.sh          - Monitor and rebuild in debug mode (default)
#   ./build.sh release  - Build the release version once and exit
#
# To exit the monitoring loop, press CTRL+C.

# Check if inotifywait is installed
if [ -z "$(which inotifywait)" ]; then
    echo "inotifywait not installed."
    echo "Install the inotify-tools package (e.g., 'sudo apt install inotify-tools') and try again."
    exit 1
fi

# Directory to monitor for changes
dir="./src"

function build() {
    echo "🔨 Building autonomo-file-writer..."
    # Only build debug version (faster, and it's what we run during development)
    if cargo build; then
        echo "✅ Build successful!"
        echo "   Run with: ./target/debug/autonomo-file-writer"
    else
        echo "❌ Build failed!"
    fi
    echo ""
}

function build_release() {
    echo "🚀 Building RELEASE version..."
    if cargo build --release; then
        echo "✅ Release build successful!"
        echo "   Binary: ./target/release/autonomo-file-writer"
    else
        echo "❌ Release build failed!"
    fi
    echo ""
}

# If "release" argument provided, build release and exit
if [ "$1" == "release" ]; then
    build_release
    exit 0
fi

# Initial build
build

echo "👀 Watching for changes in $dir..."
echo "   Press CTRL+C to stop watching and exit."
echo ""

# Set a trap to ensure a clean exit message if CTRL+C (SIGINT) is pressed.
# When inotifywait receives SIGINT, it will terminate, and this trap will fire.
trap "echo -e '\n🛑 Exiting watch. Goodbye!'; exit 0" SIGINT

# Run inotifywait and its processing loop in the foreground.
# The script will block here until inotifywait exits (e.g., via CTRL+C).
inotifywait --recursive --monitor --format "%e %w%f" \
    --event modify,move,create,delete "$dir" \
    --include '\.rs$' |
    while read -r changed; do
        echo "📝 Detected change: $changed"
        build
    done

# This line is generally not reached under normal operation as the trap handles exit.
exit 0
