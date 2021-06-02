configfile: "config.yaml"

rule getpileupsummaries:
    input:
        sample = "somatic_call/recal/{sample}.bam",
        commonbiallelic = 'somatic_call/ref/somatic-hg38_small_exac_common_3.hg38.vcf.gz'
    output:
        sample = "somatic_call/contamination/somatic.{sample}.pileups.table"
    log:
        "logs/{sample}.getpileupsummaries.txt"
    threads: 4
    message: "Executing DNA mapping on the following files {input.sample} with success. "
    shell:
        "java -jar gatk-package-4.1.9.0-local.jar GetPileupSummaries -I {input.sample} -V {input.commonbiallelic} -L {input.commonbiallelic} -O {output.sample}"
