cmake_minimum_required(VERSION 3.30)
project(subversion-test C)

block(SCOPE_FOR VARIABLES)
    add_executable(main main.c)

    find_package(unofficial-subversion CONFIG REQUIRED)
    target_link_libraries(main PRIVATE unofficial::subversion::svn_client)
endblock()