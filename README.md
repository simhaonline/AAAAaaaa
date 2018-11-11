# AAAAaaaa

The idea is to have a dead simple backup ecosystem for all our miserable LXD containers.

## Overview

A container that shall be backed up needs its own script located in `slaves/example.sh` where `example` is the name of the container.

### Master

The __master__ script (`aaaa.sh`) is responsible for giving orders to the slave scripts and harvesting the backup archives.

### Slave

The __slave__ scripts (`slaves/*.sh`) are the scripts that do the actual backup work. That's why they're called slaves.

#### Environment

- `ARCHIVE`: Path to the target tarball file that the slave shall create.

## Usage

Running

```
./aaaa.sh <container>...
```

will create a complete backup tarball `<hostname>_<timestamp>.tar.gz` in the current directory containing all partial backups from the specified list of containers.

### Example

Doing

```
./aaaa.sh minecraft mysql nextcloud
```

would produce

```
zion_20181111223344.tar.gz
|-- zion_minecraft_20181111223344.tar
|-- zion_mysql_20181111223344.tar
|-- zion_nextcloud_20181111223344.tar
```

## License

[MIT](LICENSE)
