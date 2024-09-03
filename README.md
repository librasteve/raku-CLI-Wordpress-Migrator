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

- [ ] rm passwords (ie yaml)
- [ ] new gh repo
- [ ] new raku module
- [ ] cmd with MAIN direct actions
- [ ] need module name CLI::Wordpress::Migrator
- [ ] bring pp-local into the process
- [ ] wp db search 'localhost' to mop up


---

MIGRATION PROCESS
=================

This module supports two cmd s:

```raku
./exporter.raku
./importer.raku
```

Both actions are run at the terminal of a local machine. The local machine spawns a new process which connects to the remote machine via SSH. It writes a generated perl file to the remote machine and runs it there. stdout & stderr are redirected to the local terminal. Backup files are transferred between local and remote machine via scp. They are stored as files in the dir where the cmd is run.

### Exporter

| Action                         | Pseudo Command                               |
|--------------------------------|----------------------------------------------|
| Connect to the Export Server:  | `ssh user@host`                              |
| Cd to backup dir:              | `cd /path/to/backups`                        |
| Export the Database:           | `wp db export mysite.sql`                    |
| Export the WordPress Files:    | `tar -czf backup-fs...tar.gz /../wp-content` |
| Transfer Files to local drive: | `scp user@host:/path/to/backups .`           |


### Importer

| Action                               | Pseudo Command                        |
|--------------------------------------|---------------------------------------|
| Install clean WP instance (option):  | `wp core install ...`                 |
| Transfer Files to the Import Server: | `scp . user@host:/path/to/backups`    |
| Connect to the Import Server:        | `ssh user@host`                       |
| Import the Database:                 | `wp db import mysite.sql`             |
| Extract the WordPress Files:         | `tar -xzf wordpress_files.tar.gz /..` |
| Update WordPress Configuration:      | `wp-config.php s/xxx/yyy/`            |
| Search and Replace URLs (option):    | `wp search-replace 'old' 'new'`       |
| Update Permalinks (option):          | `wp rewrite flush`                    |
| Set File Permissions[1]:             | `chmod -R a=r,a+X,u+w .`              |

Notes:

[1] 0644 files & 0755 dirs
[2] use Elementor>Tools search replace x4
[3] remake SS3 sliders?
[4] increase max_upload_size to 512M (cPanel > PHP > Options)
[5] check table prefix 'wp_'
