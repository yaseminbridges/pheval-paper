
# Download the pheval paper corpora
download-pheval-paper-corpora:
	wget https://zenodo.org/records/14679713/files/pheval-paper-corpora.tar.gz -P $(TARGET)
	tar -zxf $(TARGET)/pheval-paper-corpora.tar.gz -C $(TARGET)
	wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/latest/GRCh37/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf.gz  -P $(CORPORA_DIR)
	wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/latest/GRCh38/HG001_GRCh38_1_22_v4.2.1_benchmark.vcf.gz  -P $(CORPORA_DIR)
	wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/analysis/PacBio_pbsv_05212019/HG002_GRCh38.pbsv.vcf.gz  -P $(CORPORA_DIR)

# Install corpora
install-pheval-paper-corpora: VENV_NAME=pheval
install-pheval-paper-corpora: venv
	$(PIP) install pheval
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval-utils prepare-corpus \
		--phenopacket-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_variants/phenopackets" \
		--hg19-template-vcf "$(CORPORA_DIR)/HG001_GRCh37_1_22_v4.2.1_benchmark.vcf.gz" \
		--hg38-template-vcf "$(CORPORA_DIR)/HG001_GRCh38_1_22_v4.2.1_benchmark.vcf.gz" \
		--output-dir "$(CORPORA_DIR)/phenopacket_store_0.1.11_variants"
	$(VENV_BASE)/$(VENV_NAME)/bin/pheval-utils prepare-corpus \
		--phenopacket-dir "$(CORPORA_DIR)/structural_variants/phenopackets" \
		--hg38-template-vcf "$(CORPORA_DIR)/HG002_GRCh38.pbsv.vcf.gz" \
		--output-dir "$(CORPORA_DIR)/structural_variants"