#!/bin/bash
# ==== ./build.sh ====
# Autonomo AI's Rust Multi-Build System
# This script monitors the 'src' directory for changes in Rust files
# and automatically rebuilds the project.
#
# Usage:
#   ./build.sh          - Monitor and rebuild in debug mode (default)
#   ./build.sh release  - Build the release version once and exit
#
# To exit the monitoring loop, press CTRL+C.
# ============================================================================

# Check if inotifywait is installed
if [ -z "$(which inotifywait)" ]; then
    echo "inotifywait not installed."
    echo "Install the inotify-tools package (e.g., 'sudo apt install inotify-tools') and try again."
    exit 1
fi

# Extract binary name from Cargo.toml
if [ ! -f "Cargo.toml" ]; then
    echo "❌ Cargo.toml not found in current directory!"
    exit 1
fi

BINARY_NAME=$(grep -m1 '^name = ' Cargo.toml | sed 's/name = "\(.*\)"/\1/' | tr -d ' ')

if [ -z "$BINARY_NAME" ]; then
    echo "❌ Could not extract package name from Cargo.toml!"
    exit 1
fi

echo "============================================================================"
echo "🌎 Autonomo AI's Rust Multi-Build System"
echo "============================================================================"
echo "📦 Project: $BINARY_NAME"
echo ""

# Check if .build.local.sh exists, if not offer to download it
if [ ! -f ".build.local.sh" ]; then
    echo "📥 .build.local.sh not found."
    echo "   This optional file allows custom post-build actions."
    echo ""
    read -p "   Download example .build.local.sh? [Y/n] " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo "   Downloading from GitHub..."
        
        LOCAL_BUILD_URL="https://raw.githubusercontent.com/AutonomoDev/auto-rust-builder/trunk/.build.local.sh"
        
        if command -v curl &> /dev/null; then
            if curl -fsSL -o .build.local.sh "$LOCAL_BUILD_URL"; then
                chmod +x .build.local.sh
                echo "   ✅ Successfully downloaded .build.local.sh"
                echo "   📝 Edit this file to customize post-build behavior"
                echo ""
            else
                echo "   ⚠️  Failed to download .build.local.sh"
                echo "   You can manually download it from:"
                echo "   $LOCAL_BUILD_URL"
                echo ""
            fi
        elif command -v wget &> /dev/null; then
            if wget -q -O .build.local.sh "$LOCAL_BUILD_URL"; then
                chmod +x .build.local.sh
                echo "   ✅ Successfully downloaded .build.local.sh"
                echo "   📝 Edit this file to customize post-build behavior"
                echo ""
            else
                echo "   ⚠️  Failed to download .build.local.sh"
                echo "   You can manually download it from:"
                echo "   $LOCAL_BUILD_URL"
                echo ""
            fi
        else
            echo "   ⚠️  Neither curl nor wget found. Cannot download automatically."
            echo "   You can manually download it from:"
            echo "   $LOCAL_BUILD_URL"
            echo ""
        fi
    else
        echo "   Skipped. You can download it later from:"
        echo "   https://raw.githubusercontent.com/AutonomoDev/auto-rust-builder/trunk/.build.local.sh"
        echo ""
    fi
fi

# Load local build hooks if present
if [ -f ".build.local.sh" ]; then
    echo "📋 Loading local build hooks from .build.local.sh"
    source .build.local.sh
    LOCAL_HOOKS_LOADED=true
else
    LOCAL_HOOKS_LOADED=false
fi

# Directory to monitor for changes
dir="./src"

function build() {
    echo "🔨 Building $BINARY_NAME (debug)..."
    if cargo build; then
        echo "✅ Build successful!"
        echo "   Run with: ./target/debug/$BINARY_NAME"
        
        # Run post-build hook if available
        if [ "$LOCAL_HOOKS_LOADED" = true ] && type post_build_hook &>/dev/null; then
            post_build_hook
        fi
    else
        echo "❌ Build failed!"
    fi
    echo ""
}

function build_release() {
    echo "🚀 Building $BINARY_NAME (release)..."
    if cargo build --release; then
        echo "✅ Release build successful!"
        echo "   Binary: ./target/release/$BINARY_NAME"
        
        # Run post-build hook if available
        if [ "$LOCAL_HOOKS_LOADED" = true ] && type post_build_hook &>/dev/null; then
            post_build_hook
        fi
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
trap "echo -e '\n🛑 Exiting watch. Goodbye!'; exit 0" SIGINT

# Run inotifywait and its processing loop in the foreground.
inotifywait --recursive --monitor --format "%e %w%f" \
    --event modify,move,create,delete "$dir" \
    --include '\.rs$' |
    while read -r changed; do
        echo "📝 Detected change: $changed"
        build
    done

exit 0

