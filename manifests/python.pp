# Convience class for installing MySQLdb, the Python database adapter.
class mysql::python($pip=false, $version='1.2.3') {
  # Use pip package if requested, or if there's no
  # system package available.
  if ($pip or ! $mysql::params::python) {
    include mysql::devel
    include python::devel
    package { 'MySQL-python':
      ensure   => $version,
      alias    => 'mysqldb',
      provider => 'pip',
      require  => [ Class['mysql::devel'],
                    Class['python::devel'], ],
    }
  } else {
    package { $mysql::params::python:
      ensure => installed,
      alias  => 'mysqldb',
    }
  }
}
