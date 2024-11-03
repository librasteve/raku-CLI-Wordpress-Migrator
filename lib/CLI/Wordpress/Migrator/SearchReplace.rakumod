use CLI::Wordpress::Migrator;

class SearchReplace {
    has Server $.from;
    has Server $.to;


    method upload {
        my $s := $.server;

        say "Making temp dir on remote...";
        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("[ -d { $s.tp-dir } ] || mkdir -p { $s.tp-dir }");

        $proc.say("exit");
        await $promise;

        say "Doing file upload from local...";

        qqx`scp -P 22007 -i { $s.key-path } -r { $.bu-db-fn } { $s.login }:{ $s.hm-dir }/{ $s.tp-dir }`;
        qqx`scp -P 22007 -i { $s.key-path } -r { $.bu-fs-fn } { $s.login }:{ $s.hm-dir }/{ $s.tp-dir }`;
    }

    method perl {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing remote restore at %NOW%\n";

        print "Importing WP database...\n";
        `wp db --path='../%WP-DIR%' reset --yes`;
        `wp db --path='../%WP-DIR%' import %BU-DB-FN%`;

        print "Extracting WP files...\n";
        `tar -xvzf %BU-FS-FN% --strip-components=1`;      #extract in place to xxx.temp/wp-content, rm parent dir

        print "Moving WP files...\n";
        `rm -rf ../%WP-DIR%/wp-content`;
        `mv wp-content ../%WP-DIR%/`;

        chdir( "../%WP-DIR%" );

        print "Checking db prefix...\n";
        `wp db prefix`;

        print "Adjusting file/dir permissions...\n";
        `chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644

        print "Doing search-replace...\n";
        `wp search-replace 'https://sarahroeassociates.co.uk' 'https://test.henleycloudconsulting.co.uk' --dry-run`

        print "Refreshing permalinks...\n";
        `wp rewrite flush`;

        END

        $code ~~ s:g/'%NOW%'     /{ $.timestamp}/;
        $code ~~ s:g/'%BU-DB-FN%'/{ $.bu-db-fn }/;
        $code ~~ s:g/'%BU-FS-FN%'/{ $.bu-fs-fn }/;
        $code ~~ s:g/'%WP-DIR%'  /{ $.server.wp-dir }/;
        $code ~~ s:g/'%TP-DIR%'  /{ $.server.tp-dir }/;

        $code
    }

    method restore {
        my $s := $.server;

        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("cd { $s.tp-dir }");

        $proc.say("echo \'{ $.perl }\' > importer.pl");
        $proc.say('cat importer.pl | perl');

        sleep 30;

        $proc.say("exit");
        await $promise;
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
        $proc.say("rm -rf { $s.tp-dir }");

        $proc.say("exit");
        await $promise;
    }

    method all {
        $.upload;
        say "File upload done!";

        $.restore;
        say "Remote restore done!";

        $.cleanup;
        say 'Remote cleanup done!';
    }
}


