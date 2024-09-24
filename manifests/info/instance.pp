# Define puppi::info::instance
#
# This is a puppi info plugin specific for the tomcat::instance define
#
define puppi::info::instance (
  String $servicename  = '',
  String $processname  = '',
  String $configdir    = '',
  String $bindir       = '',
  String $pidfile      = '',
  String $datadir      = '',
  String $logdir       = '',
  Variant[String,Integer] $httpport     = '',
  Variant[String,Integer] $controlport  = '',
  Variant[String,Integer] $ajpport      = '',
  String $description  = '',
  String $run          = '',
  String $verbose      = 'no',
  String $templatefile = 'puppi/info/instance.erb',
) {
  require puppi
  require puppi::params

  file { "${puppi::params::infodir}/${name}":
    ensure  => file,
    mode    => '0750',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    content => template($templatefile),
    tag     => 'puppi_info',
  }
}
