rule multiqc:
    input:
        expand("samtools_stats/{sample}.txt" , sample=config["samples"]),
        expand("samtools_stats/{sample}.txt" , sample=config["samples"]),
        expand("qc/fastqc/{sample}_fastqc.zip", sample=config["samples"]),
        expand("qc/fastqc/{sample}_fastqc.zip", sample=config["samples"])
    output:
        "qc/{sample}_multiqc.html"
    params:

        ""  # Optional: extra parameters for multiqc.
    log:
        "logs/{sample}_multiqc.log"
    wrapper:
        "0.74.0/bio/multiqc"

rule collect_multiple_metrics:
    input:
         bam="somatic_call/recal/{sample}.bam",
         ref="ref/hg38.fasta.gz"
    output:
        multiext("stats/{sample}",
                 ".alignment_summary_metrics",
                 ".insert_size_metrics",
                 ".insert_size_histogram.pdf",
                 ".quality_distribution_metrics",
                 ".quality_distribution.pdf",
                 ".quality_by_cycle_metrics",
                 ".quality_by_cycle.pdf",
                 ".base_distribution_by_cycle_metrics",
                 ".base_distribution_by_cycle.pdf",
                 ".gc_bias.detail_metrics",
                 ".gc_bias.summary_metrics",
                 ".gc_bias.pdf",
                 ".bait_bias_detail_metrics",
                 ".bait_bias_summary_metrics",
                 ".error_summary_metrics",
                 ".pre_adapter_detail_metrics",
                 ".pre_adapter_summary_metrics",
                 ".quality_yield_metrics"
                 )
    resources:
        mem_gb=3
    log:
        "logs/picard/multiple_metrics/{sample}.log"
    params:
        # optional parameters
        "VALIDATION_STRINGENCY=LENIENT "
        "METRIC_ACCUMULATION_LEVEL=null "
        "METRIC_ACCUMULATION_LEVEL=SAMPLE "
    wrapper:
        "0.74.0/bio/picard/collectmultiplemetrics"
