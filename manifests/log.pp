# Define puppi::log
#
# This define creates a basic log file that simply contains
# the list of logs to show when issuing the puppi log command.
#
# == Usage:
# puppi::log { "system":
#   description => "General System Logs" ,
#   log  => [ "/var/log/syslog" , "/var/log/messages" ],
# }
#
# :include:../README.log
#
define puppi::log (
  Variant[String,Array] $log,
  String $description = '',
) {
  require puppi
  require puppi::params

  if $log.type =~ Array {
    $array_log = $log
  } else {
    $array_log = split($log, ',')
  }

  file { "${puppi::params::logsdir}/${name}":
    ensure  => 'file',
    mode    => '0644',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    require => Class['puppi'],
    content => template('puppi/log.erb'),
    tag     => 'puppi_log',
  }
}
