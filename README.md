# Auto Rust Builder

A simple shell script to automate the build process for Rust projects, watching for file changes and performing debug builds on the fly. It also provides an easy way to trigger a release build on demand.

This script is ideal for local development environments where you want immediate feedback on compilation errors or just want your project to be constantly ready to run after a save.

This is an [**Autonomo AI, FZCO**](https://www.autonomo.codes/), project.

100% of this code was written by the Autonomo CLI. Not a single line was written by a human. Not even this README.

## Features

*   **Automatic Debug Builds:** Monitors your `src` directory for changes to `.rs` files and automatically triggers a `cargo build` (debug) upon detection.
*   **Manual Release Build:** Provides an option to build a release version (`cargo build --release`) on demand.
*   **Immediate Exit:** Press `CTRL+C` to terminate the script immediately, stopping the watch loop.
*   **Dependency Check:** Ensures `inotifywait` (from `inotify-tools`) is installed before proceeding.
*   **Local Build Hooks:** Optional `.build.local.sh` file for custom post-build actions.
*   **Auto-Restart Development:** Includes `auto-dev` script for automatically restarting your application during development.

## Prerequisites

Before using `build.sh`, ensure you have the following installed:

1.  **Rust Toolchain (Cargo):**
    If you don't have Rust installed, follow the instructions on the official Rust website:
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```
2.  **inotify-tools:**
    This package provides `inotifywait`, which the script uses to monitor file changes.

    *   **On Debian/Ubuntu:**
        ```bash
        sudo apt update
        sudo apt install inotify-tools
        ```
    *   **On Fedora:**
        ```bash
        sudo dnf install inotify-tools
        ```
    *   **On Arch Linux:**
        ```bash
        sudo pacman -S inotify-tools
        ```
    *   **On macOS (via Homebrew):**
        ```bash
        brew install inotify-tools
        ```
        *(Note: `inotify-tools` works by polling on macOS, which is less efficient than native `inotify` on Linux, but it will still function.)*

## Installation

You can download the `build.sh` script directly from the GitHub repository:

```bash
# Create a dedicated directory for your build script (optional but recommended)
mkdir -p ~/bin
cd ~/bin

# Download the build.sh script
curl -o build.sh https://raw.githubusercontent.com/AutonomoDev/auto-rust-builder/trunk/build.sh

# Make the script executable
chmod +x build.sh

# (Optional) Add ~/bin to your PATH if it's not already
# echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc # Or ~/.zshrc, etc.
# source ~/.bashrc # Or ~/.zshrc, etc.
```

Now you can run `build.sh` from any directory containing a Rust project!

## Usage

Navigate to the root directory of your Rust project where `Cargo.toml` is located.

### 1. Watch for changes and build debug version

This is the primary mode for development. The script will perform an initial debug build, then continuously watch your `src` directory for changes. To stop watching, press `CTRL+C`.

```bash
./build.sh
```

**Demo: Basic Watch & Debug Build**
Watch the script start, perform an initial build, then detect a file modification and build again.

[![asciinema-demo-watch-build](https://asciinema.org/a/746909.svg)](https://asciinema.org/a/746909)

*(Replace `YOUR_DEMO_ID_1` with the actual asciinema recording link)*

### 2. Exit immediately

To stop the script and the watching process, press `CTRL+C`. The script will terminate cleanly without performing any additional builds.

```bash
# (While ./build.sh is running)
Press CTRL+C
```

*(Replace `YOUR_DEMO_ID_3` with the actual asciinema recording link)*

### 3. Build only release version and exit

You can also use the script to simply build a release version once and then exit, without starting the watch loop.

```bash
./build.sh release
```

**Demo: Stop with CTRL+C**

[![asciinema-release](https://asciinema.org/a/dbo81ez341a0UCVkSDtZRmzDf.svg)](https://asciinema.org/a/dbo81ez341a0UCVkSDtZRmzDf)

## Advanced Features

### Local Build Hooks (`.build.local.sh`)

The build system supports optional custom post-build actions through a `.build.local.sh` file. This file is sourced by `build.sh` when present and allows you to define custom behavior after successful builds.

#### Creating a Local Build Hook

Create a `.build.local.sh` file in your project root:

```bash
#!/bin/bash
# .build.local.sh - Custom build hooks

# This function is called after every successful build
function post_build_hook() {
    echo "🎯 Running custom post-build actions..."
    
    # Example: Kill and restart a running instance
    # kill_running_instance
    
    # Example: Run tests
    # cargo test
    
    # Example: Copy binary somewhere
    # cp ./target/debug/myapp /some/destination/
}

# Example helper function
function kill_running_instance() {
    # Your custom logic here
    pkill -f myapp
}
```

Make it executable:

```bash
chmod +x .build.local.sh
```

#### Adding to .gitignore

Since `.build.local.sh` is meant for local development customization, you may want to add it to your `.gitignore`:

```bash
echo ".build.local.sh" >> .gitignore
```

This allows each developer to have their own custom post-build actions without affecting others.

### Auto-Restart Development (`auto-dev`)

For long-running applications (servers, daemons, file watchers), the `auto-dev` script provides automatic restart functionality during development. When your application exits or is killed, it will automatically restart after a configurable delay.

#### Setting Up Auto-Restart Development

1. **Download the `auto-dev` script:**

```bash
curl -o auto-dev https://raw.githubusercontent.com/AutonomoDev/auto-rust-builder/trunk/auto-dev
chmod +x auto-dev
```

2. **Start your application with auto-restart:**

```bash
./auto-dev [arguments_to_pass_to_binary]
```

Examples:

```bash
# Run without arguments
./auto-dev

# Run with arguments
./auto-dev --port 8080

# Run with multiple arguments
./auto-dev --config ./config.toml --verbose
```

#### Combining with Build Hooks for Hot Reload

For a complete hot-reload development experience:

1. Create `.build.local.sh` to kill the running instance after builds:

```bash
#!/bin/bash

function post_build_hook() {
    kill_running_instance
}

function kill_running_instance() {
    # Send graceful shutdown signal to your app
    # This example assumes your app listens on a port
    for port in $(seq 48888 48988); do
        if timeout 0.3 bash -c "echo 'DIE: Rebuilt binary detected.' > /dev/tcp/127.0.0.1/$port" 2>/dev/null; then
            echo "💀 Sent restart signal to instance on port $port"
            sleep 0.5
        fi
    done
}
```

2. Start the auto-restart wrapper:

```bash
# Terminal 1: Run your app with auto-restart
./auto-dev --your-args
```

3. Start the build watcher:

```bash
# Terminal 2: Watch and rebuild
./build.sh
```

Now when you make changes:
- `build.sh` detects the change and rebuilds
- After successful build, `.build.local.sh` sends kill signal to running instance
- Running instance exits
- `auto-dev` waits 20 seconds and restarts automatically

#### Configuration

You can modify the restart delay by editing the `auto-dev` script:

```bash
# Change this value (in seconds)
RESTART_DELAY=20
```

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or encounter any bugs.

## License

This project is open-source and available under the [MIT License](LICENSE).
