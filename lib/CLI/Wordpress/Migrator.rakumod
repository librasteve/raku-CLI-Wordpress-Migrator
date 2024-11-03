unit module CLI::Wordpress::Migrator;

use YAMLish;

my %config-yaml = load-yaml("$*HOME/.rawm-config/rawm-config.yaml".IO.slurp);

class Server is export {
    my %y = %config-yaml;
    has $.name where * ~~ /[from|to]/;

    has $.user    = %y{$!name}<user>;
    has $.subdom  = %y{$!name}<subdom>;
    has $.domain  = %y{$!name}<domain>;
    has $.key-pub = %y{$!name}<key-pub>;
    has $.port    = %y{$!name}<port>;

    method tp-dir   {
        if $.subdom ne '_' {
            "$.subdom.temp"
        } else {
            "public_html.temp"
        }
    }
    method wp-dir   {
        if $.subdom ne '_' {
            "$.subdom.$.domain"
        } else {
            "public_html"
        }
    }

    method login    { "$.user@$.domain" }
    method hm-dir   { "/home/$.user" }

    method key-dir  { '~/.ssh' }
    method key-path { "$.key-dir/$.key-pub" }

    method hostname {
        if $.subdom ne '_' {
            "$.subdom.$.domain";
        } else {
            "$.domain";
        }
    }
}

class WP-Config is export {
    my %y = %config-yaml;
    has $.name = 'wp-config';

    has $.locale = %y{$!name}<locale>;

    has %.db = {
        name   => %y{$!name}<db><name>,
        user   => %y{$!name}<db><user>,
        pass   => %y{$!name}<db><pass>,
        prefix => %y{$!name}<db><prefix>,
    }

    has $.title = %y{$!name}<title>;
    has $.url = %y{$!name}<url>;

    has %.ad = {
        user  => %y{$!name}<admin><user>,
        pass  => %y{$!name}<admin><pass>,
        email => %y{$!name}<admin><email>,
    }
}
