#!/usr/bin/env python
from __future__ import print_function
from collections import OrderedDict
import re

regexes = {
    'hybrid-assembly': ['v_pipeline.txt', r"(\S+)"],
    'Nextflow': ['v_nextflow.txt', r"(\S+)"],
    'FastQC': ['v_fastqc.txt', r"FastQC v(\S+)"],
    'MultiQC': ['v_multiqc.txt', r"multiqc, version (\S+)"],
    'QUAST': ['v_quast.txt', r"WARNING: Python locale settings can't be changed QUAST v(\S+)"],
    'Canu': ['v_canu.txt', r"Canu (\S+)"],
    'SPAdes': ['v_spades.txt', r"SPAdes v(\S+)"]
}
results = OrderedDict()
results['hybrid-assembly'] = '<span style="color:#999999;\">N/A</span>'
results['Nextflow'] = '<span style="color:#999999;\">N/A</span>'
results['FastQC'] = '<span style="color:#999999;\">N/A</span>'
results['MultiQC'] = '<span style="color:#999999;\">N/A</span>'
results['QUAST'] = '<span style="color:#999999;\">N/A</span>'
results['Canu'] = '<span style="color:#999999;\">N/A</span>'
results['SPAdes'] = '<span style="color:#999999;\">N/A</span>'

# Search each file using its regex
for k, v in regexes.items():
    with open(v[0]) as x:
        versions = x.read()
        match = re.search(v[1], versions)
        if match:
            results[k] = "v{}".format(match.group(1))

# Dump to YAML
print ('''
id: 'hybrid-assembly-software-versions'
section_name: 'hybrid-assembly Software Versions'
section_href: 'https://github.com/kevinmenden/hybrid-assembly'
plot_type: 'html'
description: 'are collected at run time from the software output.'
data: |
    <dl class="dl-horizontal">
''')
for k,v in results.items():
    print("        <dt>{}</dt><dd>{}</dd>".format(k,v))
print ("    </dl>")
