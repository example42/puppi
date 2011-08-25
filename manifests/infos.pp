# Class puppi::infos
# Creates default system-wide info run to be used by the puppi info command
# This class is going to be filled with further info and support for different OSes
# Currently is based on Linux OS
#
class puppi::infos {

    puppi::info { "network":
        description => "Network settings and stats" ,
        run         => $operatingsystem ? {
            Solaris => [ "ifconfig -a" , "netstat -nr" , "cat /etc/resolv.conf" , "arp -an" , "netstat -na" ],
            default => [ "ifconfig" , "route -n" , "cat /etc/resolv.conf" , "arp -an" , "netstat -natup | grep LISTEN" ],
        }
    }

    puppi::info { "users":
        description => "Users and logins information" ,
        run         => $operatingsystem ? { 
            Solaris => [ "who" , "last" ],
            default => [ "who" , "last" , "lastlog | grep -v 'Never logged in'" ],
        }
    }

    puppi::info { "perf":
        description => "System performances and resources utilization" ,
        run         => $operatingsystem ? { 
            Solaris => [ "uptime" , "vmstat 1 5" ],
            default => [ "uptime" , "free" , "vmstat 1 5" ],
        }  
    }

    puppi::info { "disks":
        description => "Disks and filesystem information" ,
        run         => $operatingsystem ? {  
            Solaris => [ "df -h" , "mount" ],
            default => [ "df -h" , "mount" , "fdisk -l" ],
        }   
    }

    puppi::info { "hardware":
        description => "Hardware information" ,
        run         => $operatingsystem ? {
            Solaris => [ "find /devices/" ],
            default => [ "lspci" , "cat /proc/cpuinfo" ],
        }   
    }

    puppi::info { "packages":
        description => "Packages information" ,
        run         => $operatingsystem ? { 
            /(CentOS|RedHat|Scientific|centos|redhat|scientific)/ => [ "yum repolist" , "rpm -qa" ] ,
            /(Ubuntu|Debian|ubuntu|debian)/ => [ "apt-config dump" , "apt-cache stats" , "apt-key list" , "dpkg -l" ],
            /(Solaris)/ => [ "pkginfo" ],
            /(Archlinux)/ => [ "pacman -Qet" ],
        },
    }

    puppi::info::module { "puppi":
        configfile => "${puppi::params::basedir}/puppi.conf",
        configdir => "${puppi::params::basedir}",
        pidfile => "${puppi::params::pidfile}",
        datadir => "${puppi::params::archivedir}",
        logdir => "${puppi::params::logdir}",
        description => "What Puppet knows about puppi" ,
        verbose => "yes",
        # run => "ls -lR ${puppi::params::logdir}/puppi-data/",
    }

}
