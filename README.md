# atlas-generate

Skill [Agent Skills](https://agentskills.io) portable (Pi, Claude Code, Codex, Cursor, …) qui
génère **dans le chat** un unique document Markdown **autoportant** résumant le dossier courant —
repo, base de connaissances, projet quelconque — prêt à être copié tel quel dans ta base de
connaissances personnelle.

- **100 % read-only** : le skill n'écrit, ne modifie et ne supprime **aucun fichier** (les
  temporaires éventuels sont supprimés avant la fin). Le résultat est un seul bloc `markdown`
  affiché dans la conversation.
- **Français par défaut**, sauf demande explicite contraire :
  `/skill:atlas-generate in english`.
- **Autoportant** : quelqu'un qui n'a jamais vu le dossier comprend de quoi il s'agit, à quoi ça
  sert, comment le lancer et où trouver quoi, rien qu'en lisant le document.
- **Zéro hallucination** : que des faits lus dans les fichiers ; les incertitudes sont marquées
  `[à vérifier]`.

## Contenu

```
atlas-generate/
└── SKILL.md      ← le skill (frontmatter Agent Skills + instructions + template imposé)
LICENSE           ← MIT
```

Le document généré suit un template fixe (résumé exécutif, à quoi sert le projet, stack,
architecture annotée, points d'entrée, dépendances & config, commandes utiles, conventions,
tests/CI/déploiement, points d'attention, index des fichiers clés).

## Installation

Le skill n'est qu'un dossier contenant `SKILL.md` : il suffit de le placer dans le dossier
« skills » de ton outil — idéalement par **lien symbolique** vers un clone local (voir
« Mise à jour » pour l'intérêt).

### Pi — via les packages (recommandé : mises à jour gérées par Pi)

Le repo est aussi un **package Pi** (grâce à `package.json`) : Pi peut le cloner depuis GitHub et
le mettre à jour comme une extension installée via git :

```sh
# install (suit la branche par défaut du repo) :
pi install https://github.com/EmmanuelARB/generate-atlas
# ou explicitement sur la branche master :
pi install https://github.com/EmmanuelARB/generate-atlas@master
# version figée sur un tag — ne bougera plus :
pi install https://github.com/EmmanuelARB/generate-atlas@v1.0.0

pi list                                               # packages installés
pi update --extensions                                # met à jour TOUS les packages (dont atlas)
pi update https://github.com/EmmanuelARB/generate-atlas    # un seul package
pi remove https://github.com/EmmanuelARB/generate-atlas    # désinstaller
```

- `pi update` « reconcilie » le clone git : **sans ref figé (tag/commit), il suit la branche par
  défaut** (`@master` suit `master`) ; avec un tag ou un commit, la version reste épinglée.
- Pour un seul projet : `pi install -l https://github.com/EmmanuelARB/generate-atlas` écrit la
  déclaration dans `.pi/settings.json` (chargée après avoir fait confiance au projet).
- Test sans rien installer : `pi -e https://github.com/EmmanuelARB/generate-atlas`.
- Dans Pi, fais `/reload` après une mise à jour pour recharger le skill.

### Claude Code, Codex, Cursor, standard Agent Skills

Ces harnais n'ont pas de gestionnaire de packages de skills : on clone le repo **une fois**, puis
on pointe chaque dossier « skills » vers ce clone par **lien symbolique** — ainsi, un seul
`git pull` met à jour tous ces outils d'un coup (voir « Mise à jour ») :

```sh
# 1. clone local (une seule fois)
git clone https://github.com/EmmanuelARB/generate-atlas.git ~/generate-atlas

# 2. liens symboliques (installation « user » = tous tes projets)
mkdir -p ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.agents/skills
ln -s ~/generate-atlas/atlas-generate ~/.claude/skills/atlas-generate    # Claude Code
ln -s ~/generate-atlas/atlas-generate ~/.codex/skills/atlas-generate     # Codex CLI
ln -s ~/generate-atlas/atlas-generate ~/.cursor/skills/atlas-generate    # Cursor
ln -s ~/generate-atlas/atlas-generate ~/.agents/skills/atlas-generate    # standard Agent Skills (aussi lu par Pi)
```

> Installation « projet » (un seul dossier) : remplace `~/.<outil>/skills/` par `./.<outil>/skills/`
> dans le dossier du projet (ex. `.claude/skills/atlas-generate`).

Variante **copie** (figée, à recopier à chaque mise à jour) au lieu de symlink :
`cp -R ~/generate-atlas/atlas-generate ~/.claude/skills/atlas-generate`

Emplacements attendus par outil :

| Outil | Emplacement « user » (tous projets) | Emplacement « projet » (dossier courant) |
|---|---|---|
| **Pi** | `~/.pi/agent/skills/atlas-generate/` | `.pi/skills/atlas-generate/` |
| **Standard Agent Skills** (supporté aussi par Pi) | `~/.agents/skills/atlas-generate/` | `.agents/skills/atlas-generate/` |
| **Claude Code** | `~/.claude/skills/atlas-generate/` | `.claude/skills/atlas-generate/` |
| **Codex CLI** | `~/.codex/skills/atlas-generate/` | `.codex/skills/atlas-generate/` |
| **Cursor** | `~/.cursor/skills/atlas-generate/` | `.cursor/skills/atlas-generate/` |

Pour Pi sans package (installation manuelle), le lien se fait vers `~/.pi/agent/skills/atlas-generate`.
Dans Pi, recharge les skills si une session est déjà ouverte : `/reload`.

## Mise à jour

- **Pi (package)** : `pi update --extensions` (ou `pi update https://github.com/EmmanuelARB/generate-atlas`),
  puis `/reload` dans la session. Sans ref figé, la branche par défaut est suivie ; avec
  `@v1.0.0`, la version reste épinglée.
- **Claude Code / Codex / Cursor / Agent Skills** : les skills étant des **symlinks vers le clone
  local**, une seule commande met à jour tous ces harnais d'un coup :
  ```sh
  git -C ~/generate-atlas pull
  ```
  (aucun rechargement au prochain lancement ; `/reload` dans Pi si une session est ouverte).
  Ce `git pull` peut aussi tourner en cron pour une mise à jour automatique. Avec une
  installation par **copie**, il faut recopier le dossier à chaque fois — d'où l'intérêt du symlink.

## Utilisation

- **Commande explicite** : `/skill:atlas-generate` (dans Pi), ou `/atlas-generate` (selon l'outil).
- **Langue** : `/skill:atlas-generate in english`, `/skill:atlas-generate en espagnol`, …
- **Invocation naturelle** (le skill se déclenche tout seul quand c'est pertinent) :
  « Fais-moi un résumé de ce dossier », « Je veux mettre ce repo dans ma base de connaissances ».

L'agent explore le dossier courant (en excluant `.git`, `node_modules`, `dist`, binaires, etc.,
et en respectant `.gitignore`), puis répond par **un seul bloc `markdown`** que tu copies tel
quel dans un fichier `.md` de ta KB. Aucun fichier n'est écrit.

## Exemple de sortie

```markdown
# Atlas — mon-projet

## 1. Résumé exécutif
...
## 7. Commandes utiles
```sh
npm install
npm run dev
```
...
```

## Licence

MIT — voir [LICENSE](LICENSE).

🇬🇧 English version: [README.en.md](README.en.md)
