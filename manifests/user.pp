# Creates a MySQL user.
#
# == Parameters
# [*ensure*]
#  Defaults to 'present'.
# [*password*]
#  Defines a password for the user, by default this is `undef`.
#
# == Requires
# This class requires that `mysql::root` is declared.
#
# == Example
#
# Here's how to define user 'foo' access from 'localhost':
#
#    mysql::user { 'foo@localhost':
#        password => 'foobar',
#    }
#
define mysql::user($ensure='present', $password=undef) {
  include mysql::params

  # Require `mysql::root` so that we can login as MySQL's root
  # administrative user and change things around.
  Exec {
    path      => ['/bin', $mysql::params::bindir],
    logoutput => 'on_failure',
    require   => Class['mysql::root'],
  }

  # Pulling out the username and hostname from $name, fail
  # if we can't do this.
  $regex = '^([\w\.-]+)@([\w%\.-]+)$'
  $user = regsubst($name, $regex, '\1')
  $host = regsubst($name, $regex, '\2')
  if ($user == $name) or ($host == $name) {
    fail("Invalid user specification: ${name}; must 'user@hostname'.\n")
  }

  # Setting up the default MySQL command.
  $mysql = $mysql::root::mysql
  $db_where = "User='${user}' AND Host='${host}'"
  $user_exists = "${mysql} -e \"SELECT '1' FROM user WHERE ${db_where};\" mysql | grep 1"

  case $ensure {
    'present': {
      $create_sql = "CREATE USER '${user}'@'${host}'"

      if $password {
        $createuser = "${create_sql} IDENTIFIED BY '${password}'"
      } else {
        $createuser = $create_sql
      }

      # Only create this user if they do not exist.
      exec { "mysql-create-user-${name}":
        command => "${mysql} -e \"${createuser};\"",
        unless  => $user_exists,
      }
    }
    'absent': {
      $dropuser = "DROP USER '${user}'@'${host}';"
      exec { "mysql-drop-user-${name}":
        command => "${mysql} -e \"${dropuser}\"",
        onlyif  => $user_exists,
      }
    }
    default: {
      fail("Invalid ensure value for `mysql::user`: ${ensure}\n")
    }
  }
}
