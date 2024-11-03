NAME
====

CLI::Wordpress::Migrator

GETTING STARTED
===============

```bash
zef install CLI::Wordpress::Migrator
```

SYNOPSIS
========

```raku
> rawm
Usage:
  ./rawm [--ts=<Str>] [--backup-only] [--download-only] [--upload-only] [--restore-only] [--cleanup-only] [--dry-run] <cmd>
  
    <cmd>              One of <connect export install import search-replace migrate>
    --ts=<Str>         Enter timestamp of files [Str] eg. --ts='20241025-17-02-42'
    --backup-only      Only perform remote backup
    --download-only    Only perform download (requires timestamp [--ts])
    --upload-only      Only perform upload (requires timestamp [--ts])
    --restore-only     Only perform restore (requires timestamp [--ts])
    --cleanup-only     Only perform remote cleanup
    --dry-run          Do not perform replace
```

DESCRIPTION
===========

CLI::Wordpress::Migrator is a script to migrate a Wordpress site from one server to another. This performs export (backup), install, import (restore) and search-replace steps according to the configuration in `~/.rawm-config/rawm-config.yaml`

The process involves three systems:
 - `from` server which is running the source site
 - `to` server which is ready for the migrated site
 - local client which connects to the export / import servers in turn

This module installs the raku `rawm` command for use from the local client command line. (RAku Wordpress Migrator).

Here is a sample config file:
```yaml
from:
  user: myusername
  subdom: sdname
  domain: mydomain.com
  key-pub: kpname
  port: 22
to:
  user: myusername
  subdom: sdname
  domain: mydomain.com
  key-pub: kpname
  port: 22
wp-config:
  locale: en_GB
  db:
    name: dbname
    user: dbuser
    pass: dbpass
    prefix: wp_
  title: My New WP Installation
  url: mysite.com
  admin:
    user: aduser
    pass: adpass
    email: ademail
```

Notes:

1. The install Build process creates a new default config file at `~/.rawm-config/rawm-config.yaml`. To persist your (private) settings, copy and populate this file and save as `~/.rawm-config/rawm-configBAK.yaml`, then subsequent install Build process will restore your settings over the default.
2. If there is no subdomain use `subdom: _` (ie an underscore) to indicate none.

Prerequisites for connection:
- Uses `ssh -i` access. Please generate an ssh key pair, authorize and save private key in e.g. `~.ssh/id_rsa`, `chmod 400 id_rsa`

### Export

| Action                         | Pseudo Command                               |
|--------------------------------|----------------------------------------------|
| Connect to the `from` Server:  | `ssh user@host`                              |
| Go to to temp dir:             | `cd /path/to/temp`                           |
| Export the Database:           | `wp db export mysite.sql`                    |
| Export the WordPress Files:    | `tar -czf backup-fs...tar.gz /../wp-content` |
| Transfer Files to local drive: | `scp user@host:/path/to/temp .`              |


### Install

Prerequisites for install (example):
- Create new (sub)domain and (sub)dir via cPanel
- Create new empty database via cPanel
- Add db user & set their permissions via cPanel
- Adjust the PHP upload max size to 512M via cPanel > PHP > Options
- Register url and adjust DNS A record to server IP
- Use TLS status refresh to get certificates via cPanel

Edit your `~/.rawm-config/rawm-config.yaml` to populate these `wp-config` private settings (and copy it to `~/.rawm-config/rawm-configBAK.yaml` if you want them to persist through a re-install).

viz. https://make.wordpress.org/cli/handbook/how-to/how-to-install/

| Action                      | Pseudo Command           |
|-----------------------------|--------------------------|
| Connect to the `to` Server: | `ssh user@host`          |
| Go to to destination dir    | `cd /path/to/wpserver`   |
| Download WP core            | `wp core download`       |
| Create WP config            | `wp config create`       |
| Install WP core             | `wp core install`        |
| Adjust file/dir permissions | `chmod -R a=r,a+X,u+w .` |


### Import

| Action                               | Pseudo Command                        |
|--------------------------------------|---------------------------------------|
| Transfer Files to the Import Server: | `scp . user@host:/path/to/temp`       |
| Connect to the Import Server:        | `ssh user@host`                       |
| Import the Database:                 | `wp db import mysite.sql`             |
| Extract the WordPress Files:         | `tar -xzf wordpress_files.tar.gz /..` |
| Update WordPress Configuration:      | `wp-config.php s/xxx/yyy/`            |
| Set File Permissions[1]:             | `chmod -R a=r,a+X,u+w .`              |

Notes:
- a failed import (eg. "to" site has WP web admin configurator asking for info like a new install) is often caused by incorrect wp-config>db>prefix in `rawm-config.yaml`

### Search & Replace

| Action                               | Pseudo Command                        |
|--------------------------------------|---------------------------------------|
| Search and Replace URLs (option):    | `wp search-replace 'old' 'new'`       |
| Update Permalinks (option):          | `wp rewrite flush`                    |

Postrequisites for restore (example):
- use Elementor>Tools search replace x4
- edit all SS3 sliders

AUTHOR
======

librasteve <librasteve@furnival.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2024 librasteve

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.