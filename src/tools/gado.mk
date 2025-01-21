.PHONY: install-gado run-gado

GADO_VERSION := 1.0.4
GADO_NAME := gado-$(GADO_VERSION)
GADO_DIR := $(CONFIG_DIR)/$(GADO_NAME)

# Install GADO
install-gado:
	mkdir -p $(GADO_DIR)
	cd $(GADO_DIR) && \
		wget https://github.com/molgenis/systemsgenetics/releases/download/GADO_$(GADO_VERSION)/GadoCommandline-$(GADO_VERSION).tar.gz && \
		tar -zxf GadoCommandline-$(GADO_VERSION).tar.gz && \
		wget https://molgenis26.gcc.rug.nl/downloads/genenetwork/v2.1/genenetwork_bonf_spiked.zip && \
		unzip genenetwork_bonf_spiked.zip && \
		wget https://molgenis26.gcc.rug.nl/downloads/genenetwork/v2.1/predictions_auc_bonf.txt && \
		wget https://molgenis26.gcc.rug.nl/downloads/genenetwork/v2.1/hpo_prediction_genes.txt && \
		wget https://github.com/obophenotype/human-phenotype-ontology/releases/download/v2024-12-12/hp.obo
	cp src/tools/configs/gado-config.yaml $(GADO_DIR)/config.yaml
	@echo "Installed $(GADO_NAME) in $(GADO_DIR)"

# Run GADO
run-gado: VENV_NAME=gado
run-gado: venv
	$(PIP) install pheval.gado
	mkdir -p $(RESULTS_DIR)/$(GADO_NAME)/phenopacket_store_0.1.11_phenotypes
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval run --input-dir "$(GADO_DIR)" \
		--testdata-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_phenotypes" \
		--output-dir "$(RESULTS_DIR)/$(GADO_NAME)/phenopacket_store_0.1.11_phenotypes" \
		--runner gadophevalrunner --version $(GADO_VERSION)
	$(PIP) uninstall -y pheval.gado
	@echo "Finished running $(GADO_NAME)"

