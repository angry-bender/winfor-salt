include:
  - winfor.config.user
  - winfor.repos
  - winfor.packages
  - winfor.installers
  - winfor.standalones
  - winfor.python2-tools
  - winfor.python3-tools
  - winfor.cleanup

winfor-addon-version-file:
  file.managed:
    - name: 'C:\winfor-version'
    - source: salt://winfor/VERSION
    - replace: True
    - require:
      - sls: winfor.config.user
      - sls: winfor.repos
      - sls: winfor.packages
      - sls: winfor.installers
      - sls: winfor.standalones
      - sls: winfor.python2-tools
      - sls: winfor.python3-tools
      - sls: winfor.cleanup
