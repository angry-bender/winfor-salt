# Name: 
# Website: 
# Description: 
# Category: 
# Author: 
# License: 
# Notes:

{% set version = '7.2.0.6844' %}
{% set core_version = 'v7.2' %}
{% set hash = '61341AEB5992BC76ECD09F29D4A39D13D96AFB4D3A498FC191FD999908EA667C' %}
{% set PROGRAMDATA = salt['environ.get']('PROGRAMDATA') %}

ilspy-download:
  file.managed:
    - name: 'C:\salt\tempdownload\ILSpy_binaries_{{ version }}.zip'
    - source: https://github.com/icsharpcode/ILSpy/releases/download/{{ core_version }}/ILSpy_binaries_{{ version }}.zip
    - source_hash: sha256={{ hash }}
    - makedirs: True

ilspy-extract:
  archive.extracted:
    - name: 'C:\standalone\ilspy\'
    - source: 'C:\salt\tempdownload\ILSpy_binaries_{{ version }}.zip'
    - enforce_toplevel: False
    - require:
      - file: ilspy-download

winfor-standalones-ilspy-shortcut:
  file.shortcut:
    - name: '{{ PROGRAMDATA }}\Microsoft\Windows\Start Menu\Programs\ILSpy.lnk'
    - target: 'C:\standalone\ilspy\ILSpy.exe'
    - force: True
    - working_dir: 'C:\standalone\ilspy\'
    - makedirs: True
    - require:
      - file: ilspy-download
      - archive: ilspy-extract

ilspy-env-vars:
  win_path.exists:
    - name: 'C:\standalone\ilspy\'
