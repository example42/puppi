# = Define puppi::project::archive
#
# This is a puppi deployment project to be used for archives
# like tarballs and zips
#
#
# It uses different "core" defines (puppi::project, puppi:deploy (many),
# puppi::rollback (many)) to build a full featured template project for
# automatic deployments.
# If you need to customize it, either change the template defined here or
# build up your own custom ones.
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
# [*clean_deploy*]
#   (Optional, default false) - If during the deploy procedure, all the
#   existing files that are not on the source have to be deleted.
#   (When true, a --delete option is added to the rsync command)
#   Do not set to true if source files are incremental.
#
# [*backup_enable*]
#   (Optional, default true) - If the backup of files in the deploy dir
#   is done (before deploy). If set to false, rollback is disabled.
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
# [*always_deploy*]
#   (Optional) - If you always deploy what has been downloaded. Default="yes",
#   if set to "no" a checksum is made between the files previously downloaded
#   and the new files. If they are the same the deploy is not done.
#
# [*auto_deploy*]
#   (Optional) - If you want to automatically run this puppi deploy when
#   Puppet runs. Default: 'false'
#
define puppi::project::archive (
  String $source,
  String $deploy_root,
  String $user                     = 'root',
  String $predeploy_customcommand  = '',
  String $predeploy_user           = '',
  String $predeploy_priority       = '39',
  String $postdeploy_customcommand = '',
  String $postdeploy_user          = '',
  Variant[String,Integer] $postdeploy_priority = '41',
  String $disable_services         = '',
  String $firewall_src_ip          = '',
  Variant[String,Integer] $firewall_dst_port = '0',
  Variant[String,Integer] $firewall_delay    = '1',
  String $report_email             = '',
  Boolean $clean_deploy             = false,
  Boolean $backup_enable            = true,
  String $backup_rsync_options       = '--exclude .snapshot',
  Variant[String,Integer] $backup_retention  = '5',
  Boolean $run_checks               = true,
  Boolean $always_deploy            = true,
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

  $real_always_deploy = any2bool($always_deploy) ? {
    false   => 'no',
    true    => 'yes',
  }

  $bool_run_checks = any2bool($run_checks)
  $bool_clean_deploy = any2bool($clean_deploy)
  $bool_backup_enable = any2bool($backup_enable)
  $bool_auto_deploy = any2bool($auto_deploy)

  $source_type = url_parse($source,filetype)

  $real_source_type = $source_type ? {
    '.tar'     => 'tar',
    '.tar.gz'  => 'tarball',
    '.gz'      => 'tarball',
    '.tgz'     => 'tarball',
    '.zip'     => 'zip',
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

  # Here source file is retrieved
  puppi::deploy { "${name}-Retrieve_Archive":
    priority  => '20' ,
    command   => 'get_file.sh' ,
    arguments => "-s ${source} -t ${real_source_type} -a ${real_always_deploy}" ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  puppi::deploy { "${name}-PreDeploy_Archive":
    priority => '25' ,
    command  => 'predeploy.sh' ,
    user     => 'root' ,
    project  => $name ,
    enable   => $enable ,
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

  if ($bool_backup_enable == true) {
    puppi::deploy { "${name}-Backup_existing_Files":
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
  puppi::deploy { "${name}-Deploy":
    priority  => '40' ,
    command   => 'deploy_files.sh' ,
    arguments => "-d ${deploy_root} -c ${bool_clean_deploy}",
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

  if ($bool_backup_enable == true) {
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
