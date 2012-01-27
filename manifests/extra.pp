#
# Class puppi::extra
# This class is autoincluded if $puppi_extra is not set to false
# Extra resources needed for full puppi functionality:
# curl, rsync, mailx, nagios plugins
#
# The classes below are based on the Example42 modules set
# adapt them as needed
#
class puppi::extra {

  package { 'curl': ensure => present, }
#    include rsync::client
#    include nagios::plugins
  include mailx

}
