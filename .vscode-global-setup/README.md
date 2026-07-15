What this does

- Installs a curated set of extensions recommended for professional development.
- Optionally overwrites your global VS Code User settings (backs them up first).

How to use

1. Open PowerShell in this folder.
2. Run:

```powershell
./install-vscode-setup.ps1
```

Notes

- The script uses the `code` CLI to install extensions. If `code` is not on your PATH, open VS Code, press Ctrl+Shift+P, and run "Shell Command: Install 'code' command in PATH" (may require restart), or add the path to `code` manually.
- The script will back up your existing `%APPDATA%\Code\User\settings.json` before overwriting.
- Sign in to Settings Sync in VS Code after applying settings to persist them across machines.

If you want, I can apply a smaller set of settings, or automatically merge instead of overwrite. Which would you prefer?