#
# Class puppi::extra
# This class is autoincluded if you set $puppi_extra to something different than "no"
# Extra resources needed for full puppi functionality:
# curl, rsync, mailx, nagios plugins
#
# The classes below are based on the Example42 modules set
# adapt them as needed
#
class puppi::extra {

    package { curl: ensure => present, }
    include rsync::client
    include nagios::plugins
    include mailx

}
