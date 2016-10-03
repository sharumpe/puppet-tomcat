class susetomcat::params
{
  if ( $susetomcat::version == 6 )
  {
    $serviceName       = 'tomcat6'
    $packageName       = 'tomcat6'
    $tc_config         = '/etc/tomcat6/tomcat6.conf'
    $tc_user_config    = '/etc/tomcat6/tomcat-users.xml'
    $tc_context_config = '/etc/tomcat6/context.xml'
    $tc_server_config  = '/etc/tomcat6/server.xml'
    $tc_extGnr_config  = '/etc/tomcat6/externalGlobalNamingResources.xml'
    $tc_catalina_props = '/etc/tomcat6/catalina.properties'
    $tc_shared         = '/usr/share/tomcat6/shared'
    $tc_shared_lib     = '/usr/share/tomcat6/shared/lib'
  } else {
    $serviceName       = 'tomcat'
    $packageName       = 'tomcat'
    $tc_config         = '/etc/tomcat/tomcat.conf'
    $tc_user_config    = '/etc/tomcat/tomcat-users.xml'
    $tc_context_config = '/etc/tomcat/context.xml'
    $tc_server_config  = '/etc/tomcat/server.xml'
    $tc_extGnr_config  = '/etc/tomcat/externalGlobalNamingResources.xml'
    $tc_catalina_props = '/etc/tomcat/catalina.properties'
    $tc_shared         = '/usr/share/tomcat/shared'
    $tc_shared_lib     = '/usr/share/tomcat/shared/lib'
  }
}
