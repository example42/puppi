define puppi::run ( ) {

  exec { "Run_Puppi_${name}":
    command => "puppi deploy ${name}",
    path    => "/bin:/sbin:/usr/sbin:/usr/bin",
    refreshonly => true ,
  }

}
