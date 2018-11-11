# AAAAaaaa

The idea is to have a dead simple backup ecosystem for all our miserable LXD containers.

## Overview

A container that shall be backed up needs its own script located in `slaves/example.sh` where `example` is the name of the container.

### Master

The __master__ script (`aaaa.sh`) is responsible for giving orders to the slave scripts and harvesting the backup archives.

### Slave

The __slave__ scripts (`slaves/*.sh`) are the scripts that do the actual backup work. That's why they're called slaves.

A slave script is always associated with a container.

## Usage

Running

```
./aaaa.sh <container>...
```

will create a complete backup tarball `<hostname>_<timestamp>.tar.gz` in the current directory containing all partial backups from the specified list of containers.

## License

[MIT](LICENSE)
