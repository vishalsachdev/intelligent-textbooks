#!/bin/bash
# create-textbook.sh - Creates a new intelligent textbook repository
# Usage: ./scripts/create-textbook.sh <textbook-slug> <"Textbook Name"> [github-username]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKILLS_REPO="https://github.com/dmccreary/claude-skills.git"
FRAMEWORK_REPO="https://github.com/vishalsachdev/intelligent-textbooks.git"

# Parse arguments
TEXTBOOK_SLUG="$1"
TEXTBOOK_NAME="$2"
GITHUB_USERNAME="${3:-vishalsachdev}"

if [ -z "$TEXTBOOK_SLUG" ] || [ -z "$TEXTBOOK_NAME" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 <textbook-slug> <\"Textbook Name\"> [github-username]"
    echo ""
    echo "Example:"
    echo "  $0 biology-101 \"Biology 101\""
    echo "  $0 chemistry-intro \"Introduction to Chemistry\" your-username"
    exit 1
fi

# Validate textbook slug (lowercase, hyphens only)
if [[ ! "$TEXTBOOK_SLUG" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}Error: Textbook slug must contain only lowercase letters, numbers, and hyphens${NC}"
    exit 1
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Creating Intelligent Textbook${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Slug: ${GREEN}$TEXTBOOK_SLUG${NC}"
echo -e "Name: ${GREEN}$TEXTBOOK_NAME${NC}"
echo -e "Owner: ${GREEN}$GITHUB_USERNAME${NC}"
echo ""

# Check if directory already exists
if [ -d "../$TEXTBOOK_SLUG" ]; then
    echo -e "${RED}Error: Directory ../$TEXTBOOK_SLUG already exists${NC}"
    exit 1
fi

# Save original working directory (parent of intelligent-textbooks repo)
ORIGINAL_DIR="$(cd .. && pwd)"

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}Working in temporary directory: $TEMP_DIR${NC}"

cd "$TEMP_DIR"
mkdir "$TEXTBOOK_SLUG"
cd "$TEXTBOOK_SLUG"

echo -e "\n${BLUE}Step 1/6: Creating directory structure...${NC}"
mkdir -p docs/img
mkdir -p docs/css
mkdir -p docs/js
mkdir -p docs/sims
mkdir -p plugins
mkdir -p .github/workflows

echo -e "${GREEN}✓ Directory structure created${NC}"

echo -e "\n${BLUE}Step 2/6: Copying framework files...${NC}"

# Copy plugins from framework repo
FRAMEWORK_DIR="/home/user/intelligent-textbooks"
if [ -d "$FRAMEWORK_DIR/plugins" ]; then
    cp -r "$FRAMEWORK_DIR/plugins/"* plugins/
    echo -e "${GREEN}✓ Copied plugins${NC}"
fi

# Copy setup.py for plugin
if [ -f "$FRAMEWORK_DIR/setup.py" ]; then
    cp "$FRAMEWORK_DIR/setup.py" .
    echo -e "${GREEN}✓ Copied setup.py${NC}"
fi

# Copy essential CSS/JS
if [ -f "$FRAMEWORK_DIR/docs/css/extra.css" ]; then
    cp "$FRAMEWORK_DIR/docs/css/extra.css" docs/css/
    echo -e "${GREEN}✓ Copied CSS${NC}"
fi

if [ -f "$FRAMEWORK_DIR/docs/js/extra.js" ]; then
    cp "$FRAMEWORK_DIR/docs/js/extra.js" docs/js/
    echo -e "${GREEN}✓ Copied JavaScript${NC}"
fi

# Copy placeholder logo and favicon
if [ -f "$FRAMEWORK_DIR/docs/img/logo.png" ]; then
    cp "$FRAMEWORK_DIR/docs/img/logo.png" docs/img/
    echo -e "${GREEN}✓ Copied logo${NC}"
fi

if [ -f "$FRAMEWORK_DIR/docs/img/favicon.ico" ]; then
    cp "$FRAMEWORK_DIR/docs/img/favicon.ico" docs/img/
    echo -e "${GREEN}✓ Copied favicon${NC}"
fi

echo -e "\n${BLUE}Step 3/6: Fetching latest skills...${NC}"
git clone --depth 1 "$SKILLS_REPO" .claude-skills 2>/dev/null || {
    echo -e "${YELLOW}⚠ Could not clone skills repo, will add as reference${NC}"
    mkdir -p .claude-skills
    echo "# Skills are available at: $SKILLS_REPO" > .claude-skills/README.md
}
rm -rf .claude-skills/.git
echo -e "${GREEN}✓ Skills fetched${NC}"

echo -e "\n${BLUE}Step 4/6: Creating configuration files...${NC}"

# Create mkdocs.yml
cat > mkdocs.yml << EOF
site_name: $TEXTBOOK_NAME
site_description: 'An intelligent textbook built with AI-powered tools and interactive learning experiences.'
site_author: '$GITHUB_USERNAME'
repo_name: 'GitHub Repo'
site_url: 'https://$GITHUB_USERNAME.github.io/$TEXTBOOK_SLUG/'
repo_url: 'https://github.com/$GITHUB_USERNAME/$TEXTBOOK_SLUG'
edit_uri: 'blob/main/docs'

nav:
  - Home: index.md
  - About: about.md
  - Glossary: glossary.md
  - References: references.md
  - License: license.md

theme:
  name: material
  logo: img/logo.png
  favicon: img/favicon.ico
  palette:
    primary: 'blue'
    accent: 'orange'
  include_sidebar: true
  features:
    - content.code.copy
    - navigation.expand
    - navigation.path
    - navigation.prune
    - navigation.indexes
    - toc.follow
    - navigation.top
    - navigation.footer
    - content.action.edit

plugins:
  - search
  - social
  - social_override

markdown_extensions:
  - admonition
  - md_in_html
  - pymdownx.details
  - pymdownx.superfences
  - attr_list
  - pymdownx.highlight:
      linenums: true

extra_css:
   - css/extra.css

extra_javascript:
    - js/extra.js

copyright: Copyright &copy; 2025 $GITHUB_USERNAME. Licensed under <a href="license/">CC BY-NC-SA 4.0</a> for non-commercial use.

extra:
  generator: false
EOF
echo -e "${GREEN}✓ Created mkdocs.yml${NC}"

# Create index.md
cat > docs/index.md << EOF
# $TEXTBOOK_NAME

Welcome to $TEXTBOOK_NAME - an intelligent textbook built using AI-powered tools and interactive learning experiences.

## About This Textbook

This textbook is designed to provide an engaging, interactive learning experience using:

- **Interactive Simulations (MicroSims)** - Hands-on p5.js visualizations
- **Concept Dependency Graphs** - Clear learning pathways
- **AI-Generated Content** - High-quality educational materials
- **Adaptive Learning** - Content that responds to your needs

## Getting Started

Start your learning journey by exploring the topics in the navigation menu.

## Built With

This textbook uses the [Intelligent Textbooks Framework](https://github.com/dmccreary/intelligent-textbooks) and [Claude Skills](https://github.com/dmccreary/claude-skills).

---

*Last updated: $(date +"%Y-%m-%d")*
EOF
echo -e "${GREEN}✓ Created index.md${NC}"

# Create about.md
cat > docs/about.md << EOF
# About $TEXTBOOK_NAME

## Overview

This textbook provides comprehensive coverage of [your subject area].

## Learning Objectives

By the end of this textbook, you will be able to:

- [Objective 1]
- [Objective 2]
- [Objective 3]

## Structure

This textbook is organized into the following sections:

- **[Section 1]** - Introduction and fundamentals
- **[Section 2]** - Core concepts
- **[Section 3]** - Advanced topics

## Target Audience

This textbook is designed for:

- [Audience 1]
- [Audience 2]
- [Audience 3]

## Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]

## How to Use This Textbook

[Instructions for using the textbook]
EOF
echo -e "${GREEN}✓ Created about.md${NC}"

# Create glossary.md
cat > docs/glossary.md << EOF
# Glossary

## A

**Term A**: Definition of term A.

## B

**Term B**: Definition of term B.

---

*Glossary terms will be added as the textbook develops.*
EOF
echo -e "${GREEN}✓ Created glossary.md${NC}"

# Create references.md
cat > docs/references.md << EOF
# References

## Primary Sources

1. [Reference 1]
2. [Reference 2]

## Additional Resources

- [Resource 1]
- [Resource 2]

## Related Textbooks

- [Building Intelligent Textbooks](https://dmccreary.github.io/intelligent-textbooks/)
EOF
echo -e "${GREEN}✓ Created references.md${NC}"

# Create license.md
cat > docs/license.md << EOF
# License

## Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International

This work is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

### You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material

### Under the following terms:

- **Attribution** — You must give appropriate credit
- **NonCommercial** — You may not use the material for commercial purposes
- **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the same license

### Author

$GITHUB_USERNAME

### Year

2025
EOF
echo -e "${GREEN}✓ Created license.md${NC}"

# Create README.md
cat > README.md << EOF
# $TEXTBOOK_NAME

[![Built with Material for MkDocs](https://img.shields.io/badge/Material_for_MkDocs-526CFE?style=for-the-badge&logo=MaterialForMkDocs&logoColor=white)](https://squidfunk.github.io/mkdocs-material/)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-222222?style=for-the-badge&logo=GitHub%20Pages&logoColor=white)](https://$GITHUB_USERNAME.github.io/$TEXTBOOK_SLUG/)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg?style=for-the-badge)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

An intelligent textbook built with AI-powered tools and interactive learning experiences.

## 🌐 Website

**[View the Live Site →](https://$GITHUB_USERNAME.github.io/$TEXTBOOK_SLUG/)**

## 📖 About

[Add description of your textbook here]

## 🚀 Quick Start

### Local Development

\`\`\`bash
# Create conda environment
conda create -n $TEXTBOOK_SLUG python=3
conda activate $TEXTBOOK_SLUG

# Install dependencies
pip install mkdocs "mkdocs-material[imaging]"

# Install custom plugins
pip install -e .

# Serve locally
mkdocs serve
# Visit http://localhost:8000
\`\`\`

### Deployment

\`\`\`bash
# Deploy to GitHub Pages
mkdocs gh-deploy
\`\`\`

## 🔄 Keeping Updated

### Update Skills

\`\`\`bash
./sync-skills.sh
\`\`\`

### Update Framework (plugins, tools)

\`\`\`bash
./sync-framework.sh
\`\`\`

## 📚 Built With

- [Intelligent Textbooks Framework](https://github.com/dmccreary/intelligent-textbooks)
- [Claude Skills](https://github.com/dmccreary/claude-skills)
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/)
- [p5.js](https://p5js.org/) for interactive simulations

## 📄 License

This work is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

## 🤝 Contributing

[Add contribution guidelines if applicable]

---

*Created with [create-textbook.sh](https://github.com/$GITHUB_USERNAME/intelligent-textbooks)*
EOF
echo -e "${GREEN}✓ Created README.md${NC}"

# Create .gitignore
cat > .gitignore << EOF
site/
.cache/
*.egg-info/
__pycache__/
*.pyc
.DS_Store
*.swp
*.swo
*~
.venv/
venv/
EOF
echo -e "${GREEN}✓ Created .gitignore${NC}"

# Create CLAUDE.md
cat > CLAUDE.md << EOF
# CLAUDE.md

This file provides guidance to Claude Code when working on this textbook.

## Project Overview

This is **$TEXTBOOK_NAME**, an intelligent textbook built using the Intelligent Textbooks Framework. It combines AI-powered content generation with interactive learning experiences.

## Development Commands

### Local Development
\`\`\`bash
# Install dependencies
conda create -n $TEXTBOOK_SLUG python=3
conda activate $TEXTBOOK_SLUG
pip install mkdocs "mkdocs-material[imaging]"
pip install -e .

# Build the site
mkdocs build

# Run local server
mkdocs serve

# Deploy to GitHub Pages
mkdocs gh-deploy
\`\`\`

## Architecture

- **Framework**: Based on [intelligent-textbooks](https://github.com/dmccreary/intelligent-textbooks)
- **Skills**: Uses [Claude Skills](https://github.com/dmccreary/claude-skills)
- **Content**: Located in \`docs/\`
- **Simulations**: Located in \`docs/sims/\`

## File Conventions

- All content pages are Markdown files in \`docs/\`
- Navigation structure is defined in \`mkdocs.yml\`
- MicroSims follow the pattern: \`docs/sims/[name]/index.md\` + \`main.html\` + \`*.js\`
- Custom CSS in \`docs/css/extra.css\`
- Custom JS in \`docs/js/extra.js\`

## Keeping Updated

Run these scripts to sync with upstream:

- \`./sync-skills.sh\` - Update skills from dmccreary/claude-skills
- \`./sync-framework.sh\` - Update framework plugins and tools

## Content Organization

[Add specific information about how content is organized in this textbook]
EOF
echo -e "${GREEN}✓ Created CLAUDE.md${NC}"

# Create GitHub Actions workflow
cat > .github/workflows/deploy.yml << EOF
name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: |
          pip install mkdocs "mkdocs-material[imaging]"
          pip install -e .

      - name: Deploy to GitHub Pages
        run: mkdocs gh-deploy --force
EOF
echo -e "${GREEN}✓ Created GitHub Actions workflow${NC}"

echo -e "\n${BLUE}Step 5/6: Creating sync scripts...${NC}"

# Create sync-skills.sh
cat > sync-skills.sh << 'EOF'
#!/bin/bash
# sync-skills.sh - Updates skills from dmccreary/claude-skills

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILLS_REPO="https://github.com/dmccreary/claude-skills.git"

echo -e "${BLUE}Syncing skills from upstream...${NC}"

if [ -d ".claude-skills" ]; then
    rm -rf .claude-skills
fi

git clone --depth 1 "$SKILLS_REPO" .claude-skills
rm -rf .claude-skills/.git

echo -e "${GREEN}✓ Skills updated successfully${NC}"
echo -e "Skills are now at the latest version from dmccreary/claude-skills"
EOF
chmod +x sync-skills.sh
echo -e "${GREEN}✓ Created sync-skills.sh${NC}"

# Create sync-framework.sh
cat > sync-framework.sh << 'EOF'
#!/bin/bash
# sync-framework.sh - Updates framework files from intelligent-textbooks

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

FRAMEWORK_REPO="https://github.com/vishalsachdev/intelligent-textbooks.git"

echo -e "${BLUE}Syncing framework from upstream...${NC}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

git clone --depth 1 "$FRAMEWORK_REPO" framework

# Go back to textbook directory
cd -

# Update plugins
if [ -d "$TEMP_DIR/framework/plugins" ]; then
    echo -e "${YELLOW}Updating plugins...${NC}"
    rm -rf plugins/*
    cp -r "$TEMP_DIR/framework/plugins/"* plugins/
    echo -e "${GREEN}✓ Plugins updated${NC}"
fi

# Update setup.py
if [ -f "$TEMP_DIR/framework/setup.py" ]; then
    cp "$TEMP_DIR/framework/setup.py" .
    echo -e "${GREEN}✓ setup.py updated${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ Framework updated successfully${NC}"
echo -e "${YELLOW}Note: Review changes and reinstall plugins: pip install -e .${NC}"
EOF
chmod +x sync-framework.sh
echo -e "${GREEN}✓ Created sync-framework.sh${NC}"

echo -e "\n${BLUE}Step 6/6: Initializing git repository...${NC}"

git init
git add .
git commit --no-gpg-sign -m "Initial commit: $TEXTBOOK_NAME

Created with intelligent-textbooks framework
Skills from dmccreary/claude-skills
"
echo -e "${GREEN}✓ Git repository initialized${NC}"

# Move to final location (parent of intelligent-textbooks repo)
cd ..
FINAL_DIR="$ORIGINAL_DIR/$TEXTBOOK_SLUG"
mv "$TEXTBOOK_SLUG" "$FINAL_DIR"
cd "$FINAL_DIR"

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Textbook created successfully!${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "\nLocation: ${BLUE}$FINAL_DIR${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. cd $FINAL_DIR"
echo -e "  2. Review and customize the content in docs/"
echo -e "  3. Create GitHub repository:"
echo -e "     ${BLUE}gh repo create $TEXTBOOK_SLUG --public --source=. --remote=origin${NC}"
echo -e "  4. Push to GitHub:"
echo -e "     ${BLUE}git branch -M main${NC}"
echo -e "     ${BLUE}git push -u origin main${NC}"
echo -e "  5. Enable GitHub Pages in repository settings"
echo -e "  6. Install and test locally:"
echo -e "     ${BLUE}conda create -n $TEXTBOOK_SLUG python=3${NC}"
echo -e "     ${BLUE}conda activate $TEXTBOOK_SLUG${NC}"
echo -e "     ${BLUE}pip install mkdocs \"mkdocs-material[imaging]\"${NC}"
echo -e "     ${BLUE}pip install -e .${NC}"
echo -e "     ${BLUE}mkdocs serve${NC}"
echo -e "\n${YELLOW}To update from upstream:${NC}"
echo -e "  - Update skills: ${BLUE}./sync-skills.sh${NC}"
echo -e "  - Update framework: ${BLUE}./sync-framework.sh${NC}"
echo -e "\n${GREEN}Happy teaching! 📚${NC}\n"
