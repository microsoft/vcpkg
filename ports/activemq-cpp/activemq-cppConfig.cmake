set(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}")
foreach(i RANGE 1 2)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    if (_IMPORT_PREFIX STREQUAL "/")
        set(_IMPORT_PREFIX "")
        break()
    endif()
endforeach()


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
                find_library(APR_LIB_RELEASE libapr-1.lib PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
                find_library(APR_DLL_RELEASE libapr-1.dll PATHS "${_IMPORT_PREFIX}/bin" NO_DEFAULT_PATH)
                find_library(APR_LIB_DEBUG libapr-1.lib PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
                find_library(APR_DLL_DEBUG libapr-1.dll PATHS "${_IMPORT_PREFIX}/debug/bin" NO_DEFAULT_PATH)
                if (APR_LIB_RELEASE AND APR_DLL_RELEASE AND APR_LIB_DEBUG AND APR_DLL_DEBUG)
                    # the APR port doesn't have a CMake config target so create one
                    add_library(activemq-cpp::apr SHARED IMPORTED)
                    set_target_properties(activemq-cpp::apr
                                          PROPERTIES
                                              MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                              MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                              IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libapr-1.lib"
                                              IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/libapr-1.dll"
                                              IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/libapr-1.lib"
                                              IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/libapr-1.dll"
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
                                              INTERFACE_LINK_LIBRARIES activemq-cpp::apr
                    )
                    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
                else()
                    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}")
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
        find_library(APR_LIB_RELEASE apr-1.lib PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_library(APR_LIB_DEBUG apr-1.lib PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (APR_LIB_RELEASE AND APR_LIB_DEBUG)
            # the APR port doesn't have a CMake config target so create one
            add_library(activemq-cpp::apr STATIC IMPORTED)
            set_target_properties(activemq-cpp::apr
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/apr-1.lib"
                                      IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/apr-1.lib"
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
                                      INTERFACE_LINK_LIBRARIES activemq-cpp::apr
            )
            set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
        else()
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}")
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
        find_library(APR_LIB_RELEASE libapr-1.so PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_library(APR_LIB_DEBUG libapr-1.so PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (APR_LIB_RELEASE AND APR_LIB_DEBUG)
            # the APR port doesn't have a CMake config target so create one
            add_library(activemq-cpp::apr SHARED IMPORTED)
            set_target_properties(activemq-cpp::apr
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libapr-1.so"
                                      IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libapr-1.so"
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
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}")
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
        find_library(APR_LIB_RELEASE libapr-1.a PATHS "${_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
        find_library(APR_LIB_DEBUG libapr-1.a PATHS "${_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
        if (APR_LIB_RELEASE AND APR_LIB_DEBUG)
            # the APR port doesn't have a CMake config target so create one
            add_library(activemq-cpp::apr STATIC IMPORTED)
            set_target_properties(activemq-cpp::apr
                                  PROPERTIES
                                      MAP_IMPORTED_CONFIG_MINSIZEREL Release
                                      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
                                      IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libapr-1.a"
                                      IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/libapr-1.a"
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
            set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Activemq-cpp vcpkg install dependency failure: apr vcpkg port not found in ${_IMPORT_PREFIX}")
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
