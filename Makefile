# -----------------------------------------------------------------------------
# This Makefile uses GNU Make to orchestrate a small Python-based docs workflow.
# It is intentionally minimal and relies on Make's timestamp-based dependency
# tracking, not shell scripting.
#
# Key ideas:
# - Targets describe *states*, not commands (e.g. "deps are installed").
# - A Python virtual environment lives in $(VENV) and is never globally activated.
# - The STAMP file ($(STAMP)) is a sentinel that records "dependencies installed".
#   If pyproject.toml changes, Make will reinstall deps automatically.
# - Commands always invoke tools from the venv directly (no `source venv/bin/activate`).
# - `make preview` or `make build` is all a user should need on a clean machine.
#
# Typical usage:
#   make preview   # create venv (if needed), install deps, run mkdocs serve
#   make build     # build static site into $(SITE_DIR)/
#   make clean     # remove all derived artifacts (venv + site output)
#
# This pattern is portable across Linux / macOS / WSL and favors reproducibility
# over cleverness.
#
# Core Makefile syntax reminder:
#
# target: dependencies
#     recipe (one or more shell commands)
#
# Meaning:
# "To make <target>, ensure <dependencies> are up to date first, then run the recipe."
#
# Targets usually represent *states* ("deps installed", "site built"), not files
# you edit directly.
#
# Common "automatic variables" used here:
# $@ → name of the current target
# $< → first dependency
# $^ → all dependencies
#
# Example:
# $(STAMP): pyproject.toml | venv
#     pip install ...
#     touch $@
#
# This says: "If pyproject.toml changes, reinstall deps and mark that fact by
# updating the timestamp of $(STAMP)."
#
# Docs for more Make variables and syntax:
# https://www.gnu.org/software/make/manual/make.html
# (see: Automatic Variables, Rule Syntax)
# -----------------------------------------------------------------------------

# -------- config --------
VENV           := venv
PYTHON         := python3
PIP            := $(VENV)/bin/pip
PY             := $(VENV)/bin/python
MKDOCS         := $(VENV)/bin/mkdocs
PRECOMMIT      := $(VENV)/bin/pre-commit
STAMP          := $(VENV)/bin/.deps
PRECOMMIT_HOOK := .git/hooks/pre-commit

SITE_DIR       := site

# If you use extras, set this:
EXTRAS         := dev

# -------- targets --------
.PHONY: help venv install preview build lint clean

help:
	@echo "make venv     - create virtual environment"
	@echo "make install  - install deps from pyproject.toml (editable)"
	@echo "make preview  - run mkdocs dev server"
	@echo "make build    - build static site"
	@echo "make lint     - run pre-commit hooks on all files"
	@echo "make clean    - remove virtualenv"

$(VENV)/bin/activate:
	$(PYTHON) -m venv $(VENV)
	$(PIP) install --upgrade pip setuptools wheel

venv: $(VENV)/bin/activate

# Re-install when pyproject.toml changes (and when venv is recreated)
$(STAMP): pyproject.toml | venv
	$(PIP) install -e ".[${EXTRAS}]"
	@touch $@

# Install pre-commit hook script into .git/hooks/
$(PRECOMMIT_HOOK): $(STAMP)
	$(PRECOMMIT) install

install: $(PRECOMMIT_HOOK)

preview: install
	$(MKDOCS) serve --livereload

build: install
	$(MKDOCS) build -d $(SITE_DIR)

lint: install
	$(PRECOMMIT) run --all-files

clean:
	rm -rf $(VENV) $(SITE_DIR) $(PRECOMMIT_HOOK)
