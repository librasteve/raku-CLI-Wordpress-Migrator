unit module CLI::Wordpress::Migrator;

use YAMLish;

my %config-yaml = load-yaml("$*HOME/.rawm-config/rawm-config.yaml".IO.slurp);

class Server is export {
    my %y = %config-yaml;

    has $.name;
    has $.user    = %y{$!name}<user>;
    has $.domain  = %y{$!name}<domain>;
    has $.subdom  = %y{$!name}<subdom>;
    has $.key-pub = %y{$!name}<key-pub>;
    has $.port    = %y{$!name}<port>;

    method bu-dir   { "$.subdom.backup" }
    method wp-dir   { "$.subdom.$.domain" }

    method login    { "$.user@$.domain" }
    method hm-dir   { "/home/$.user" }

    method key-dir  { '~/.ssh' }
    method key-path { "$.key-dir/$.key-pub" }
}
