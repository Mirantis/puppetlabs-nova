class nova::mysql_ha {
  include nova::patch

  file { "/tmp/mysql.patch":
    ensure => present,
    source => 'puppet:///modules/nova/mysql.patch'
  }

  exec { 'patch-nova-mysql':
    unless  => "/bin/grep sql_inc_retry_interval /usr/lib/${::nova::params::python_path}/nova/flags.py",
    command => "/usr/bin/patch -p1 -d /usr/lib/${::nova::params::python_path}/nova </tmp/mysql.patch",
    require => [ [File['/tmp/mysql.patch']],[Package['patch', 'python-nova']]], 
    subscribe => Package['python-nova']
  } ->
  # Do this BEFORE any nova services are started
  Nova_config <| |>
}
