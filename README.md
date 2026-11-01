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
install.sh        ← installe le skill pour Pi / Claude Code / Codex / Cursor (symlink ou copie)
LICENSE           ← MIT
```

Le document généré suit un template fixe (résumé exécutif, à quoi sert le projet, stack,
architecture annotée, points d'entrée, dépendances & config, commandes utiles, conventions,
tests/CI/déploiement, points d'attention, index des fichiers clés, métadonnées avec branche et
commit git).

## Installation

Le skill n'est qu'un dossier contenant `SKILL.md` : il suffit de le placer (copie ou symlink)
dans le dossier « skills » de ton outil.

### Via les packages Pi (recommandé — mises à jour gérées par Pi)

Le repo est aussi un **package Pi** (grâce à `package.json`) : Pi peut le cloner depuis GitHub et
le mettre à jour comme une extension installée via git :

```sh
# install (suit la branche par défaut du repo) :
pi install git:github.com/EmmanuelARB/generate-atlas
# ou explicitement sur la branche master :
pi install git:github.com/EmmanuelARB/generate-atlas@master
# version figée sur un tag — ne bougera plus :
pi install git:github.com/EmmanuelARB/generate-atlas@v1.0.0

pi list                                               # packages installés
pi update --extensions                                # met à jour TOUS les packages (dont atlas)
pi update git:github.com/EmmanuelARB/generate-atlas    # un seul package
pi remove git:github.com/EmmanuelARB/generate-atlas    # désinstaller
```

- `pi update` « reconcilie » le clone git : **sans ref figé (tag/commit), il suit la branche par
  défaut** (`@main` suit `main`) ; avec un tag ou un commit, la version reste épinglée.
- Pour un seul projet : `pi install -l git:github.com/EmmanuelARB/generate-atlas` écrit la
  déclaration dans `.pi/settings.json` (chargée après avoir fait confiance au projet).
- Test sans rien installer : `pi -e git:github.com/EmmanuelARB/generate-atlas`.
- Dans Pi, fais `/reload` après une mise à jour pour recharger le skill.

> Claude Code / Codex / Cursor n'ont pas de gestionnaire de packages de skills : le plus simple
> reste de garder un clone local à jour (`git pull`) et de relancer `./install.sh` (resymlink),
> éventuellement via un cron.

### Méthode rapide (script)

```sh
./install.sh            # installe en "user" pour Pi + emplacements détectés (crée ~/.pi et ~/.agents si besoin)
./install.sh --all      # force tous les emplacements user connus (Pi, Agent Skills, Claude Code, Codex, Cursor)
./install.sh --project  # installe dans le dossier courant (skills projet)
./install.sh --copy     # copie au lieu de faire un lien symbolique
```

### Méthode manuelle (un seul dossier à placer)

| Outil | Emplacement « user » (tous projets) | Emplacement « projet » (dossier courant) |
|---|---|---|
| **Pi** | `~/.pi/agent/skills/atlas-generate/` | `.pi/skills/atlas-generate/` |
| **Standard Agent Skills** (supporté aussi par Pi) | `~/.agents/skills/atlas-generate/` | `.agents/skills/atlas-generate/` |
| **Claude Code** | `~/.claude/skills/atlas-generate/` | `.claude/skills/atlas-generate/` |
| **Codex CLI** | `~/.codex/skills/atlas-generate/` | `.codex/skills/atlas-generate/` |
| **Cursor** | `~/.cursor/skills/atlas-generate/` | `.cursor/skills/atlas-generate/` |

Exemple (Pi, installation user) :

```sh
git clone https://github.com/EmmanuelARB/generate-atlas.git
ln -s "$PWD/generate-atlas/atlas-generate" ~/.pi/agent/skills/atlas-generate
# ou : cp -r atlas-generate ~/.pi/agent/skills/
```

Dans Pi, recharge les skills si une session est déjà ouverte : `/reload`.

## Mise à jour

- **Pi (package git)** : `pi update --extensions` (ou `pi update git:github.com/EmmanuelARB/generate-atlas`),
  puis `/reload` dans la session. Voir la section « packages Pi » ci-dessus pour le choix
  branche suivie vs tag épinglé.
- **Autres outils** : `git -C /chemin/vers/generate-atlas pull` puis `./install.sh` (les symlinks
  pointent vers le clone, donc ils sont à jour dès le pull).

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

> Fiche autoportante générée le 2025-01-15 par le skill `atlas-generate`.

## 1. Résumé exécutif
...
## 7. Commandes utiles
```sh
npm install
npm run dev
```
...
## 12. Métadonnées
- Dossier analysé : `mon-projet`
- Git : branche `main`, commit `a1b2c3d`
- Portée : complet (312 fichiers lus)
- Langue du document : français
```

## Licence

MIT — voir [LICENSE](LICENSE).

🇬🇧 English version: [README.en.md](README.en.md)
