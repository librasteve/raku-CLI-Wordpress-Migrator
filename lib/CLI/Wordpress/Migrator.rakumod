unit module CLI::Wordpress::Migrator;

use YAMLish;

my %config-yaml := load-yaml("$*HOME/.rawm-config/rawm-config.yaml".IO.slurp);

class Login is export {
    my $y := %config-yaml;

    has $.server;

    has $.user    = $y{$!server}<user>;
    has $.domain  = $y{$!server}<domain>;
    has $.subdom  = $y{$!server}<subdom>;
    has $.key-pub = $y{$!server}<key-pub>;
    has $.port    = $y{$!server}<port>;
}
