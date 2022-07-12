# About
Infinity Desktop enables fast monitor selection for Windows' [Remote Desktop Connection](https://support.microsoft.com/en-us/windows/how-to-use-remote-desktop-5fe128d5-8fb1-7a23-3b8a-41e636865e8c).

# Features
- Provides fast and easy selection of monitors used when using RDC
- Remembers the selected monitors from the last session
- Allows customization with essential settings
- Is standalone

# Installation
1. Download the executable file
|Version|Operating System|Download URL|
|---|---|---|---|
|[v1.0.0.3-beta](https://github.com/DaraJKong/Infinity-Desktop/releases/tag/v1.0.0.3-beta)|Windows 10 32-bit|[Download](https://github.com/DaraJKong/Infinity-Desktop/releases/download/v1.0.0.3-beta/InfinityDesktop32.exe)|
||Windows 10 64-bit|[Download](https://github.com/DaraJKong/Infinity-Desktop/releases/download/v1.0.0.3-beta/InfinityDesktop64.exe)|

2. Make sure you have [Remote Desktop Connection](https://support.microsoft.com/en-us/windows/) installed (it should be by default)

# How To Use
To connect to your remote desktop using multiple monitors, double-click on the executable file to open it. All of your screens will turn black for a moment and once everything is loaded, you will see numbers appearing on each monitor. These numbers represent the monitors' IDs.

Left-click on any screen to select or unselect it. A yellow background means the monitor is selected for the remote connection. Monitors you don't select will be used for your current computer. Once you are satisfied with your setup, simply press the Enter key or the Space key. The screens will go back to normal as the remote connection is starting using a custom RDP file.

To cancel the remote connection, you can press the Escape key, the Delete key or the Backspace key.

The app will create a folder named "Infinity Desktop" in the directory "C:\Users\kongda\AppData\Roaming\". You will find a useful configuration file in it where settings are stored.

## Default.rdp
The "Default.rdp" file is created by default by the [Remote Desktop Connection](https://support.microsoft.com/en-us/windows/) software. It is hidden and located into your Documents folder ("C:\Users\kongda\Documents\Default.rdp"). Infinity Desktop will always pull settings from this file so make sure you save your favorite configuration there.

## Settings
### Fullscreen
Sets whether the screen overlays are displayed in fullscreen or not. Set to 1 for the app to be in fullscreen mode or 0 to disable the setting.

### EditConnection
If set to 1, the remote connection will enable you to edit the settings before proceding. Set to 0 if you want to skip that step. It is recommended to save your remote connection settings to the "Default.rdp" file before disabling this setting, because it ensures you always connect with the right configuration.

## Not able to run the app?
For security reasons, Windows sometimes will ask you if you trust the file before executing it.

# TODO
- Remember relative positions of selected monitors (main monitor, left, middle, right, first, last) and implement universal pattern that adapts when number of monitors is not the same (instead of remembering IDs)
- Workaround for not able to select monitors of different resolutions
- Notify user when selected monitors are of different resolutions and might not give expected results
- Enable user to change settings easily
- How to use tips and shortcuts map
- Easy remembering, saving, managing RDP config file and reload settings automatically