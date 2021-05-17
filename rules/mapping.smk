configfile: "config.yaml"

rule bwa_mem:
    input:
        reads=["reads/BIMA10/{sample}_1.trim.fastq.gz", "reads/BIMA10/{sample}_2.trim.fastq.gz"]
    output:
        "mapped/{sample}.bam"
    log:
        "logs/bwa_mem/{sample}.log"
    params:
        index="ref/hg38.fa",
        extra=r"-R '@RG\tID:{sample}\tDS:{sample}\tPL:ILLUMINA\tSM:{sample}'",
        sort="samtools",             # Can be 'none', 'samtools' or 'picard'.
        sort_order="coordinate",  # Can be 'queryname' or 'coordinate'.
        sort_extra=""            # Extra args for samtools/picard.
    threads: 4
    wrapper:
        "0.72.0/bio/bwa/mem"

rule mark_duplicates:
    input:
        "mapped/{sample}.bam"
    output:
        bam="dedup/{sample}.bam",
        metrics="dedup/{sample}.metrics.txt"
    log:
        "logs/picard/dedup/{sample}.log"
    params:
        "REMOVE_DUPLICATES=true"
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "0.72.0/bio/picard/markduplicates"

rule samtools_stats:
    input:
        "dedup/{sample}.bam"
    output:
        "samtools_stats/{sample}.txt"
    params:
        extra="",                       # Optional: extra arguments.
        region=""      # Optional: region string.
    log:
        "logs/samtools_stats/{sample}.log"
    wrapper:
        "0.72.0/bio/samtools/stats"

rule gatk_baserecalibrator:
    input:
        bam="dedup/{sample}.bam",
        ref="ref/hg38.fa",
        dict="ref/hg38.dict",
        known="ref/dbsnp_146.hg38.vcf.gz"  # optional known sites
    output:
        recal_table="recal/{sample}.grp"
    log:
        "logs/gatk/baserecalibrator/{sample}.log"
    params:
        extra="",  # optional
        java_opts="-DGATK_STACKTRACE_ON_USER_EXCEPTION=true", # optional
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "0.72.0/bio/gatk/baserecalibrator"

rule samtools_index:
    input:
        "dedup/{sample}.bam"
    output:
        "dedup/{sample}.bam.bai"
    log:
        "logs/samtools_index/{sample}.log"
    params:
        "" # optional params string
    wrapper:
        "0.72.0/bio/samtools/index"

rule gatk_applybqsr:
    input:
        bam="dedup/{sample}.bam",
        ref="ref/hg38.fa",
        dict="ref/hg38.dict",
        recal_table="recal/{sample}.grp"
    output:
        protected("somatic_call/recal/{sample}.bam")
    log:
        "logs/gatk/gatk_applybqsr/{sample}.log"
    params:
        extra="",  # optional
        java_opts="", # optional
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "0.72.0/bio/gatk/applybqsr"
