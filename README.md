# AAAAaaaa

A dead simple backup ecosystem for our miserable LXD containers.

## Overview

A container that shall be backed up needs to have its own script in `slaves/example.sh` where `example` is the name of the container.

### Master

The __master__ script (`aaaa.sh`) is responsible for giving orders to the slave scripts and harvesting the backup archives.

### Slave

The __slave__ scripts (`slaves/*.sh`) are the scripts that do the actual backup work. That's why they're called slaves.

#### Example

Here's what everything boils down to:

```bash
function main {
    tar cvf "$ARCHIVE" file1 file2 file3 || { >&2 echo "Something went south."; exit 1; }
}

main
```

Just make sure that your slave script exits with a non-zero status if it cannot create the tarball for some reason.

#### Environment variables

The following environment variables are available inside slave scripts:

- `ARCHIVE`: Path to the target tarball file that the slave shall create.

## Usage

```
./aaaa.sh [<container>...]
```

Create a complete backup tarball in the current directory containing all partial backup tarballs from the specified list of containers.

```
<hostname>_<timestamp>.tar.gz
|-- <hostname>_<container1>_<timestamp>.tar.gz
|-- <hostname>_<container2>_<timestamp>.tar.gz
|-- <hostname>_<container3>_<timestamp>.tar.gz
```


If no containers are specified, then _all_ available slave scripts will be triggered.


> __Protip!__ The last line of the output is the filename of the freshly created backup.

## License

[MIT](LICENSE)
