# This class sets up the root user's password for MySQL.
#
# == Parameters
# [*password*]
#  The password to use for the MySQL root user.  Defaults to ''.
#
# == Example
# Here, the root user's password is being set to 'foo':
#
#    class { 'mysql::root':
#        password => 'foo',
#    }
#
class mysql::root($password='') {
  # For calling MySQL commands, by other MySQL defines, e.g.,
  # `mysql::user`, `mysql::database`, and `mysql::grant` all
  # use these variables.
  include mysql::service
  if $password != '' {
    $passwd = shellquote($password)
    $mysql = "mysql -ss -B -u root -p${passwd}"

    exec { "mysql-root":
      command => "mysqladmin --user=root password ${passwd}",
      path    => "/bin:/usr/bin",
      unless  => "mysqladmin --user=root --password=${passwd} status",
      require => Service["mysql"],
    }
  } else {
    $mysql = "mysql -ss -B -u root"
  }
}
