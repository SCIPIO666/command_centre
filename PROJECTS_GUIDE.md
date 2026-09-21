# 📘 Projects Guide

Everything you need to add, edit, or delete a project.

## The structure of a project

```json
{
  "<PROJECT_KEY>": [
    { "name": "...", "path": "...", "cmd": "...", "type": "service|terminal" },
    ...
  ]
}
```

- `<PROJECT_KEY>` is what you type into `launch.bat` (e.g. `MYPROJECT`).
- The value is an **array** of tab/pane definitions, in the order they open.

## Adding a new project

### 1. Open `projects.json`

### 2. Add a new key alongside existing ones (mind the comma!)

```json
{
  "MYPROJECT": [ ... ],

  "SHOPAPP": [
    {
      "name": "🐳 Postgres",
      "path": "D:\\code\\shopapp",
      "cmd": "docker compose up db",
      "type": "service"
    },
    {
      "name": "🧠 API",
      "path": "D:\\code\\shopapp\\api",
      "cmd": "npm run dev",
      "type": "service"
    },
    {
      "name": "🐚 Shell",
      "path": "D:\\code\\shopapp",
      "cmd": "",
      "type": "terminal"
    }
  ]
}
```

### 3. Save and run `launch.bat` → type `SHOPAPP`.

## Field-by-field

### `name`
- Shown as the tab title.
- Emojis welcome 🎉
- Keep short — long titles get truncated.

### `path`
- **Double backslashes** `\\` in JSON, or forward slashes `/` (Windows accepts both).
- Must exist, or the entry is skipped with a warning.
- Example: `"C:\\Users\\me\\code\\api"` or `"C:/Users/me/code/api"`.

### `cmd`
- Any shell command run with `cmd /k` (keeps the tab open after it exits).
- Leave empty (`""`) for a plain interactive shell.
- If it contains the word `docker`, Docker Desktop is auto-started first.

### `type`
- `"service"` → included in `auto` mode (and `all`).
- `"terminal"` → included in `cmd` mode (and `all`).

## Common command recipes

| What you want | `cmd` value |
|---------------|-------------|
| Docker Compose up | `docker compose up` |
| Docker Compose detached | `docker compose up -d` |
| Node dev server | `npm run dev` |
| Yarn dev server | `yarn dev` |
| pnpm | `pnpm dev` |
| Python (uvicorn) | `python -m uvicorn main:app --reload` |
| Python (Django) | `python manage.py runserver` |
| Prisma Studio | `npx prisma studio` |
| Open browser | `start http://localhost:3000` |
| Open specific browser | `"C:\\Program Files\\Mozilla Firefox\\firefox.exe" http://localhost:3000` |
| Run migrations then start | `npm run migrate && npm run dev` |
| SSH somewhere | `ssh user@host` |
| Just a shell | `""` (empty) |

## De-duplicating repeated work

If you find yourself copy-pasting the same entries into many projects,
keep them in **one** project and reference it mentally, or create a
"workspace" project that bundles everything.

## Deleting a project

Just remove its key (and its array) from `projects.json`. Nothing else
to clean up.

## Tips

- **Keep the "services" first**, terminals last. Services start in the
  background; terminals are where you'll type.
- **Browser tab last** so it doesn't grab focus while services boot.
- **Quotes inside `cmd`**: JSON strings need `\"` for embedded quotes, e.g.
  `"cmd": "docker exec -it db psql -c \"SELECT 1;\""`
- **Ampersands**: in JSON they're fine, but Windows `cmd` treats `&` as a
  command separator. Wrap in quotes if needed.
- **Spaces in paths**: fine as long as they're inside the JSON string.