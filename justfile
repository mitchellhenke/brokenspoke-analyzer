set positional-arguments := true

src_dir := "brokenspoke_analyzer"

# Meta task running ALL the CI tasks at onces.
ci: lint docs test

# Meta task running all the linters at once.
lint: lint-md lint-python

# Lint markown files.
lint-md:
    npx --yes markdownlint-cli2 "**/*.md" "#.venv"

# Lint python files.
lint-python:
    poetry run isort --check .
    poetry run black --check {{ src_dir }}
    poetry run ruff check {{ src_dir }}
    poetry run mypy {{ src_dir }}

# Meta tasks running all formatters at once.
fmt: fmt-md fmt-python fmt-just

# Format the justfile.
fmt-just:
    just --fmt --unstable

# Format markdown files.
fmt-md:
    npx --yes prettier --write --prose-wrap always **/*.md

# Format python files.
fmt-python:
    poetry run isort .
    poetry run black {{ src_dir }}
    poetry run black examples
    poetry run ruff check --fix {{ src_dir }}
    poetry run ruff check --fix examples

# Run the unit tests.
test *extra_args='':
    poetry run pytest --cov={{ src_dir }} -x $@

# Build the documentation
docs:
    cd docs && poetry run make html
    @echo
    @echo "Click this link to open the documentation in the browser:"
    @echo "  file://${PWD}/docs/build/html/index.html"
    @echo

# Rebuild Sphinx documentation on changes, with live-reload in the browser
docs-autobuild:
    poetry run sphinx-autobuild docs/source docs/build/html

# Clean the docs
docs-clean:
    rm -fr docs/build

# Run the US Cities examples
example-uscities:
    poetry run python examples/us-cities.py
