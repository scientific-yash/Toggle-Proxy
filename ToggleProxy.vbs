' ToggleProxy.vbs - Runs PowerShell tray icon silently
Set WshShell = CreateObject("WScript.Shell")
scriptdir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
psCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & scriptdir & "\ProxyTray.ps1"""
WshShell.Run psCommand, 0, False