class Build {
    method build($dist-path) {

        my $name = 'rawm-config';
        my $dir  = "$*HOME/.$name";
        my $file =  $name ~ ".yaml";
        my $bak  =  $name ~ "BAK.yaml";

        mkdir $dir;

        copy "resources/$file", "$dir/$file";

        if "$dir/$bak".IO.e {
            warn "Restoring $dir/$bak";
            copy "$dir/$bak", "$dir/$file";
        }

        warn 'Build successful';

        exit 0
    }
}
