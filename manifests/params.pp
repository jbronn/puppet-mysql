# OS-dependent variables for installing/configuring MySQL.
class mysql::params {
  case $::osfamily {
    solaris: {
      if $::operatingsystemrelease < '5.11' {
        fail("MySQL supported only on Solaris 5.11 and above.\n")
      }
      $version  = "5.1"
      $version_ = "51"
      $server   = "database/mysql-${version_}"
      $service  = "svc:/application/database/mysql:version_${version_}"
      $provider = 'pkg'
      $config   = "/etc/mysql/${version}/my.cnf"
      $bindir   = "/usr/mysql/${version}/bin/amd64"
      $datadir  = "/var/mysql/${version}/data"
    }
    debian: {
      $client   = "mysql-client"
      $server   = "mysql-server"
      $devel    = ["libmysqlclient-dev", "libmysqld-dev"]
      $service  = 'mysql'
      $python   = 'python-mysqldb'
      $ruby     = 'libmysql-ruby'
      $bindir   = "/usr/bin"
      $config   = "/etc/mysql/my.cnf"
      $datadir  = "/var/lib/mysql"
    }
    redhat: {
      $client   = 'mysql'
      $server   = 'mysql-server'
      $devel    = "mysql-devel"
      $service  = 'mysqld'
      $ruby     = 'ruby-mysql' # from EPEL
      $python   = 'MySQL-python'
      $bindir   = "/usr/bin"
      $config   = "/etc/my.cnf"
      $datadir  = "/var/lib/mysql"
    }
    default: {
      fail("Do not know how to install MySQL on: ${::operatingsystem}.\n")
    }
  }
}
