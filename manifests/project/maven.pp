# = Define puppi::project::maven
#
# This is a shortcut define to build a puppi project for the
# deploy of war and tar files generated via Maven and published on
# a repository like Sonar.
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
#   The full URL of the maven-metadata.xml file to retrieve.
#   Format should be in URI standard (http:// file:// ssh:// rsync://).
#
# [*http_password*]
#   The http_password to use for authentication to the source in case of http.
#
# [*http_user*]
#   The http_user to use for authentication to the source in case of http.
#
# [*artifact_type*]
#   The artifact_type to parse the maven-metadata.xml. Either "release", "latest" or
#   a specific version (e.g. "2.5.0")
#   Default is "release". With artifactory, don't use the
#   "Maven Snapshot Version Behavior" "unique" for your repository.
#
# [*deploy_root*]
#   The destination directory where file(s) are deployed.
#
# [*user*]
#   (Optional) - The user to be used for deploy operations.
#
# [*war_suffix*]
#   (Optional) - The suffix (Maven qualifier) that might be appended to the war
#
# [*zip_root*]
#   (Optional) - The destination directory where the zip is unpacked
#
# [*zip_user*]
#   (Optional) - The user to be used for deploy operations of the zip
#
# [*zip_suffix*]
#   (Optional) - The suffix (Maven qualifier) that might be appended to the zip
#
# [*jar_root*]
#   (Optional) - The destination directory where the jar is copied.
#   If set a jar file is searched in Maven
#
# [*jar_user*]
#   (Optional) - The user to be used for deploy operations of the jar
#   (owner of the files deployed in $jar_root)
#
# [*jar_suffix*]
#   (Optional) - The suffix (Maven qualifier) that might be appended to the jar
#
# [*document_root*]
#   (Optional) - The destination directory where the eventual tarball generated
#   via Maven containing static files ("src tar") is unpacked
#
# [*document_suffix*]
#   (Optional) - The suffix (Maven qualifier) that might be appended to the
#   static files tarballs ("src tar")
#
# [*document_init_source*]
#   (Optional) - The full URL to be used to retrieve, for the first time, the
#    project files present in the source tarball. They are copied to the
#    $document_root. Format should be in URI standard (http:// file:// ...)
#
# [*document_user*]
#   (Optional) - The user to be used for deploy operations of the tarball
#   (owner of the files in $document_root)
#
# [*config_root*]
#   (Optional) - The destination directory where the cfg tar is unpacked
#
# [*config_suffix*]
#   (Optional) - The suffix (Maven qualifier) that might be appended to
#   configuration tarballs ("cfg tar")
#
# [*config_init_source*]
#   (Optional) - The full URL to be used to retrieve, for the first time, the
#   project files present in the cfg tar. They are copied to the $config_root.
#   Format should be in URI standard (http:// file:// ssh:// svn://)
#
# [*config_user*]
#   (Optional) - The user to be used for deploy operations of cfg tar
#   (owner of the files in $config_root)
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
# [*report_mongo*]
#   (Optional) - A mongourl with optional user:password to report to. Append the
#   database with a slash ("mongodb://user:password@mymongo.mydomain.com/theNameOfDb")
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
# [*check_deploy*]
#   (Optional) - Checks if the war is deployed (Default yes). Set to no if
#   you deploy on Jboss or the deployed dir is different for the war filename
#
# [*auto_deploy*]
#   (Optional) - If you want to automatically run this puppi deploy when
#   Puppet runs. Default: 'false'
#
define puppi::project::maven (
  String $source,
  String $http_user                = '',
  String $http_password            = '',
  String $artifact_type            = 'release',
  String $deploy_root              = '',
  String $user                     = 'root',
  String $war_suffix               = 'suffixnotset',
  String $zip_root                 = '',
  String $zip_user                 = '',
  String $zip_suffix               = 'suffixnotset',
  String $jar_root                 = '',
  String $jar_user                 = '',
  String $jar_suffix               = 'suffixnotset',
  String $document_root            = '',
  String $document_user            = '',
  String $document_suffix          = 'suffixnotset',
  String $document_init_source     = '',
  String $config_root              = '',
  String $config_user              = '',
  String $config_suffix            = 'suffixnotset',
  String $config_init_source       = '',
  String $predeploy_customcommand  = '',
  String $predeploy_user           = '',
  Variant[String,Integer] $predeploy_priority       = '39',
  String $postdeploy_customcommand = '',
  String $postdeploy_user          = '',
  Variant[String,Integer] $postdeploy_priority      = '41',
  String $init_script              = '',
  String $disable_services         = '',
  String $firewall_src_ip          = '',
  Variant[String,Integer] $firewall_dst_port        = '0',
  Variant[String,Integer] $firewall_delay           = '1',
  String $report_email             = '',
  String $report_mongo             = '',
  String $backup_rsync_options     = '--exclude .snapshot',
  Variant[String,Integer] $backup_retention         = '5',
  Boolean $run_checks               = true,
  Boolean $always_deploy            = true,
  Boolean $check_deploy             = true,
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

  $config_real_user = $config_user ? {
    ''      => $user,
    default => $config_user,
  }

  $document_real_user = $document_user ? {
    ''      => $user,
    default => $document_user,
  }

  $jar_real_user = $jar_user ? {
    ''      => $user,
    default => $jar_user,
  }

  $zip_real_user = $zip_user ? {
    ''      => $user,
    default => $zip_user,
  }

  $real_always_deploy = any2bool($always_deploy) ? {
    false   => 'no',
    true    => 'yes',
  }

  $bool_run_checks = any2bool($run_checks)
  $bool_check_deploy = any2bool($check_deploy)
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
    enable                   => $enable,
    document_root            => $document_root,
    config_root              => $config_root,
  }

### INIT SEQUENCE
  if ($document_init_source != '') {
    puppi::initialize { "${name}-Deploy_Files":
      priority  => '40' ,
      command   => 'get_file.sh' ,
      arguments => "-s ${document_init_source} -d ${deploy_root}" ,
      user      => $document_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($config_init_source != '') {
    puppi::initialize { "${name}-Deploy_CFG_Files":
      priority  => '40' ,
      command   => 'get_file.sh' ,
      arguments => "-s ${config_init_source} -d ${deploy_root}" ,
      user      => $config_real_user ,
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

  $metadata_arguments = $http_password ? {
    '' => "-s ${source}/maven-metadata.xml -t maven-metadata -a ${real_always_deploy}",
    default => "-s ${source}/maven-metadata.xml -t maven-metadata -a ${real_always_deploy} -u ${http_user} -p ${http_password}"
  }

  puppi::deploy { "${name}-Get_Maven_Metadata_File":
    priority  => '20' ,
    command   => 'get_file.sh' ,
    arguments => $metadata_arguments,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  puppi::deploy { "${name}-Extract_Maven_Metadata":
    priority  => '22' ,
    command   => 'get_metadata.sh' ,
    arguments => "-m ${document_suffix} -mc ${config_suffix} -mj ${jar_suffix} -mw ${war_suffix} -mz ${zip_suffix} -at ${artifact_type}" ,
    user      => 'root' ,
    project   => $name ,
    enable    => $enable ,
  }

  # Files retrieval
  if ($deploy_root != '') {
    $war_arguments = $http_password ? {
      '' => "${source} warfile",
      default => "-u ${http_user} -p ${http_password} ${source} warfile"
    }

    puppi::deploy { "${name}-Get_Maven_Files_WAR":
      priority  => '25' ,
      command   => 'get_maven_files.sh' ,
      arguments => $war_arguments,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($jar_root != '') {
    puppi::deploy { "${name}-Get_Maven_Files_JAR":
      priority  => '25' ,
      command   => 'get_maven_files.sh' ,
      arguments => "${source} jarfile" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($config_root != '') {
    puppi::deploy { "${name}-Get_Maven_Files_Config":
      priority  => '25' ,
      command   => 'get_maven_files.sh' ,
      arguments => "${source} configfile" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($document_root != '') {
    puppi::deploy { "${name}-Get_Maven_Files_SRC":
      priority  => '25' ,
      command   => 'get_maven_files.sh' ,
      arguments => "${source} srcfile" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($zip_root != '') {
    $real_arguments = $http_password ? {
      ''      => "${source} zipfile",
      default => "-u ${http_user} -p ${http_password} ${source} zipfile"
    }

    puppi::deploy { "${name}-Get_Maven_Files_ZIP":
      priority  => '25' ,
      command   => 'get_maven_files.sh' ,
      arguments => $real_arguments,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($firewall_src_ip != '') {
    puppi::deploy { "${name}-Load_Balancer_Block":
      priority  => '30' ,
      command   => 'firewall.sh' ,
      arguments => "${firewall_src_ip} ${firewall_dst_port} on ${firewall_delay}" ,
      user      => 'root',
      project   => $name ,
      enable    => $enable ,
    }
  }

  # Existing files backup
  if ($deploy_root != '') {
    puppi::deploy { "${name}-Backup_Existing_WAR":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${deploy_root} -t war -s move -m diff -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($jar_root != '') {
    puppi::deploy { "${name}-Backup_Existing_JAR":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${jar_root} -t jar -s move -m diff -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($config_root != '') {
    puppi::deploy { "${name}-Backup_Existing_ConfigDir":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${config_root} -t config -d predeploydir_configfile -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($document_root != '') {
    puppi::deploy { "${name}-Backup_Existing_DocumentDir":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${document_root} -t docroot -d predeploydir_configfile -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($zip_root != '') {
    puppi::deploy { "${name}-Backup_Existing_ZipDir":
      priority  => '30' ,
      command   => 'archive.sh' ,
      arguments => "-b ${zip_root} -t ziproot -d predeploydir_zipfile -o '${backup_rsync_options}' -n ${backup_retention}" ,
      user      => 'root' ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($bool_check_deploy == true) and ($deploy_root != '') {
    puppi::deploy { "${name}-Check_undeploy":
      priority  => '31' ,
      command   => 'checkwardir.sh' ,
      arguments => "-a ${deploy_root} -c deploy_warpath" ,
      user      => $user ,
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

  # Deploys
  if ($deploy_root != '') {
    puppi::deploy { "${name}-Deploy_Maven_WAR":
      priority  => '40' ,
      command   => 'deploy.sh' ,
      arguments => $deploy_root ,
      user      => $user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($jar_root != '') {
    puppi::deploy { "${name}-Deploy_Maven_JAR":
      priority  => '40' ,
      command   => 'deploy.sh' ,
      arguments => $jar_root ,
      user      => $jar_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($config_root != '') {
    puppi::deploy { "${name}-Deploy_ConfigDir":
      priority  => '40' ,
      command   => 'deploy.sh' ,
      arguments => "${config_root} predeploydir_configfile" ,
      user      => $config_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($document_root != '') {
    puppi::deploy { "${name}-Deploy_DocumentDir":
      priority  => '40' ,
      command   => 'deploy.sh' ,
      arguments => "${document_root} predeploydir_srcfile" ,
      user      => $document_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($zip_root != '') {
    puppi::deploy { "${name}-Deploy_Zip":
      priority  => '40' ,
      command   => 'deploy.sh' ,
      arguments => "${zip_root} predeploydir_zipfile" ,
      user      => $zip_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
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

  if ($bool_check_deploy == true) and ($deploy_root != '') {
    puppi::deploy { "${name}-Check_deploy":
      priority  => '45' ,
      command   => 'checkwardir.sh' ,
      arguments => "-p ${deploy_root} -c deploy_warpath" ,
      user      => $user ,
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

  if ($deploy_root != '') {
    puppi::rollback { "${name}-Recover_WAR":
      priority  => '40' ,
      command   => 'archive.sh' ,
      arguments => "-r ${deploy_root} -t war -o '${backup_rsync_options}'" ,
      user      => $user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($jar_root != '') {
    puppi::rollback { "${name}-Recover_JAR":
      priority  => '40' ,
      command   => 'archive.sh' ,
      arguments => "-r ${jar_root} -t jar -o '${backup_rsync_options}'" ,
      user      => $jar_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($config_root != '') {
    puppi::rollback { "${name}-Recover_ConfigDir":
      priority  => '40' ,
      command   => 'archive.sh' ,
      arguments => "-r ${config_root} -t config -o '${backup_rsync_options}'" ,
      user      => $config_real_user ,
      project   => $name ,
      enable    => $enable ,
    }
  }

  if ($document_root != '') {
    puppi::rollback { "${name}-Recover_DocumentDir":
      priority  => '40' ,
      command   => 'archive.sh' ,
      arguments => "-r ${document_root} -t docroot -o '${backup_rsync_options}'" ,
      user      => $document_real_user ,
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

  if ($bool_check_deploy == true) {
    puppi::rollback { "${name}-Check_deploy":
      priority  => '45' ,
      command   => 'checkwardir.sh' ,
      arguments => "-p ${deploy_root} -c deploy_warpath" ,
      user      => $user ,
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

  if ($report_mongo != '') {
    puppi::report { "${name}-Mongo_Store":
      priority  => '30' ,
      command   => 'report_mongo.sh' ,
      arguments => $report_mongo ,
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
