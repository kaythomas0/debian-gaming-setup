# debian-gaming-setup
An interactive shell script for installing recommended tools to game efficiently on Debian.

## Requirements
* Debian 10 - Stable (Buster), Debian 11 - Testing (Bullseye), or Debian Unstable (Sid)
* AMD64 (x86-64) CPU Architecture
* For Nvidia GPUs: GeForce 8 through 300, 400, 500, and 600 and newer
* For AMD GPUs: Newer AMD Radeon GPUs[1][2]

## Setting up the script
1. In your terminal, navigate to where you want this script downloaded.
2. Clone the repo: `git clone git@github.com:KevinNThomas/debian-gaming-setup.git`
3. Go into the directory: `cd debian-gaming-setup`
4. Make the script executeable: `chmod +x debian-gaming-setup`

## Running the script
1. `./debian-gaming-setup`

### GUI mode
If you prefer to have a graphical user interface:
1. Install the `zenity` package: `sudo apt install zenity`
2. Run the script with the gui flag: `./debian-gaming-setup --gui`

---

[1] Exact list of supported AMD GPUs for the xserver-xorg-video-amdgpu package is unclear. At least the following chip families should be supported: Bonaire, Hawaii, Kaveri, Kabini Mullins, Iceland, Tonga, Carrizo, Fiji, and Stoney. However, newer AMD GPUs *should* work. See [xserver-xorg-video-amdgpu package](https://packages.debian.org/buster/xserver-xorg-video-amdgpu) and [AtiHowTo Debian wiki page](https://wiki.debian.org/AtiHowTo)

[2] Navi GPUs may have problems as they are very new. Debian Testing or Unstable is recommended for Navi GPUs.