find_package(unofficial-libmysql CONFIG REQUIRED)
if (TARGET mysqlclient)
    set(MYSQL_LIBRARY mysqlclient)
elseif (TARGET libmysql)
    set(MYSQL_LIBRARY libmysql)
endif()

set(libmysql_FOUND 1)
set(MYSQL_LIBRARIES ${MYSQL_LIBRARY})
