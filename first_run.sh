#!/usr/bin/env bash

if [ ! "$AUTO_UPDATE" = "1" ]; then
  echo "AUTO_UPDATE not requested, keeping installed version"
else
  echo "AUTO_UPDATE requested, updating to latest version"
  wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"
  rm -rf /tmp/calibre-installer-cache
fi

if [ -z "$CALIBRE_LIBRARY_DIRECTORY" ]; then
  CALIBRE_LIBRARY_DIRECTORY=/opt/calibre/library
fi
if [ -z "$CALIBRE_CONFIG_DIRECTORY" ]; then
  CALIBRE_CONFIG_DIRECTORY=/opt/calibre/config
fi
if [ -z "$CALIBREDB_IMPORT_DIRECTORY" ]; then
  CALIBREDB_IMPORT_DIRECTORY=/opt/calibre/import
fi
