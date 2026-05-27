$ErrorActionPreference = "Stop"

dotnet publish `
  -c Release `
  -r win-x64 `
  --self-contained true

Write-Host "Published DesktopPet for Windows."
