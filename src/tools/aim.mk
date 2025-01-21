
AIM_VERSION := 0.1.0
AIM_NAME := ai_marrvel-$(AIM_VERSION)
AIM_DIR := $(CONFIG_DIR)/$(AIM_NAME)

# WARNING!! This requires ~626GB disk space just for the install it also requires the aws client to be pre-installed

# Install AI-MARRVEL
run-ai-marrvel: VENV_NAME=aim
install-ai-marrvel: venv
	$(PIP) install awscli
	mkdir -p $(AIM_DIR)
	cd $(AIM_DIR) && \
		aws s3 sync s3://aim-data-dependencies-2.0-public . --no-sign-request
	cp src/tools/configs/aim-config.yaml $(AIM_DIR)/config.yaml
	@echo "Installed $(AIM_NAME) in $(AIM_DIR)"

# Run AI-MARRVEL
run-ai-marrvel: VENV_NAME=aim
run-ai-marrvel: venv
	$(PIP) install pheval.ai_marrvel
	$(VENV_BASE)/bin/pheval run --input-dir "$(AIM_DIR)" \
		--testdata-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_variants" \
		--output-dir "$(RESULTS_DIR)/$(AIM_NAME)/phenopacket_store_0.1.11_variants" \
		--runner aimarrvelrunner --version $(AIM_VERSION)

