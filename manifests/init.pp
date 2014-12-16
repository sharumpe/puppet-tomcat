# == Class: tomcat
#
# Full description of class tomcat here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { tomcat:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class tomcat
(
	$version		= 7,
	$httpPort		= 8080,
	$httpRedirectPort	= 8443,
	$httpsPort		= 8443,
	$ajpPort		= 8009,
	$ajpRedirectPort	= 8443,
	$ajpMaxThreads		= 150,
	$ajpMinSpareThreads	= 25,
	$ajpMaxSpareThreads	= 50,
	$contextSharedSessions 	= false,
	$sharedLoader		= false
)
{
	include tomcat::params

	#
	# Install the packages for the version of Tomcat we're using
	#
	if ( $version == 6 ) {
		# If we're working with Tomcat6, the package requirements are... different.
		include tomcat::tc6packages
	} else {
		package { 'tomcat' :
			ensure	=> latest,
		}
		package { 'tomcat-admin-webapps' :
			ensure	=> installed,
			require	=> Package[ 'tomcat' ],
		}
	}


	#
	# Ensure that the service is running and enabled on boot.
	#
	service { 'tomcat' :
		ensure	=> running,
		enable	=> true,
		require	=> [ Package[ 'tomcat' ], Package[ 'tomcat-admin-webapps' ] ],
		provider	=> systemd,
	}

	#
	# Concat instance for context.xml
	#
	concat { $params::tc_context_config:
		owner	=> 'root',
		group	=> 'root',
		mode	=> '0644',
		require	=> Package[ 'tomcat' ],
	}

	if ( $contextSharedSessions ) {
		$sessionCookiePath = "sessionCookiePath=\"/\""
	}

	concat::fragment { 'context_preamble' :
		target	=> $params::tc_context_config,
		order	=> 01,
		#source	=> "puppet:///modules/tomcat/${version}${params::tc_context_config}.f1",
		content	=> template( "tomcat/${version}${params::tc_context_config}.f1.erb" )
	}
	concat::fragment { 'context_postamble' :
		target	=> $params::tc_context_config,
		order	=> 99,
		content	=> "</Context>\n",
	}

	#
	# Concat instance for server.xml
	#
        file { $params::tc_server_config :
                owner   => 'root',
                group   => 'root',
		mode	=> '0644',
                content	=> template( "tomcat/${version}${params::tc_server_config}.erb" ),
		require	=> Package[ 'tomcat' ],
	}

	#
	# Shared Loader Setup
	#
	if ( $sharedLoader ) {
		file_line { 'enable_shared_loader' :
			path	=> $params::tc_catalina_props,
			line	=> 'shared.loader=${catalina.base}/shared/lib/*.jar',
			match	=> '^shared.loader=',
		}
		file { [$params::tc_shared,$params::tc_shared_lib] :
			ensure	=> directory,
			owner	=> 'root',
			group 	=> 'root',
			mode	=> '0755',
		}
	}

/*
	concat { $params::tc_server_config:
		owner	=> 'root',
		group	=> 'root',
		mode	=> '0644',
		require	=> Package[ 'tomcat' ],
	}
	concat::fragment { 'preamble' :
		target	=> $params::tc_server_config,
		order	=> 01,
		source	=> "puppet:///modules/tomcat/${version}${params::tc_server_config}.f1",
	}
	concat::fragment { 'postamble' :
		target	=> $params::tc_server_config,
		order	=> 99,
		source	=> "puppet:///modules/tomcat/${version}${params::tc_server_config}.f2",
	}
*/

	#
	# Concat instance for tomcat-users.xml
	#
	concat { $params::tc_user_config:
		owner	=> 'root',
		group	=> 'root',
		mode	=> '0644',
		require	=> Package[ 'tomcat' ],
	}
	concat::fragment { 'user_preamble' :
		target	=> $params::tc_user_config,
		order	=> 01,
		source	=> "puppet:///modules/tomcat/${version}${params::tc_user_config}.f1",
	}
	concat::fragment { 'user_postamble' :
		target	=> $params::tc_user_config,
		order	=> 99,
		source	=> "puppet:///modules/tomcat/${version}${params::tc_user_config}.f2",
	}

	#
	# Default: create the "admin" and "manager" roles
	#
	tomcat::role { 'tomcat_admin' :
		role	=> 'admin',
	}
	tomcat::role { 'tomcat_manager' :
		role    => 'manager',
	}
	tomcat::role { 'tomcat_gui_manager' :
		role    => 'manager-gui',
	}
	tomcat::role { 'tomcat_script_manager' :
		role    => 'manager-script',
	}

	#
	# We will need to use the tomcat::server::resource class even if there's
	# nothing there most of the time.
	#
	class { 'tomcat::server::resource' : }

}
