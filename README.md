# 🚀 Command Centre

A generalised Windows Terminal project launcher. Define any project's tabs,
panes, and startup commands in `projects.json`, then launch everything with
one click.

## ✨ Features

- 🗂 **Multiple projects** — define as many as you want in one JSON file
- 🎛 **Three launch modes** — `all`, `auto` (services only), `cmd` (terminals only)
- 🐳 **Auto-starts Docker Desktop** if any entry needs it
- 🪟 **Windows Terminal tabs + split panes** — no more manual setup
- 🧩 **Zero code changes** to add a new project — just edit JSON
- ✅ **Validates paths** before launching and warns about missing ones
- 🖱 **Interactive menu** via `launch.bat`

## 📋 Requirements

| Requirement | Notes |
|-------------|-------|
| Windows 10/11 | |
| PowerShell 5.1+ | Preinstalled on Win10/11 |
| Windows Terminal (`wt.exe`) | https://aka.ms/terminal |
| Docker Desktop *(optional)* | Only needed if a command uses `docker` |

## 🚀 Quick Start

1. **Download / clone** this folder anywhere.
2. **Copy** `projects.example.json` → `projects.json`.
3. **Edit** `projects.json` and add your project(s).
4. **Double-click** `launch.bat`, type your project name, choose a mode. Done.

## 🧭 The three modes

| Mode   | What it opens | Use it when |
|--------|---------------|-------------|
| `all`  | Every entry | You want the full workspace |
| `auto` | Entries with `"type": "service"` | You only want Docker, servers, browsers, etc. |
| `cmd`  | Entries with `"type": "terminal"` | You only want shells, no auto-run commands |

## 🎮 Usage

### Interactive
```bat
launch.bat
```

### Direct
```bat
launch-all.bat        MYPROJECT
launch-services.bat   MYPROJECT
launch-terminals.bat  MYPROJECT
```

### Advanced (from PowerShell)
```powershell
# Custom Docker path
.\command_centre.ps1 MYPROJECT all -DockerPath "D:\Docker\Docker Desktop.exe"

# Custom config file
.\command_centre.ps1 MYPROJECT all -ConfigPath "D:\shared\projects.json"
```

## 📁 Files

| File | Purpose |
|------|---------|
| `command_centre.ps1` | The launcher logic |
| `projects.json` | **Your** project definitions (edit this) |
| `projects.example.json` | Reference template |
| `launch.bat` | Interactive menu |
| `launch-all.bat` | Shortcut: launch everything |
| `launch-services.bat` | Shortcut: services only |
| `launch-terminals.bat` | Shortcut: terminals only |

## ⚙ How it works

1. Reads `projects.json` and finds your project by key.
2. Filters entries by `type` based on the chosen mode.
3. If any command contains `docker`, ensures Docker Desktop is running.
4. Builds `wt.exe` arguments: first entry → `new-tab`, rest → `split-pane`.
5. Each pane opens in the entry's `path` with `cmd /k <cmd>`.

## 🧪 Testing

1. Copy `projects.example.json` → `projects.json`.
2. Replace `MYPROJECT` paths with real folders on your machine.
3. Run:
   ```bat
   launch.bat
   ```
4. Enter `MYPROJECT`, choose mode `1`. Windows Terminal should open with
   panes for each entry.

## 📚 More docs

- **[PROJECTS_GUIDE.md](PROJECTS_GUIDE.md)** — how to add/edit projects
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — common problems & fixes