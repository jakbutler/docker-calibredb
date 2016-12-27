FROM frolvlad/alpine-glibc

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
RUN mkdir -p /etc/my_init.d
ADD first_run.sh /etc/my_init.d/first_run.sh
RUN chmod +x /etc/my_init.d/first_run.sh

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

# Run cron job and start calibre server
#CMD cron && /usr/bin/calibre-server --with-library=/opt/calibre/library

# Use baseimage-docker's init system
CMD ["cron && /sbin/my_init"]



