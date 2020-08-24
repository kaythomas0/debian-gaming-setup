# debian-gaming-setup
An interactive shell script for installing recommended tools to game efficiently on Debian.

[![pipeline status](https://gitlab.com/KevinNThomas/debian-gaming-setup/badges/master/pipeline.svg)](https://gitlab.com/KevinNThomas/debian-gaming-setup/commits/master)

## Requirements
* Debian 10 - Stable (Buster), Debian 11 - Testing (Bullseye), or Debian Unstable (Sid)
* AMD64 (x86-64) CPU Architecture
* For Nvidia GPUs: GeForce 8 through 300, 400, 500, and 600 and newer
* For AMD GPUs: GCN 1.2 ("GCN 3rd generation") or newer. This is most chips released after June 2015[1]

## Downloading the script
* You can download the script from the latest release here: https://gitlab.com/KevinNThomas/debian-gaming-setup/-/releases

## Running the script
* Make the script executable: `chmod +x debian-gaming-setup`
* Run the script with sudo permissions: `sudo ./debian-gaming-setup`

### GUI mode (recommended for users not comfortable with the terminal)
If you prefer to have a graphical user interface:
1. Install the `zenity` package: `sudo apt install zenity`
2. Run the script with the gui flag: `sudo ./debian-gaming-setup --gui`

## Testing

Tests are made using [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System) and are ran inside a Debian Docker container

### Running the tests (requires Docker)
1. Clone the repo
2. Add the submodules for testing: `git submodule update --init --recursive`
3. Run the tests inside the docker container: `docker build .`

---

[1] Navi GPUs may have problems as they are very new. Debian Testing or Unstable is recommended for Navi GPUs.
