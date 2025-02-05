# Name: KsDumper 11
# Website: https://github.com/mastercodeon314/KsDumper-11
# Description: Kernel Space Dumper utility
# Category: Executables
# Author: mastercodeon314
# License: None at this time
# Version: 1.0
# Notes:

{% set downloads = salt['pillar.get']('downloads', 'C:\winfor-downloads') %}
{% set version = '1.0' %}
{% set hash = '99319f08a373956d51caa80e1b8f25aaac1fa55dbcb38c84c1fc28602960b810' %}

ksdumper11-download-only:
  file.managed:
    - name: '{{ downloads }}\KsDumper11.zip'
    - source: https://github.com/mastercodeon314/KsDumper-11/releases/download/{{ version }}/KsDumper11.zip
    - source_hash: sha256={{ hash }}
    - makedirs: True
