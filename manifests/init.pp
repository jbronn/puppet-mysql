# This class only includes the MySQL client libraries.  If you
# wish to run the server, than include `mysql::server` as well.
class mysql {
  include mysql::client
}
