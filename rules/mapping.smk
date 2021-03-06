configfile: "config.yaml"

rule bwa_mem:
    input:
        reads=["preprocessing/mergedFASTQ/{sample}_R1.fastq.gz", "preprocessing/mergedFASTQ/{sample}_R2.fastq.gz"]
    output:
        temp("mapped/{sample}.bam")
    log:
        "logs/bwa_mem/{sample}.log"
    params:
        index="ref/hg38.fa",
        extra=r"-R '@RG\tID:{sample}\tDS:{sample}\tPL:ILLUMINA\tSM:{sample}'",
        sort="samtools",             # Can be 'none', 'samtools' or 'picard'.
        sort_order="coordinate",  # Can be 'queryname' or 'coordinate'.
        sort_extra=""            # Extra args for samtools/picard.
    threads: 8
    wrapper:
        "0.74.0/bio/bwa/mem"

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
    resources:
        mem_mb=1024
    wrapper:
        "0.74.0/bio/picard/markduplicates"

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
        "0.74.0/bio/samtools/stats"

rule gatk_baserecalibrator:
    input:
        bam="dedup/{sample}.bam",
        ref="ref/hg38.fa",
        dict="ref/hg38.dict",
        known="ref/dbsnp.hg38.vcf.gz"  # optional known sites
    output:
        recal_table="recal/{sample}.grp"
    log:
        "logs/gatk/baserecalibrator/{sample}.log"
    params:
        extra="",  # optional
        java_opts="-DGATK_STACKTRACE_ON_USER_EXCEPTION=true", # optional
    resources:
        mem_mb=1024
    wrapper:
        "0.74.0/bio/gatk/baserecalibrator"

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
        "0.74.0/bio/samtools/index"

rule gatk_applybqsr:
    input:
        bam="dedup/{sample}.bam",
        ref="ref/hg38.fa",
        dict="ref/hg38.dict",
        recal_table="recal/{sample}.grp"
    output:
        bam="somatic_call/recal/{sample}.bam"
    log:
        "logs/gatk/gatk_applybqsr/{sample}.log"
    params:
        extra="",  # optional
        java_opts="", # optional
    resources:
        mem_mb=1024
    wrapper:
        "0.74.0/bio/gatk/applybqsr"

rule fastqc:
    input:
        "mapped/{sample}.bam"
    output:
        html="qc/fastqc/{sample}.html",
        zip="qc/fastqc/{sample}_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: ""
    log:
        "logs/fastqc/{sample}.log"
    threads: 1
    wrapper:
        "0.74.0/bio/fastqc"
