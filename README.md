# AAAAaaaa

A dead simple backup ecosystem for our miserable LXD containers.

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

## Get started

A container that we want to backup needs to have its own script `slaves/example.sh` where `example` is the name of the container.

### Master

The __master__ script (`aaaa.sh`) is responsible for giving orders to the slave scripts and harvesting the backup archives.

### Slave

The __slave__ scripts (`slaves/*.sh`) are the container-specific scripts that do the actual backup work. That's why they're called slaves.

#### Template

Here's a script template to get started:

```bash
function main {
    d "Stopping some service..."
    systemctl stop some.service || { e "Could not stop some service."; exit 1; }

    d "Backing stuff up..."
    tar cvf "$ARCHIVE" file1 file2 file3 || { e "Something went south."; exit 1; }

    d "Starting some service..."
    systemctl start some.service || { e "Could not start some service."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
```

You get the general idea.

> __Protip!__ Make sure that your slave script exits with a non-zero status if it cannot create the tarball for some reason.

#### Environment variables

The following environment variables are available inside slave scripts:

- `ARCHIVE`: Path to the target tarball file that the slave shall create.

## License

[MIT](LICENSE)
