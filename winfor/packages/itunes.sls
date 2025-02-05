# Name: Apple iTunes
# Website: https://www.apple.com
# Description: Media viewer and Apple device manager
# Category: Utilities
# Author: Apple
# License: EULA
# Version: 12.11.3.17
# Notes:

itunes:
  pkg.installed

itunes-icon:
  file.absent:
    - name: 'C:\Users\Public\Desktop\iTunes.lnk'
    - require:
      - pkg: itunes
