set(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}")
foreach(i RANGE 1 2)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    if (_IMPORT_PREFIX STREQUAL "/")
        set(_IMPORT_PREFIX "")
        break()
    endif()
endforeach()

# Macro to find OS dependencies for windows builds.
# Sets up for failure find_package() failure if dependencies not found.
# On success, creates targets activemq-cpp::ws2, activemq-cpp::rpcrt4, and activemq-cpp::mswsock.
# Sets boolean ${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND to TRUE or FALSE to indicate success or failure.
macro(_activemq_cpp_windows_dependencies)
    find_library(ACTIVEMQ_CPP_LIBWS2 WS2_32)
    find_library(ACTIVEMQ_CPP_LIBRPCRT4 RpcRT4)
    find_library(ACTIVEMQ_CPP_LIBMSWSOCK MsWsock)
    if(ACTIVEMQ_CPP_LIBWS2 AND ACTIVEMQ_CPP_LIBRPCRT4 AND ACTIVEMQ_CPP_LIBMSWSOCK)
        add_library(activemq-cpp::ws2 SHARED IMPORTED)
        set_target_properties(activemq-cpp::ws2 PROPERTIES IMPORTED_LOCATION "${ACTIVEMQ_CPP_LIBWS2}" IMPORTED_CONFIGURATIONS "RELEASE;DEBUG")
        add_library(activemq-cpp::rpcrt4 SHARED IMPORTED)
        set_target_properties(activemq-cpp::rpcrt4 PROPERTIES IMPORTED_LOCATION "${ACTIVEMQ_CPP_LIBRPCRT4}" IMPORTED_CONFIGURATIONS "RELEASE;DEBUG")
        add_library(activemq-cpp::mswsock SHARED IMPORTED)
        set_target_properties(activemq-cpp::mswsock PROPERTIES IMPORTED_LOCATION "${ACTIVEMQ_CPP_LIBMSWSOCK}" IMPORTED_CONFIGURATIONS "RELEASE;DEBUG")
        set(${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND TRUE)
    else()
        if (NOT ACTIVEMQ_CPP_LIBWS2)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "WS2_32.lib")
        endif()
        if (NOT ACTIVEMQ_CPP_LIBRPCRT4)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "RpcRT4.lib")
        endif()
        if (NOT ACTIVEMQ_CPP_LIBMSWSOCK)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "MsWsock.lib")
        endif()
        list(JOIN _ACTIVEMQ_CPP_MISSINGS, ", ", _ACTIVEMQ_CPP_MISSINGS_STR)
        list(LENGTH _ACTIVEMQ_CPP_MISSINGS, _ACTIVEMQ_CPP_MISSINGS_COUNT)
        if(_ACTIVEMQ_CPP_MISSINGS_COUNT EQUALS 1)
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: Did not find windows dependency: ${_ACTIVEMQ_CPP_MISSINGS_STR}")
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: Did not find windows dependencies: ${_ACTIVEMQ_CPP_MISSINGS_STR}")
        endif()
        set(_ACTIVEMQ_CPP_MISSINGS_COUNT)
        set(_ACTIVEMQ_CPP_MISSINGS_STR)
        set(_ACTIVEMQ_CPP_MISSINGS)
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        set(${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND FALSE)
    endif()
endmacro()

#
# Since this is a CMake config file for a non-CMake project, and one that is
# for vcpkg to as well, the config file has to cover the various products of
# the builds on the various platforms.
#
# Below, Windows and Linux are covered for static and shared libraries.
#
if (EXISTS "${_IMPORT_PREFIX}/bin/activemq-cpp.dll")
    #
    # Windows shared install
    #
    if (EXISTS "${_IMPORT_PREFIX}/lib/activemq-cpp.lib")
        if (EXISTS "${_IMPORT_PREFIX}/debug/bin/activemq-cppd.dll")
            if (EXISTS "${_IMPORT_PREFIX}/debug/lib/activemq-cppd.lib")
                find_file(ACTIVEMQ_CPP_APR_LIB_RELEASE libapr-1.lib PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
                find_file(ACTIVEMQ_CPP_APR_DLL_RELEASE libapr-1.dll PATHS "${_IMPORT_PREFIX}/bin" NO_DEFAULT_PATH)
                find_file(ACTIVEMQ_CPP_APR_LIB_DEBUG libapr-1.lib PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
                find_file(ACTIVEMQ_CPP_APR_DLL_DEBUG libapr-1.dll PATHS "${_IMPORT_PREFIX}/debug/bin" NO_DEFAULT_PATH)
                if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_DLL_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG AND ACTIVEMQ_CPP_APR_DLL_DEBUG)
                    _activemq_cpp_windows_dependencies()
                    if (${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND)
                        # the APR port doesn't have a CMake config target so create one
                        add_library(activemq-cpp::apr SHARED IMPORTED)
                        set_target_properties(activemq-cpp::apr
                                              PROPERTIES
                                                  MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                                  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                                  IMPORTED_IMPLIB_RELEASE "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                                  IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_APR_DLL_RELEASE}"
                                                  IMPORTED_IMPLIB_DEBUG "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                                  IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_APR_DLL_DEBUG}"
                                                  IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                                  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                        )

                        # the create the activemq-cpp CMake config target with a dependency on apr
                        add_library(activemq-cpp::activemq-cpp SHARED IMPORTED)
                        set_target_properties(activemq-cpp::activemq-cpp
                                              PROPERTIES
                                                  MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                                  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                                  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/activemq-cpp.lib"
                                                  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/activemq-cpp.dll"
                                                  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/activemq-cppd.lib"
                                                  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/activemq-cppd.dll"
                                                  IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                                  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                                                  INTERFACE_LINK_LIBRARIES "activemq-cpp::apr;activemq-cpp:ws2;activemq-cpp:rpcrt4;activemq-cpp:mswsock"
                        )
                        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
                    endif()
                else()
                    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
                    if(NOT APR_LIB_RELEASE)
                        string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/lib/libapr-1.lib\" not found.")
                    endif()
                    if(NOT APR_DLL_RELEASE)
                        string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/bin/libapr-1.dll\" not found.")
                    endif()
                    if(NOT APR_LIB_DEBUG)
                        string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/debug/lib/libapr-1.lib\" not found.")
                    endif()
                    if(NOT APR_DLL_DEBUG)
                        string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/debug/bin/libapr-1.dll\" not found.")
                    endif()
                    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                    set(activemq-cppConfig_FOUND TRUE)
                endif()
            else()
                set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}debug/bin/activemq-cppd.dll but not ${_IMPORT_PREFIX}/debug/lib/activemq-cppd.lib")
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            endif()
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}/bin/activemq-cpp.dll but not ${_IMPORT_PREFIX}/debug/bin/activemq-cppd.dll")
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        endif()
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}/bin/activemq-cpp.dll but not ${_IMPORT_PREFIX}/lib/activemq-cpp.lib")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif()
elseif (EXISTS "${_IMPORT_PREFIX}/lib/libactivemq-cpp.lib")
    #
    # Windows static install
    #
    if (EXISTS "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.lib")
        find_file(ACTIVEMQ_CPP_APR_LIB_RELEASE apr-1.lib PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_file(ACTIVEMQ_CPP_APR_LIB_DEBUG apr-1.lib PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (APR_LIB_RELEASE AND APR_LIB_DEBUG)
            _activemq_cpp_windows_dependencies()
            if (${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND)
                # the APR port doesn't have a CMake config target so create one
                add_library(activemq-cpp::apr STATIC IMPORTED)
                set_target_properties(activemq-cpp::apr
                                      PROPERTIES
                                          MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                          MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                          IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                          IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                          INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                )

                # the create the activemq-cpp CMake config target with a dependency on apr
                add_library(activemq-cpp::activemq-cpp STATIC IMPORTED)
                set_target_properties(activemq-cpp::activemq-cpp
                                      PROPERTIES
                                          MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                          MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                          IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.lib"
                                          IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libactivemq-cpp.lib"
                                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                          INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                                          INTERFACE_LINK_LIBRARIES "activemq-cpp::apr;activemq-cpp:ws2;activemq-cpp:rpcrt4;activemq-cpp:mswsock"
                )
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
            endif()
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
            if(NOT APR_LIB_RELEASE)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/lib/apr-1.lib\" not found.")
            endif()
            if(NOT APR_LIB_DEBUG)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/debug/lib/apr-1.lib\" not found.")
            endif()
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        endif()
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}/lib/libactivemq-cpp.lib but not ${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.lib")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif()
elseif (EXISTS "${_IMPORT_PREFIX}/lib/libactivemq-cpp.so.19.0.5")
    #
    # Linux shared install  (this may pick up some other Unix-like installs)
    #
    if (EXISTS "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.so.19.0.5")
        find_library(ACTIVEMQ_CPP_APR_LIB_RELEASE libapr-1.so PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_library(ACTIVEMQ_CPP_APR_LIB_DEBUG libapr-1.so PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG)
            # the APR port doesn't have a CMake config target so create one
            add_library(activemq-cpp::apr SHARED IMPORTED)
            set_target_properties(activemq-cpp::apr
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                      IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                      IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
            )

            # the create the activemq-cpp CMake config target with a dependency on apr
            add_library(activemq-cpp::activemq-cpp SHARED IMPORTED)
            set_target_properties(activemq-cpp::activemq-cpp
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libactivemq-cpp.so.19.0.5"
                                      IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.so.19.0.5"
                                      IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                                      INTERFACE_LINK_LIBRARIES activemq-cpp::apr
            )
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
            if(NOT APR_LIB_RELEASE)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/lib/libapr-1.so\" not found.")
            endif()
            if(NOT APR_LIB_DEBUG)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/debug/lib/libapr-1.so\" not found.")
            endif()
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        endif()
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}/lib/libactivemq-cpp.so but not ${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.so")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif()
elseif (EXISTS "${_IMPORT_PREFIX}/lib/libactivemq-cpp.a")
    #
    # Linux static install (this may pick up some other Unix-like installs)
    #
    if (EXISTS ${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.a)
        find_file(ACTIVEMQ_CPP_APR_LIB_RELEASE libapr-1.a PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_file(ACTIVEMQ_CPP_APR_LIB_DEBUG libapr-1.a PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG)
            # the APR port doesn't have a CMake config target so create one
            add_library(activemq-cpp::apr STATIC IMPORTED)
            set_target_properties(activemq-cpp::apr
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                      IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                      IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
            )

            # the create the activemq-cpp CMake config target with a dependency on apr
            add_library(activemq-cpp::activemq-cpp STATIC IMPORTED)
            set_target_properties(activemq-cpp::activemq-cpp
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libactivemq-cpp.a"
                                      IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.a"
                                      IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                                      INTERFACE_LINK_LIBRARIES activemq-cpp::apr
            )
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
            if(NOT APR_LIB_RELEASE)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/lib/libapr-1.a\" not found.")
            endif()
            if(NOT APR_LIB_DEBUG)
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_IMPORT_PREFIX}/debug/lib/libapr-1.a\" not found.")
            endif()
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        endif()
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}/lib/libactivemq-cpp.so but not ${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.so")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif()
else()
    #
    # Some other configuration...
    #
    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg unexpected install: could not find any expected activemq-cpp libraries under ${_IMPORT_PREFIX}. The CMake configuration file only understands Windows and Linux static and shared installs from vcpkg.")
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
endif()
