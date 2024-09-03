#!/usr/bin/perl
use strict;
use warnings;

`wp core download --locale=en_GB`;
`wp config create --dbname=dbname --dbuser=myusername --dbpass=xxx --dbprefix=wp_`;
`wp core install --url=subdom.mydomain.com --title="Celebrant Kate Demo" --admin_user=admin --admin_password=apw --admin_email=mymail`;
`chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644