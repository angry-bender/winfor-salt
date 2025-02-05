# Name: MemProcFS
# Website: https://github.com/ufrisk/MemProcFS
# Description: Memory Process File System
# Category: Raw Parsers / Decoders
# Author: Ulf Frisk
# License: GNU Affero GPL v3.0 - https://github.com/ufrisk/MemProcFS/blob/master/LICENSE
# Version: 5.4.5
# Notes: 

{% set short = '5.4' %}
{% set version = '5.4.5' %}
{% set date = '20230316' %}
{% set hash = '889521d76bce1fddeaf3d8e42e324f1f94a3c7fe9bb8d6aabf9ace3ff5970efd' %}
{% set downloads = salt['pillar.get']('downloads', 'C:\winfor-downloads') %}

memprocfs-download-only:
  file.managed:
    - name: '{{ downloads }}\MemProcFS_files_and_binaries_v{{ version }}-win_x64-{{ date }}.zip'
    - source: https://github.com/ufrisk/MemProcFS/releases/download/v{{ short }}/MemProcFS_files_and_binaries_v{{ version }}-win_x64-{{ date }}.zip
    - source_hash: sha256={{ hash }}
    - makedirs: True
