# SKVR-LMIS

**Skyrim VR Linux Modding Installation Script**

SKVR-LMIS installs [Mod Organizer 2](https://github.com/ModOrganizer2/modorganizer2) and [SKSE](https://skse.silverlock.org/) into the Proton prefix of *The Elder Scrolls V: Skyrim VR*, making modding on Linux a one-command affair.

## Features

- Installs **Mod Organizer 2** directly into your Skyrim VR Proton prefix
- Installs **SKSE (Skyrim Script Extender)** for VR
- No manual prefix path fiddling required

## Requirements

- **Steam** version of *The Elder Scrolls V: Skyrim VR* (other editions are **not** supported)
- A supported Linux distribution:
  - Fedora
  - Ubuntu
  - Debian

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/d3m0-sm/SKVR-LMIS.git
   cd SKVR-LMIS
   
2. Make the script executable

   ```bash
   chmod +x install.sh
   
3. Run it:

   ```bash
   ./install.sh

## Usage
  Once the script finishes, launch Skyrim VR from Steam as usual. Mod Organizer 2 will be available inside the game's Proton prefix, and SKSE will be ready to load your mods.

## Troubleshooting
- **Script fails to find the Proton prefix** – Make sure you have launched Skyrim VR at least once so Steam creates the prefix.
- **Unsupported distribution** – The script only supports Fedora, Ubuntu, and Debian. Other distros may work but are untested.
- **Custom Steam directory** – If your Steam library (where Skyrim VR is installed) is not located at `~/.steam/steam`, adjust the `DEFAULT_STEAM_DIR` variable at the top of the script.   

## Contributing
  Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change

  ## License
  MIT

