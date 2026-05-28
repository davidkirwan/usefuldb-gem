# UsefulDB

A local, tag-searchable notebook for shell commands, URLs, and other snippets. Data is stored in YAML at `~/.usefuldb/db.yaml`.

Requires Ruby 3.0+.

## Install

```bash
gem install usefuldb
```

From source:

```bash
bundle install
make install
```

## Usage

```bash
usefuldb help
usefuldb help search
```

### Search

Find entries whose tags match all given terms (use `--any` for OR):

```bash
usefuldb search git push
usefuldb search git commit --value-only
usefuldb search docker --json
```

### Manage entries

```bash
usefuldb list
usefuldb show 42
usefuldb count

usefuldb add --tags git,commit --value "git commit -m 'msg'" --description "Commit changes"
usefuldb add    # interactive prompts

usefuldb remove 42
usefuldb remove --tags git,push --value "git push origin main"
```

### Export and import

```bash
usefuldb export backup.yaml
usefuldb export backup.json --format json
usefuldb export -o - --format yaml    # stdout

usefuldb import backup.yaml           # merge (default)
usefuldb import backup.yaml --replace # overwrite
usefuldb import -                     # read from stdin
```

### Global options

```bash
usefuldb --db /path/to/db.yaml search git
usefuldb -q search git                # quiet
usefuldb -v search git                # verbose
usefuldb --version
```

## Development

```bash
make build
make install
make clean
```

Or use the equivalent `rake` tasks (`build`, `install`, `clean`).

## License

GPL-2.0-only. See [COPYING](COPYING).
