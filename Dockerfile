FROM faisyl/alpine-runit

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set environment variables

# User/Group Id gui app will be executed as default are 0
ENV USER_ID=0
ENV GROUP_ID=0

# Calibre environment variables
ENV CALIBRE_LIBRARY_DIRECTORY = /opt/calibre/library
ENV CALIBRE_CONFIG_DIRECTORY = /opt/calibre/config
ENV CALIBRE_PLUGIN_DIRECTORY = /opt/calibre/plugins

# Auto-import directory
ENV CALIBREDB_IMPORT_DIRECTORY = /opt/calibre/import

# Python specific variables
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/calibre/lib

# Flag for automatically updating to the latest version on startup
ENV AUTO_UPDATE = 0


# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.23-r3" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
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
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
ENV LANG=C.UTF-8

# Install packages needed for app
RUN apk update && \
    apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    gcc \
    mesa-gl \
    python \
    qt5-qtbase-x11 \
    imagemagick \
    wget \
    xdg-utils \
    xz && \
#########################################
##          GUI APP INSTALL            ##
#########################################
    wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" && \
    rm -rf /tmp/calibre-installer-cache

ENV PATH $PATH:/opt/calibre/bin

# Add the first_run.sh script to run on container startup
# RUN mkdir -p /etc/runit_init.d
ADD first_run.sh /etc/runit_init.d/first_run.sh
RUN chmod +x /etc/runit_init.d/first_run.sh

# Copy the calibre start script to right location
COPY start.sh /start.sh

# Create directory for library, configs, database
#RUN mkdir -p $CALIBRE_LIBRARY_DIRECTORY
#RUN mkdir -p $CALIBRE_CONFIG_DIRECTORY
#RUN mkdir -p $CALIBRE_PLUGIN_DIRECTORY

# Create directory to import files
#RUN mkdir -p $CALIBREDB_IMPORT_DIRECTORY

# Add crontab job to import books in the library
ADD crontab /etc/cron.d/calibre-library-update
RUN chmod 0644 /etc/cron.d/calibre-library-update
RUN touch /var/log/cron.log

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME ["/opt/calibre/config"]
VOLUME ["/opt/calibre/library"]
VOLUME ["/opt/calibre/plugins"]
VOLUME ["/opt/calibre/import"]
EXPOSE 3389 8080

# Run cron job and use baseimage-docker's init system
CMD ["crond && /sbin/start_runit"]



