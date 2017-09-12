class susetomcat::server::resource
{
  concat { $susetomcat::params::tc_extGnr_config :
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ 'tomcat' ],
  }

  concat::fragment { 'blankline' :
    target  => $susetomcat::params::tc_extGnr_config,
    order   => 99,
    content => ' ',
  }
}

define susetomcat::server::adddbcpresource
(
  $driverClass,
  $connectionUrl,
  $connectionUser,
  $connectionPass,
  $validationQuery,
  $resourceName = $name,
  $maxActive    = 100,
  $maxIdle      = 30,
  $maxWait      = 10000
)
{
  include susetomcat::params

  concat::fragment { "dbcp-${resourceName}" :
    target  => $susetomcat::params::tc_extGnr_config,
    order   => 20,
    content => template( "tomcat/${susetomcat::version}${susetomcat::params::tc_extGnr_config}-dbcp-frag.erb")
  }
}

define susetomcat::server::environment
(
  $value,
  $envName     = $name,
  $type        = 'java.lang.String',
  $override    = true,
  $description = "${name} defined by Puppet"
)
{
  include susetomcat::params

  validate_string( $envName )
  validate_string( $value )
  validate_string( $type )
  validate_bool( $override )
  validate_string( $description )

  $output = "<!-- ${description} -->\n<Environment name=\"${envName}\"\n\tvalue=\"${value}\"\n\ttype=\"${type}\"\n\toverride=\"${override}\" />\n\n"

  # Place the output in the concat fragment
  concat::fragment { "tc_context_environment_${envName}" :
    target  => $susetomcat::params::tc_extGnr_config,
    order   => 10,
    content => $output,
  }

}
