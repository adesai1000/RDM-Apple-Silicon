# RDM for Apple Silicon

The original RDM (Retina Display Menu) project is now archived and no longer provides a `.dmg` installer, and its source code can’t be built natively on Apple Silicon Macs due to outdated architecture flags and dependencies. This fork updates the build system and code to work on modern macOS and Apple Silicon (M1, M2, M3 series) Macs. You can either download a .dmg from the releases page or can compile and run it directly without issues.

### ⚠️ Caution
This version only includes modifications to the `utils.h` file and the `Makefile`, made with help from ChatGPT. It works as expected on Apple Silicon Macs, but if it doesn’t, please don’t blame me lol.  
I don’t plan to actively maintain this project, but if you’d like to improve it, feel free to open a PR.

## 🛠️ Building from Source

First, ensure that Xcode Command Line Tools are installed by running: (If you use Homebrew, you already have it!)

    xcode-select --install

Then simply clone this repository and build RDM:

    git clone https://github.com/adesai1000/RDM-Apple-Silicon.git
    cd RDM-Apple-Silicon
    make clean && make && make RDM.app
    open RDM.app

## 💻 About RDM

RDM is a tool that lets you use your MacBook Pro Retina’s highest and unsupported resolutions.

For example, a Retina MacBook Pro 13" can be set to 3360×2100 maximum resolution, as opposed to Apple’s max supported 1680×1050.

Once built, RDM will appear in your macOS menu bar, where you can easily switch between resolutions.

## ⚡️ HiDPI (Retina) Resolutions

Resolutions marked with ⚡️ (lightning) indicate HiDPI or 2× pixel density modes. These provide sharper, crisper text and visuals, and should generally be preferred.

## 🖼️ Screenshot

![RDM Screenshot](https://cloud.githubusercontent.com/assets/3484242/7100316/255a7d74-dff0-11e4-9bf9-16e726336e29.png)

## 📄 License

This project is based on the original RDM by @avibrazil and is distributed under the same license without any financial incentive.