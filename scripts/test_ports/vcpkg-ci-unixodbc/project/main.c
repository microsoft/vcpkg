/* https://www.unixodbc.org/doc/ProgrammerManual/Tutorial/ has
 * #include <odbc/sql.h>
 * but actual pkgconfig files and MS ODBC documentation suggest
 * #include <sql.h>
 */
#include <sql.h>
#include <stdio.h>

int main()
{
    SQLHENV odbc_handle;
	long result = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &odbc_handle);
	if ((result != SQL_SUCCESS) && (result != SQL_SUCCESS_WITH_INFO))
		return 1;

    SQLCHAR l_dsn[100], l_desc[100];
    SQLUSMALLINT l_len1, l_len2, l_next;
    for (short int l_next = SQL_FETCH_FIRST;
         SQLDataSources(odbc_handle, l_next, l_dsn, sizeof(l_dsn), &l_len1, l_desc, sizeof(l_desc), &l_len2) == SQL_SUCCESS;
         l_next = SQL_FETCH_NEXT)
    {
        printf("Server '%s' (%s)\n", l_dsn, l_desc);
    }

    SQLFreeHandle(SQL_HANDLE_ENV, odbc_handle);
    return 0;
}
