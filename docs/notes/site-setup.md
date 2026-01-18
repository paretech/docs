# Site Setup and Deployment

This site is built with [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) and deployed to [GitHub Pages](https://pages.github.com/) using the modern GitHub Actions workflow.

## Architecture Overview

```
Local Development          GitHub                    GitHub Pages
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  mkdocs serve   │──push─▶│  GitHub Actions │──────▶│  Static Site    │
│  (localhost)    │       │  (build/deploy) │       │  (public URL)   │
└─────────────────┘       └─────────────────┘       └─────────────────┘
```

## Key Components

### MkDocs Configuration

The site configuration lives in `mkdocs.yml` at the repository root:

```yaml
site_name: Docs
site_url: https://paretech.github.io/docs
theme:
  name: material
nav:
  - Home: index.md
  - Notes:
      - Page Title: notes/example.md
```

**Documentation**: [MkDocs Configuration](https://www.mkdocs.org/user-guide/configuration/)

### GitHub Actions Workflow

The deployment workflow (`.github/workflows/ci.yml`) uses the modern artifact-based approach rather than the legacy `gh-deploy` method.

```yaml
name: ci
on:
  push:
    branches:
      - main

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: 3.x
      - run: pip install mkdocs-material
      - run: mkdocs build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: site

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

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

## Local Development

### Prerequisites

```bash
pip install mkdocs-material
```

### Serve Locally

```bash
mkdocs serve
```

This starts a local server at `http://127.0.0.1:8000` with live reload.

### Build Locally

```bash
mkdocs build
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

3. Commit and push to `main`
4. The GitHub Action will automatically build and deploy

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
