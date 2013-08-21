# This class enables the MySQL server service on the platform.
class mysql::service {
  include mysql::params

  service { $mysql::params::service:
    ensure     => running,
    alias      => 'mysql',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[$mysql::params::server],
  }

  # By default, Solaris packages use 32-bit binaries; here we modify
  # the service properties to use the 64-bit ones.
  if $::osfamily == Solaris {
    $mysql64 = "mysql/enable_64bit"
    exec { "mysql-enable-64bit":
      path    => ["/usr/sbin", "/usr/bin"],
      command => "svccfg -s ${mysql::params::service} setprop ${mysql64} = boolean: true",
      unless  => "svcprop -p ${mysql64} ${mysql::params::service} | grep '^true$'",
      require => Class['mysql::server'],
    }

    exec { "mysql-refresh":
      command     => "/usr/sbin/svcadm refresh ${mysql::params::service}",
      subscribe   => Exec['mysql-enable-64bit'],
      refreshonly => true,
      notify      => Service['mysql'],
    }
  }
}
