
LIRICAL_VERSION := 2.0.2
LIRICAL_NAME := lirical-$(LIRICAL_VERSION)
LIRICAL_DIR := $(CONFIG_DIR)/$(LIRICAL_NAME)

# Install LIRICAL
install-lirical:
	mkdir -p $(LIRICAL_DIR)/2309/data
	wget -P $(LIRICAL_DIR)/2309/data https://storage.googleapis.com/public-download-files/hgnc/tsv/tsv/hgnc_complete_set.txt
	cd $(LIRICAL_DIR)/2309 && \
		wget https://github.com/TheJacksonLaboratory/LIRICAL/releases/download/v$(LIRICAL_VERSION)/lirical-cli-$(LIRICAL_VERSION)-distribution.zip && \
		unzip lirical-cli-$(LIRICAL_VERSION)-distribution.zip && rm lirical-cli-$(LIRICAL_VERSION)-distribution.zip
	java -jar $(LIRICAL_DIR)/2309/lirical-cli-$(LIRICAL_VERSION)/lirical-cli-$(LIRICAL_VERSION).jar download -d $(LIRICAL_DIR)/2309/data
	cd $(LIRICAL_DIR)/2309 && \
		wget https://g-879a9f.f5dc97.75bc.dn.glob.us/data/2309_hg19.zip && \
		wget https://g-879a9f.f5dc97.75bc.dn.glob.us/data/2309_hg38.zip && \
		unzip 2309_hg19.zip && rm 2309_hg19.zip && \
		unzip 2309_hg38.zip && rm 2309_hg38.zip && \
		mv 2309_hg19/2309_hg19_variants.mv.db . && \
		mv 2309_hg38/2309_hg38_variants.mv.db . && \
		rm -r 2309_hg19 2309_hg38
	cp src/tools/configs/lirical-config.yaml $(LIRICAL_DIR)/2309/config.yaml
	@echo "Installed $(LIRICAL_NAME) in $(LIRICAL_DIR)"


# Run LIRICAL
run-lirical: VENV_NAME=lirical
run-lirical: venv
	$(PIP) install pheval.lirical
	mkdir -p $(RESULTS_DIR)/$(LIRICAL_NAME)-2309/phenopacket_store_0.1.11_variants
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval run --input-dir "$(LIRICAL_DIR)/2309" \
		--testdata-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_variants" \
		--output-dir "$(RESULTS_DIR)/$(LIRICAL_NAME)-2309/phenopacket_store_0.1.11_variants" \
		--runner liricalphevalrunner --version $(LIRICAL_VERSION)
