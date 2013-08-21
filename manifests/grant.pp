# Grants database-level privileges to a MySQL user.  Column, table,
# global-level, and proxy privileges are not supported at this time as I
# do not use them.  Note the `$name` of this define must include the user,
# host, and database in the following manner: 'user@host/db'.
#
# == Parameters
# [*ensure*]
#  Either 'present' or 'absent'.  Defaults to 'present'.
# [*privileges*]
#  An array allowable MySQL privileges, all in *lowercase*.  Defaults to 'all'.
#  For available MySQL privileges please consult:
#   http://dev.mysql.com/doc/refman/5.5/en/grant.html#grant-privileges
#
# == Requires
# This class requires that `mysql::root` is declared.
#
# == Example
#
# Here's how to give user 'foo@localhost' all privileges on the
# database 'bar':
#
#    mysql::database { 'bar': }
#    mysql::user { 'foo@localhost': }
#
#    mysql::grant { 'foo@localhost/bar':
#        permissions => ['all'],
#    }
#
define mysql::grant($ensure='present', $privileges=['all']) {
  include mysql::params

  $regex = '^([\w\.-]+)@([\w%\.-]+)/(\w+)$'
  $user  = regsubst($name, $regex, '\1')
  $host  = regsubst($name, $regex, '\2')
  $db    = regsubst($name, $regex, '\3')

  if ($user == $name) or ($host == $name) or ($db == $name) {
    fail("Can't parse user, host, and database from: ${name}.\n")
  }

  # Require `mysql::root` so that we can login as MySQL's root
  # administrative user and change things around.
  Exec {
    path    => ['/bin', $mysql::params::bindir],
    require => [ Class['mysql::root'],
                 Mysql::User["${user}@${host}"],
                 Mysql::Database[$db] ],
  }

  # The ensure value determines SQL snippets we're going to use.
  case $ensure {
    'present': {
      $template = 'mysql/grant.erb'
      $perm_exists = 'Y'
      $perm_absent = 'N'
    }
    'absent': {
      $template = 'mysql/revoke.erb'
      $perm_exists = 'N'
      $perm_absent = 'Y'
    }
    default: {
      fail("Invalid ensure value for `mysql::database`: ${ensure}.\n")
    }
  }

  if ('all' in $privileges) or $privileges == 'all' {
    $all = true
  } else {
    $all = false
  }

  if $all or ('select' in $privileges) {
    $select = $perm_exists
  } else {
    $select = $perm_absent
  }

  if $all or ('insert' in $privileges) {
    $insert = $perm_exists
  } else {
    $insert = $perm_absent
  }

  if $all or ('update' in $privileges) {
    $update = $perm_exists
  } else {
    $update = $perm_absent
  }

  if $all or ('delete' in $privileges) {
    $delete = $perm_exists
  } else {
    $delete = $perm_absent
  }

  if $all or ('create' in $privileges) {
    $create = $perm_exists
  } else {
    $create = $perm_absent
  }

  if $all or ('drop' in $privileges) {
    $drop = $perm_exists
  } else {
    $drop = $perm_absent
  }

  if 'grant' in $privileges {
    $grant = $perm_exists
  } else {
    $grant = $perm_absent
  }

  if $all or ('index' in $privileges) {
    $index = $perm_exists
  } else {
    $index = $perm_absent
  }

  if $all or ('alter' in $privileges) {
    $alter = $perm_exists
  } else {
    $alter = $perm_absent
  }

  if $all or ('create temporary tables' in $privileges) {
    $create_temp = $perm_exists
  } else {
    $create_temp = $perm_absent
  }

  if $all or ('lock tables' in $privileges) {
    $lock_tables = $perm_exists
  } else {
    $lock_tables = $perm_absent
  }

  if $all or ('create view' in $privileges) {
    $create_view = $perm_exists
  } else {
    $create_view = $perm_absent
  }

  if $all or ('show view' in $privileges) {
    $show_view = $perm_exists
  } else {
    $show_view = $perm_absent
  }

  if $all or ('create routine' in $privileges) {
    $create_routine = $perm_exists
  } else {
    $create_routine = $perm_absent
  }

  if $all or ('alter routine' in $privileges) {
    $alter_routine = $perm_exists
  } else {
    $alter_routine = $perm_absent
  }

  if $all or ('execute' in $privileges) {
    $execute = $perm_exists
  } else {
    $execute = $perm_absent
  }

  if $all or ('event' in $privileges) {
    $event = $perm_exists
  } else {
    $event = $perm_absent
  }

  if $all or ('trigger' in $privileges) {
    $trigger = $perm_exists
  } else {
    $trigger = $perm_absent
  }

  # Setting up the default MySQL command.
  $mysql = $mysql::root::mysql

  $priv_cols = "Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, \
Drop_priv, Grant_priv, Index_priv, Alter_priv, Create_tmp_table_priv,\
Lock_tables_priv, Create_view_priv, Show_view_priv, Create_routine_priv, \
Alter_routine_priv, Execute_priv, Event_priv, Trigger_priv"

  # Be very careful and do not indent after the definitions of
  # this -- it will mess up the `$perms_right` query.
  $perms = shellquote("${select}	${insert}	${update}	\
${delete}	${create}	${drop}	${grant}	${index}	\
${alter}	${create_temp}	${lock_tables}	${create_view}	\
${show_view}	${create_routine}	${alter_routine}	\
${execute}	${event}	${trigger}")

  $db_where = "User='${user}' AND Host='${host}' AND Db='${db}'"
  $perms_exist = "${mysql} -e \"SELECT '1' FROM db WHERE ${db_where};\" mysql | grep 1"
  $perms_right = "${mysql} -e \"SELECT ${priv_cols} FROM db WHERE ${db_where};\" mysql | grep ${perms}"
  $perms_grant_sql = shellquote(template($template))
  $perms_grant = "${mysql} -e ${perms_grant_sql}"

  case $ensure {
    'present': {
      exec { "mysql-permissions-${name}":
        command => $perms_grant,
        unless  => $perms_right,
      }
    }
    'absent': {
      exec { "mysql-permissions-${name}":
        command => $perms_grant,
        onlyif  => $perms_exist,
      }
    }
  }
}
