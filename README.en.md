# atlas-generate

Portable [Agent Skills](https://agentskills.io) skill (Pi, Claude Code, Codex, Cursor, …) that
outputs **in the chat** a single **self-contained Markdown document** summarizing the current
directory — repo, knowledge base, any project — ready to be pasted as-is into your personal
knowledge base.

- **100 % read-only**: the skill never writes, modifies or deletes any file (any temporary file is
  removed before finishing). The output is one `markdown` code block in the conversation.
- **French by default**, unless explicitly asked otherwise: `/skill:atlas-generate in english`.
- **Self-contained**: someone who has never seen the directory understands what it is, what it's
  for, how to run it and where to find what, just by reading the document.
- **No hallucinations**: only facts read from the files; uncertainties are marked `[to verify]`.

## Install

The skill is just a directory containing `SKILL.md` — copy or symlink it into your tool's skills
directory:

| Tool | User location | Project location |
|---|---|---|
| **Pi** | `~/.pi/agent/skills/atlas-generate/` | `.pi/skills/atlas-generate/` |
| **Agent Skills standard** (also supported by Pi) | `~/.agents/skills/atlas-generate/` | `.agents/skills/atlas-generate/` |
| **Claude Code** | `~/.claude/skills/atlas-generate/` | `.claude/skills/atlas-generate/` |
| **Codex CLI** | `~/.codex/skills/atlas-generate/` | `.codex/skills/atlas-generate/` |
| **Cursor** | `~/.cursor/skills/atlas-generate/` | `.cursor/skills/atlas-generate/` |

### Via Pi packages (recommended — updates managed by Pi)

The repo is also a **Pi package** (thanks to `package.json`), so Pi can clone it from GitHub and
update it like a git-installed extension:

```sh
pi install git:github.com/EmmanuelARB/generate-atlas          # follows the default branch
pi install git:github.com/EmmanuelARB/generate-atlas@main     # follows main explicitly
pi install git:github.com/EmmanuelARB/generate-atlas@v1.0.0   # pinned to a tag (never moves)

pi list                                                        # installed packages
pi update --extensions                                         # update ALL packages (incl. atlas)
pi update git:github.com/EmmanuelARB/generate-atlas            # update one package
pi remove git:github.com/EmmanuelARB/generate-atlas            # uninstall
```

`pi update` reconciles the git checkout: **without a pinned ref (tag/commit) it follows the
default branch**; with a tag or commit the version stays pinned. For one project only:
`pi install -l git:github.com/EmmanuelARB/generate-atlas` (writes to `.pi/settings.json`).
Try without installing: `pi -e git:github.com/EmmanuelARB/generate-atlas`. In Pi, run `/reload`
after an update.

> Claude Code / Codex / Cursor have no skill package manager: keep a local clone up to date
> (`git pull`) and re-run `./install.sh` (symlinks point at the clone), e.g. from a cron.

Quick install script: `./install.sh` (add `--all`, `--project`, `--copy` as needed).

```sh
git clone https://github.com/EmmanuelARB/generate-atlas.git
ln -s "$PWD/generate-atlas/atlas-generate" ~/.pi/agent/skills/atlas-generate
```

In Pi, run `/reload` if a session is already open.

## Updates

- **Pi (git package)**: `pi update --extensions` (or `pi update git:github.com/EmmanuelARB/generate-atlas`),
  then `/reload` in the session.
- **Other tools**: `git -C /path/to/generate-atlas pull` then `./install.sh`.

## Usage

- `/skill:atlas-generate` (Pi) or `/atlas-generate` (depending on the tool)
- Language override: `/skill:atlas-generate in english`
- Natural invocation: "summarize this directory", "I want to add this repo to my knowledge base"

The agent explores the current directory (excluding `.git`, `node_modules`, `dist`, binaries,
respecting `.gitignore`) and replies with a single `markdown` block to paste into a `.md` file of
your KB. No file is written.

## License

MIT — see [LICENSE](LICENSE). 🇫🇷 Version française : [README.md](README.md)
