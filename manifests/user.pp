define susetomcat::user
(
  $password,
  $role,
  $user = $name
)
{
  include susetomcat::params

  validate_string( $user )
  validate_string( $password )
  validate_string( $role )

  # Require that the requested role exists.

  $output = "\t<user name=\"${user}\" password=\"${password}\" roles=\"${role}\" />\n"

  # Place the output in the concat fragment
  concat::fragment { "tc_user_${user}" :
    target  => $params::tc_user_config,
    order   => 15,
    content => $output,
  }

}
