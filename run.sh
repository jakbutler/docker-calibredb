#!/usr/bin/env bash

if [ ! "$AUTO_UPDATE" = "1" ]; then
  echo "AUTO_UPDATE not requested, keeping installed version"
else
  echo "AUTO_UPDATE requested, updating to latest version"
  wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"
  rm -rf /tmp/calibre-installer-cache
fi

if [ -z "$CALIBRE_LIBRARY_DIRECTORY" ]; then
  CALIBRE_LIBRARY_DIRECTORY=/opt/calibredb/library
fi
if [ -z "$CALIBRE_CONFIG_DIRECTORY" ]; then
  CALIBRE_CONFIG_DIRECTORY=/opt/calibredb/config
fi
if [ -z "$CALIBREDB_IMPORT_DIRECTORY" ]; then
  CALIBREDB_IMPORT_DIRECTORY=/opt/calibredb/import
fi

while true
do
  inotifywait -r -e modify,moved_to,create $CALIBREDB_IMPORT_DIRECTORY
  ./update_library.sh
done