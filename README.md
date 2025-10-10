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


## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or encounter any bugs.

## License

This project is open-source and available under the [MIT License](LICENSE).
