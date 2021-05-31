configfile: "config.yaml"

rule all:
    input:
        "qc/multiqc.html",
        expand("dedup/{sample}.bam.bai", sample=config["samples"]),
        expand("recal/{sample}.grp", sample=config["samples"]),
        expand("recal/{sample}.bam", sample=config["samples"]),
        expand("somatic_call/contamination/somatic.{sample}.pileups.table", sample=config["samples"])

### Modules ###

include: "rules/mapping.smk"
include: "rules/qc.smk"
include: "rules/contamination.smk"
include: "rules/qc.smk"
