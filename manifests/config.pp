# This define sets up a MySQL configuration file; the name of the
# resource is the path to where the file is stored.  Each section
# of the configuration file is a parameter, which is a hash of
# configuration parameters and their values.
#
# == Parameters
# [*ensure*]
#  Defaults to 'present'.  If set to absent, will ensure the configuration
#  file is purged from the system.
# [*client*]
#  Hash of `[client]` configuration parameters and values.
#  Defaults to false.
# [*isamchk*]
#  Hash of `[isamchk]` configuration parameters and values.
#  Defaults to false.
# [*mysql*]
#  Hash of `[mysql]` configuration parameters and values.
#  Defaults to false.
# [*mysqld*]
#  Hash of `[mysqld]` configuration parameters and values.
#  Defaults to false.
# [*mysqldump*]
#  Hash of `[mysqldump]` configuration parameters and values.
#  Defaults to false.
# [*mysqld_safe*]
#  Hash of `[mysqld_safe]` configuration parameters and values.
#  Defaults to false.
# [*server*]
#  Hash of `[server]` configuration parameters and values.
#  Defaults to false.
# [*template*]
#  The template to use when creating the configuration file,
#  defaults to 'mysql/my.cnf.erb'.  Customize this parameter
#  at your own risk (in other words, things may not work without the
#  template logic in the default template).
#
define mysql::config(
  $ensure="present",
  $client=false,
  $isamchk=false,
  $mysql=false,
  $mysqld=false,
  $mysqldump=false,
  $mysqld_safe=false,
  $server=false,
  $path=false,
  $template="mysql/my.cnf.erb"
  ){
  include mysql::params

  # If settings are for MySQL server, then set up to notify the
  # database service.
  if $mysqld or $mysqld_safe {
    include mysql::server
    $config_notify  = Service['mysql']
    $config_require = Class['mysql::server']
  } else {
    include mysql::client
    $config_notify = undef
    $config_require = Class['mysql::client']
  }

  if $::osfamily == 'Solaris' {
    $group = 'bin'
  } else {
    $group = 'root'
  }

  # If the `ensure` value is 'present', then create the configuration file,
  # otherwise make sure it's not present on the system.
  if $ensure == 'present' {
    # Creating the MySQL configuration file according to the given parameters,
    # which the template will put in the right place.
    file { $name:
      ensure  => file,
      owner   => 'root',
      group   => $group,
      mode    => '0644',
      content => template($template),
      notify  => $config_notify,
      require => $config_require,
    }
  } else {
    file { $name:
      ensure => absent,
    }
  }
}
