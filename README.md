# Yabridge Bottles Wineloader

## Overview

When using Yabridge to run VST plugins with WINE, users typically rely on the system version of WINE.
However, many users prefer utilizing Bottles, an application designed to manage WINE prefix directories in a more user-friendly way.
There is only one limitation with this approach: some of the key settings in Bottles, specifically for choosing the WINE variant and version, become ineffective as the system WINE is used instead.

## Project Purpose

This repository hosts a script that addresses this issue by enabling seamless integration between Yabridge and Bottles.
With this script, users can effectively leverage the capabilities of Bottles to select their desired WINE variant and version.

## Installation

### Install `yq`

#### Arch Linux
You can install `yq` from the Arch User Repository (AUR) using `yay`:

```bash
yay -S yq
```

#### Debian/Ubuntu
For Debian and Ubuntu, you can install `yq` using the apt package manager.
```bash
sudo apt install yq
```

#### Fedora
You can install `yq` using the DNF package manager:

```bash
sudo dnf install yq
```

### Download and install wineloader script
Create the directory ``~/.local/bin`` if it does not exist, then move the downloaded script to ``~/.local/bin/wineloader.sh``:

```bash
mkdir -p ~/.local/bin
mv ~/Downloads/wineloader.sh ~/.local/bin/wineloader.sh
chmod +x ~/.local/bin/wineloader.sh
```

### Create a systemd user environment variable
Create the directory ``~/.config/environment.d`` if it does not exist, then create the file ``~/.config/environment.d/wineloader.conf``.
Change the ``<username>`` to your username.

```bash
# ~/.config/environment.d/wineloader.conf
WINELOADER=/home/<username>/.local/bin/wineloader.sh
```

#### Reboot

