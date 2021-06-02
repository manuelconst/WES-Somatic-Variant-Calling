configfile: "config.yaml"

rule mergeFastq:
    input:
        r1=["FASTQ/{sample}_L001_R1_001.fastq.gz", "FASTQ/{sample}_L002_R1_001.fastq.gz"],
        r2=["FASTQ/{sample}_L001_R2_001.fastq.gz", "FASTQ/{sample}_L002_R2_001.fastq.gz"]
    output:
        r1=["mergedFASTQ/{sample}_R1.fastq.gz"],
        r2=["mergedFASTQ/{sample}_R2.fastq.gz"]
    log: "mergedFASTQ/logs/{sample}.mergeFastq.log"
    shell: """
        cat {input.r1} > {output.r1} 2> {log}
        cat {input.r2} > {output.r2} 2>> {log}
        """
