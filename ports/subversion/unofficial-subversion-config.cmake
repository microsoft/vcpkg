find_dependency(unofficial-apr CONFIG QUIET)
find_dependency(OpenSSL QUIET)
find_dependency(ZLIB QUIET)
find_dependency(expat CONFIG QUIET)
find_dependency(unofficial-sqlite3 CONFIG QUIET)

find_library(APR_LIBRARY
    NAMES apr-1 libapr-1
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib
    NO_DEFAULT_PATH
)
find_library(APR_LIBRARY_DEBUG
    NAMES apr-1 libapr-1 apr-1d libapr-1d
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib
    NO_DEFAULT_PATH
)

find_library(APRUTIL_LIBRARY
    NAMES aprutil-1 libaprutil-1
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib
    NO_DEFAULT_PATH
)
find_library(APRUTIL_LIBRARY_DEBUG
    NAMES aprutil-1 libaprutil-1 aprutil-1d libaprutil-1d
    PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib
    NO_DEFAULT_PATH
)

find_path(SUBVERSION_INCLUDE_DIR 
    NAMES svn_client.h
    PATH_SUFFIXES subversion-1
)

set(_subversion_libs
    svn_client
    svn_delta
    svn_diff
    svn_fs
    svn_fs_base
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

foreach(_lib ${_subversion_libs})
    find_library(SUBVERSION_${_lib}_LIBRARY_RELEASE
        NAMES ${_lib}-1 lib${_lib}-1
        PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib
        NO_DEFAULT_PATH
    )
    
    find_library(SUBVERSION_${_lib}_LIBRARY_DEBUG
        NAMES ${_lib}-1 lib${_lib}-1 ${_lib}-1d lib${_lib}-1d
        PATHS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib
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
        
        set(_link_libs "")
        
        list(APPEND _link_libs unofficial::apr::apr)
        list(APPEND _link_libs OpenSSL::SSL OpenSSL::Crypto)
        list(APPEND _link_libs ZLIB::ZLIB)
        list(APPEND _link_libs expat::expat)
        list(APPEND _link_libs unofficial::sqlite3::sqlite3)
        
        if(WIN32)
            list(APPEND _link_libs crypt32 ws2_32 version)
        endif()
        
        target_link_libraries(unofficial::subversion::${_lib} INTERFACE ${_link_libs})
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
