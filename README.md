NAME
====

CLI::Wordpress::Migrator - blah blah blah

SYNOPSIS
========

```raku
use CLI::Wordpress::Migrator;
```

DESCRIPTION
===========

CLI::Wordpress::Migrator is ...

AUTHOR
======

librasteve <librasteve@furnival.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2024 librasteve

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

---

MANUAL PROCESS
==============
The manual process that is being automated:

- wp_   <== table prefix in wp-config.inc.
- softaculous new install
- increase max load size to 512M (cPanel > PHP > Options)
- tar -czf mysite-sdname-vXXX_files.tar.gz wp-content
- use cP File Manager to upload & copy in files
- upload sql to public dir
- adjust wp-config.inc
- wp db import ...
- wp search-replace 'http://localhost:XXXX' 'https://sdname.mydomain.com'
- wp search-replace 'http://localhost'      'https://sdname.mydomain.com'
- [--dry-run]

---

TODOS
=====

- [x] rm passwords (ie yaml)
- [x] new gh repo
- [x] new raku module
- [x] cmd with MAIN direct actions
- [x] need module name CLI::Wordpress::Migrator
- [ ] wp db search 'localhost' to mop up
- [ ] make subdom a list (for multiple backups)


---

MIGRATION PROCESS
=================

The process involves three systems:
 - `from` server which is running the source site
 - `to` server which is ready for the migrated site
 - local client which connects to the export / import servers in turn

This module installs the raku `rawm` command for use from the local client command line.

```raku
Usage:
  rawm [--backup-only] [--download-only] [--cleanup-only] [--ts=<Str>] <cmd>
  
    <cmd>              One of <export>
    --backup-only      Only perform remote backup
    --download-only    Only perform download (needs timestamp)
    --cleanup-only     Only perform remote cleanup
    --ts=<Str>         Enter timestamp of files [Str] eg. --ts='20241025-17-02-42'

```

GETTING STARTED
===============

`zef install CLI::Wordpress::Migrator`

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


### Search & Replace

| Action                               | Pseudo Command                        |
|--------------------------------------|---------------------------------------|
| Search and Replace URLs (option):    | `wp search-replace 'old' 'new'`       |
| Update Permalinks (option):          | `wp rewrite flush`                    |

Postrequisites for restore (example):
- use Elementor>Tools search replace x4
- edit all SS3 sliders

