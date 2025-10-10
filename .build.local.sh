#!/bin/bash
# ==== ./.build.local.sh ====
# Local build hooks for autonomo-file-writer
# This file is sourced by build.sh when present.
#
# Available hooks:
#   post_build_hook() - Called after successful builds
#
# This file is optional and can be used to customize build behavior
# without modifying the main build.sh script.
# ============================================================================

# Hook function called after successful builds (both debug and release)
function post_build_hook() {
    kill_running_instance
}

# Kills any running instances of autonomo-file-writer
function kill_running_instance() {
    # Use pkill for simpler process killing (if available)
    if command -v pkill &> /dev/null; then
        echo "💀 Searching for running instances..."
        if pkill -TERM -f "autonomo-file-writer" 2>/dev/null; then
            echo "   ✅ Sent SIGTERM to running instance(s)"
            sleep 1
            
            # Force kill any remaining processes
            pkill -KILL -f "autonomo-file-writer" 2>/dev/null
        else
            echo "ℹ️  No running instances found"
        fi
    else
        # Fallback to ps + kill
        local pids=$(ps aux | grep '[a]utonomo-file-writer' | awk '{print $2}')
        
        if [ -z "$pids" ]; then
            echo "ℹ️  No running instances found"
            return 0
        fi
        
        for pid in $pids; do
            echo "💀 Killing running instance (PID: $pid)..."
            kill -TERM $pid 2>/dev/null
            sleep 0.5
            kill -KILL $pid 2>/dev/null
        done
        
        sleep 1
    fi
}
