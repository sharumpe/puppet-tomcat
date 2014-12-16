class tomcat::server::resource
{
	concat { $params::tc_extGnr_config :
		owner   => 'root',
		group   => 'root',
		mode	=> '0644',
		require	=> Package[ 'tomcat' ],
	}
}

define tomcat::server::addDbcpResource
(
	$resourceName	= $name,
	$driverClass,
	$connectionUrl,
	$connectionUser,
	$connectionPass,
	$maxActive	= 100,
	$maxIdle	= 30,
	$maxWait	= 10000,
	$validationQuery
)
{
	include tomcat::params

	concat::fragment { "dbcp-$resourceName" :
		target	=> $params::tc_extGnr_config,
		order	=> 20,
		content	=> template( "tomcat/${tomcat::version}${params::tc_extGnr_config}-dbcp-frag.erb")
	}
}

define tomcat::server::environment
(
	$envName = $name,
	$value,
	$type = "java.lang.String",
	$override = true,
	$description = "${name} defined by Puppet"
)
{
	include tomcat::params

	validate_string( $envName )
	validate_string( $value )
	validate_string( $type )
	validate_bool( $override )
	validate_string( $description )

	$output = "<!-- ${description} -->\n<Environment name=\"${envName}\"\n\tvalue=\"${value}\"\n\ttype=\"${type}\"\n\toverride=\"${override}\" />\n\n"

	# Place the output in the concat fragment
	concat::fragment { "tc_context_environment_${envName}" :
		target	=> $params::tc_extGnr_config,
		order	=> 10,
		content	=> $output,
	}

}

