# This class installs the MySQL client program and libraries.
class mysql::client {
  include mysql::params
  if $mysql::params::client {
    package { $mysql::params::client:
      ensure   => installed,
      alias    => 'mysql-client',
      provider => $mysql::params::provider,
    }
  }
}
