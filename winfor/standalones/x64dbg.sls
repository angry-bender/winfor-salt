# Name: x64dbg
# Website: https://sourceforge.net/projects/x64dbg/
# Description: Open Source x64/x32 debugger for Windows
# Category: Executables
# Author: Duncan Ogilvie (mrexodia)
# License: GNU General Public License v3 (https://github.com/x64dbg/x64dbg/blob/development/LICENSE)
# Version: 2023-03-04_02-26
# Notes: 

{% set inpath = salt['pillar.get']('inpath', 'C:\standalone') %}
{% set version = '2023-03-04_02-26' %}
{% set hash = '68d260e26300b289bba4f87c3c2774709e7d04b9906837b87833ef0b32035dbb' %}
{% set PROGRAMDATA = salt['environ.get']('PROGRAMDATA') %}

x64dbg-download:
  file.managed:
    - name: 'C:\salt\tempdownload\snapshot_{{ version }}.zip'
    - source: https://github.com/x64dbg/x64dbg/releases/download/snapshot/snapshot_{{ version }}.zip
    - source_hash: sha256={{ hash }}
    - makedirs: True

x64dbg-extract:
  archive.extracted:
    - name: '{{ inpath }}\x64dbg'
    - source: 'C:\salt\tempdownload\snapshot_{{ version }}.zip'
    - enforce_toplevel: False
    - require:
      - file: x64dbg-download

standalones-x64dbg-shortcut-1:
  file.shortcut:
    - name: '{{ PROGRAMDATA }}\Microsoft\Windows\Start Menu\Programs\x64dbg.lnk'
    - target: '{{ inpath }}\x64dbg\release\x64\x64dbg.exe'
    - force: True
    - working_dir: '{{ inpath }}\x64dbg\release\x64\'
    - makedirs: True
    - require:
      - file: x64dbg-download
      - archive: x64dbg-extract

standalones-x64dbg-shortcut-2:
  file.shortcut:
    - name: '{{ PROGRAMDATA }}\Microsoft\Windows\Start Menu\Programs\x32dbg.lnk'
    - target: '{{ inpath }}\x64dbg\release\x32\x32dbg.exe'
    - force: True
    - working_dir: '{{ inpath }}\x64dbg\release\x32'
    - makedirs: True
    - require:
      - file: x64dbg-download
      - archive: x64dbg-extract
