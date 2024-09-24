# Class: puppi::params
#
# Sets internal variables and defaults for puppi module
#
class puppi::params {
## PARAMETERS
  $version              = '1'
  $install_dependencies = true
  $template             = 'puppi/puppi.conf.erb'
  $helpers_class        = 'puppi::helpers'
  $logs_retention_days  = '30'
  $extra_class          = 'puppi::extras'

## INTERNALVARS
  $basedir     = '/etc/puppi'
  $scriptsdir  = '/etc/puppi/scripts'
  $checksdir   = '/etc/puppi/checks'
  $logsdir     = '/etc/puppi/logs'
  $infodir     = '/etc/puppi/info'
  $tododir     = '/etc/puppi/todo'
  $projectsdir = '/etc/puppi/projects'
  $datadir     = '/etc/puppi/data'
  $helpersdir  = '/etc/puppi/helpers'
  $libdir      = '/var/lib/puppi'
  $readmedir   = '/var/lib/puppi/readme'
  $logdir      = '/var/log/puppi'
  $archivedir  = '/var/lib/puppi/archive'
  $workdir     = '/tmp/puppi'
  $configfile_mode  = '0644'
  $configfile_owner = 'root'
  $configfile_group = 'root'

# External tools
# Directory where are placed the checks scripts
# By default we use Nagios plugins
  $checkpluginsdir = $facts['os']['name'] ? {
    /(?i:RedHat|CentOS|Scientific|Amazon|Linux)/ => $facts['os']['architecture'] ? {
      'x86_64'  => '/usr/lib64/nagios/plugins',
      default => '/usr/lib/nagios/plugins',
    },
    default                    => '/usr/lib/nagios/plugins',
  }

  $package_nagiosplugins = $facts['os']['name'] ? {
    /(?i:RedHat|CentOS|Scientific|Amazon|Linux|Fedora)/ => 'nagios-plugins-all',
    /(?i:Debian|Ubuntu|Mint)/ => 'monitoring-plugins',
    default                   => 'nagios-plugins',
  }

  $package_mail = $facts['os']['name'] ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'bsd-mailx',
    default           => 'mailx',
  }

  $ntp = 'pool.ntp.org'

# Mcollective paths
# TODO: Add Paths for Puppet Enterprise:
# /opt/puppet/libexec/mcollective/mcollective/
  $mcollective = $facts['os']['name'] ? {
    'debian'  => '/usr/share/mcollective/plugins/mcollective',
    'ubuntu'  => '/usr/share/mcollective/plugins/mcollective',
    'centos'  => '/usr/libexec/mcollective/mcollective',
    'redhat'  => '/usr/libexec/mcollective/mcollective',
    default => '/usr/libexec/mcollective/mcollective',
  }

  $mcollective_user = 'root'
  $mcollective_group = 'root'

# Commands used in puppi info templates
  $info_package_query = $facts['os']['name'] ? {
    /(?i:RedHat|CentOS|Scientific|Amazon|Linux)/ => 'rpm -qi',
    /(?i:Ubuntu|Debian|Mint)/          => 'dpkg -s',
    default                    => 'echo',
  }
  $info_package_list = $facts['os']['name'] ? {
    /(?i:RedHat|CentOS|Scientific|Amazon|Linux)/ => 'rpm -ql',
    /(?i:Ubuntu|Debian|Mint)/                    => 'dpkg -L',
    default                                      => 'echo',
  }
  $info_service_check = $facts['os']['name'] ? {
    default => '/etc/init.d/',
  }
}
