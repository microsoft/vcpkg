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
# On success, creates targets unofficial::activemq-cpp::ws2, unofficial::activemq-cpp::rpcrt4, and unofficial::activemq-cpp::mswsock.
# Sets boolean ${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND to TRUE or FALSE to indicate success or failure.
macro(_activemq_cpp_windows_dependencies)
    find_library(ACTIVEMQ_CPP_LIBWS2 WS2_32)
    find_file(ACTIVEMQ_CPP_DLLWS2 WS2_32.dll)
    find_library(ACTIVEMQ_CPP_LIBRPCRT4 RpcRT4)
    find_file(ACTIVEMQ_CPP_DLLRPCRT4 RpcRT4.dll)
    find_library(ACTIVEMQ_CPP_LIBMSWSOCK MsWsock)
    find_file(ACTIVEMQ_CPP_DLLMSWSOCK MsWsock.dll)
    if(ACTIVEMQ_CPP_LIBWS2 AND ACTIVEMQ_CPP_DLLWS2 AND ACTIVEMQ_CPP_LIBRPCRT4 AND ACTIVEMQ_CPP_DLLRPCRT4 AND ACTIVEMQ_CPP_LIBMSWSOCK AND ACTIVEMQ_CPP_DLLMSWSOCK)
        add_library(unofficial::activemq-cpp::ws2 SHARED IMPORTED)
        set_target_properties(unofficial::activemq-cpp::ws2 
                              PROPERTIES
                                  IMPORTED_LOCATION "${ACTIVEMQ_CPP_DLLWS2}" 
                                  IMPORTED_IMPLIB "${ACTIVEMQ_CPP_LIBWS2}" 
                                  IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                              )
        add_library(unofficial::activemq-cpp::rpcrt4 SHARED IMPORTED)
        set_target_properties(unofficial::activemq-cpp::rpcrt4
                              PROPERTIES 
                                  IMPORTED_LOCATION "${ACTIVEMQ_CPP_DLLRPCRT4}" 
                                  IMPORTED_IMPLIB "${ACTIVEMQ_CPP_LIBRPCRT4}" 
                                  IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                              )
        add_library(unofficial::activemq-cpp::mswsock SHARED IMPORTED)
        set_target_properties(unofficial::activemq-cpp::mswsock
                              PROPERTIES
                                  IMPORTED_LOCATION "${ACTIVEMQ_CPP_DLLMSWSOCK}"
                                  IMPORTED_IMPLIB "${ACTIVEMQ_CPP_LIBMSWSOCK}"
                                  IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                              )
        set(${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND TRUE)
    else()
        if (NOT ACTIVEMQ_CPP_LIBWS2)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "WS2_32.lib")
        endif()
        if (NOT ACTIVEMQ_CPP_DLLWS2)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "WS2_32.dll")
        endif()
        if (NOT ACTIVEMQ_CPP_LIBRPCRT4)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "RpcRT4.lib")
        endif()
        if (NOT ACTIVEMQ_CPP_DLLRPCRT4)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "RpcRT4.dll")
        endif()
        if (NOT ACTIVEMQ_CPP_LIBMSWSOCK)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "MsWsock.lib")
        endif()
        if (NOT ACTIVEMQ_CPP_DLLMSWSOCK)
            list(APPEND _ACTIVEMQ_CPP_MISSINGS "MsWsock.dll")
        endif()
        list(JOIN _ACTIVEMQ_CPP_MISSINGS ", " _ACTIVEMQ_CPP_MISSINGS_STR)
        list(LENGTH _ACTIVEMQ_CPP_MISSINGS _ACTIVEMQ_CPP_MISSINGS_COUNT)
        if(_ACTIVEMQ_CPP_MISSINGS_COUNT EQUAL 1)
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

# Set the variable named VARNAME to "${FILE}" if the file FILE exists; clears it
# otherwise. Opposite for VARNAME_MISSING.
function(_set_exists VARNAME VARNAME_MISSING FILE)
    if (EXISTS "${FILE}")
        set(${VARNAME} "${FILE}" PARENT_SCOPE)
        unset(${VARNAME_MISSING} PARENT_SCOPE)
    else()
        set(${VARNAME_MISSING} "${FILE}" PARENT_SCOPE)
        unset(${VARNAME} PARENT_SCOPE)
    endif()
endfunction()

# Add the unofficial::activemq-cpp::apr and unofficial::activemq-cpp::activemq-cpp targets
# Doesn't work for Windows DLL installs because that takes more args...
function(_add_apr_and_amq_targets INC_PARENT LIB_TYPE APR_REL APR_DEB AMQ_REL AMQ_DEB DEPS)
    # the APR port doesn't have a CMake config target so create one
    add_library(unofficial::activemq-cpp::apr ${LIB_TYPE} IMPORTED)
    set_target_properties(unofficial::activemq-cpp::apr
                          PROPERTIES
                              MAP_IMPORTED_CONFIG_MINSIZEREL Release
                              MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                              IMPORTED_LOCATION_RELEASE "${APR_REL}"
                              IMPORTED_LOCATION_DEBUG "${APR_DEB}"
                              IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                              INTERFACE_INCLUDE_DIRECTORIES "${INC_PARENT}/include"
    )

    # the create the activemq-cpp CMake config target with a dependency on apr
    add_library(unofficial::activemq-cpp::activemq-cpp ${LIB_TYPE} IMPORTED)
    set_target_properties(unofficial::activemq-cpp::activemq-cpp
                          PROPERTIES
                              MAP_IMPORTED_CONFIG_MINSIZEREL Release
                              MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                              IMPORTED_LOCATION_DEBUG "${AMQ_DEB}"
                              IMPORTED_LOCATION_RELEASE "${AMQ_REL}"
                              IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                              INTERFACE_INCLUDE_DIRECTORIES "${INC_PARENT}/include"
                              INTERFACE_LINK_LIBRARIES "${DEPS}"
    )
endfunction()

#
# Since this is a CMake config file for a non-CMake project, and one that is
# for vcpkg to as well, the config file has to cover the various products of
# the builds on the various platforms.
#
# Below, Windows and Linux are covered for static and shared libraries.
#
_set_exists(ACTIVEMQ_CPP_DLL_RELEASE _ACTIVEMQ_CPP_DLL_RELEASE_MISSING "${_IMPORT_PREFIX}/bin/activemq-cpp.dll")
_set_exists(ACTIVEMQ_CPP_LIB_RELEASE _ACTIVEMQ_CPP_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/activemq-cpp.lib")
_set_exists(ACTIVEMQ_CPP_DLL_DEBUG _ACTIVEMQ_CPP_DLL_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/bin/activemq-cppd.dll")
_set_exists(ACTIVEMQ_CPP_LIB_DEBUG _ACTIVEMQ_CPP_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/activemq-cppd.lib")
if (ACTIVEMQ_CPP_DLL_RELEASE)
    #
    # Windows shared install
    #
    if (ACTIVEMQ_CPP_LIB_RELEASE AND ACTIVEMQ_CPP_DLL_DEBUG AND ACTIVEMQ_CPP_LIB_DEBUG)
        _set_exists(ACTIVEMQ_CPP_APR_LIB_RELEASE _ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libapr-1.lib")
        _set_exists(ACTIVEMQ_CPP_APR_DLL_RELEASE _ACTIVEMQ_CPP_APR_DLL_RELEASE_MISSING "${_IMPORT_PREFIX}/bin/libapr-1.dll")
        _set_exists(ACTIVEMQ_CPP_APR_LIB_DEBUG _ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libapr-1.lib")
        _set_exists(ACTIVEMQ_CPP_APR_DLL_DEBUG _ACTIVEMQ_CPP_APR_DLL_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/bin/libapr-1.dll")
        if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_DLL_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG AND ACTIVEMQ_CPP_APR_DLL_DEBUG)
            _activemq_cpp_windows_dependencies()
            if (${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND)
                # the APR port doesn't have a CMake config target so create one
                add_library(unofficial::activemq-cpp::apr SHARED IMPORTED)
                set_target_properties(unofficial::activemq-cpp::apr
                                      PROPERTIES
                                          MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                          MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                          IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_APR_DLL_RELEASE}"
                                          IMPORTED_IMPLIB_RELEASE "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                          IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_APR_DLL_DEBUG}"
                                          IMPORTED_IMPLIB_DEBUG "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                          INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                )

                # the create the activemq-cpp CMake config target with a dependency on apr
                add_library(unofficial::activemq-cpp::activemq-cpp SHARED IMPORTED)
                set_target_properties(unofficial::activemq-cpp::activemq-cpp
                                      PROPERTIES
                                          MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                          MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                          IMPORTED_LOCATION_RELEASE "${ACTIVEMQ_CPP_DLL_RELEASE}"
                                          IMPORTED_IMPLIB_RELEASE "${ACTIVEMQ_CPP_LIB_RELEASE}"
                                          IMPORTED_LOCATION_DEBUG "${ACTIVEMQ_CPP_DLL_DEBUG}"
                                          IMPORTED_IMPLIB_DEBUG "${ACTIVEMQ_CPP_LIB_DEBUG}"
                                          IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
                                          INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
                                          INTERFACE_LINK_LIBRARIES "unofficial::activemq-cpp::apr;unofficial::activemq-cpp::ws2;unofficial::activemq-cpp::rpcrt4;unofficial::activemq-cpp::mswsock"
                )
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
            endif()
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
            foreach(_MISSING 
                        ${_ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING}
                        ${_ACTIVEMQ_CPP_APR_DLL_RELEASE_MISSING}
                        ${_ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING}
                        ${_ACTIVEMQ_CPP_APR_DLL_DEBUG_MISSING}
            )
                string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_MISSING}\" not found.")
            endforeach()
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            set(activemq-cppConfig_FOUND TRUE)
        endif()
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${_IMPORT_PREFIX}debug/bin/activemq-cppd.dll.")
        foreach(_MISSING 
                    ${_ACTIVEMQ_CPP_LIB_RELEASE_MISSING}
                    ${_ACTIVEMQ_CPP_DLL_DEBUG_MISSING}
                    ${_ACTIVEMQ_CPP_LIB_DEBUG_MISSING})
            string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_MISSING}\" not found.")
        endforeach()
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    endif()
else() 
    #
    # not Windows shared install
    #
    _set_exists(ACTIVEMQ_CPP_LIB_RELEASE _ACTIVEMQ_CPP_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libactivemq-cpp.lib")
    _set_exists(ACTIVEMQ_CPP_LIB_DEBUG _ACTIVEMQ_CPP_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.lib")
    if (ACTIVEMQ_CPP_LIB_RELEASE)
        #
        # Windows static install
        #
        if (ACTIVEMQ_CPP_LIB_DEBUG)
            _set_exists(ACTIVEMQ_CPP_APR_LIB_RELEASE _ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/apr-1.lib")
            _set_exists(ACTIVEMQ_CPP_APR_LIB_DEBUG _ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/apr-1.lib")
            if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG)
                _activemq_cpp_windows_dependencies()
                if (${CMAKE_FIND_PACKAGE_NAME}_WINDOWS_DEPENDENCIES_FOUND)
                    _add_apr_and_amq_targets("${_IMPORT_PREFIX}"
                                             STATIC
                                             "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                             "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                             "${ACTIVEMQ_CPP_LIB_RELEASE}"
                                             "${ACTIVEMQ_CPP_LIB_DEBUG}"
                                             "unofficial::activemq-cpp::apr;unofficial::activemq-cpp::ws2;unofficial::activemq-cpp::rpcrt4;unofficial::activemq-cpp::mswsock")
                    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
                endif()
            else()
                set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
                foreach(_MISSING ${_ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING} ${_ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING})
                    string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_MISSING}\" not found.")
                endforeach()
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            endif()
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${ACTIVEMQ_CPP_LIB_RELEASE} but not ${_ACTIVEMQ_CPP_LIB_DEBUG_MISSING}.")
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        endif()
    else()
        #
        # not Windows shared or static install
        #
        _set_exists(ACTIVEMQ_CPP_LIB_RELEASE _ACTIVEMQ_CPP_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libactivemq-cpp.so.19.0.5")
        _set_exists(ACTIVEMQ_CPP_LIB_DEBUG _ACTIVEMQ_CPP_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.so.19.0.5")
        if(ACTIVEMQ_CPP_LIB_RELEASE)
            #
            # Linux shared install (this may pick up some other Unix-like installs)
            #
            if (ACTIVEMQ_CPP_LIB_DEBUG)
                _set_exists(ACTIVEMQ_CPP_APR_LIB_RELEASE _ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libapr-1.so")
                _set_exists(ACTIVEMQ_CPP_APR_LIB_DEBUG _ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libapr-1.so")
                if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG)
                    find_package(Threads)
                    if (Threads_FOUND)
                        _add_apr_and_amq_targets("${_IMPORT_PREFIX}"
                                                 SHARED
                                                 "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                                 "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                                 "${ACTIVEMQ_CPP_LIB_RELEASE}"
                                                 "${ACTIVEMQ_CPP_LIB_DEBUG}"
                                                 "unofficial::activemq-cpp::apr;Threads::Threads")
                        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
                    else()
                        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: threads library not found.")
                        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                    endif()
                else()
                    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
                    foreach(_MISSING ${_ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING} ${_ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING})
                        string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_MISSING}\" not found.")
                    endforeach()
                    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                endif()
            else()
                set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${ACTIVEMQ_CPP_LIB_RELEASE} but not ${_ACTIVEMQ_CPP_LIB_DEBUG_MISSING}")
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            endif()
        else()
            #
            # not Windows shared or static or Linux shared install
            #
            _set_exists(ACTIVEMQ_CPP_LIB_RELEASE _ACTIVEMQ_CPP_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libactivemq-cpp.a")
            _set_exists(ACTIVEMQ_CPP_LIB_DEBUG _ACTIVEMQ_CPP_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libactivemq-cpp.a")
            if (ACTIVEMQ_CPP_LIB_RELEASE)
                #
                # Linux static install (this may pick up some other Unix-like installs)
                #
                if (ACTIVEMQ_CPP_LIB_DEBUG)
                    _set_exists(ACTIVEMQ_CPP_APR_LIB_RELEASE _ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING "${_IMPORT_PREFIX}/lib/libapr-1.a")
                    _set_exists(ACTIVEMQ_CPP_APR_LIB_DEBUG _ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING "${_IMPORT_PREFIX}/debug/lib/libapr-1.a")
                    if (ACTIVEMQ_CPP_APR_LIB_RELEASE AND ACTIVEMQ_CPP_APR_LIB_DEBUG)
                        find_package(Threads)
                        if (Threads_FOUND)
                            _add_apr_and_amq_targets("${_IMPORT_PREFIX}"
                                                     STATIC
                                                     "${ACTIVEMQ_CPP_APR_LIB_RELEASE}"
                                                     "${ACTIVEMQ_CPP_APR_LIB_DEBUG}"
                                                     "${ACTIVEMQ_CPP_LIB_RELEASE}"
                                                     "${ACTIVEMQ_CPP_LIB_DEBUG}"
                                                     "unofficial::activemq-cpp::apr;Threads::Threads")
                            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
                        else()
                            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: threads library not found.")
                            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                        endif()
                    else()
                        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}.")
                        foreach(_MISSING ${_ACTIVEMQ_CPP_APR_LIB_RELEASE_MISSING} ${_ACTIVEMQ_CPP_APR_LIB_DEBUG_MISSING})
                            string(APPEND ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE " \"${_MISSING}\" not found.")
                        endforeach()
                        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                    endif()
                else()
                    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install error: Found ${ACTIVEMQ_CPP_LIB_RELEASE} but not ${_ACTIVEMQ_CPP_LIB_DEBUG_MISSING}")
                    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
                endif()
            else()
                #
                # Some other configuration...
                # (not Windows shared or static or Linux shared or static install)
                #
                set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg unexpected install: could not find any expected activemq-cpp libraries under ${_IMPORT_PREFIX}. The CMake configuration file only understands Windows and Linux static and shared installs from vcpkg.")
                set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
            endif()
        endif()
    endif()
endif()
