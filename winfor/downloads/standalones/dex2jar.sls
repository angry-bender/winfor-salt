# Name: dex2jar
# Website: https://github.com/pxb1988/dex2jar
# Description: Android .dex and .class file analysis
# Category: Mobile Analysis
# Author: Bob Pan (pxb1988)
# License: Apache License v2.0 (https://github.com/pxb1988/dex2jar/blob/2.x/LICENSE.txt)
# Version: 2.1
# Notes: 

{% set downloads = salt['pillar.get']('downloads', 'C:\winfor-downloads') %}

dex2jar-download-only:
  file.managed:
    - name: '{{ downloads }}\dex2jar-2.1.zip'
    - source: https://github.com/pxb1988/dex2jar/releases/download/v2.1/dex2jar-2.1.zip
    - source_hash: sha256=7a9bdf843d43de4d1e94ec2e7b6f55825017b0c4a7ee39ff82660e2493a46f08
    - makedirs: True
