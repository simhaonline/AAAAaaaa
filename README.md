# AAAAaaaa

A dead simple backup ecosystem for our miserable LXD containers.

## Usage

```
./aaaa.sh [-p <prefix>] [<container>...]
```

Create an encrypted backup tarball containing all partial backups from the specified list of containers.

```
<hostname>_<timestamp>.tar.gz.enc
|-- <hostname>_<container1>_<timestamp>.tar
|-- <hostname>_<container2>_<timestamp>.tar
|-- <hostname>_<container3>_<timestamp>.tar
```


If no containers are specified, then _all_ available slave scripts will be triggered.

### Options

- `-p <prefix>` Add a prefix to the generated tarball filename. The format will be `<hostname>_<prefix>_<timestamp>.tar.gz`.

> __Protip!__ The last line of the output is the filename of the freshly created backup.

## Get started

Create a `.env` file and configure things as needed.

```bash
cp .env.example .env
```

A container that we want to backup needs to have its own script `slaves/example.sh` where `example` is the name of the container.

### Master

The __master__ script (`aaaa.sh`) is responsible for calling the slave scripts and harvesting the backup archives that they produce.

The following example will expect two containers (`foo` and `bar`) as well as two slave scripts (`slaves/foo.sh` and `slaves/bar.sh`).

```bash
./aaaa.sh foo bar
```

After running this command you will end up with an encrypted master backup archive (perhaps `myserver_20200409150000.tar.gz.enc`) that contains both partial backups (perhaps `foo_20200409150000.tar` and `bar_20200409150000.tar`).

### Slaves

The __slave__ scripts (`slaves/*.sh`) are the container-specific scripts that do the actual backup work inside the container.

Each slave script is supposed to deliver an archive holding whatever needs to be backed up. The path to the target tarball file is passed down to the slave script as the `$ARCHIVE` environment variable.

A slave script should always exit with a non-zero status code if they fail in order to communicate that something went wrong to the calling master script.

#### Environment Variables

The following environment variables are available inside slave scripts:

- `$ARCHIVE`: Path to the target tarball file that the slave script shall output.

### Crons

Your `crontab` could look something along the lines of this:

```
0 * * * * /path/to/crons/hourly.sh >/dev/null 2>&1
...
```

Example cron scripts are available in `crons/`.

#### Template

Here's a __slave__ script template to get started:

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

### Config

The following environment variables can be set in the `.env` file:

- `$AAAA_WORKING_DIRECTORY`: The directory where backups will be stored.
- `$AAAA_LOGFILE`: Path to a log file.

- `$AAAA_KEEP_LAST_HOURLY`: Number of most recent hourly backups to keep.
- `$AAAA_KEEP_LAST_DAILY`: Number of most recent daily backups to keep.
- `$AAAA_KEEP_LAST_WEEKLY`: Number of most recent weekly backups to keep.

- `$AAAA_PASSWORD`: Password to be used during backup encryption.


## License

[MIT](LICENSE)
