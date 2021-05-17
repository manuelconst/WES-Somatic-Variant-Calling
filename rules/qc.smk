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
        "0.72.0/bio/fastqc"

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
        "0.72.0/bio/multiqc"
