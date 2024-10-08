# = Define puppi::project::files
#
# This is a sample define to build a puppi project for the deploy of
# one or more files based on a provided list containing, one per line,
# the full path of the files to deploy.
# The place (url) from where to get the files is defined by the
# $source_baseurl variable.
# You can strip out some beginning chars from each line with the
# (optional) $files_prefix variable.
# Files are then copied to the $deploy_root you define.
#
# Many different variables are optional in order to adapt the define
# to different cases and needs, if you still need to customize it,
# you can clone this puppi::project into another file and change the
# define name.
#
# == Variables:
#
# [*source*]
#   The full URL of the main file to retrieve.
#   Format should be in URI standard (http:// file:// ssh:// rsync://).
#
# [*deploy_root*]
#   The destination directory where the retrieved file(s) are deployed.
#
# [*source_baseurl*]
#   The full URL, in URI standard format, to prepend to the entries i
#   the files list in order to retrieve the relative files.
#
# [*init_source*]
#   (Optional) - The full URL to be used to retrieve, for the first time,
#   the project files. They are copied directly to the $deploy_root
#   Format should be in URI standard (http:// file:// ssh:// svn://).
#
# [*prefix*]
#   (Optional) - The prefix that might be present in the filelist to
#   define custom  metadata
#
# [*files_prefix*]
#   (Optional) The prefix to remove from the list entries in order to
#   determine the files path on the deploy_root
#   We suggest to place in the files list just the deploy_root relative
#   paths of the files, and in this case the $files_prefix is null
#
# [*user*]
#   (Optional) - The user to be used for deploy operations.
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
# [*init_script*]
#   (Optional - Obsolete) - The name (ex: tomcat) of the init script of your
#   Application server. If you define it, the AS is stopped and then started
#   during deploy. This option is deprecated, you can use $disable_services
#   for the same functionality
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
#
# [*backup_retention*]
#   (Optional) - Number of backup archives to keep. (Default 5).
#   Lower the default value if your backups are too large and may fill up the
#   filesystem.
#
# [*run_checks*]
#   (Optional) - If you want to run local puppi checks before and after the
#   deploy procedure. Default: "true".
#
# [*auto_deploy*]
#   (Optional) - If you want to automatically run this puppi deploy when
#   Puppet runs. Default: 'false'
#
define puppi::project::files (
  String $source,
  String $source_baseurl,
  String $deploy_root,
  String $init_source              = '',
  String $files_prefix             = '',
  String $prefix                   = '',
  String $user                     = 'root',
  String $predeploy_customcommand  = '',
  String $predeploy_user           = '',
  Variant[String,Integer] $predeploy_priority  = '39',
  String $postdeploy_customcommand = '',
  String $postdeploy_user          = '',
  Variant[String,Integer] $postdeploy_priority = '41',
  String $init_script              = '',
  String $disable_services         = '',
  String $firewall_src_ip          = '',
  Variant[String,Integer] $firewall_dst_port   = '0',
  Variant[String,Integer] $firewall_delay      = '1',
  String $report_email             = '',
  String $backup_rsync_options     = '--exclude .snapshot',
  Variant[String,Integer] $backup_retention    = '5',
  Boolean $run_checks               = true,
  Boolean $auto_deploy              = false,
  Variant[Boolean,String] $enable   = true,
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

  $bool_run_checks = any2bool($run_checks)
  $bool_auto_deploy = any2bool($auto_deploy)

### CREATE PROJECT
  puppi::project { $name:
    source                   => $source,
    deploy_root              => $deploy_root,
    user                     => $user,
    predeploy_customcommand  => $predeploy_customcommand,
    postdeploy_customcommand => $postdeploy_customcommand,
    init_script              => $init_script,
    disable_services         => $disable_services,
    firewall_src_ip          => $firewall_src_ip,
    firewall_dst_port        => $firewall_dst_port,
    report_email             => $report_email,
    enable                   => $enable ,
    files_prefix             => $files_prefix,
    source_baseurl           => $source_baseurl,
  }

### INIT SEQUENCE
  if ($init_source != '') {
    puppi::initialize { "${name}-Deploy_Files":
      priority  => '40' ,
      command   => 'get_file.sh' ,
      arguments => "-s ${init_source} -d ${deploy_root}" ,
      user      => $user ,
      project   => $name ,
      enable    => $enable ,
    }
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

  puppi::deploy { "${name}-Retrieve_File_List":
    priority  => '20' ,
    command   => 'get_file.sh' ,
    arguments => "-s ${source} -t list" ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  $args_prefix = $prefix ? {
    ''      => '',
    default => "-m ${prefix}",
  }

  puppi::deploy { "${name}-Extract_File_Metadata":
    priority  => '22' ,
    command   => 'get_metadata.sh' ,
    arguments => $args_prefix,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  puppi::deploy { "${name}-Clean_File_List":
    priority  => '24' ,
    command   => 'clean_filelist.sh' ,
    arguments => $files_prefix ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  puppi::deploy { "${name}-Retrieve_Files":
    priority  => '25' ,
    command   => 'get_filesfromlist.sh' ,
    arguments => $source_baseurl ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
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

  puppi::deploy { "${name}-Backup_existing_Files":
    priority  => '30' ,
    command   => 'archive.sh' ,
    arguments => "-b ${deploy_root} -o '${backup_rsync_options}' -n ${backup_retention}" ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
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

  if ($init_script != '') {
    puppi::deploy { "${name}-Service_stop":
      priority  => '38' ,
      command   => 'service.sh' ,
      arguments => "stop ${init_script}" ,
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
  puppi::deploy { "${name}-Deploy":
    priority  => '40' ,
    command   => 'deploy.sh' ,
    arguments => $deploy_root ,
    user      => $user ,
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

  if ($init_script != '') {
    puppi::deploy { "${name}-Service_start":
      priority  => '42' ,
      command   => 'service.sh' ,
      arguments => "start ${init_script}" ,
      user      => 'root',
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

### ROLLBACK SEQUENCE

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
      priority  => '36' ,
      command   => 'service.sh' ,
      arguments => "stop ${disable_services}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($init_script != '') {
    puppi::rollback { "${name}-Service_stop":
      priority  => '38' ,
      command   => 'service.sh' ,
      arguments => "stop ${init_script}" ,
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

  puppi::rollback { "${name}-Recover_Files_To_Deploy":
    priority  => '40' ,
    command   => 'archive.sh' ,
    arguments => "-r ${deploy_root} -o '${backup_rsync_options}'" ,
    user      => $user ,
    project   => $name ,
    enable    => $enable ,
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

  if ($init_script != '') {
    puppi::rollback { "${name}-Service_start":
      priority  => '42' ,
      command   => 'service.sh' ,
      arguments => "start ${init_script}" ,
      user      => 'root',
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
