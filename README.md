## Readme - v0.1.0

[![Build Status](https://travis-ci.org/davidkirwan/usefuldb-gem.svg?branch=master)](https://travis-ci.org/davidkirwan/usefuldb-gem)

### Install
This gem is also stored on rubygems.org and can be installed with the following command:
gem install usefuldb

### Build
Build and install locally with `make build`, `make install`, or the equivalent `rake` tasks (`rake build`, `rake install`).

### Usage
```bash
usefuldb help
usefuldb search git push
usefuldb search git commit --value-only
usefuldb list
usefuldb add --tags git,commit --value "git commit -m 'msg'"
usefuldb show 42
usefuldb remove 42
usefuldb count
usefuldb export backup.yaml
usefuldb import backup.yaml
usefuldb import other.yaml --replace
```

Run `usefuldb help` for the full command reference.
