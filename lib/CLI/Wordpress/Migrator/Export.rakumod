use CLI::Wordpress::Migrator;

class Export {
    has Server $.server;
    has Str    $.timestamp;

    method bu-db-fn {
        "backup-db-{$.timestamp}.sql"
    }
    method bu-fs-fn {
        "backup-fs-{$.timestamp}.tar.gz"
    }

    method perl {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing remote backup at %NOW%\n";

        `wp db --path='../%WP-DIR%' export %BU-DB-FN%`;
        `tar -czf %BU-FS-FN% ../%WP-DIR%/wp-content`;
        END

        $code ~~ s:g/'%NOW%'     /{ $.timestamp}/;
        $code ~~ s:g/'%BU-DB-FN%'/{ $.bu-db-fn }/;
        $code ~~ s:g/'%BU-FS-FN%'/{ $.bu-fs-fn }/;
        $code ~~ s:g/'%WP-DIR%'  /{ $.server.wp-dir }/;
        $code
    }

    method backup {
        my $s := $.server;

        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("mkdir { $s.bu-dir }");
        $proc.say("cd { $s.bu-dir }");

        $proc.say("echo \'{ $.perl }\' > exporter.pl");
        $proc.say('cat exporter.pl | perl');

        sleep 30;

        $proc.say("exit");
        await $promise;
    }

    method download {
        my $s := $.server;
        say "Doing file download...";

        qqx`scp -P 22007 -i { $s.key-path } -r { $s.login }:{ $s.hm-dir }/{ $s.bu-dir }/{ $.bu-db-fn } .`;
        qqx`scp -P 22007 -i { $s.key-path } -r { $s.login }:{ $s.hm-dir }/{ $s.bu-dir }/{ $.bu-fs-fn } .`;
    }

    method cleanup {
        say "Doing remote cleanup...";

        my $s := $.server;

        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Goodbye, World'");
        $proc.say("pwd");
        $proc.say("rm -rf { $s.bu-dir }");

        $proc.say("exit");
        await $promise;
    }

    method all {
        $.backup;
        say "Remote backup done!";

        $.download;
        say "File download done!";

        $.cleanup;
        say 'Remote cleanup done!';
    }
}


