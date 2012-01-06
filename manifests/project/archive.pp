# Define puppi::project::archive
#
# This is a puppi deployment project to be used for archives like tarballs and zips
#
# == Parameters
# [*source*]
#   The full URL to be used to retrieve the archive. Format should be in URI standard (http:// file:// ssh:// svn://)  
#
# [*deploy_root*]
#   The destination directory where the files have to be deployed
#
# [*user*]
#   (Optional) - The user to be used for deploy operations 
#
# [*predeploy_customcommand*]
#   (Optional) - Full path with arguments of an eventual custom command to execute before the deploy.
#
# [*predeploy_user*]
#   (Optional) - The user to be used to execute the $predeploy_customcommand. By default is the same of $user
#
# [*predeploy_priority*]
#   (Optional) - The priority (execution sequence number) that defines the execution order ot the predeploy command.
#   Default: 39 (immediately before the copy of files on the deploy root)
#
# [*postdeploy_customcommand*]
#   (Optional) - Full path with arguments of an eventual custom command to execute after the deploy.
#
# [*postdeploy_user*]
#   (Optional) - The user to be used to execute the $postdeploy_customcommand. By default is the same of $user
#
# [*postdeploy_priority*]
#   (Optional) - The priority (execution sequence number) that defines the execution order ot the postdeploy command.
#   Default: 41 (immediately after the copy of files on the deploy root)
#
# [*disable_services*]
#   (Optional) - The names (space separated) of the services you might want to stop
#   during deploy. By default is blank. Example: "puppet monit apache"
#
# [*firewall_src_ip*]
#   (Optional) - The IP address of a loadbalancer you might want to block during deploy
#
# [*firewall_dst_port*]
#   (Optional) - The local port to block from the loadbalancer during deploy (Default all)
#
# [*firewall_delay*]
#   (Optional) - How many seconds to wait after firewalling loadbalancer. Default: 5
#   (Should be more than loadbalancer's check interval)
#
# [*report_email*]
#   (Optional) - The (space separated) email(s) to notify of deploy/rollback operations
#
# [*backup_rsync_options*]
#   (Optional) - The extra options to pass to rsync for backup operations. Use this, for example, to exclude 
#   directories that you don't want to archive.
#   IE: "--exclude .snapshot --exclude cache --exclude www/cache"
#
# [*backup_retention*]
#   (Optional) - Number of backup archives to keep on the filesystem. (Default 5). Lower if your backups 
#   are too large and may fill up the filesystem
#
# [*run_checks*]
#   (Optional) - If you want to run local puppi checks before and after the deploy procedure. Default: 'true'
#
# [*auto_deploy*]
#   (Optional) - If you want to automatically run a puppi deploy during Puppet run. Default: 'false'
#
# [*always_deploy*]
#   (Optional) - If you always deploy what has been downloaded. Default='true', if set to 'false' a checksum is made between the files
#   previously downloaded and the new files. If they are the same the deploy is not done.
#
define puppi::project::archive (
  $source,
  $deploy_root,
  $user                      = "root",
  $predeploy_customcommand   = "",
  $predeploy_user            = "",
  $predeploy_priority        = "39",
  $postdeploy_customcommand  = "",
  $postdeploy_user           = "",
  $postdeploy_priority       = "41",
  $disable_services          = "",
  $firewall_src_ip           = "",
  $firewall_dst_port         = "0",
  $firewall_delay            = "5",
  $report_email              = "",
  $backup_rsync_options      = "--exclude .snapshot",
  $backup_retention          = "5",
  $run_checks                = 'true',
  $always_deploy             = 'true',
  $auto_deploy               = 'false',
  $enable                    = 'true' ) {

  require puppi::params
  include puppi

  # Set values for internally used variables
  $real_run_checks = any2bool("$run_checks") # any2bool is provided by stdlib42
  $real_always_deploy = any2bool("$always_deploy")
  $real_auto_deploy = any2bool("$auto_deploy")
  $real_enable = any2bool("$enable")

  $real_predeploy_user = $predeploy_user ? {
    ''    => $user,
	default => $predeploy_user,
  }

  $real_postdeploy_user = $postdeploy_user ? {
    ''    => $user,
	default => $postdeploy_user,
  }

  $source_type = url_parse($source,filetype) # url_parse function is provided by stdlib42

  $real_source_type = $source_type ? {
    ".tar"     => "tar",
    ".tar.gz"  => "tarball",
    ".gz"      => "tarball",
    ".tgz"     => "tarball",
    ".zip"     => "zip",
  }

  # Create Project
  puppi::project { $name: enable => $enable }

  # Populate Project scripts for deploy
  puppi::deploy {
    "${name}-Retrieve_Archive":
       priority => "20" , command => "get_file.sh" , arguments => "-s $source -t $real_source_type -a $real_always_deploy" ,
       user => "root" , project => "$name" , enable => $enable ;
    "${name}-PreDeploy_Tar":
       priority => "25" , command => "predeploy.sh" ,
       user => "$root" , project => "$name" , enable => $enable;
    "${name}-Backup_existing_Files":
       priority => "30" , command => "archive.sh" , arguments => "-b $deploy_root -o '$backup_rsync_options' -n $backup_retention" ,
       user => "root" , project => "$name" , enable => $enable;
    "${name}-Deploy":
       priority => "40" , command => "deploy.sh" , arguments => "$deploy_root" ,
       user => "$user" , project => "$name" , enable => $enable;
  }

  puppi::rollback {
    "${name}-Recover_Files_To_Deploy":
       priority => "40" , command => "archive.sh" , arguments => "-r $deploy_root -o '$backup_rsync_options'" ,
       user => "$user" , project => "$name" , enable => $enable;
    "${name}-Run_POST-Checks":
       priority => "80" , command => "check_project.sh" , arguments => "$name" ,
       user => "root" , project => "$name" , enable => $enable ;
  }

  # Run PRE and POST automatic checks
  if ($real_run_checks == 'true') {
    puppi::deploy {
        "${name}-Run_PRE-Checks":
             priority => "10" , command => "check_project.sh" , arguments => "$name" ,
             user => "root" , project => "$name" , enable => $enable;
        "${name}-Run_POST-Checks":
             priority => "80" , command => "check_project.sh" , arguments => "$name" ,
             user => "root" , project => "$name" , enable => $enable ;
    }
    puppi::rollback {
        "${name}-Run_POST-Checks":
             priority => "80" , command => "check_project.sh" , arguments => "$name" ,
             user => "root" , project => "$name" , enable => $enable ;
    }
  }

  # Run predeploy custom script, if defined
  if ($predeploy_customcommand != "") {
    puppi::deploy {
      "${name}-Run_Custom_PreDeploy_Script":
         priority => "$predeploy_priority" , command => "execute.sh" , arguments => "$predeploy_customcommand" ,
         user => "$real_predeploy_user" , project => "$name" , enable => $enable;
    }
    puppi::rollback {
      "${name}-Run_Custom_PreDeploy_Script":
         priority => "$predeploy_priority" , command => "execute.sh" , arguments => "$predeploy_customcommand" ,
         user => "$real_predeploy_user" , project => "$name" , enable => $enable;
    }
  }

  # Run postdeploy custom script, if defined
  if ($postdeploy_customcommand != "") {
    puppi::deploy {
      "${name}-Run_Custom_PostDeploy_Script":
         priority => "$postdeploy_priority" , command => "execute.sh" , arguments => "$postdeploy_customcommand" ,
         user => "$real_postdeploy_user" , project => "$name" , enable => $enable;
    }
    puppi::rollback {
      "${name}-Run_Custom_PostDeploy_Script":
         priority => "$postdeploy_priority" , command => "execute.sh" , arguments => "$postdeploy_customcommand" ,
         user => "$real_postdeploy_user" , project => "$name" , enable => $enable;
    }
  }

  # Disable services that might start the AS during deploy
  if ($disable_services != "") {
    puppi::deploy {
      "${name}-Disable_extra_services":
         priority => "36" , command => "service.sh" , arguments => "stop $disable_services" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Enable_extra_services":
         priority => "44" , command => "service.sh" , arguments => "start $disable_services" ,
         user => "root" , project => "$name" , enable => $enable;
    }
    puppi::rollback {
      "${name}-Disable_extra_services":
         priority => "36" , command => "service.sh" , arguments => "stop $disable_services" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Enable_extra_services":
         priority => "44" , command => "service.sh" , arguments => "start $disable_services" ,
         user => "root" , project => "$name" , enable => $enable;
    }
  }

  # Exclusion from Load Balancer is managed only if $firewall_src_ip is set
  if ($firewall_src_ip != "") {
    puppi::deploy {
      "${name}-Load_Balancer_Block":
         priority => "35" , command => "firewall.sh" , arguments => "$firewall_src_ip $firewall_dst_port on" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Load_Balancer_Delay":
         priority => "36" , command => "wait.sh" , arguments => "-s $firewall_delay" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Load_Balancer_Unblock":
         priority => "45" , command => "firewall.sh" , arguments => "$firewall_src_ip $firewall_dst_port off" ,
         user => "root" , project => "$name" , enable => $enable;
    }
    puppi::rollback {
      "${name}-Load_Balancer_Block":
         priority => "35" , command => "firewall.sh" , arguments => "$firewall_src_ip $firewall_dst_port on" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Load_Balancer_Delay":
         priority => "36" , command => "wait.sh" , arguments => "-s $firewall_delay" ,
         user => "root" , project => "$name" , enable => $enable;
      "${name}-Load_Balancer_Unblock":
         priority => "45" , command => "firewall.sh" , arguments => "$firewall_src_ip $firewall_dst_port off" ,
         user => "root" , project => "$name" , enable => $enable;
    }
  }

  # Reporting
  if ($report_email != "") {
    puppi::report {
      "${name}-Mail_Notification":
         priority => "20" , command => "report_mail.sh" , arguments => "$report_email" ,
         user => "root" , project => "$name" , enable => $enable ;
    }
  }

  # Puppi auto_run
  if $real_auto_run != "ff" {
    puppi::run { "$name": }
  }

}
