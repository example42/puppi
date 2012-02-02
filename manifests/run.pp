# Define puppi::run
#
# This define triggers a puppi deploy run directly during Puppet
# execution. It can be used to automate FIRST TIME applications
# deployments directly during the first Puppet execution
#
# == Variables
#
# [*name*]
#   The title/name you use has to be the name of an existing puppi::project
#   procedure define
#
# == Usage
# Basic Usage:
# puppi::run { "myapp": }
#
define puppi::run (
  $project = '' ) {

  require puppi::params

  # This is a workaround to be avoid automatic puppi deploy at first Puppet run
  # when we are not sure that the puppi deploy project has beed correctly
  # setup.
  # Sadly a better solution hasn't been found
  exec { "Run_Puppi_${name}_FirstTimeLock":
    command     => "touch ${puppi::params::archivedir}/puppirun_${name}_lock",
    path        => '/bin:/sbin:/usr/sbin:/usr/bin',
    refreshonly => true,
  }

  exec { "Run_Puppi_${name}":
    command => "puppi deploy ${name} && touch ${puppi::params::archivedir}/puppirun_${name}",
    path    => '/bin:/sbin:/usr/sbin:/usr/bin',
    onlyif  => "rm ${puppi::params::archivedir}/puppirun_${name}_lock",
    creates => "${puppi::params::archivedir}/puppirun_${name}",
    before  => "Run_Puppi_${name}_FirstTimeLock",
  }

}
