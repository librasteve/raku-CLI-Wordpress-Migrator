#!/usr/bin/perl
use strict;
use warnings;


my $sql_file = "backup-db-20240614-15-36-58.sql";    #%NOW%?
#`wp db --path='../%WP-DIR%' export $sql_file`;
`wp db --path='../celebdemo.mydomain.com' reset --yes`;
`wp db --path='../celebdemo.mydomain.com' import $sql_file`;

my $tar_file = "backup-fs-20240614-15-36-58.tar.gz";         #%NOW%?
`tar -xvzf $tar_file`;                                         #extract in place

`rm -rf ../celebdemo.mydomain.com/wp-content`;
`mv p4mdemo.mydomain.com/wp-content ../celebdemo.mydomain.com/`;`
`chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644





