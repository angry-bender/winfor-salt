# Name: Wireshark
# Website: https://www.wireshark.org
# Description: Network packet capture and analysis tool
# Category: Network
# Author: The Wireshark Foundation (https://gitlab.com/wireshark/wireshark/-/blob/master/AUTHORS)
# License: GNU General Public License v2 (https://gitlab.com/wireshark/wireshark/-/blob/master/COPYING)
# Version: 4.0.1
# Notes: 

{% set downloads = salt['pillar.get']('downloads', 'C:\winfor-downloads') %}
{% set version = '4.0.1' %}
{% set hash = '39a544884be9fd40eb2c83f2440cd5efdc43a04f8ccd230379905c157c9b532e' %}

wireshark-download-only:
  file.managed:
    - name: '{{ downloads }}\Wireshark-win64-{{ version }}.exe'
    - source: https://1.na.dl.wireshark.org/win64/all-versions/Wireshark-win64-{{ version }}.exe
    - source_hash: sha256={{ hash }}
    - makedirs: True
