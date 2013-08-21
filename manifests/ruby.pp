# Installs the MySQL-Ruby database adapter.
class mysql::ruby {
  include mysql::params

  if $mysql::params::ruby {
    if $::osfamily == RedHat {
      # Package requires EPEL on RedHat.
      include redhat::epel
      $require = Package['epel']
    } else {
      $require = undef
    }

    package { $mysql::params::ruby:
      ensure  => installed,
      alias   => 'mysql-ruby',
      require => $require,
    }
  }
}
