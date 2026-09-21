# 🛠 Troubleshooting

## "No projects.json found"
You didn't copy the example yet. Do:
```
copy projects.example.json projects.json
```

## "Project 'X' not found"
The key in `projects.json` is case-sensitive. Check the spelling.

## "Windows Terminal (wt.exe) not found"
Install Windows Terminal:
- Microsoft Store → "Windows Terminal"
- Or: https://aka.ms/terminal

## "Path does not exist for 'X'"
- Double backslashes in JSON: `"C:\\Users\\me"` not `"C:\Users\me"`.
- Or use forward slashes: `"C:/Users/me"`.
- Verify the folder really exists.

## "Docker needed but not found"
- Docker Desktop isn't installed at the default path.
- Override with: `.\command_centre.ps1 MYPROJECT all -DockerPath "D:\Docker\Docker Desktop.exe"`

## Docker starts but panes fail
- First launch of Docker takes 30–90s. The script waits up to 120s.
- If your machine is slow, raise `$maxWait` in `command_centre.ps1`.

## Panes open but command doesn't run
- Make sure `cmd` isn't empty.
- Check the command works manually in `cmd` from that folder.
- Some commands need a shell that supports them (PowerShell vs cmd).
  Since we use `cmd /k`, only `cmd`-compatible commands run directly.

## Extra quotes / escaping
- In JSON, wrap the whole command in quotes and escape inner quotes:
  `"cmd": "echo \"hello world\""`
- For complex multi-line commands, consider putting them in a `.bat`
  file and calling that: `"cmd": "start.bat"`.

## "Execution of scripts is disabled"
Run PowerShell once as admin:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Tabs open in wrong order
Entries open top-to-bottom; each new one splits the previous pane.
If order feels off, reorder the JSON array.

## One bad entry kills the whole launch
The script skips entries with missing `name`/`path` and warns. If everything
fails, you'll get "No valid entries to launch".

## I want horizontal splits instead of vertical
Edit `command_centre.ps1`, change `"split-pane"` to `"split-pane -H"` for
horizontal splits.