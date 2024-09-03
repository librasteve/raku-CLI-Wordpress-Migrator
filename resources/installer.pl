#!/usr/bin/perl
use strict;
use warnings;

`wp core download --locale=en_GB`;
`wp config create --dbname=myusername_wp187 --dbuser=myusername_wp187 --dbpass=dikpif-varQo4-guzruq --dbprefix=wp_`;
`wp core install --url=celebdemo.mydomain.com --title="Celebrant Kate Demo" --admin_user=admin --admin_password=florida800! --admin_email=hcc@furnival.net`;
`chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644