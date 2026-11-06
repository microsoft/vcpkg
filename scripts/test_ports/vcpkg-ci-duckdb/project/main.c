#include <stdio.h>
#include <duckdb.h>

int main()
{
    duckdb_database db;
    if (duckdb_open(NULL, &db) == DuckDBError) {
        printf("open failed\n");
        return 1;
    }
    duckdb_connection con;
    if (duckdb_connect(db, &con) == DuckDBError) {
        printf("connect failed\n");
        return 2;
    }
    const char* query_icu =
        "LOAD icu;"
        "SELECT current_localtime();"
        "PRAGMA collations;"
        "SELECT list(collname) FROM pragma_collations();"
        ;
    duckdb_result result;
    if (duckdb_query(con, query_icu, &result) == DuckDBError) {
        printf("icu query failed: %s\n", duckdb_result_error(&result));
        return 3;
    }
    else {
        printf("success\n");
    }
    duckdb_disconnect(&con);
    duckdb_close(&db);
    return 0;
}
