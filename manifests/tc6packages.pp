class susetomcat::tc6packages
{
  #
  # Make sure we've got the repo we need
  #
  zypprepo { 'evergreen-11.4-for-tomcat6' :
    baseurl     => 'http://download.opensuse.org/repositories/openSUSE:/Evergreen:/11.4/standard/',
    enabled     => 1,
    autorefresh => 0,
    name        => 'evergreen-11.4-for-tomcat6',
    gpgcheck    => 0,
  }

  $jcct5_url = 'http://suse.mobile-central.org/distribution/12.3/repo/oss/suse/noarch/jakarta-commons-collections-tomcat5-3.2-103.1.3.noarch.rpm'
  package { 'jakarta-commons-collections-tomcat5' :
    ensure   => installed,
    provider => rpm,
    source   => $jcct5_url,
  }

  package { 'tomcat' :
    ensure  => installed,
    name    => 'tomcat6',
    require => [ Package[ 'jakarta-commons-collections-tomcat5' ], Zypprepo[ 'evergreen-11.4-for-tomcat6' ] ],
  }

  package { 'tomcat-admin-webapps' :
    ensure  => installed,
    name    => 'tomcat6-admin-webapps',
    require => Package[ 'tomcat' ],
  }
}
