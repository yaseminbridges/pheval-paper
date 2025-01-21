.PHONY: install-exomiser run-exomiser

EXOMISER_VERSION := 14.0.2
EXOMISER_NAME := exomiser-$(EXOMISER_VERSION)
EXOMISER_DIR := $(CONFIG_DIR)/$(EXOMISER_NAME)

# Install Exomiser
install-exomiser:
	mkdir -p $(EXOMISER_DIR)/2406/variants
	cd $(EXOMISER_DIR)/2406/variants && \
		wget https://github.com/exomiser/Exomiser/releases/download/$(EXOMISER_VERSION)/exomiser-cli-$(EXOMISER_VERSION)-distribution.zip && \
		wget https://g-879a9f.f5dc97.75bc.dn.glob.us/data/2406_phenotype.zip && \
		wget https://g-879a9f.f5dc97.75bc.dn.glob.us/data/2406_hg19.zip && \
		wget https://g-879a9f.f5dc97.75bc.dn.glob.us/data/2406_hg38.zip && \
		for f in *.zip; do unzip "$$f" && rm "$$f"; done
	cp $(EXOMISER_DIR)/2406/variants/exomiser-cli-$(EXOMISER_VERSION)/examples/preset-exome-analysis.yml $(EXOMISER_DIR)/2406/variants/.
	sed -i 's/\[ REVEL, MVP \]/\[ REVEL, MVP, ALPHA_MISSENSE \]/g' $(EXOMISER_DIR)/2406/variants/preset-exome-analysis.yml
	cp src/tools/configs/exomiser-variant-config.yaml $(EXOMISER_DIR)/2406/variants/config.yaml
	mkdir -p $(EXOMISER_DIR)/2406/phenotype
	cp -r $(EXOMISER_DIR)/2406/variants/exomiser-cli-$(EXOMISER_VERSION) $(EXOMISER_DIR)/2406/phenotype/
	cd $(EXOMISER_DIR)/2406/phenotype && \
		ln -s ../variants/2406_phenotype . && \
		ln -s ../variants/2406_hg19 . && \
		ln -s ../variants/2406_hg38 .
	cp src/tools/configs/exomiser-phenotype-config.yaml $(EXOMISER_DIR)/2406/phenotype/config.yaml
	@echo "Installed $(EXOMISER_NAME) in $(EXOMISER_DIR)"

# Run Exomiser - this could be split into three separate targets to run in parallel on an HPC
run-exomiser: VENV_NAME=exomiser
run-exomiser: venv
	$(PIP) install pheval.exomiser
	# analyse variants corpus
	mkdir -p $(RESULTS_DIR)/$(EXOMISER_NAME)-2406/phenopacket_store_0.1.11_variants
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval run --input-dir "$(EXOMISER_DIR)/2406/variants" \
		--testdata-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_variants" \
		--output-dir "$(RESULTS_DIR)/$(EXOMISER_NAME)-2406/phenopacket_store_0.1.11_variants" \
		--runner exomiserphevalrunner --version $(EXOMISER_VERSION)
	# analyse phenotype only corpus	
	mkdir -p $(RESULTS_DIR)/$(EXOMISER_NAME)-2406/phenopacket_store_0.1.11_phenotypes
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval run --input-dir "$(EXOMISER_DIR)/2406/phenotype" \
		--testdata-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_phenotypes" \
		--output-dir "$(RESULTS_DIR)/$(EXOMISER_NAME)-2406/phenopacket_store_0.1.11_phenotypes" \
		--runner exomiserphevalrunner --version $(EXOMISER_VERSION)
	# analyse SV corpus	
	mkdir -p $(RESULTS_DIR)/$(EXOMISER_NAME)-2406/structural_variants
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval run --input-dir "$(EXOMISER_DIR)/2406/variants" \
		--testdata-dir "$(CORPORA_DIR)/structural_variants" \
		--output-dir "$(RESULTS_DIR)/$(EXOMISER_NAME)-2406/structural_variants" \
		--runner exomiserphevalrunner --version $(EXOMISER_VERSION)
