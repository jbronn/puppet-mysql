# Creates a MySQL database.
#
# == Parameters
# [*ensure*]
#  Either 'present' or 'absent'.  Defaults to 'present'.
# [*encoding*]
#  The encoding of the MySQL database.  Defaults to 'utf8'.
# [*collate*]
#  The collate of the MySQL database.  Defaults to undef.
#
# == Requires
# This class requires that `mysql::root` be defined.
#
# == Example
#
#    mysql::database { 'foo':
#        ensure => present,
#    }
#
define mysql::database($ensure='present', $encoding='utf8', $collate=undef) {
  include mysql::params

  # Require `mysql::root` so that we can login as MySQL's root
  # administrative user and change things around.
  Exec {
    path    => ['/bin', $mysql::params::bindir],
    require => Class['mysql::root'],
  }

  # This command determines whether the database already exists.
  $dbexists = "${mysql::root::mysql} -e \"SHOW DATABASES\" | grep '^${name}$'"

  case $ensure {
    'present': {
      # Setting up the default database collation.
      if $collate {
        $collation = $collate
      } else {
        # Use more accurate collation (`xxx_unicode_ci`) by default
        # if a Unicode character set is used.  See:
        #  http://dev.mysql.com/doc/refman/5.5/en/charset-unicode-sets.html
        if $encoding in ['ucs2', 'utf8', 'utf8mb4', 'utf16', 'utf32'] {
          $collation = "${encoding}_unicode_ci"
        } else {
          $collation = $collate
        }
      }

      # Constructing the Creation SQL.
      $create_base = "CREATE DATABASE `${name}` CHARACTER SET ${encoding}"
      if $collation {
        $create_sql = shellquote("${create_base} COLLATE ${collation}")
      } else {
        $create_sql = shellquote($create_base)
      }

      # Create the database, unless it already exists.
      exec { "mysql-createdb-${name}":
        command => "${mysql::root::mysql} -e ${create_sql}",
        unless  => $dbexists,
      }
    }
    'absent': {
      # Drop the database only if it exists.
      $drop_sql = shellquote("DROP DATABASE `${name}`")
      exec { "mysql-dropdb-${name}":
        command => "${mysql::root::mysql} -e ${drop_sql}",
        onlyif  => $dbexists,
      }
    }
    default: {
      fail("Invalid ensure value for `mysql::database`: ${ensure}.\n")
    }
  }
}
