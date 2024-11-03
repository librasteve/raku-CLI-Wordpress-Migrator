use CLI::Wordpress::Migrator;

class SearchReplace {
    has Server $.from;
    has Server $.to;
    has $.dry-run;

    method sr-block {
        sub inner($tls, $www) {
            my $protocol = $tls ?? 'https://' !! 'http://';
            my $preamble = $www ?? 'www.' !! '';
            my $modifier = $.dry-run ?? '--dry-run' !! '';

            my $search  = $protocol ~ $preamble ~ $.from.hostname;
            my $replace = $protocol ~ $preamble ~ $.to.hostname;

            qq|`wp search-replace '$search' '$replace' $modifier`;|;
        }

        qq:to/END/;
        { inner(0,0) }
        { inner(0,1) }
        { inner(1,0) }
        { inner(1,1) }
        END
    }

    method perl {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing search-replace...\n";
        %SR-BLOCK%

        print "Refreshing permalinks...\n";
        `wp rewrite flush`;

        END

        $code ~~ s:g/'%SR-BLOCK%'  /{ $.sr-block }/;

        $code
    }

    method all {
        my $s := $!to;

        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("cd { $s.wp-dir }");

        $proc.say("echo \'{ $.perl }\' > importer.pl");
        $proc.say('cat importer.pl | perl');

        sleep 5;

        $proc.say("exit");
        await $promise;
    }
}


