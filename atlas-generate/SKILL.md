---
name: atlas-generate
description: >-
  Génère DANS LE CHAT un unique bloc Markdown autoportant qui résume le dossier courant
  (repo, base de connaissances, projet quelconque) : résumé exécutif, à quoi il sert, stack,
  architecture, points d'entrée, dépendances, commandes utiles, conventions, tests/CI,
  points d'attention et index des fichiers clés — prêt à être copié tel quel dans une base de
  connaissances personnelle. Cible : dossier courant par défaut, ou repo git distant si une URL
  est passée en argument (ex. `/skill:atlas-generate https://github.com/user/repo` — clone
  superficiel temporaire, supprimé ensuite). 100 % READ-ONLY : n'écrit, ne modifie et ne supprime
  aucun fichier (tout temporaire éventuel est supprimé avant la fin). Langue : français par
  défaut, sauf demande explicite contraire (ex. `/skill:atlas-generate in english`). À utiliser
  dès que l'utilisateur demande un résumé / une fiche / un « atlas » / un condensé du dossier
  courant ou d'un projet pour alimenter sa base de connaissances.
license: MIT
metadata:
  author: dqdev
  version: "1.0.0"
---

# Atlas Generate

Ta mission : produire **dans le chat** un unique document Markdown **autoportant** qui résume le
dossier courant — ou un repo git distant si une URL est passée en argument —, destiné à être
copié tel quel dans une base de connaissances personnelle.

## 1. Contrat absolu : lecture seule (read-only)

- Tu n'écris, ne modifies et ne supprimes **aucun fichier persistant**, ni dans le dossier
  analysé ni ailleurs.
- N'utilise **aucun outil d'écriture** (write/edit/patch) et **aucune commande qui modifie
  l'état** du projet ou du système (pas d'install, de build, de migration, de `git commit`,
  de `git checkout`, etc.). Lecture seule : lister, lire, chercher (grep), `git log`/`git status`.
- **Seule exception autorisée** : si une URL a été passée en argument (section 2.2), un
  `git clone --depth 1` strictement dans un répertoire temporaire système (`mktemp -d`), sans
  submodules, et sans exécuter aucun code du repo cloné.
- Si des fichiers temporaires ont été créés pendant l'analyse (ex. le clone), **supprime-les
  avant de terminer, même en cas d'erreur** (`rm -rf` du répertoire temporaire).
- Si tu t'apprêtes à écrire un fichier : arrête-toi. Ce skill ne produit que du texte dans le chat.

## 2. Arguments de la commande

### 2.1 Langue de sortie

- **Français par défaut** pour tout le document (titres de sections, explications, commentaires).
- Si l'utilisateur demande explicitement une autre langue — argument après la commande
  (`/skill:atlas-generate in english`, `/skill:atlas-generate en espagnol`) ou une phrase comme
  « réponds en anglais » — alors **tout le document** est rédigé dans cette langue.
- Les noms de fichiers, chemins, commandes, symboles et extraits de code restent **inchangés**
  quelle que soit la langue.

### 2.2 Cible : dossier courant ou URL de repo git

- **Par défaut** (aucun argument, ou argument = langue) : la racine analysée est le **dossier
  courant**.
- Si un argument ressemble à une URL de repo git (`https://…`, `http://…`, `git@…:…`, ou se
  termine par `.git`) — ex. `/skill:atlas-generate https://github.com/user/repo` — alors :
  1. Crée un répertoire temporaire et clone en superficiel, **sans submodules** :
     `TMP=$(mktemp -d)` puis `git clone --depth 1 "<URL>" "$TMP/repo"`.
  2. La racine analysée devient `$TMP/repo` (mêmes règles d'exploration, section 3).
  3. Le nom du « dossier racine » pour le titre est le dernier segment de l'URL, sans `.git`.
  4. Dans le résumé exécutif, indique la source en première ligne :
     « Source : `<URL>` (clone superficiel `--depth 1`, branche par défaut). »
  5. **Nettoyage obligatoire avant de répondre** : `rm -rf "$TMP"`, même si l'analyse échoue.
- Si le clone échoue (URL invalide, repo privé, pas de réseau…) : réponds en une phrase que le
  clone a échoué et pourquoi ; **ne produis pas de document**.
- Les arguments se combinent : `/skill:atlas-generate https://github.com/user/repo in english`.
- Ne traite jamais une URL comme un chemin local ; seules les URLs de repos git sont supportées
  (pas de page web non git).

## 3. Méthode d'exploration (read-only uniquement)

1. La racine analysée est le **dossier courant**, ou le **clone temporaire de l'URL** si un
   argument URL a été donné (section 2.2). Liste d'abord l'arborescence complète.
2. **Exclusions par défaut** : `.git`, `node_modules`, `dist`, `build`, `out`, `.next`, `.nuxt`,
   `.output`, `coverage`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `.venv`,
   `venv`, `env`, `.tox`, `.idea`, `.vscode`, `*.egg-info`, `target`, `vendor`, `bower_components`,
   `.terraform`, `.cache`, plus tous les **fichiers binaires** (images, vidéos, PDF, archives,
   exécutables compilés) : note leur existence, ne tente pas de les lire. Ignore aussi le contenu
   des fichiers de plus de ~200 Ko ou ~5 000 lignes (note-les seulement dans l'index si importants).
3. Si un `.gitignore` (ou `.atlasignore`) existe à la racine, utilise-le comme exclusion complémentaire.
4. **Ordre de lecture prioritaire** : `README*`, `LICENSE`, `CONTRIBUTING*`, `CHANGELOG*`,
   manifests et configs (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`,
   `*.csproj`, `composer.json`, `Makefile`, `Dockerfile`, `docker-compose*`, `.env.example`,
   `tsconfig*`, `*.yaml`/`*.yml` de CI...), puis les **points d'entrée évidents** (`main.*`,
   `index.*`, `app.*`, `cli.*`, `server.*`, `cmd/`, `src/index.*`, `bin/`...).
5. Ensuite, parcours les dossiers par ordre d'importance : d'abord les fichiers les plus
   centraux, puis un **échantillon représentatif** par sous-dossier. Si le volume est trop grand
   pour tout lire, fais un résumé sur échantillon intelligent.
6. Si c'est un repo git (commandes read-only) : branche courante et dernier commit
   (`git rev-parse --abbrev-ref HEAD`, `git log -1 --pretty=format:'%h %ad %s' --date=short`,
   `git status --porcelain | head`).
7. Au fil de la lecture, repère : but du projet, stack, architecture, dépendances et leur rôle,
   scripts/commandes, configuration requise (variables d'environnement), tests, CI/déploiement,
   conventions de nommage et de structure, `TODO`/`FIXME`/`XXX`/`HACK`, dettes ou risques visibles.

## 4. Règles du document autoportant

- **Autoportant** = une personne qui n'a **jamais vu ce dossier** doit comprendre, rien qu'en
  lisant ce document : de quoi il s'agit, à quoi ça sert, comment l'utiliser/le lancer, la stack,
  l'organisation interne, et où trouver quoi.
- **Zéro hallucination** : n'écris que des faits lus dans les fichiers. En cas de doute, marque `[à vérifier]`.
- Chemins relatifs **exacts**, commandes **copiables telles quelles**.
- Utilise le **template imposé** ci-dessous, dans cet ordre, sans renommer les sections — même si
  une section est vide, écris « Non détecté » ou « Non applicable » (stabilité du format pour la KB).
- Concision : vise un document complet mais dense (typiquement 150–600 lignes de Markdown).

## 5. Template imposé du document

```markdown
# Atlas — <nom du dossier racine>

## 1. Résumé exécutif
(5–10 lignes : ce que c'est, pourquoi, pour qui, état général ; si cible = URL, première ligne = « Source : <URL> »)

## 2. À quoi sert ce projet

## 3. Stack & technologies

## 4. Architecture & arborescence
(arborescence annotée des dossiers/fichiers importants, avec le rôle de chacun)

## 5. Points d'entrée
(CLI, API, UI, entrypoint, par où commencer la lecture du code)

## 6. Dépendances & configuration clés
(dépendances majeures et pourquoi ; variables d'environnement requises, cf. .env.example)

## 7. Commandes utiles
(bloc de commandes copiables : install, dev, test, build, lint, deploy...)

## 8. Conventions & patterns observés

## 9. Tests, CI & déploiement

## 10. Points d'attention
(TODO/FIXME marquants, dette technique, risques, pièges connus)

## 11. Index des fichiers clés
(tableau : `chemin` → rôle en une ligne)
```

## 6. Format de la réponse finale — affichage en texte BRUT

Le document doit apparaître dans le chat en **texte brut** (les `#`, `**`, `-` restent visibles
tels quels), jamais interprété. Or tout Markdown émis hors d'un bloc de code est affiché rendu
par le chat (gros titres, gras, listes) : pour obtenir le brut, le document entier doit tenir
dans un unique bloc de code.

1. Une courte phrase d'intro, ex. : « Voici l'atlas du dossier `nom-du-dossier` : »
2. **Un seul bloc de code** contenant le document complet, ouvert par une rangée de **quatre
   backticks** suivie de `markdown`, et fermé par quatre backticks — jamais trois, car le
   document contient lui-même des blocs de code à trois backticks (ex. « Commandes utiles »),
   ce qui fermerait prématurément le bloc.
3. **Règle absolue** : aucune ligne du document ne sort de ce bloc de code. Ne jamais émettre
   le document en Markdown nu hors bloc : il serait affiché rendu et ne serait plus copiable
   tel quel en brut.
4. Une seule phrase de clôture, ex. : « Document brut prêt à être copié tel quel dans ta base
   de connaissances — aucun fichier n'a été écrit. »
5. **Rien d'autre après.** Ne propose pas d'écrire le fichier : ce skill ne produit que du
   texte dans le chat.

## 7. Ne bloque pas

Ne pose pas de question pour décider : avance avec les règles ci-dessus, marque `[à vérifier]`
en cas de doute, et produis toujours le document.
