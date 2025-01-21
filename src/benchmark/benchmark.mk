
PHEVAL_UTILS := $(VENV_BASE)/$(VENV_NAME)/bin/pheval-utils

# Default target
#all: run-variant-benchmarks run-structural-variant-benchmarks run-phenotype-only-benchmarks

## Install pheval and dependencies in a virtual environment
install-pheval: VENV_NAME=pheval
install-pheval: venv 
	$(PIP) install pheval

setup-benchmarks: install-pheval
	mkdir -p $(BENCHMARK_DIR)
	cp src/benchmark/configs/*.yaml $(BENCHMARK_DIR)/.

# Benchmark targets
run-variant-benchmarks: setup-benchmarks
	cd $(TARGET) && $(PHEVAL_UTILS) generate-benchmark-stats --run-yaml $(BENCHMARK_DIR)/variant_runs.yaml

run-structural-variant-benchmarks: setup-benchmarks
	cd $(TARGET) && $(PHEVAL_UTILS) generate-benchmark-stats --run-yaml $(BENCHMARK_DIR)/structural_variant_runs.yaml

run-phenotype-only-benchmarks: setup-benchmarks
	cd $(TARGET) && $(PHEVAL_UTILS) generate-benchmark-stats --run-yaml $(BENCHMARK_DIR)/phenotype_only_runs.yaml

