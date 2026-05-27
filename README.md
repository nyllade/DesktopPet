# DesktopPet

DesktopPet is a lightweight native macOS desktop companion built with AppKit. It floats above other apps, can be dragged around the screen, switches between six character sprites, and reacts with character-specific thoughts, ambient magic, focus modes, and cursor-petting hearts.

## Features

- Native transparent macOS overlay, not Electron and not a webpage.
- Six selectable companions:
  - Nebula Nix
  - Pippa Orbitpaw
  - Luma Moppet
  - Ossia Nocturne
  - Velvet Howl
  - Mochi Cloudlet
- Right-click menu for character, mode, size, settings, reset, and quit.
- Modes: Companion, Study Focus, Do Not Disturb.
- Character-specific speech style for clicks, double-clicks, focus, attention, app context, and cursor petting.
- Smooth drag behavior with screen-edge clamping.
- Local rule-based thoughts using app context, mood, memory, time of day, and character voice.

## Build

```sh
./build.sh
```

The built app is written to:

```text
DesktopPet/DesktopPet.app
```

## Run

```sh
open DesktopPet/DesktopPet.app
```

## Local Companion Logic

DesktopPet currently uses local, rule-based companion behavior. It tracks mode, mood, focus time, idle returns, comfort, bond, app context, and character personality lines without sending anything to an external API.

## Windows Version

A native Windows/WPF version lives in:

```text
WindowsPet/
```

On Windows with the .NET 8 SDK:

```powershell
cd WindowsPet
dotnet run
```

To publish a standalone Windows build:

```powershell
.\build-windows.ps1
```
