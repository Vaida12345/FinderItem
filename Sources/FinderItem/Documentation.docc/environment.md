# Environment-Dependent Directories

A set of predefined directories whose path is different for each project.

| directory | Purgeable | Backup | Reported | Examples |
| --------- | --------- | ------ | -------- | -------- |
| ``FinderItem/documentsDirectory`` | no | yes | yes | downloadable content |
| ``FinderItem/applicationSupportDirectory`` | no | yes | yes | data files, configuration |
| ``FinderItem/cachesDirectory`` | yes | no | no | downloadable content |
| ``FinderItem/temporaryDirectory`` | yes | no | no | temp |
| ``FinderItem/itemReplacementDirectory`` | yes | no | no | replacing files |


- Purgeable: Eligible for automatic purging when app isn't running or when reboot
- Backup: The system backs up files when performing an iCloud backup.
- Reported: Disk space used is reported in the storage settings.


## Topics

- ``FinderItem/url(for:in:appropriateFor:create:)``

### common directories
- ``FinderItem/desktopDirectory``
- ``FinderItem/downloadsDirectory``
- ``FinderItem/moviesDirectory``
- ``FinderItem/musicDirectory``
- ``FinderItem/picturesDirectory``
- ``FinderItem/trashDirectory``

### app directories
- ``FinderItem/bundleDirectory``
- ``FinderItem/homeDirectory``
- ``FinderItem/libraryDirectory``
- ``FinderItem/logsDirectory``
- ``FinderItem/preferencesDirectory``

### long-lived files
- ``FinderItem/documentsDirectory``
- ``FinderItem/applicationSupportDirectory``

### short-lived files
- ``FinderItem/cachesDirectory``
- ``FinderItem/temporaryDirectory``
- ``FinderItem/itemReplacementDirectory``
- ``FinderItem/itemReplacementDirectory(in:)``

### Constants
- ``FinderItem/currentDirectory``
- ``FinderItem/updateCurrentDirectory(to:)``
