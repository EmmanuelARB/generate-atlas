# atlas-generate

Portable [Agent Skills](https://agentskills.io) skill (Pi, Claude Code, Codex, Cursor, …) that
outputs **in the chat** a single **self-contained Markdown document** summarizing the current
directory — repo, knowledge base, any project — or a remote git repo passed as an argument
(`/skill:atlas-generate https://github.com/user/repo`) — ready to be pasted as-is into your
personal knowledge base.

- **100 % read-only**: the skill never writes, modifies or deletes any file (any temporary file is
  removed before finishing). The output is one `markdown` code block in the conversation.
- **French by default**, unless explicitly asked otherwise: `/skill:atlas-generate in english`.
- **Self-contained**: someone who has never seen the directory understands what it is, what it's
  for, how to run it and where to find what, just by reading the document.
- **No hallucinations**: only facts read from the files; uncertainties are marked `[to verify]`.

## Install

The skill is just a directory containing `SKILL.md` — place it in your tool's skills directory,
ideally as a **symlink** to a local clone (see « Updates » below for why).

### Via Pi packages (recommended — updates managed by Pi)

The repo is also a **Pi package** (thanks to `package.json`), so Pi can clone it from GitHub and
update it like a git-installed extension:

```sh
pi install https://github.com/EmmanuelARB/generate-atlas          # follows the default branch
pi install https://github.com/EmmanuelARB/generate-atlas@master     # follows master explicitly
pi install https://github.com/EmmanuelARB/generate-atlas@v1.0.0   # pinned to a tag (never moves)

pi list                                                        # installed packages
pi update --extensions                                         # update ALL packages (incl. atlas)
pi update https://github.com/EmmanuelARB/generate-atlas            # update one package
pi remove https://github.com/EmmanuelARB/generate-atlas            # uninstall
```

`pi update` reconciles the git checkout: **without a pinned ref (tag/commit) it follows the
default branch**; with a tag or commit the version stays pinned. For one project only:
`pi install -l https://github.com/EmmanuelARB/generate-atlas` (writes to `.pi/settings.json`).
Try without installing: `pi -e https://github.com/EmmanuelARB/generate-atlas`. In Pi, run `/reload`
after an update.

### Claude Code, Codex, Cursor, Agent Skills standard

These harnesses have no skill package manager: clone the repo **once**, then point each skills
directory at that clone with a **symlink** — one `git pull` then updates all of them at once
(see « Updates »):

```sh
# 1. local clone (once)
git clone https://github.com/EmmanuelARB/generate-atlas.git ~/generate-atlas

# 2. symlinks (user install = all your projects)
mkdir -p ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.agents/skills
ln -s ~/generate-atlas/atlas-generate ~/.claude/skills/atlas-generate    # Claude Code
ln -s ~/generate-atlas/atlas-generate ~/.codex/skills/atlas-generate     # Codex CLI
ln -s ~/generate-atlas/atlas-generate ~/.cursor/skills/atlas-generate    # Cursor
ln -s ~/generate-atlas/atlas-generate ~/.agents/skills/atlas-generate    # Agent Skills standard (also read by Pi)
```

> Project install (single folder): replace `~/.<tool>/skills/` with `./.<tool>/skills/` inside the
> project (e.g. `.claude/skills/atlas-generate`).

Copy variant (frozen — re-copy on each update) instead of symlink:
`cp -R ~/generate-atlas/atlas-generate ~/.claude/skills/atlas-generate`

Expected locations per tool:

| Tool | User location | Project location |
|---|---|---|
| **Pi** | `~/.pi/agent/skills/atlas-generate/` | `.pi/skills/atlas-generate/` |
| **Agent Skills standard** (also supported by Pi) | `~/.agents/skills/atlas-generate/` | `.agents/skills/atlas-generate/` |
| **Claude Code** | `~/.claude/skills/atlas-generate/` | `.claude/skills/atlas-generate/` |
| **Codex CLI** | `~/.codex/skills/atlas-generate/` | `.codex/skills/atlas-generate/` |
| **Cursor** | `~/.cursor/skills/atlas-generate/` | `.cursor/skills/atlas-generate/` |

For Pi without the package manager, the manual link target is `~/.pi/agent/skills/atlas-generate`.
In Pi, run `/reload` if a session is already open.

## Updates

- **Pi (package)**: `pi update --extensions` (or `pi update https://github.com/EmmanuelARB/generate-atlas`),
  then `/reload` in the session. Without a pinned ref it follows the default branch; `@v1.0.0`
  stays pinned.
- **Claude Code / Codex / Cursor / Agent Skills**: the skills are **symlinks to the local clone**,
  so a single command updates all of these harnesses at once:
  ```sh
  git -C ~/generate-atlas pull
  ```
  (no reload needed on next launch; `/reload` in Pi if a session is open). This `git pull` can
  also run from a cron for fully automatic updates. With a copy install, the folder must be
  re-copied every time — hence the symlink.

## Usage

- `/skill:atlas-generate` (Pi) or `/atlas-generate` (depending on the tool)
- From a URL: `/skill:atlas-generate https://github.com/user/repo` — the skill shallow-clones the
  repo (`--depth 1`, no submodules) into a temp directory, analyzes it, then deletes the clone.
  Handy to summarize someone else's project without installing anything. (First time, your tool
  may ask permission to run `git clone`.)
- Language override: `/skill:atlas-generate in english`
  (combinable with a URL: `/skill:atlas-generate https://github.com/user/repo in english`)
- Natural invocation: "summarize this directory", "I want to add this repo to my knowledge base"

The agent explores the current directory (excluding `.git`, `node_modules`, `dist`, binaries,
respecting `.gitignore`) and replies with a single `markdown` block to paste into a `.md` file of
your KB. No file is written.

## License

MIT — see [LICENSE](LICENSE). 🇫🇷 Version française : [README.md](README.md)
