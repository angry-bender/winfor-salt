include:
  - winfor.packages.7zip
  - winfor.packages.git
  - winfor.packages.autopsy
  - winfor.packages.firefox
  - winfor.packages.chrome
  - winfor.packages.registry-viewer
  - winfor.packages.httplogbrowser
  - winfor.packages.db-browser-sqlite
  - winfor.packages.bulk-extractor
  - winfor.packages.vs-community
  - winfor.packages.vcxsrv
  - winfor.packages.cygwin
  - winfor.packages.libreoffice
  - winfor.packages.npp
  - winfor.packages.adobereader
  - winfor.packages.python3
  - winfor.packages.python2
  - winfor.packages.dbeaver
  - winfor.packages.sublime-text
  - winfor.packages.passware-encryption-analyzer
  - winfor.packages.logparser
  - winfor.packages.active-disk-editor
  - winfor.packages.kernel-pst-viewer  
  - winfor.packages.kernel-ost-viewer
  - winfor.packages.kernel-edb-viewer
  - winfor.packages.apimonitor
  - winfor.packages.putty

winfor-packages:
  test.nop:
    - require:
      - sls: winfor.packages.7zip
      - sls: winfor.packages.git
      - sls: winfor.packages.autopsy
      - sls: winfor.packages.firefox
      - sls: winfor.packages.chrome
      - sls: winfor.packages.registry-viewer
      - sls: winfor.packages.httplogbrowser
      - sls: winfor.packages.db-browser-sqlite
      - sls: winfor.packages.bulk-extractor
      - sls: winfor.packages.vs-community
      - sls: winfor.packages.vcxsrv
      - sls: winfor.packages.cygwin
      - sls: winfor.packages.libreoffice
      - sls: winfor.packages.npp
      - sls: winfor.packages.adobereader
      - sls: winfor.packages.python3
      - sls: winfor.packages.python2
      - sls: winfor.packages.dbeaver
      - sls: winfor.packages.sublime-text
      - sls: winfor.packages.passware-encryption-analyzer
      - sls: winfor.packages.logparser
      - sls: winfor.packages.active-disk-editor
      - sls: winfor.packages.kernel-pst-viewer
      - sls: winfor.packages.kernel-ost-viewer
      - sls: winfor.packages.kernel-edb-viewer
      - sls: winfor.packages.apimonitor
      - sls: winfor.packages.putty
