configfile: "config.yaml"

rule all:
    input:
        expand("dedup/{sample}.bam.bai", sample=config["samples"]),
        expand("recal/{sample}.grp", sample=config["samples"]),
        expand("somatic_call/recal/{sample}.bam", sample=config["samples"]),
        expand("somatic_call/contamination/somatic.{sample}.pileups.table", sample=config["samples"]),
        "qc/multiqc.html",
        expand("stats/{sample}.insert_size_histogram.pdf", sample=config["samples"])

### Modules ###

include: "rules/mapping.smk"
include: "rules/contamination.smk"
include: "rules/qc.smk"
