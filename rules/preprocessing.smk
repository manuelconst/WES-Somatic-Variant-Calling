configfile: preprocessing/"config.yaml"

rule mergeFastq:
    input:
        r1=expand(initialIndir + "/{sample}", sample=config["samples"),
        r2=lambda wildcards: expand(initialIndir + "/{sample}", sample=config["samples"),
    output:
        r1="mergedFASTQ/{sample}" + reads[0] + ext,
        r2="mergedFASTQ/{sample}" + reads[1] + ext
        log: "mergedFASTQ/logs/{sample}.mergeFastq.log"
        shell: """
            cat {input.r1} > {output.r1} 2> {log}
            cat {input.r2} > {output.r2} 2>> {log}
            """
