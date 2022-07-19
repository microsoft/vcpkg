_find_package(${ARGS})

if(TARGET mysqlcppconn AND NOT TARGET mysqlcppconn-static)
    add_library(mysqlcppconn-static INTERFACE IMPORTED)
    set_target_properties(mysqlcppconn-static PROPERTIES INTERFACE_LINK_LIBRARIES mysqlcppconn)
elseif(TARGET mysqlcppconn-static AND NOT TARGET mysqlcppconn)
    add_library(mysqlcppconn INTERFACE IMPORTED)
    set_target_properties(mysqlcppconn PROPERTIES INTERFACE_LINK_LIBRARIES mysqlcppconn-static)
endif()
