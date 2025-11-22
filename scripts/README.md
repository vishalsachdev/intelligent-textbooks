# Textbook Generation Scripts

This directory contains scripts to create and manage intelligent textbook repositories.

## Quick Start

### Create a New Textbook

```bash
./scripts/create-textbook.sh biology-101 "Biology 101"
```

This creates a complete, independent textbook repository in `../biology-101/` with:
- ✅ Full MkDocs configuration
- ✅ Latest skills from [dmccreary/claude-skills](https://github.com/dmccreary/claude-skills)
- ✅ Framework plugins and tools
- ✅ Starter content (index, about, glossary, etc.)
- ✅ GitHub Actions for auto-deployment
- ✅ Update scripts for syncing upstream changes

### Full Usage

```bash
./scripts/create-textbook.sh <textbook-slug> <"Textbook Name"> [github-username]
```

**Parameters:**
- `textbook-slug` - Repository name (lowercase, hyphens only, e.g., `biology-101`)
- `Textbook Name` - Display name (quoted, e.g., `"Biology 101"`)
- `github-username` - Optional (defaults to `vishalsachdev`)

**Examples:**
```bash
# Basic usage
./scripts/create-textbook.sh chemistry-intro "Introduction to Chemistry"

# With custom GitHub username
./scripts/create-textbook.sh physics-101 "Physics 101" yourname
```

## What Gets Created

Each textbook is a **completely independent repository** with this structure:

```
biology-101/
├── docs/                       # All content
│   ├── index.md               # Home page
│   ├── about.md               # About the textbook
│   ├── glossary.md            # Terminology
│   ├── references.md          # Citations
│   ├── license.md             # CC BY-NC-SA 4.0
│   ├── css/
│   │   └── extra.css          # Custom styles
│   ├── js/
│   │   └── extra.js           # Custom scripts
│   ├── img/
│   │   ├── logo.png           # Site logo
│   │   └── favicon.ico        # Browser icon
│   └── sims/                  # MicroSims directory
├── plugins/
│   └── social_override.py     # Custom MkDocs plugins
├── .claude-skills/            # Latest from dmccreary/claude-skills
├── .github/workflows/
│   └── deploy.yml             # Auto-deploy to GitHub Pages
├── mkdocs.yml                 # Site configuration
├── setup.py                   # Plugin installation
├── README.md                  # Repository documentation
├── CLAUDE.md                  # Claude Code guidance
├── .gitignore                 # Git ignore rules
├── sync-skills.sh            # Update skills from upstream
└── sync-framework.sh         # Update framework from upstream
```

## After Creating a Textbook

### 1. Navigate to the new directory
```bash
cd ../biology-101
```

### 2. Create GitHub repository
```bash
# Using GitHub CLI (recommended)
gh repo create biology-101 --public --source=. --remote=origin
git branch -M main
git push -u origin main
```

Or create manually at https://github.com/new and push:
```bash
git remote add origin https://github.com/yourname/biology-101.git
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages
1. Go to repository Settings → Pages
2. Source: "GitHub Actions"
3. Wait ~2 minutes for deployment
4. Visit: `https://yourname.github.io/biology-101/`

### 4. Develop locally
```bash
# Create conda environment
conda create -n biology-101 python=3
conda activate biology-101

# Install dependencies
pip install mkdocs "mkdocs-material[imaging]"
pip install -e .

# Start development server
mkdocs serve
# Visit http://localhost:8000
```

## Keeping Textbooks Updated

Each textbook includes two sync scripts:

### Update Skills
```bash
./sync-skills.sh
```
Fetches the latest skills from [dmccreary/claude-skills](https://github.com/dmccreary/claude-skills).

### Update Framework
```bash
./sync-framework.sh
```
Updates plugins and tools from [vishalsachdev/intelligent-textbooks](https://github.com/vishalsachdev/intelligent-textbooks).

**Recommended:** Run both scripts monthly or when upstream announces updates.

## Architecture Overview

```
┌─────────────────────────────────────┐
│ dmccreary/intelligent-textbooks     │  ← Original framework
└───────────────┬─────────────────────┘
                │ (forked)
                ↓
┌─────────────────────────────────────┐
│ vishalsachdev/intelligent-textbooks │  ← Your fork (this repo)
└───────────────┬─────────────────────┘
                │
                │ (scripts)
                ↓
    ┌───────────────────────┬─────────────────┐
    ↓                       ↓                 ↓
┌─────────┐          ┌─────────┐      ┌──────────┐
│biology  │          │chemistry│      │physics   │
│-101     │          │-intro   │  ... │-101      │
└─────────┘          └─────────┘      └──────────┘
    │                     │                 │
    ↓                     ↓                 ↓
  (pulls skills)      (pulls skills)   (pulls skills)
    │                     │                 │
    └─────────────────────┴─────────────────┘
                          │
                          ↓
          ┌────────────────────────────┐
          │ dmccreary/claude-skills    │  ← Skills repo
          └────────────────────────────┘
```

## Workflow for Multiple Textbooks

### Today: Create 5 textbooks
```bash
cd /path/to/intelligent-textbooks
./scripts/create-textbook.sh biology-101 "Biology 101"
./scripts/create-textbook.sh chemistry-intro "Introduction to Chemistry"
./scripts/create-textbook.sh physics-101 "Physics 101"
./scripts/create-textbook.sh calculus-basics "Calculus Basics"
./scripts/create-textbook.sh world-history "World History"
```

### Push all to GitHub
```bash
for dir in ../biology-101 ../chemistry-intro ../physics-101 ../calculus-basics ../world-history; do
  cd "$dir"
  gh repo create $(basename $dir) --public --source=. --remote=origin
  git branch -M main
  git push -u origin main
  cd -
done
```

### Monthly: Update all textbooks
```bash
for dir in ../biology-101 ../chemistry-intro ../physics-101 ../calculus-basics ../world-history; do
  cd "$dir"
  echo "Updating $(basename $dir)..."
  ./sync-skills.sh
  ./sync-framework.sh
  git add .
  git commit -m "Updated skills and framework from upstream"
  git push
  cd -
done
```

## Working with Claude Code Web Interface

### Single Textbook Session
1. Open Claude Code at https://claude.ai/code
2. Open one textbook repository
3. Work on content, MicroSims, etc.
4. Commit and push when done

### Multiple Textbooks (Sequential)
Since Claude Code web works on one repo at a time:
1. Work on textbook A → commit → push
2. Switch to textbook B → work → commit → push
3. Switch to textbook C → work → commit → push

### Best Practice
- Keep sessions focused on one textbook
- Use clear commit messages
- Push frequently to save work

## Collaborator Management

Each textbook repository is independent:

```bash
# Add collaborator to specific textbook
cd ../biology-101
gh repo add-collaborator yourname/biology-101 collaborator-username

# Collaborator only has access to biology-101
# They cannot see chemistry-intro, physics-101, etc.
```

Perfect for:
- Different co-authors per textbook
- Subject matter experts per domain
- Student contributors to specific courses

## Troubleshooting

### Script fails with "command not found: gh"
The GitHub CLI is optional. Create repos manually at https://github.com/new

### "Directory already exists"
The script checks for existing directories. Use a different slug or remove the old directory.

### Plugins not working
After running `sync-framework.sh`, reinstall:
```bash
pip install -e .
```

### Skills not updating
Check your internet connection and try:
```bash
rm -rf .claude-skills
./sync-skills.sh
```

## Contributing Back

Found a bug or improvement? Contribute back to:
- Framework: [vishalsachdev/intelligent-textbooks](https://github.com/vishalsachdev/intelligent-textbooks)
- Or upstream: [dmccreary/intelligent-textbooks](https://github.com/dmccreary/intelligent-textbooks)
- Skills: [dmccreary/claude-skills](https://github.com/dmccreary/claude-skills)

## License

Scripts are part of the intelligent-textbooks framework.
Licensed under CC BY-NC-SA 4.0 for non-commercial use.

---

**Questions?** Open an issue at https://github.com/vishalsachdev/intelligent-textbooks/issues
