# Define puppi::info
#
# This define creates a basic info file that simply contains a set
# of commands that show infos about custom topics.
# To be used by the puppi info command.
# By default it builds the info script based on the minimal puppi/info.erb
# template but you can choose a custom template.
# Other info defines are used to gather and create puppi info scripts with
# different arguments and contents.
# Check puppi/manifests/info/ for alternative puppi::info::  plugins
#
# == Usage:
# puppi::info { "network":
#   description => "Network status and information" ,
#   run  => [ "ifconfig" , "route -n" ],
# }
#
# :include:../README.info
#
define puppi::info (
  String $description  = '',
  String $templatefile = 'puppi/info.erb',
  Variant[String,Array] $run = '',
) {
  require puppi
  require puppi::params

  if $run.type =~ Array {
    $array_run = $run
  } else {
    $array_run = [$run]
  }
  file { "${puppi::params::infodir}/${name}":
    ensure  => file,
    mode    => '0750',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    require => Class['puppi'],
    content => template($templatefile),
    tag     => 'puppi_info',
  }
}
