find_package(unofficial-libmysql CONFIG REQUIRED)
set(libmysql_FOUND 1)
set(MYSQL_LIBRARIES unofficial::libmysql::libmysql)
