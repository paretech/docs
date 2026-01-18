.PHONY: setup serve build lint

setup:
	pip install -e ".[dev]"
	pre-commit install

serve:
	mkdocs serve

build:
	mkdocs build

lint:
	pre-commit run --all-files
