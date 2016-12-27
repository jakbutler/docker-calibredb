#!/usr/bin/env bash

[[ -f /tmp/.X1-lock ]] && rm /tmp/.X1-lock && echo "X1-lock found, deleting"

if [ ! "$AUTO_UPDATE" = "1" ]; then
  echo "AUTO_UPDATE not requested, keeping stable version"
else
  echo "AUTO_UPDATE requested, updating to latest version"
  wget -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"
fi

# Install any custom plugins
for filename in $CALIBRE_PLUGIN_DIRECTORY/*.zip; do
  /opt/calibre/calibre-customize --add-plugin $filename
done

if [ -z "$CALIBRE_LIBRARY_DIRECTORY" ]; then
  CALIBRE_LIBRARY_DIRECTORY=/opt/calibre/library
fi
if [ -z "$CALIBRE_CONFIG_DIRECTORY" ]; then
  CALIBRE_CONFIG_DIRECTORY=/opt/calibre/config
fi
if [ -z "$CALIBRE_PLUGIN_DIRECTORY" ]; then
  CALIBRE_PLUGIN_DIRECTORY=/opt/calibre/plugins
fi
if [ -z "$CALIBREDB_IMPORT_DIRECTORY" ]; then
  CALIBREDB_IMPORT_DIRECTORY=/opt/calibre/import
fi

./start.sh

