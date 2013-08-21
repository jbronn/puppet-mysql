# This class installs the MySQL server (as well as client), and enables
# it as a service.
class mysql::server {
  include mysql::client
  include mysql::params

  # Ensure the MySQL server package is installed.
  package { $mysql::params::server:
    ensure   => installed,
    alias    => 'mysql-server',
    provider => $mysql::params::provider,
    require  => Class['mysql::client'],
  }

  # Enable the MySQL server service.
  include mysql::service
}
