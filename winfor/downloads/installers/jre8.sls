# Name: Java Runtime Environment
# Website: https://www.java.com
# Description: Java Engine
# Category: Requirements
# Author: Oracle
# License: https://www.oracle.com/legal/terms.html
# Version: 8u361
# Notes: 

{% set downloads = salt['pillar.get']('downloads', 'C:\winfor-downloads') %}

jre8-download-only:
  file.managed:
    - name: '{{ downloads }}\jre-8u361-windows-x64.exe'
    - source: 'https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247947_0ae14417abb444ebb02b9815e2103550'
    - source_hash: sha256=419328F3A2325B1DC27F710ABD73E232E9DEAC47915B4DBA61A697B925B5B83D
    - makedirs: True
