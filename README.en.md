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

Quick install script: `./install.sh` (add `--all`, `--project`, `--copy` as needed).

```sh
git clone https://github.com/<your-user>/generate-atlas.git
ln -s "$PWD/generate-atlas/atlas-generate" ~/.pi/agent/skills/atlas-generate
```

In Pi, run `/reload` if a session is already open.

## Usage

- `/skill:atlas-generate` (Pi) or `/atlas-generate` (depending on the tool)
- Language override: `/skill:atlas-generate in english`
- Natural invocation: "summarize this directory", "I want to add this repo to my knowledge base"

The agent explores the current directory (excluding `.git`, `node_modules`, `dist`, binaries,
respecting `.gitignore`) and replies with a single `markdown` block to paste into a `.md` file of
your KB. No file is written.

## License

MIT — see [LICENSE](LICENSE). 🇫🇷 Version française : [README.md](README.md)
