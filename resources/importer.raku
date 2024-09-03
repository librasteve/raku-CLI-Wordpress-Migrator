#`[
notes

cpan make a new domain
DNS add new A record
cpan make a new database (myusername_wpXXX), user (myusername_wpXXX) and GRANT ALL
do import - may need to check table prefix

wp_186
wp_186
xywhyb-Cibdys-8bymhu

viz. https://make.wordpress.org/cli/handbook/how-to/how-to-install/

#]

### RUN INSTALLER (OPTIONAL)
#`wp core download --locale=en_GB`;
#`wp config create --dbname=myusername_wp186 --dbuser=myusername_wp186 --dbpass=xywhyb-Cibdys-8bymhu`;
#`wp core install --url=celebdemo.mydomain.com --title="Celebrant Kate Demo" --admin_user=admin --admin_password=florida800     --admin_email=hcc@furnival.net`
#`chmod -R a=r,a+X,u+w .`;   #dirs to 0755, files to 0644

### UPLOAD BACKUP FILES
#scp -P 22 -i ~/.ssh/kpname -r backup-db-20240614-15-36-58.sql myusername@mydomain.com:/home/myusername/celebdemo.backup
#scp -P 22 -i ~/.ssh/kpname -r backup-fs-20240614-15-36-58.tar.gz myusername@mydomain.com:/home/myusername/celebdemo.backup backup-fs-20240614-15-36-58.tar.gz

### RUN IMPORTER
#cd celebdemo.backup


