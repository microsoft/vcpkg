cmake_minimum_required(VERSION 3.25)
project(subversion-test CXX)

block(SCOPE_FOR VARIABLES)
    add_executable(main main.cpp)

    find_package(unofficial-subversion CONFIG REQUIRED)
    target_link_libraries(main PRIVATE 
        unofficial::subversion::svn_client
        unofficial::subversion::svn_delta
        unofficial::subversion::svn_diff
        unofficial::subversion::svn_fs
        unofficial::subversion::svn_fs_fs
        unofficial::subversion::svn_fs_util
        unofficial::subversion::svn_fs_x
        unofficial::subversion::svn_ra
        unofficial::subversion::svn_ra_local
        unofficial::subversion::svn_ra_serf
        unofficial::subversion::svn_ra_svn
        unofficial::subversion::svn_repos
        unofficial::subversion::svn_subr
        unofficial::subversion::svn_wc
    )
endblock()