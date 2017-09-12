define susetomcat::context::parameter
(
  $value,
  $paramName = $name,
  $description = "${name} defined by Puppet"
)
{
  include susetomcat::params

  validate_string( $paramName )
  validate_string( $value )
  validate_string( $description )

  $output = "\t<!-- ${description} -->\n\t<Parameter name=\"${paramName}\"\n\t\tvalue=\"${value}\" />\n"

  # Place the output in the concat fragment
  concat::fragment { "tc_context_parameter_${paramName}" :
    target  => $susetomcat::params::tc_context_config,
    order   => 15,
    content => $output,
  }

}
