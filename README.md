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
- Right-click menu for character, mode, size, reset, AI thoughts, and quit.
- Modes: Companion, Study Focus, Do Not Disturb.
- Character-specific speech style for clicks, double-clicks, focus, attention, app context, and cursor petting.
- Smooth drag behavior with screen-edge clamping.
- Optional OpenAI-powered thoughts using app metadata only, no screenshots.

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

## Optional AI Thoughts

AI thoughts are off by default. If enabled in the menu, the app looks for an API key in either:

- `NSUserDefaults` key `OpenAIAPIKey`
- environment variable `OPENAI_API_KEY`

The current implementation sends only lightweight context such as active app name, mode, mood, bond, energy, and idle time. It does not send screenshots.
