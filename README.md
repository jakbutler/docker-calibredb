# docker-calibredb
A lightweight docker container, based on [Alpine Linux](https://alpinelinux.org/), for running the [calibredb](https://manual.calibre-ebook.com/generated/en/calibredb.html) backend component to auto-import new books into a library. Intended to work in tandem with other containers running other parts of [calibre](https://calibre-ebook.com/) or serving up its library.

# What is this? 
Many of the existing calibre containers are designed around running the calibre-server or similar ([COPS](https://github.com/seblucas/cops), [calibre2odps](https://calibre2opds.com/), [CalibreWeb](https://github.com/janeczku/calibre-web), etc.) and they do it well; but few provided a reliable method for automatically importing new eBooks from a downloader such as [LazyLibrarian](https://github.com/DobyTang/LazyLibrarian). This container is intended to fill that gap. 

## Usage
```
docker create --name=calibredb \
              -e AUTO_UPDATE="1" \
              -v </path/to/calibre/config>:/opt/calibredb/config:rw \
              -v </path/to/calibre/import>:/opt/calibredb/import:rw \
              -v </path/to/calibre/library>:/opt/calibredb/library:rw \
              -v /etc/localtime:/etc/localtime:ro \
        jakbutler/docker-calibredb
        /usr/bin/run_auto_importer.sh
```
## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a volume `-v external:internal` - what this shows is the volume mapping from internal to external of the container.
So `-v ~/calibre/library:/opt/calibredb/library` would expose a folder from the user's home directory to be accessible from the container at the mount point `/opt/calibredb/library`.

The below tables list the supported parameters for the container, not all of which are required. 

#### Environment Variables

| Variable  | Description  | Default  |
| --------  | -----------  | -------  |
| `AUTO_UPDATE`  | A boolean (0\|1) environment variable flag indicating whether or not to update the calibre version when the container starts | `0` |   
| `CALIBRE_CONFIG_DIRECTORY`  | A calibre environment variable; specific the local directory where the application configurations are stored. | `/opt/calibredb/config` |
| `CALIBREDB_IMPORT_DIRECTORY`  | A custom environment variable for specifying the local directory where the new files to import will be saved; after import, all files will be removed from this directory. | `/opt/calibre/import` |
| `CALIBRE_LIBRARY_DIRECTORY`  | A calibre environment variable; specifies the local directory where the library metadata and files are stored. | `/opt/calibredb/library` |
**Please note:** If over-ridding the defaults for any of the directory variables, they should not overlap with the calibre install location (`/opt/calibre`) or the auto update functionality will break. After over-riding, it is import to use the same values when mapping the host and container volumes, below.   

#### Shared Volumes

| Volume  | Description |
| ------------- | ------------- |
| `/opt/calibredb/config`  | (Required) The local directory where the application configurations are stored, specified in the `CALIBRE_CONFIG_DIRECTORY` environment variable.  |
| `/opt/calibredb/import`  | (Required) The local directory where the new files to import will be saved, specified in the `CALIBREDB_IMPORT_DIRECTORY` environment variable.|
| `/opt/calibredb/library`  | (Required) The local directory where the library metadata and files are stored, specified in the `CALIBRE_LIBERARY_DIRECTORY` environment variable.  |

## Other Details
On startup, the container should execute the command `/usr/bin/run_auto_importer.sh` in order to perform the auto-importing and stay running. 

For shell access whilst the container is running: `docker exec -it calibredb /bin/bash`

## Install on unRaid
On unRaid, install from the **Community Repositories** and enter the required folder locations.

## Install on QNAP
On a QNAP, install using the Create Container page of **ContainerStation**. Search for *calibredb* and select the image from the **Docker Hub** tab and click **Create**. Specify the desired name and set the **Command** to `/usr/bin/run_auto_importer.sh`. Adjust CPU and Memory limits as desired, then click on **Advanced Settings >>** to specify the environment variable and volume mappings. Click **Create** when done.   

## Versions
+ **2016-12-29:** Initial release.