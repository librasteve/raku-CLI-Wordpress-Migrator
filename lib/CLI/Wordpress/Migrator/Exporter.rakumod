use CLI::Wordpress::Migrator;

class Exporter {
    has Server $.server;
    has Str    $.now;

    method perl-code {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing remote backup at %NOW%\n";

        my $sql_file = "backup-db-%NOW%.sql";
        `wp db --path='../%WP-DIR%' export $sql_file`;

        my $tar_file = "backup-fs-%NOW%.tar.gz";
        `tar -czf $tar_file ../%WP-DIR%/wp-content`;

        END

        $code ~~ s:g/'%NOW%'   /{$.now}/;
        $code ~~ s:g/'%WP-DIR%'/{$.server.wp-dir}/;

        $code
    }

    method perl-remote {
        my $s := $.server;

        my $proc = Proc::Async.new: :w, qqw|ssh -p {$s.port} -tt -i {$s.key-path} {$s.login}|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("mkdir {$s.bu-dir}");
        $proc.say("cd {$s.bu-dir}");

        $proc.say("echo \'{$.perl-code}\' > exporter.pl");
        $proc.say('cat exporter.pl | perl');

        sleep 30;

        $proc.say("exit");
        await $promise;
        say "Remote backup done!";
    }

}


