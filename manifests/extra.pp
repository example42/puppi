#
# Class puppi::extra
# Extra resources needed for full puppi functionality
# You might have them defined somewhere else. In this case do not include this class in init.pp
#
class puppi::extra {

    package { curl: ensure => present, }
#    include rsync::client
    include mailx

}
