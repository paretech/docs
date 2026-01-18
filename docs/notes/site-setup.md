# About This Site

This site is a place where I can store my "evergreen" notes. I have used Microsoft OneNote for well over a decade. OneNote has generally served me well. However, a recent data loss event gave me pause. I needed a better place for the notes I care most about.

!!! warning "Material for MkDocs in Maintenance Mode"
    [As of November 6, 2025, Material for MkDocs is in maintenance mode](https://github.com/squidfunk/mkdocs-material/issues/8523).

    - No new features to Material for MkDocs.
    - Critical bug fixes and security updates through end of 2026.
    - Maintainers encourage migrating to [Zensical](https://zensical.org/).

This site is built with [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) and deployed to [GitHub Pages](https://pages.github.com/) using the modern GitHub Actions workflow.

I made the decision to start a new Material site after the maintenance mode announcement because:

- Material is mature with a rich core and ecosystem
- Material was trivial to setup and deploy with GitHub pages
- [Zensical](https://zensical.org) is offering compatibility and an upgrade path if I want to go that way in the future.

I wanted a personal documentation site that I could start using today rather than yet another project for tomorrow. Habits are hard to break, I am not yet sure how much I will use this site or how it might fit into my workflow.

## Architecture Overview

```ASCII
Local Development          GitHub                    GitHub Pages
┌─────────────────┐        ┌─────────────────┐       ┌─────────────────┐
│  mkdocs serve   │──push─▶│  GitHub Actions │──────▶│  Static Site    │
│  (localhost)    │        │  (build/deploy) │       │  (public URL)   │
└─────────────────┘        └─────────────────┘       └─────────────────┘
```

## Key Components

### MkDocs Configuration

The site configuration lives in `mkdocs.yml` at the repository root:

**Documentation**: [MkDocs Configuration](https://www.mkdocs.org/user-guide/configuration/)

### Navigation

The site uses Material's `navigation.tabs` feature to display top-level sections as tabs at the top of the page.

```yaml
theme:
  features:
    - navigation.tabs
```

**Auto-population**: There is no `nav` section in `mkdocs.yml`. MkDocs automatically generates navigation from the folder structure under `docs/`. Files are sorted alphabetically, and folder names become section titles.

**When to add explicit `nav`**:

- You need a specific ordering (not alphabetical)
- You want custom titles different from header
- You want to exclude certain files from navigation
- The auto-generated structure becomes confusing as the site grows

**Documentation**: [Material - Navigation tabs](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/#navigation-tabs)

### GitHub Actions Workflow

The deployment workflow (`.github/workflows/ci.yml`) uses the modern artifact-based approach rather than the legacy `gh-deploy` method.

#### Why Two Jobs?

The workflow separates build and deploy for clarity and to leverage GitHub's deployment environments. The `deploy` job runs in the special `github-pages` environment, which provides deployment history and status tracking in the repository's "Environments" section.

#### Required Permissions

| Permission | Purpose |
|------------|---------|
| `contents: read` | Read repository files during build |
| `pages: write` | Publish to GitHub Pages |
| `id-token: write` | OIDC authentication for secure deployment |

**Documentation**:

- [GitHub - Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
- [actions/deploy-pages](https://github.com/actions/deploy-pages)
- [actions/upload-pages-artifact](https://github.com/actions/upload-pages-artifact)

### GitHub Pages Configuration

In the repository settings under **Pages**, configure:

- **Source**: GitHub Actions (not "Deploy from a branch")
- This tells GitHub to use the artifact uploaded by the workflow rather than serving files directly from a branch

**Documentation**: [GitHub Pages Quickstart](https://docs.github.com/en/pages/quickstart)

## Deployment Methods Compared

There are two common approaches to deploying MkDocs to GitHub Pages:

### Legacy: `mkdocs gh-deploy`

```yaml
- run: mkdocs gh-deploy --force
```

- Builds the site and pushes HTML directly to a `gh-pages` branch
- Requires `contents: write` permission
- Simple but clutters the repository with build artifacts
- GitHub Pages must be configured to deploy from the `gh-pages` branch

**Documentation**: [MkDocs - Deploying Your Docs](https://www.mkdocs.org/user-guide/deploying-your-docs/)

### Modern: GitHub Actions Artifact Deployment

```yaml
- run: mkdocs build
- uses: actions/upload-pages-artifact@v3
- uses: actions/deploy-pages@v4
```

- Builds the site and uploads as a workflow artifact
- GitHub's deploy action publishes from the artifact
- No `gh-pages` branch needed
- Better integration with GitHub's deployment tracking
- Uses OIDC tokens for secure authentication

**Documentation**: [Material for MkDocs - Publishing Your Site](https://squidfunk.github.io/mkdocs-material/publishing-your-site/)

## Markdown Linting

This site uses [markdownlint](https://github.com/DavidAnson/markdownlint) to enforce consistent Markdown formatting. Linting is configured at three levels:

### VS Code (Editor)

The `davidanson.vscode-markdownlint` extension provides inline warnings and auto-fix on save.

Configuration in `.vscode/settings.json`:

```json
"[markdown]": {
  "editor.codeActionsOnSave": {
    "source.fixAll.markdownlint": "explicit"
  }
}
```

The `"explicit"` value means fixes run on manual save (Cmd+S), not on auto-save.

### Pre-commit Hook (Local)

The [pre-commit](https://pre-commit.com/) framework runs markdownlint before each commit.

Configuration in `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.17.1
    hooks:
      - id: markdownlint-cli2
        args: ["--fix"]
```

The hook auto-fixes issues when possible. If fixes are applied, the commit is blocked so you can review and re-commit.

**Setup required**: Run `make setup` (see [Local Development](#local-development)).

### GitHub Action (CI)

The lint workflow (`.github/workflows/lint.yml`) runs on pushes to `main` and on pull requests when Markdown files change. This catches issues from GitHub web UI edits.

```yaml
on:
  push:
    branches: [main]
    paths: ["**.md"]
  pull_request:
    paths: ["**.md"]
```

### Lint Rules

Rules are configured in `.markdownlint.json`:

- **MD013** (line length): Disabled — prose wraps naturally
- **MD024** (duplicate headings): `siblings_only: true` — allows duplicate headings in different sections
- **MD046** (code block style): Disabled — false positives from Material admonitions (indented content is required syntax, not code blocks)
- **MD060** (table column style): Disabled — pedantic; tables render correctly without strict pipe alignment

**Documentation**: [markdownlint rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)

### Running Lint Manually

To check specific files outside of pre-commit or CI:

```bash
npx markdownlint-cli2 docs/notes/site-setup.md
```

Or lint all Markdown files:

```bash
make lint
```

## Dependencies

Dependencies are managed in `pyproject.toml` using optional dependency groups:

```toml
[project]
dependencies = [          # Core: required for building
    "mkdocs-material",
    "mdx-truly-sane-lists",
]

[project.optional-dependencies]
dev = [                   # Dev: only needed locally
    "pre-commit",
]
```

| Group | Installed by | Used for |
|-------|--------------|----------|
| Core (`dependencies`) | `pip install .` | Building the site (CI and local) |
| Dev (`[dev]`) | `pip install -e ".[dev]"` | Local development (pre-commit, etc.) |

The GitHub Action only installs core dependencies. Local development installs both.

## Local Development

### Prerequisites

Install dependencies using the Makefile:

```bash
make setup
```

This runs `pip install -e ".[dev]"` to install all dependencies (core + dev) in editable mode, then configures the pre-commit hook.

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make setup` | Install dependencies and configure pre-commit hook |
| `make serve` | Run local dev server at `http://127.0.0.1:8000` |
| `make build` | Build static site to `site/` directory |
| `make lint` | Run markdownlint on all Markdown files |

### Serve Locally

```bash
make serve
```

This starts a local server at `http://127.0.0.1:8000` with live reload.

### Build Locally

```bash
make build
```

This generates the static site in the `site/` directory.

## Adding New Pages

1. Create a new Markdown file in `docs/` or a subdirectory (e.g., `docs/notes/`)
2. Add the page to the `nav` section in `mkdocs.yml`:

```yaml
nav:
  - Home: index.md
  - Notes:
      - New Page: notes/new-page.md
```

1. Commit and push to `main`
2. The GitHub Action will automatically build and deploy

## Troubleshooting

### Site Not Updating After Push

1. Check the **Actions** tab for workflow run status
2. Verify GitHub Pages source is set to "GitHub Actions" (not a branch)
3. Check the **Environments** section for deployment status

### 404 Errors on Pages

- Ensure the file exists in `docs/` and is listed in `mkdocs.yml` nav
- Verify `site_url` in `mkdocs.yml` matches your GitHub Pages URL

### Workflow Permission Errors

Ensure the workflow has the required permissions:

```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

## References

- [Material for MkDocs Documentation](https://squidfunk.github.io/mkdocs-material/)
- [Material for MkDocs - Publishing Your Site](https://squidfunk.github.io/mkdocs-material/publishing-your-site/)
- [MkDocs Documentation](https://www.mkdocs.org/)
- [MkDocs - Deploying Your Docs](https://www.mkdocs.org/user-guide/deploying-your-docs/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub - Using Custom Workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
- [actions/deploy-pages](https://github.com/actions/deploy-pages)
- [actions/upload-pages-artifact](https://github.com/actions/upload-pages-artifact)
