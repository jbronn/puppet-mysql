# This class installs the MySQL development headers.
class mysql::devel {
  include mysql::params
  if $mysql::params::devel {
    package { $mysql::params::devel:
      ensure   => installed,
      alias    => 'mysql-devel',
      provider => $mysql::params::provider,
    }
  }
}
