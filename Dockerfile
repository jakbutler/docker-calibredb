FROM faisyl/alpine-runit

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Calibre environment variables
ENV CALIBRE_LIBRARY_DIRECTORY = /opt/calibre/library
ENV CALIBRE_CONFIG_DIRECTORY = /opt/calibre/config

# Auto-import directory
ENV CALIBREDB_IMPORT_DIRECTORY = /opt/calibre/import

# Python specific variables
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/calibre/lib

# Flag for automatically updating to the latest version on startup
ENV AUTO_UPDATE = 0

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
ADD first_run.sh /etc/runit_init.d/first_run.sh
RUN chmod +x /etc/runit_init.d/first_run.sh

# Add crontab job to import books in the library
ADD crontab /etc/cron.d/calibre-library-update
RUN chmod 0644 /etc/cron.d/calibre-library-update
RUN touch /var/log/cron.log

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME ["/opt/calibre/config"]
VOLUME ["/opt/calibre/import"]
VOLUME ["/opt/calibre/library"]

# Run cron job
#CMD [sh -c "/sbin/start_runit && /usr/sbin/crond -f -l 8"]
CMD ["/sbin/start_runit && /usr/sbin/crond && tail -f /var/log/cron.log"]



