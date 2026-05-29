include(CMakeFindDependencyMacro)

find_package(apr CONFIG QUIET)
if(NOT apr_FOUND AND NOT WIN32)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(APR REQUIRED IMPORTED_TARGET apr-1)
endif()

find_path(SUBVERSION_INCLUDE_DIR 
    NAMES svn_client.h
    PATH_SUFFIXES subversion-1
    HINTS "${CMAKE_CURRENT_LIST_DIR}/../../include"
)

set(_subversion_libs
    svn_client
    svn_delta
    svn_diff
    svn_fs
    svn_fs_fs
    svn_fs_util
    svn_fs_x
    svn_ra
    svn_ra_local
    svn_ra_serf
    svn_ra_svn
    svn_repos
    svn_subr
    svn_wc
)

get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

find_library(_SERF_LIBRARY_RELEASE NAMES serf-1 libserf-1 PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
find_library(_SERF_LIBRARY_DEBUG NAMES serf-1 libserf-1 PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
find_library(_APR_UTIL_LIBRARY_RELEASE NAMES aprutil-1 libaprutil-1 PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
find_library(_APR_UTIL_LIBRARY_DEBUG NAMES aprutil-1 libaprutil-1 PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)

foreach(_lib ${_subversion_libs})
    find_library(SUBVERSION_${_lib}_LIBRARY_RELEASE
        NAMES ${_lib}-1.a ${_lib}-1 lib${_lib}-1.a lib${_lib}-1
        PATHS "${_IMPORT_PREFIX}/lib"
        NO_DEFAULT_PATH
    )
    
    find_library(SUBVERSION_${_lib}_LIBRARY_DEBUG
        NAMES ${_lib}-1.a ${_lib}-1 lib${_lib}-1.a lib${_lib}-1 ${_lib}-1d.a ${_lib}-1d lib${_lib}-1d.a lib${_lib}-1d
        PATHS "${_IMPORT_PREFIX}/debug/lib"
        NO_DEFAULT_PATH
    )
    
    if(SUBVERSION_${_lib}_LIBRARY_RELEASE OR SUBVERSION_${_lib}_LIBRARY_DEBUG)
        add_library(unofficial::subversion::${_lib} UNKNOWN IMPORTED)
        
        if(SUBVERSION_${_lib}_LIBRARY_RELEASE)
            set_property(TARGET unofficial::subversion::${_lib} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE
            )
            set_target_properties(unofficial::subversion::${_lib} PROPERTIES
                IMPORTED_LOCATION_RELEASE "${SUBVERSION_${_lib}_LIBRARY_RELEASE}"
            )
        endif()
        
        if(SUBVERSION_${_lib}_LIBRARY_DEBUG)
            set_property(TARGET unofficial::subversion::${_lib} APPEND PROPERTY
                IMPORTED_CONFIGURATIONS DEBUG
            )
            set_target_properties(unofficial::subversion::${_lib} PROPERTIES
                IMPORTED_LOCATION_DEBUG "${SUBVERSION_${_lib}_LIBRARY_DEBUG}"
            )
        endif()
        
        set_target_properties(unofficial::subversion::${_lib} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${SUBVERSION_INCLUDE_DIR}"
        )
        
        if(TARGET apr::libapr-1)
            target_link_libraries(unofficial::subversion::${_lib} INTERFACE apr::libapr-1)
        elseif(TARGET apr::apr-1)
            target_link_libraries(unofficial::subversion::${_lib} INTERFACE apr::apr-1)
        elseif(TARGET PkgConfig::APR)
            target_link_libraries(unofficial::subversion::${_lib} INTERFACE PkgConfig::APR)
        endif()

        if(NOT BUILD_SHARED_LIBS)
            find_dependency(OpenSSL REQUIRED)
            find_dependency(ZLIB REQUIRED)
            find_dependency(expat CONFIG REQUIRED)
            find_dependency(unofficial-sqlite3 CONFIG REQUIRED)
            
            target_link_libraries(unofficial::subversion::${_lib} INTERFACE
                OpenSSL::SSL
                OpenSSL::Crypto
                ZLIB::ZLIB
                expat::expat
                unofficial::sqlite3::sqlite3
            )
            
            if(_SERF_LIBRARY_RELEASE OR _SERF_LIBRARY_DEBUG)
                target_link_libraries(unofficial::subversion::${_lib} INTERFACE
                    "$<IF:$<CONFIG:Debug>,${_SERF_LIBRARY_DEBUG},${_SERF_LIBRARY_RELEASE}>"
                )
            endif()

            if(_APR_UTIL_LIBRARY_RELEASE OR _APR_UTIL_LIBRARY_DEBUG)
                target_link_libraries(unofficial::subversion::${_lib} INTERFACE
                    "$<IF:$<CONFIG:Debug>,${_APR_UTIL_LIBRARY_DEBUG},${_APR_UTIL_LIBRARY_RELEASE}>"
                )
            endif()
            
            if(WIN32)
                target_link_libraries(unofficial::subversion::${_lib} INTERFACE crypt32 ws2_32 version secur32)
            endif()
        endif()
    endif()
endforeach()

if(TARGET unofficial::subversion::svn_client)
    target_link_libraries(unofficial::subversion::svn_client INTERFACE
        unofficial::subversion::svn_wc
        unofficial::subversion::svn_ra
        unofficial::subversion::svn_delta
        unofficial::subversion::svn_diff
        unofficial::subversion::svn_subr
    )
endif()

if(TARGET unofficial::subversion::svn_wc)
    target_link_libraries(unofficial::subversion::svn_wc INTERFACE
        unofficial::subversion::svn_delta
        unofficial::subversion::svn_diff
        unofficial::subversion::svn_subr
    )
endif()

if(TARGET unofficial::subversion::svn_ra)
    target_link_libraries(unofficial::subversion::svn_ra INTERFACE
        unofficial::subversion::svn_delta
        unofficial::subversion::svn_subr
    )
endif()

if(TARGET unofficial::subversion::svn_repos)
    target_link_libraries(unofficial::subversion::svn_repos INTERFACE
        unofficial::subversion::svn_fs
        unofficial::subversion::svn_delta
        unofficial::subversion::svn_subr
    )
endif()

if(TARGET unofficial::subversion::svn_fs)
    if(TARGET unofficial::subversion::svn_fs_fs)
        target_link_libraries(unofficial::subversion::svn_fs INTERFACE
            unofficial::subversion::svn_fs_fs
        )
    endif()
    if(TARGET unofficial::subversion::svn_fs_x)
        target_link_libraries(unofficial::subversion::svn_fs INTERFACE
            unofficial::subversion::svn_fs_x
        )
    endif()
    target_link_libraries(unofficial::subversion::svn_fs INTERFACE
        unofficial::subversion::svn_subr
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(unofficial-subversion
    REQUIRED_VARS SUBVERSION_INCLUDE_DIR SUBVERSION_svn_client_LIBRARY_RELEASE
)

mark_as_advanced(SUBVERSION_INCLUDE_DIR)

unset(_IMPORT_PREFIX)
unset(_subversion_libs)
unset(_SERF_LIBRARY_RELEASE CACHE)
unset(_SERF_LIBRARY_DEBUG CACHE)
unset(_APR_UTIL_LIBRARY_RELEASE CACHE)
unset(_APR_UTIL_LIBRARY_DEBUG CACHE)
