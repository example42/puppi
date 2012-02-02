# Class: puppi
#
# This is Puppi. Include it and things happen.
#
# Puppi is a Puppet module that has 2 functions:
# - Make Application deployments easy
# - Transfer "Puppet Knowledge to the shell"
#
# == Parameters
# No parameters is needed.
# If you set the variable $$::puppi::extra to "yes" the puppi::extra class
# which delivers some Puppi's dependencies is automatically included
# (But you can include puppi::extra directly)
#
class puppi {

  require puppi::params

  # Main configuration file
  file { 'puppi.conf':
    ensure  => present,
    path    => "${puppi::params::basedir}/puppi.conf",
    mode    => '0644',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    content => template('puppi/puppi.conf.erb'),
    require => File['puppi_basedir'],
  }

  # The Puppi command
  file { 'puppi':
    ensure  => present,
    path    => '/usr/sbin/puppi',
    mode    => '0750',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    content => template('puppi/puppi.erb'),
    require => File['puppi_basedir'],
  }

  # Puppi common scripts
  file { 'puppi.scripts':
    ensure  => present,
    path    => "${puppi::params::scriptsdir}/",
    mode    => '0755',
    owner   => $puppi::params::configfile_owner,
    group   => $puppi::params::configfile_group,
    source  => "${puppi::params::general_base_source}/puppi/scripts/",
    recurse => true,
#   purge   => true,
    ignore  => '.svn',
    require => File['puppi_basedir'],
  }

  # Create Puppi workdirs
  include puppi::skel

  # Some extra packages we use in Puppi scripts
  # This class might conflict with your existing classes
  # Just be sure to provide the requested packages
  if $puppi::params::extra != 'no' { include puppi::extra }


  # To show some of the Puppi features some System-Wide general defines:

  # General system logs for puppi log
  include puppi::logs
  # General system infos for puppi info
  include puppi::infos
  # General system checks for puppi check
  include puppi::checks

}
