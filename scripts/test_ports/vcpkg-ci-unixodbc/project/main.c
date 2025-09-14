/* https://www.unixodbc.org/doc/ProgrammerManual/Tutorial/ has
 * #include <odbc/sql.h>
 * but actual pkgconfig files and MS ODBC documentation suggest
 * #include <sql.h>
 */
#include <sql.h>

int main()
{
    SQLHENV odbc_handle;
	long result = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &odbc_handle);
	if ((result != SQL_SUCCESS) && (result != SQL_SUCCESS_WITH_INFO))
		return 1;

    SQLFreeHandle(SQL_HANDLE_ENV, odbc_handle);
    return 0;
}
