use DateTime::Format;

my $user     = 'myusername';
my $domain   = 'mydomain.com';
my $subdom   = 'sdname';
my $key-pub  = 'kpname';
my $port     = 22;

my $bu-dir   = "$subdom.backup";
my $wp-dir   = "$subdom.$domain" ;

my $login    = "$user@$domain"; 
my $home-path = "/home/$user";
my $key-dir  = '~/.ssh';
my $key-path = "$key-dir/$key-pub";

# spawn process and ssh connect it
my $proc = Proc::Async.new: :w, qqw|ssh -p $port -tt -i $key-path $login|;
 
# subscribe to new output from out and err handles: 
$proc.stdout.tap(-> $v { print "Output: $v" });
$proc.stderr.tap(-> $v { print "Error:  $v" });
 
my $now = strftime('%Y%m%d-%H-%M-%S', DateTime.now);

say perl;
die;

say "starting $now ...";
my $promise = $proc.start; 

# use connected proc to make bu files
$proc.say: "mkdir $bu-dir";
$proc.say: "cd $bu-dir";

$proc.say: "echo \'{perl}\' > exporter.pl";
$proc.say: 'cat exporter.pl | perl';

sleep 3;
$proc.say: 'exit';
await $promise;
say "remote sesh done!";

say "downloading [may take a few mins]...";
# use local proc to get them
qqx|scp -P $port -i $key-path -r $login:$home-path/$bu-dir/backup-db-$now.sql .|;
qqx|scp -P $port -i $key-path -r $login:$home-path/$bu-dir/backup-fs-$now.tar.gz .|;

# spawn process and ssh connect it
$proc = Proc::Async.new: :w, qqw|ssh -p $port -tt -i $key-path $login|;
 
# subscribe to new output from out and err handles: 
$proc.stdout.tap(-> $v { print "Output: $v" });
$proc.stderr.tap(-> $v { print "Error:  $v" });
 
say "cleaning up ...";
$promise = $proc.start;

# use connected proc to make bu files
$proc.say: "rm -rf $bu-dir";

sleep 3;
$proc.say: 'exit';
await $promise;
say "cleanup done!";

sub perl {
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

    $code ~~ s:g/'%NOW%'   /$now/;
    $code ~~ s:g/'%WP-DIR%'/$wp-dir/;

    $code
}
