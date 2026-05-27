# DesktopPet for Windows

This is the native Windows version of DesktopPet. It uses WPF/C# to create a transparent, always-on-top desktop companion window.

## Requirements

- Windows 10 or Windows 11
- .NET 8 SDK

## Run

From PowerShell:

```powershell
cd WindowsPet
dotnet run
```

## Publish

```powershell
dotnet publish -c Release -r win-x64 --self-contained true
```

The published app will be under:

```text
WindowsPet\bin\Release\net8.0-windows\win-x64\publish
```

## Current Features

- Transparent always-on-top pet window
- Six selectable characters
- Companion, Study Focus, and Do Not Disturb modes
- Size and motion intensity settings
- Smooth dragging
- Stronger shake for fast dragging
- Circular drag spin
- Cursor petting with hearts
- Short character-specific thought bubbles
- Local settings saved in `%APPDATA%\DesktopPet\settings.json`

This is intentionally separate from the macOS AppKit app because the macOS version uses AppKit APIs that do not exist on Windows.
