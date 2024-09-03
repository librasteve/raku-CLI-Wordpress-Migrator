#!/usr/bin/perl
use strict;
use warnings;

#cd WP-DIR

`wp search-replace 'https://ckdemo.mydomain.com' 'https://celebdemo.mydomain.com' --dry-run`;

#`wp plugin activate --all`;    #option (typically already activated)
#`wp plugin update --all`;      #option
#`wp theme update --all`;       #option
#`wp db prefix`;                #check?
#
#Error: The site you have requested is not installed.
#  Your table prefix is 'wp_'. Found installation with table prefix: wpdh_.
#  Or, run `wp core install` to create database tables.

#my $output = `your_command_here`;
#if ($? != 0) {
#    die "Command failed with error code: $?";
#}
#
#print "Command output: $output";