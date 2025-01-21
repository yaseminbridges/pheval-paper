.PHONY: all install-corpora install-tools run benchmark

.DEFAULT_GOAL := help

CWD := $(shell pwd)
VENV_BASE := $(CWD)/.venv
PYTHON := $(VENV_BASE)/$(VENV_NAME)/bin/python
PIP = $(VENV_BASE)/$(VENV_NAME)/bin/pip
PHEVAL_UTILS = $(VENV_BASE)/$(VENV_NAME)/bin/pheval-utils
TARGET := $(CWD)/target
CORPORA_DIR := $(TARGET)/corpora
CONFIG_DIR := $(TARGET)/configurations
RESULTS_DIR := $(TARGET)/results
BENCHMARK_DIR := $(TARGET)/benchmark

# Include child Makefiles
include src/corpora/corpora.mk
include src/tools/aim.mk
include src/tools/exomiser.mk
include src/tools/gado.mk
include src/tools/lirical.mk
include src/tools/phen2gene.mk
include src/tools/phenogenius.mk
include src/tools/svanna.mk
include src/benchmark/benchmark.mk


help:
	@echo "This Makefile illustrates how to setup and run a set of PhEval benchmarks for comparing various phenotype-driven genomic analysis tools."

all:
	@echo "This is a warning - do not run this unless you have weeks to wait: 'make install-corpora install-tools run benchmark'"

# Virtual environment setup
venv:
	@if [ -z "$(VENV_NAME)" ]; then \
		echo "Error: Please specify VENV_NAME when calling venv"; \
		exit 1; \
	fi
	python3 -m venv $(VENV_BASE)/$(VENV_NAME)
	$(PIP) install --upgrade pip
	@echo "Virtual environment created at $(VENV_BASE)/$(VENV_NAME)"

install-corpora: download-pheval-paper-corpora install-pheval-paper-corpora

# Install dependencies and prepare data
install-tools: install-aim install-exomiser install-gado install-lirical install-phen2gene install-phenogenius install-svanna
	@echo "Install complete!"

# Run the main application
run: run-aim run-exomiser run-gado run-lirical run-phen2gene run-phenogenius run-svanna
	@echo "All tools have been run successfully"

# Run benchmarks and analysis
benchmark: run-phenotype-only-benchmarks run-variant-benchmarks run-structural-variant-benchmarks
	@echo "Finished benchmarks"

# Downloads the results of the 'install-tools' and 'run' targets from Zenodo, unpacks them and then runs the 'benchmark'
# target to produce Figure 3. of the paper
run-paper-benchmarks: install-paper-results	benchmark

# Download and results of the analyses run for the PheVal paper and then run the benchmark target to produce Figure 3.
# This will download a 5.3 GB archive which will expand to ~35 GB
install-paper-results:
	wget https://zenodo.org/records/14679713/files/pheval-paper-results.tar.gz -P $(TARGET)
	tar -zxf $(TARGET)/pheval-paper-results.tar.gz --strip-components=1 -C $(RESULTS_DIR)