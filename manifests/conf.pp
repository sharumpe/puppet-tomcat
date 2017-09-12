define susetomcat::conf
(
  $debugEnable    = false,
  $debugPort      = 9666,

  $jmxEnable      = false,
  $jmxPort        = 8666,

  $memoryMin      = 128,
  $memoryMax      = 1024,
  $memoryPermGen  = 256,

  $connectTimeout = 30,
  $readTimeout    = 300,

  $java_opt       = '',
  $catalina_opt   = ''
)
{
  include susetomcat::params

  # These will always be prepended to CATALINA_OPTS
  $catalina_opt_prepend = '-server -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC'

  validate_bool( $debugEnable )
  validate_re( $debugPort, '^\d+$' )
  validate_bool( $jmxEnable )
  validate_re( $jmxPort, '^\d+$' )
  validate_re( $memoryMin, '^\d+$' )
  validate_re( $memoryMax, '^\d+$' )
  validate_re( $memoryPermGen, '^\d+$' )
  validate_re( $connectTimeout, '^\d+$' )
  validate_re( $readTimeout, '^\d+$' )
  validate_string( $java_opt )
  validate_string( $catalina_opt )

  # Make the Debug string
  if ( $debugEnable == true ) {
    $debugString = "-Xdebug -Xrunjdwp:transport=dt_socket,address=${debugPort},server=y,suspend=n"
  } else {
    $debugString = undef
  }

  # Make the JMX string
  if ( $jmxEnable == true ) {
    $jmxString = "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=${jmxPort} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
  } else {
    $jmxString = undef
  }

  # Make the timeouts string
  $ctms          = $connectTimeout * 1000
  $rtms          = $readTimeout * 1000
  $timeoutString = "-Dsun.net.client.defaultConnectTimeout=${ctms} -Dsun.net.client.defaultReadTimeout=${rtms}"

  # Make the memory string
  $memoryString = "-Xms${memoryMin}m -Xmx${memoryMax}m -XX:MaxPermSize=${memoryPermGen}m"

  # Prepend the "always" stuff to catalina_opt
  $catalinaOptString = "CATALINA_OPTS=\"${catalina_opt_prepend} ${memoryString} ${timeoutString} ${debugString} ${jmxString} ${catalina_opt}\""

  # Just pass along java_opt
  if ( empty( $java_opt ) == false ) {
    $javaOptString = "JAVA_OPTS=\"${java_opt}\""
  } else {
    $javaOptString = ''
  }

  # Now put it all in the appropriate template
  file { $susetomcat::params::tc_config :
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template( "susetomcat/${susetomcat::version}${susetomcat::params::tc_config}.erb" ),
    require => Package[ 'tomcat' ],
  }

}
