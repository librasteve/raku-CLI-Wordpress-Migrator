class Build {
    method build($dist-path) {

        chdir $*HOME;
        mkdir '.rawppp-config';    # FIXME
        chdir '.rawppp-config';

        my $exporter-text = q:to/ENDEX/;    # FIXME vv
#!/usr/bin/perl

##chdir

`wp db export backup-db-20240605-11-00-22.sql`;
`tar -czf backup-fs-20240605-11-00-22.tar.gz wp-content`;

##mv backup* ../sdname-backups
ENDEX

        qqx`echo \'$exporter-text\' > exporter.pl`;

        warn 'Build successful';

        exit 0
    }
}
