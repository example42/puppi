# == Define puppi::project::hg
#
# This is a shortcut define to build a puppi project for the deploy of
# file from a mercurial repo.
# It uses different "core" defines (puppi::project, puppi:deploy (many),
# puppi::rollback (many)) to build a full featured template project for
# automatic deployments.
# If you need to customize it, either change the template defined here or
# build up your own custom ones.
#
# == Variables:
#
# [*source*]
#   The full URL of the mercurial repo to retrieve.
#   Format should be in mercurial friendly standard (http:// ssh:// ..).
#
# [*deploy_root*]
#   The destination directory where the retrieved file(s) are deployed.
#
# [*install_hg*]
#   If the mercurial package has to be installed. Default true.
#   Set to false if you install mercurial via other modules and have resource
#   conflicts.
#
# [*tag*]
#   (Optional) - A specific tag you may want to deploy. Default undefined
#   You can override the default value via command-line with:
#   puppi deploy myapp -o "tag=release"
#
# [*branch*]
#   (Optional) - A specific branch you may want to deploy. Default: master
#   You can override the default value via command-line with:
#   puppi deploy myapp -o "branch=devel"
#
# [*commit*]
#   (Optional) - A specific commit you may want to use. Default undefined
#   You can override the default value via command-line with:
#   puppi deploy myapp -o "commit=1061cb731bc75a1188b58b889b74ce1505ccb412"
#
# [*keep_hgdata*]
#   (Optional) - Define if you want to keep mercurial metadata directory (.hg)
#   in the deploy root. According to this value backup and rollback
#   operations change (with keep_hgdata set to true no real backups are done
#   and operations are made on the mercurial tree, if set to false, file are copied
#   and the $backup_* options used. Default is true
#
# [*verbose*]
#   (Optional) - If you want to see verbose mercurial output (file names) during
#   the deploy. Default is true.
#
# [*user*]
#   (Optional) - The user to be used for deploy operations.
#   If different from root (default) it must have write permissions on
#   the $deploy_root dir.
#
# [*predeploy_customcommand*]
#   (Optional) -  Full path with arguments of an eventual custom command to
#   execute before the deploy. The command is executed as $predeploy_user.
#
# [*predeploy_user*]
#   (Optional) - The user to be used to execute the $predeploy_customcommand.
#   By default is the same of $user.
#
# [*predeploy_priority*]
#   (Optional) - The priority (execution sequence number) that defines when,
#   during the deploy procedure, the $predeploy_customcommand is executed
#   Default: 39 (immediately before the copy of files on the deploy root).
#
# [*postdeploy_customcommand*]
#   (Optional) -  Full path with arguments of an eventual custom command to
#   execute after the deploy. The command is executed as $postdeploy_user.
#
# [*postdeploy_user*]
#   (Optional) - The user to be used to execute the $postdeploy_customcommand.
#   By default is the same of $user.
#
# [*postdeploy_priority*]
#   (Optional) - The priority (execution sequence number) that defines when,
#   during the deploy procedure, the $postdeploy_customcommand is executed
#   Default: 41 (immediately after the copy of files on the deploy root).
#
# [*disable_services*]
#   (Optional) - The names (space separated) of the services you might want to
#   stop during deploy. By default is blank. Example: "apache puppet monit".
#
# [*firewall_src_ip*]
#   (Optional) - The IP address of a loadbalancer you might want to block out
#   during a deploy.
#
# [*firewall_dst_port*]
#   (Optional) - The local port to block from the loadbalancer during deploy
#   (Default all).
#
# [*firewall_delay*]
#   (Optional) - A delay time in seconds to wait after the block of
#   $firewall_src_ip. Should be at least as long as the loadbalancer check
#   interval for the services stopped during deploy (Default: 1).
#
# [*report_email*]
#   (Optional) - The (space separated) email(s) to notify of deploy/rollback
#   operations. If none is specified, no email is sent.
#
# [*backup_rsync_options*]
#   (Optional) - The extra options to pass to rsync for backup operations. Use
#   it, for example, to exclude directories that you don't want to archive.
#   IE: "--exclude .snapshot --exclude cache --exclude www/cache".
#   This option is used when $keep_hgmeta is set to false
#
# [*backup_retention*]
#   (Optional) - Number of backup archives to keep. (Default 5).
#   Lower the default value if your backups are too large and may fill up the
#   filesystem.
#   This option is used when $keep_hgmeta is set to false
#
# [*run_checks*]
#   (Optional) - If you want to run local puppi checks before and after the
#   deploy procedure. Default: "true".
#
# [*auto_deploy*]
#   (Optional) - If you want to automatically run this puppi deploy when
#   Puppet runs. Default: 'false'
#
define puppi::project::hg (
  String $source,
  String $deploy_root,
  Boolean $install_hg              = true,
  String $tag                      = 'undefined',
  String $branch                   = 'default',
  String $commit                   = 'undefined',
  Boolean $keep_hgdata             = true,
  Boolean$verbose                  = true,
  String $user                     = 'root',
  String $predeploy_customcommand  = '',
  String $predeploy_user           = '',
  Variant[String,Integer] $predeploy_priority  = '39',
  String $postdeploy_customcommand = '',
  String $postdeploy_user          = '',
  Variant[String,Integer] $postdeploy_priority = '41',
  String $disable_services         = '',
  String $firewall_src_ip          = '',
  Variant[String,Integer] $firewall_dst_port   = '0',
  Variant[String,Integer] $firewall_delay      = '1',
  String $report_email             = '',
  String $backup_rsync_options     = '--exclude .snapshot',
  Variant[String,Integer] $backup_retention    = '5',
  Boolean $run_checks              = true,
  Boolean $auto_deploy             = false,
  Variant[Boolean,String] $enable  = true,
) {
  require puppi
  require puppi::params

  # Set default values
  $predeploy_real_user = $predeploy_user ? {
    ''      => $user,
    default => $predeploy_user,
  }

  $postdeploy_real_user = $postdeploy_user ? {
    ''      => $user,
    default => $postdeploy_user,
  }

  $bool_install_hg = any2bool($install_hg)
  $bool_keep_hgdata = any2bool($keep_hgdata)
  $bool_verbose = any2bool($verbose)
  $bool_run_checks = any2bool($run_checks)
  $bool_auto_deploy = any2bool($auto_deploy)

### INSTALL HG
  if ($bool_install_hg == true) {
    if ! defined(Package['mercurial']) { package { 'mercurial': ensure => installed } }
  }

### CREATE PROJECT
  puppi::project { $name:
    source                   => $source,
    deploy_root              => $deploy_root,
    user                     => $user,
    predeploy_customcommand  => $predeploy_customcommand,
    postdeploy_customcommand => $postdeploy_customcommand,
    disable_services         => $disable_services,
    firewall_src_ip          => $firewall_src_ip,
    firewall_dst_port        => $firewall_dst_port,
    report_email             => $report_email,
    enable                   => $enable ,
  }

### DEPLOY SEQUENCE
  if ($bool_run_checks == true) {
    puppi::deploy { "${name}-Run_PRE-Checks":
      priority  => '10' ,
      command   => 'check_project.sh' ,
      arguments => $name ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($firewall_src_ip != '') {
    puppi::deploy { "${name}-Load_Balancer_Block":
      priority  => '25' ,
      command   => 'firewall.sh' ,
      arguments => "${firewall_src_ip} ${firewall_dst_port} on ${firewall_delay}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_keep_hgdata == true) {
    puppi::deploy { "${name}-Backup_existing_data":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${deploy_root} -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($disable_services != '') {
    puppi::deploy { "${name}-Disable_extra_services":
      priority  => '36' ,
      command   => 'service.sh' ,
      arguments => "stop ${disable_services}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($predeploy_customcommand != '') {
    puppi::deploy { "${name}-Run_Custom_PreDeploy_Script":
      priority  => $predeploy_priority ,
      command   => 'execute.sh' ,
      arguments => $predeploy_customcommand ,
      user      => $predeploy_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  # Here is done the deploy on $deploy_root
  puppi::deploy { "${name}-Deploy_Files":
    priority  => '40' ,
    command   => 'hg.sh' ,
    arguments => "-a deploy -s ${source} -d ${deploy_root} -u ${user} -t ${tag} -b ${branch} -c ${commit} -v ${bool_verbose} -k ${bool_keep_hgdata}" , # lint:ignore:140chars
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  if ($postdeploy_customcommand != '') {
    puppi::deploy { "${name}-Run_Custom_PostDeploy_Script":
      priority  => $postdeploy_priority ,
      command   => 'execute.sh' ,
      arguments => $postdeploy_customcommand ,
      user      => $postdeploy_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($disable_services != '') {
    puppi::deploy { "${name}-Enable_extra_services":
      priority  => '44' ,
      command   => 'service.sh' ,
      arguments => "start ${disable_services}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($firewall_src_ip != '') {
    puppi::deploy { "${name}-Load_Balancer_Unblock":
      priority  => '46' ,
      command   => 'firewall.sh' ,
      arguments => "${firewall_src_ip} ${firewall_dst_port} off 0" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_run_checks == true) {
    puppi::deploy { "${name}-Run_POST-Checks":
      priority  => '80' ,
      command   => 'check_project.sh' ,
      arguments => $name ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

### ROLLBACK PROCEDURE

  if ($firewall_src_ip != '') {
    puppi::rollback { "${name}-Load_Balancer_Block":
      priority  => '25' ,
      command   => 'firewall.sh' ,
      arguments => "${firewall_src_ip} ${firewall_dst_port} on ${firewall_delay}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($disable_services != '') {
    puppi::rollback { "${name}-Disable_extra_services":
      priority  => '37' ,
      command   => 'service.sh' ,
      arguments => "stop ${disable_services}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($predeploy_customcommand != '') {
    puppi::rollback { "${name}-Run_Custom_PreDeploy_Script":
      priority  => $predeploy_priority ,
      command   => 'execute.sh' ,
      arguments => $predeploy_customcommand ,
      user      => $predeploy_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_keep_hgdata == true) {
    puppi::rollback { "${name}-Recover_Files_To_Deploy":
      priority  => '40' ,
      command   => 'archive.sh' ,
      arguments => "-r ${deploy_root} -o '${backup_rsync_options}'" ,
      user      => $user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_keep_hgdata != true) {
    puppi::rollback { "${name}-Rollback_Files":
      priority  => '40' ,
      command   => 'hg.sh' ,
      arguments => "-a rollback -s ${source} -d ${deploy_root} -t ${tag} -b ${branch} -c ${commit} -v ${bool_verbose} -k ${bool_keep_hgdata}" , # lint:ignore:140chars
      user      => $user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($postdeploy_customcommand != '') {
    puppi::rollback { "${name}-Run_Custom_PostDeploy_Script":
      priority  => $postdeploy_priority ,
      command   => 'execute.sh' ,
      arguments => $postdeploy_customcommand ,
      user      => $postdeploy_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($disable_services != '') {
    puppi::rollback { "${name}-Enable_extra_services":
      priority  => '44' ,
      command   => 'service.sh' ,
      arguments => "start ${disable_services}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($firewall_src_ip != '') {
    puppi::rollback { "${name}-Load_Balancer_Unblock":
      priority  => '46' ,
      command   => 'firewall.sh' ,
      arguments => "${firewall_src_ip} ${firewall_dst_port} off 0" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_run_checks == true) {
    puppi::rollback { "${name}-Run_POST-Checks":
      priority  => '80' ,
      command   => 'check_project.sh' ,
      arguments => $name ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

### REPORTING

  if ($report_email != '') {
    puppi::report { "${name}-Mail_Notification":
      priority  => '20' ,
      command   => 'report_mail.sh' ,
      arguments => $report_email ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

### AUTO DEPLOY DURING PUPPET RUN
  if ($bool_auto_deploy == true) {
    puppi::run { $name: }
  }
}
