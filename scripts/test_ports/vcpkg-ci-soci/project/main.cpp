#include <soci/soci.h>
#include <soci/mysql/soci-mysql.h>
#include <soci/postgresql/soci-postgresql.h>
#include <soci/sqlite3/soci-sqlite3.h>

int main()
{
    soci::session mysql_db(soci::mysql, "test:mysql");
    soci::session pgsql_db(soci::postgresql, "test:postgresql");
    soci::session sqlite3_db(soci::sqlite3, "test.db");
}
