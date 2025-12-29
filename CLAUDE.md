# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an educational resource repository for building intelligent textbooks using MkDocs with the Material theme. The project demonstrates how to create interactive educational content with microsimulations (MicroSims) using p5.js, learning graphs for concept dependencies, and AI-powered content generation workflows.

## Development Commands

### Local Development
```bash
# Install dependencies (requires conda environment)
conda create -n mkdocs python=3
conda activate mkdocs
pip install mkdocs "mkdocs-material[imaging]"

# Build the site locally
mkdocs build

# Run local development server
mkdocs serve
# Site will be available at http://localhost:8000

# Deploy to GitHub Pages
mkdocs gh-deploy
```

### Image Processing Dependencies (macOS)
For social card generation, install additional dependencies:
```bash
brew install cairo freetype libffi libjpeg libpng zlib
export DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib
```

## Architecture

### Core Components

**MkDocs Site Structure**: Standard MkDocs project with Material theme, organized into educational sections (Tutorial, Concepts, Prompts, Workflows, MicroSims, Case Studies).

**MicroSims**: Interactive p5.js simulations embedded via iframes. Each MicroSim has:
- `index.md` - Documentation and embedding
- `main.html` - Standalone HTML page
- `*.js` - p5.js simulation code
- Template structure in `docs/sims/templates/`

**Custom Social Override Plugin**: Python plugin (`plugins/social_override.py`) that allows pages to specify custom Open Graph images via metadata instead of auto-generated social cards.

**Learning Graphs**: Concept dependency visualizations stored as CSV/JSON data in `docs/sims/learning-graph/` with interactive graph viewer.

**Content Organization**:
- `docs/` - All markdown content
- `docs/sims/` - MicroSim directories
- `docs/css/extra.css` and `docs/js/extra.js` - Custom styling and functionality
- `src/` - Python utility scripts for analytics, CSV processing, and content generation

### Key Features

**Educational Concepts**: Implements Bloom's Taxonomy, scaffolding, and five levels of textbook intelligence.

**AI Prompts Collection**: Structured prompts for content generation, concept enumeration, dependency mapping, and quality assessment.

**Workflow Documentation**: Step-by-step processes for creating educational content with AI assistance.

**Analytics Scripts**: Python tools in `src/` for site metrics, content analysis, and report generation.

## File Conventions

**MicroSim Structure**: Each simulation follows the pattern:
```
docs/sims/[name]/
├── index.md          # Documentation page
├── main.html         # Standalone simulation
└── [name].js         # p5.js code
```

**Social Images**: Pages can override auto-generated social cards by adding `image: path/to/image.png` in frontmatter.

**Navigation**: All content structure defined in `mkdocs.yml` nav section - update this when adding new pages.

## Python Environment

The project uses conda for environment management rather than venv to support potential future multi-language dependencies. All Python utilities are in `src/` subdirectories with specific purposes (analytics, CSV processing, etc.).

---

## AI Assistant Guidelines

### DO:
- Help understand concepts and explain approaches
- Review code structure and suggest improvements
- Assist with debugging and error explanation
- Help create MicroSims and explain p5.js concepts
- Explain educational design patterns and Bloom's Taxonomy

### DON'T:
- Provide complete solutions to assignments
- Write code that students should write themselves
- Share answers to graded assessments

---

## Current Focus
- [ ] Improve PDF-to-textbook extraction workflow (better LaTeX/math handling)

## Roadmap
- [x] Add AI Assistant Guidelines to CLAUDE.md
- [x] Add roadmap pattern to CLAUDE.md
- [x] Sync with upstream (dmccreary/intelligent-textbooks)
- [x] Create CS229 ML textbook from PDF source
- [ ] Improve PDF extraction for mathematical notation (marker-pdf or nougat-ocr)
- [ ] Add MicroSims to CS229 textbook for key concepts (gradient descent, etc.)
- [ ] Create reusable PDF-to-textbook workflow documentation

## Session Log
### 2025-12-27
- Added AI Assistant Guidelines and roadmap sections

### 2025-12-29
- Synced intelligent-textbooks repo with upstream (31 commits pulled)
- Added 3 new skills from upstream: concept-classifier, installer, microsim-utils
- Created CS229 ML textbook at `/Users/vishal/teaching/cs229-ml/` from 227-page PDF
  - Extracted 17 chapters using PyPDF2
  - Created learning graph (120 concepts) and glossary (80+ terms)
  - Set up MkDocs with Material theme
- Attempted marker-pdf and nougat-ocr for better PDF extraction (aborted due to system restart)
- Cleaned up marker/nougat files and caches (~1.5 GB freed)
- Next: Improve PDF extraction workflow for better LaTeX/math handling
