class Build {
    method build($dist-path) {

        chdir $*HOME;
        mkdir '.rawm-config';    # FIXME
        chdir '.rawm-config';

        my $text1 = q:to/END1/;
from:
  user: myusername
  domain: mydomain.com
  subdom: sdname
  key-pub: kpname
  port: 22
to:
  user: myusername
  domain: mydomain.com
  subdom: sdname
  key-pub: kpname
  port: 22
END1

        qqx`echo \'$text1\' > rawm-config.yaml`;

        warn 'Build successful';

        exit 0
    }
}
