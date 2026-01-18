.PHONY: setup serve build lint

setup:
	pip install -e ".[dev]"
	pre-commit install

preview:
	mkdocs serve --livereload

build:
	mkdocs build

lint:
	pre-commit run --all-files
