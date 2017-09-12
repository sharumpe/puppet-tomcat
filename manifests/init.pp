
class susetomcat
(
  $version                 = 7,
  $httpPort                = 8080,
  $httpRedirectPort        = 8443,
  $httpsPort               = 8443,
  $ajpPort                 = 8009,
  $ajpTomcatAuthentication = true,
  $ajpRedirectPort         = 8443,
  $ajpMaxThreads           = 150,
  $ajpMinSpareThreads      = 25,
  $ajpMaxSpareThreads      = 50,
  $contextSharedSessions   = false,
  $sharedLoader            = false,
  $ensureRunning           = false
)
{
  include susetomcat::params

  validate_bool( $ensureRunning )

  #
  # Install the packages for the version of Tomcat we're using
  #
  if ( $version == 6 ) {
    # If we're working with Tomcat6, the package requirements are... different.
    include susetomcat::tc6packages
  } else {
    package { 'tomcat' :
      ensure  => latest,
    }
    package { 'tomcat-admin-webapps' :
      ensure  => installed,
      require => Package[ 'tomcat' ],
    }
  }


  #
  # Ensure that the service is running and enabled on boot.
  #
  service { 'tomcat' :
    enable   => true,
    require  => [ Package[ 'tomcat' ], Package[ 'tomcat-admin-webapps' ] ],
    provider => systemd,
  }
  if ( $ensureRunning ) {
    Service[ 'tomcat' ] {
      ensure => running,
    }
  }

  #
  # Concat instance for context.xml
  #
  concat { $susetomcat::params::tc_context_config:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ 'tomcat' ],
  }

  if ( $contextSharedSessions ) {
    $sessionCookiePath = "sessionCookiePath=\"/\""
  }

  concat::fragment { 'context_preamble' :
    target  => $susetomcat::params::tc_context_config,
    order   => 01,
    content => template( "susetomcat/${version}${susetomcat::params::tc_context_config}.f1.erb" )
  }
  concat::fragment { 'context_postamble' :
    target  => $susetomcat::params::tc_context_config,
    order   => 99,
    content => "</Context>\n",
  }

  #
  # Concat instance for server.xml
  #
  file { $susetomcat::params::tc_server_config :
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template( "susetomcat/${version}${susetomcat::params::tc_server_config}.erb" ),
    require => Package[ 'tomcat' ],
  }

  #
  # Shared Loader Setup
  #
  if ( $sharedLoader ) {
    file_line { 'enable_shared_loader' :
      path  => $susetomcat::params::tc_catalina_props,
      line  => 'shared.loader=${catalina.base}/shared/lib/*.jar',
      match => '^shared.loader=',
    }
    file { [$susetomcat::params::tc_shared,$susetomcat::params::tc_shared_lib] :
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # concat { $susetomcat::params::tc_server_config:
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0644',
  #   require => Package[ 'tomcat' ],
  # }
  # concat::fragment { 'preamble' :
  #   target => $susetomcat::params::tc_server_config,
  #   order  => 01,
  #   source => "puppet:///modules/susetomcat/${version}${susetomcat::params::tc_server_config}.f1",
  # }
  # concat::fragment { 'postamble' :
  #   target => $susetomcat::params::tc_server_config,
  #   order  => 99,
  #   source => "puppet:///modules/susetomcat/${version}${susetomcat::params::tc_server_config}.f2",
  # }

  #
  # Concat instance for tomcat-users.xml
  #
  concat { $susetomcat::params::tc_user_config:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ 'tomcat' ],
  }
  concat::fragment { 'user_preamble' :
    target => $susetomcat::params::tc_user_config,
    order  => 01,
    source => "puppet:///modules/susetomcat/${version}${susetomcat::params::tc_user_config}.f1",
  }
  concat::fragment { 'user_postamble' :
    target => $susetomcat::params::tc_user_config,
    order  => 99,
    source => "puppet:///modules/susetomcat/${version}${susetomcat::params::tc_user_config}.f2",
  }

  #
  # Default: create the "admin" and "manager" roles
  #
  susetomcat::role { 'tomcat_admin' :
    role => 'admin',
  }
  susetomcat::role { 'tomcat_manager' :
    role => 'manager',
  }
  susetomcat::role { 'tomcat_gui_manager' :
    role => 'manager-gui',
  }
  susetomcat::role { 'tomcat_script_manager' :
    role => 'manager-script',
  }

  #
  # We will need to use the susetomcat::server::resource class even if there's
  # nothing there most of the time.
  #
  class { 'susetomcat::server::resource' : }

}
