use CLI::Wordpress::Migrator;

class Install {
    has Server    $.server;
    has WP-Config $.wp-config;

    has $.yo = 'yo';

    method perl {
        my $code = q:to/END/;
        #!/usr/bin/perl
        use strict;
        use warnings;

        print "Doing remote WP install\n";

        print "Downloading WP core...\n";
        `wp core download --locale=%LOCALE%`;

        print "Removing old WP config...\n";
        `rm wp-config.php`;

        print "Creating WP config...\n";
        `wp config create --dbname='%DBNAME%' --dbuser='%DBUSER%' --dbpass='%DBPASS%' --dbprefix='%DBPREFIX%'`;


        print "Resetting WP database & config...\n";
        `wp db reset --yes`;

        print "Installing WP core...\n";

        my $wp_command = "wp core install --url=test.henleycloudconsulting.co.uk --title=\"My WP Test\" --admin_user=steveroe --admin_password=florida800! --admin_email=";
        my $email = "%ADEMAIL%";

        my $wp_combine = $wp_command . $email;
        `$wp_combine`;         #best way to smuggle @ past quotes

        print "Adjusting file/dir permissions...\n";
        `chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644
        END


        my $c := $!wp-config;

        $code ~~ s:g/'%LOCALE%'  /{ $c.locale }/;

        $code ~~ s:g/'%DBNAME%'/{ $c.db<name> }/;
        $code ~~ s:g/'%DBUSER%'/{ $c.db<user> }/;
        $code ~~ s:g/'%DBPASS%'/{ $c.db<pass> }/;
        $code ~~ s:g/'%DBPREFIX%'/{ $c.db<prefix> }/;

        $code ~~ s:g/'%TITLE%'/{ $c.title }/;
        $code ~~ s:g/'%URL%'/{ $c.url }/;

        $code ~~ s:g/'%ADUSER%'/{ $c.ad<user> }/;
        $code ~~ s:g/'%ADPASS%'/{ $c.ad<pass> }/;

        my $email = $c.ad<email>;
        $email ~~ s/'@'/\\@/;
        $code ~~ s:g/'%ADEMAIL%'/{ $email }/;

        $code
    }

    method all {
        my $s := $.server;

        my $proc = Proc::Async.new: :w, qqw|ssh -p { $s.port } -tt -i { $s.key-path } { $s.login }|;
        $proc.stdout.tap({ print "stdout: $^s" });
        $proc.stderr.tap({ print "stderr: $^s" });

        my $promise = $proc.start;

        $proc.say("echo 'Hello, World'");
        $proc.say("id");

        $proc.say("cd { $s.wp-dir }");

        $proc.say("echo \'{ $.perl }\' > installer.pl");
        $proc.say('cat installer.pl | perl');

        sleep 30;

        $proc.say("exit");
        await $promise;
    }
}
