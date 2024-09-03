#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw/strftime/;

my $now = strftime('%Y%m%d-%H-%M-%S',localtime);
print "Doing backup at $now\n";

my $sql_file = "backup-db-$now.sql";
`wp db export $sql_file`;

my $tar_file = "backup-fs-$now.tar.gz";
`tar -czf $tar_file wp-content`;