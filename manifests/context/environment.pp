define susetomcat::context::environment
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

  $output = "\t<!-- ${description} -->\n\t<Environment name=\"${envName}\"\n\t\tvalue=\"${value}\"\n\t\ttype=\"${type}\"\n\t\toverride=\"${override}\" />\n\n"

  # Place the output in the concat fragment
  concat::fragment { "tc_context_environment_${envName}" :
    target  => $susetomcat::params::tc_context_config,
    order   => 10,
    content => $output,
  }

}
