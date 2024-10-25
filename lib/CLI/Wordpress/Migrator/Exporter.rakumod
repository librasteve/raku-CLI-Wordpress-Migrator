use CLI::Wordpress::Migrator;

class Exporter {
    has Server $.server;
    has Str    $.now;

    method perl {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing backup at %NOW%\n";

        my $sql_file = "backup-db-%NOW%.sql";
        `wp db --path='../%WP-DIR%' export $sql_file`;

        my $tar_file = "backup-fs-%NOW%.tar.gz";
        `tar -czf $tar_file ../%WP-DIR%/wp-content`;
        END

        $code ~~ s:g/'%NOW%'   /{$.now}/;
        $code ~~ s:g/'%WP-DIR%'/{$.server.wp-dir}/;

        $code
    }

}


