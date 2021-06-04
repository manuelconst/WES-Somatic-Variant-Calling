configfile: "config.yaml"

rule mutect2_tumor_normal:
    input:
        # Required arguments.
        ref = 'ref/hg38.fa',
        tumor1 = expand("recal/{tumor1}.bam", tumor1= config["tumor1"]),
        normal = expand("recal/{normal}.bam", normal= config["normal"]),
        reference_dict = 'ref/hg38.dict',
        # Optional arguments. Omit unused files.
        germline_resource = 'ref/af-only-gnomad.hg38.vcf.gz',
        panel_of_normals = 'ref/hg38_1000g_pon.hg38.vcf'
    output:
        vcf = "somatic/{normal}.vcf.gz"
    log:
        "logs/{normal}.mutect2.txt"
    threads: 8
    resources:
        mem_mb=16000
    params:
        java_opts= "-Xmx=1G",
        extra = '--stats'
    shell:
        "java -jar gatk-package-4.1.9.0-local.jar Mutect2 -R {input.ref} -I {input.tumor1} -I {input.normal} -normal B10-273-W18 --germline-resource {input.germline_resource} --panel-of-normals {input.panel_of_normals} -L ref/S31285117_Regions.bed --af-of-alleles-not-in-resource 0.001 --interval-padding 0 --padding-around-indels 75 -O {output.vcf}"

rule calculate_contamination:
    input:
        # Required arguments.
        normal = expand("contamination/somatic.{normal}.pileups.table", normal= config["normal"]),
        tumor = expand("contamination/somatic.{tumor}.pileups.table", tumor= config["tumor1"]),
        # Optional arguments. Omit unused files.
    output:
        'contamination/contamination.{normal}.table'
    params:
        java_options = '-Xmx4g',
        extra = '',
    threads: 1
    resources: RAM = 4
    log: 'logs/gatk/calculate-contamination/{normal}.log'
    shell:
        "java -jar gatk-package-4.1.9.0-local.jar CalculateContamination -I {input.tumor} -matched {input.normal} --output {output} "

rule gatk_filtermutectcalls:
    input:
        vcf = "somatic/{normal}.vcf.gz",
        ref = 'ref/hg38.fa',
        contamination= 'contamination/contamination.BIMA1.table'
    output:
        vcf="somatic/snvs.{normal}.filtered.vcf",
    log:
        "logs/gatk/filter/snvs.{normal}.log",
    params:
        extra="--max-alt-allele-count 3",  # optional arguments, see GATK docs
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    shell:
        "java -jar gatk-package-4.1.9.0-local.jar FilterMutectCalls -R {input.ref} -V {input.vcf} --contamination-table {input.contamination} -O {output.vcf}"

rule gatk_funcotator:
    input:
        data = "funcotator_dataSources.v1.7.20200521s",
        ref = 'ref/hg38.fa',
        variant = "somatic/snvs.{normal}.filtered.vcf"
    output:
        maf="somatic/snvs.{normal}.ann.maf",
    log:
        "logs/gatk/funcotator/snvs.{normal}.log",
    resources:
        mem_mb=1024,
    shell:
        "java -jar gatk-package-4.1.9.0-local.jar Funcotator --data-sources-path {input.data} -R {input.ref} -V {input.variant} --output-file-format MAF --ref-version hg38 -O {output.maf} --remove-filtered-variants --verbosity DEBUG"
