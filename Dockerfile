FROM faisyl/alpine-runit

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Calibre environment variables
ENV CALIBRE_LIBRARY_DIRECTORY=/opt/calibre/library
ENV CALIBRE_CONFIG_DIRECTORY=/opt/calibre/config

# Auto-import directory
ENV CALIBREDB_IMPORT_DIRECTORY=/opt/calibre/import

# Flag for automatically updating to the latest version on startup
# ENV AUTO_UPDATE=0

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.23-r3" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
       "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
       "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

ENV LANG=C.UTF-8

# Install packages needed for app
RUN apk update && \
    apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    python \
    wget \
    gcc \
    mesa-gl \
    imagemagick \
    qt5-qtbase-x11 \
    xdg-utils \
    xz \
    inotify-tools && \
#########################################
##          GUI APP INSTALL            ##
#########################################
    wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" && \
    rm -rf /tmp/calibre-installer-cache

# Add the first_run.sh script to run on container startup
#ADD run.sh /etc/runit_init.d/run.sh
ADD run.sh ~/run.sh
#RUN chmod a+x /etc/runit_init.d/run.sh
RUN chmod +x ~/run.sh

# Add crontab job to import books in the library
#ADD crontab /etc/cron.d/calibre-library-update
ADD update_library.sh ~/update_library.sh
#RUN chmod a+x /etc/cron.d/calibre-library-update
RUN chmod +x ~/update_library.sh
RUN touch /var/log/calibredb.log

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /opt/calibre/config
VOLUME /opt/calibre/import
VOLUME /opt/calibre/library

# Run container startup script, cron job, and then watch the log file
CMD ~/run.sh && tail -f /var/log/calibredb.log



