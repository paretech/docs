.PHONY: setup serve build lint

setup:
	pip install -r requirements.txt
	pip install pre-commit
	pre-commit install

serve:
	mkdocs serve

build:
	mkdocs build

lint:
	pre-commit run --all-files
