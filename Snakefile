rule all:
    input: 
	"done.txt"
    
rule format_pmcids:
    input:
        "pmcids.txt"
    output:
        "pmcids.formatted.txt"
    shell:
        "tr ' ' '\n' < {input} > {output}"

checkpoint split:
    input:
        "pmcids.formatted.txt"
    output:
        "intermediate.txt",
        directory("split_pmcids")
    shell:
        """
        mkdir {output[1]}
        touch {output[0]}
        split -l 30 {input} cluster_
        mv cluster_* {output[1]}
        """

def aggregate_input(wildcards):
     checkpoints.split.get()
     cluster_ids=glob_wildcards(f"split_pmcids/cluster_{{id}}").id
     return expand(f"split_pmcids/cluster_{{id}}", id=cluster_ids)
     
rule download_nxml:
    input:
        aggregate_input
    output:
        "done.txt"
    threads: 8
    shell:
        """
        touch {output}
        python fetch_nxml.py --pmcids $(cat {input})
        """
