define tomcat::role
(
	$role = $name
)
{
	include tomcat::params

	validate_string( $role )

	# Require that the requested role exists.

	$output = "\t<role rolename=\"${role}\" />\n"

	# Place the output in the concat fragment
	concat::fragment { "tc_role_${role}" :
		target	=> $params::tc_user_config,
		order	=> 10,
		content	=> $output,
	}

}

