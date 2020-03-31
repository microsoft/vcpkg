## # vcpkg_configure_meson
##
## Configure Meson for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_meson(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `meson.build`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### OPTIONS
## Additional options passed to Meson during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to Meson during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to Meson during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to Meson. To see the full list, examine the source.
##
## ## Examples
##
## * [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
## * [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)
function(vcpkg_configure_meson)
    cmake_parse_arguments(_vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})
    
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    #Extract compiler flags
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(MESON_CMAKE_FLAG_SUFFIX "_INIT")
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
            set(MESON_CMAKE_FLAG_SUFFIX "")
        elseif(VCPKG_TARGET_IS_LINUX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_TARGET_IS_ANDROID)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_TARGET_IS_OSX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VVCPKG_TARGET_IS_FREEBSD)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_TARGET_IS_MINGW)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
        endif()
    endif()

    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    
    string(APPEND MESON_COMMON_CFLAGS " ${CMAKE_C_FLAGS${MESON_CMAKE_FLAG_SUFFIX}}")
    string(APPEND MESON_COMMON_CXXFLAGS " ${CMAKE_CXX_FLAGS${MESON_CMAKE_FLAG_SUFFIX}}")

    string(APPEND MESON_DEBUG_CFLAGS " ${CMAKE_C_FLAGS_DEBUG${MESON_CMAKE_FLAG_SUFFIX}}")
    string(APPEND MESON_DEBUG_CXXFLAGS " ${CMAKE_CXX_FLAGS_DEBUG${MESON_CMAKE_FLAG_SUFFIX}}")

    string(APPEND MESON_RELEASE_CFLAGS " ${CMAKE_C_FLAGS_RELEASE${MESON_CMAKE_FLAG_SUFFIX}}")
    string(APPEND MESON_RELEASE_CXXFLAGS " ${CMAKE_CXX_FLAGS_RELEASE${MESON_CMAKE_FLAG_SUFFIX}}")

    string(APPEND MESON_COMMON_LDFLAGS " ${CMAKE_SHARED_LINKER_FLAGS${MESON_CMAKE_FLAG_SUFFIX}}")
    string(APPEND MESON_DEBUG_LDFLAGS " ${CMAKE_SHARED_LINKER_FLAGS_DEBUG${MESON_CMAKE_FLAG_SUFFIX}}")
    string(APPEND MESON_RELEASE_LDFLAGS " ${CMAKE_SHARED_LINKER_FLAGS_RELEASE${MESON_CMAKE_FLAG_SUFFIX}}")
    
    # select meson cmd-line options
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND _vcm_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}','${CURRENT_INSTALLED_DIR}/share']")
    else()
        list(APPEND _vcm_OPTIONS "-Dcmake_prefix_path=['${CURRENT_INSTALLED_DIR}']")
    endif()
    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _vcm_OPTIONS --default-library shared)
    else()
        list(APPEND _vcm_OPTIONS --default-library static)
    endif()
    
    list(APPEND _vcm_OPTIONS --libdir lib) # else meson install into an architecture describing folder
    list(APPEND _vcm_OPTIONS_DEBUG --prefix ${CURRENT_PACKAGES_DIR}/debug --includedir ../include)
    list(APPEND _vcm_OPTIONS_RELEASE --prefix  ${CURRENT_PACKAGES_DIR})
    
    vcpkg_find_acquire_program(MESON)
    
    get_filename_component(CMAKE_PATH ${CMAKE_COMMAND} DIRECTORY)
    vcpkg_add_to_path("${CMAKE_PATH}") # Make CMake invokeable for Meson

    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    vcpkg_add_to_path("${NINJA_PATH}")

    if(NOT ENV{PKG_CONFIG})
        find_program(PKGCONFIG pkg-config)
        if(NOT PKGCONFIG AND CMAKE_HOST_WIN32)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
            vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        endif()
        find_program(PKGCONFIG pkg-config REQUIRED)
    else()
        debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()
    set(PKGCONFIG_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig/")
    if(WIN32)
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_SHARE_DIR "${PKGCONFIG_SHARE_DIR}")
    endif()
    # configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")        
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        
        #setting up PKGCONFIG
        if(NOT PKGCONFIG MATCHES "--define-variable=prefix")
            set(PKGCONFIG_PREFIX "${CURRENT_INSTALLED_DIR}/debug")
            # if(WIN32)
                # string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_PREFIX "${PKGCONFIG_PREFIX}")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${PKGCONFIG_PREFIX}")
        endif()
        set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/")
        if(WIN32)
            string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_INSTALLED_DIR "${PKGCONFIG_INSTALLED_DIR}")
        endif()
        if(ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}: ${PKGCONFIG_SHARE_DIR}: $ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}: ${PKGCONFIG_SHARE_DIR}")
        endif()

        set(CFLAGS "-Dc_args=[${MESON_COMMON_CFLAGS} ${MESON_DEBUG_CFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" CFLAGS ${CFLAGS}) # Seperate compiler arguments with comma and enclose in '
        string(REGEX REPLACE " *\\\]" "']" CFLAGS ${CFLAGS}) # Add trailing ' at end
        string(REGEX REPLACE "\\\['," "[" CFLAGS ${CFLAGS}) # Remove prepended ', introduced in #1
        string(REGEX REPLACE "\\\['\\\]" "[]" CFLAGS ${CFLAGS}) # Remove trailing ' introduced in #2 if no elements

        set(CXXFLAGS "-Dcpp_args=[${MESON_COMMON_CXXFLAGS} ${MESON_DEBUG_CXXFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['," "[" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['\\\]" "[]" CXXFLAGS ${CXXFLAGS})

        set(LDFLAGS "[${MESON_COMMON_LDFLAGS} ${MESON_DEBUG_LDFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE " *\\\]" "']" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['," "[" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['\\\]" "[]" LDFLAGS ${LDFLAGS})
        set(CLDFLAGS "-Dc_link_args=${LDFLAGS}")
        set(CXXLDFLAGS "-Dcpp_link_args=${LDFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_DEBUG} ${_vcm_SOURCE_PATH} ${CFLAGS} ${CXXFLAGS} ${CLDFLAGS} ${CXXLDFLAGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        
        #Copy meson log files into buildtree for CI
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/meson-logs/meson-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/meson-logs/meson-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/meson-log.txt" "${CURRENT_BUILDTREES_DIR}/meson-log-dbg.txt")
        endif()
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/meson-logs/install-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/meson-logs/install-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/install-log.txt" "${CURRENT_BUILDTREES_DIR}/install-log-dbg.txt")
        endif()
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
        
        #Restore PKG_CONFIG_PATH
        if(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_DEBUG}")
            unset(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG)
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
    endif()
    
    # configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)        
        #setting up PKGCONFIG
        if(NOT PKGCONFIG MATCHES "--define-variable=prefix")
            set(PKGCONFIG_PREFIX "${CURRENT_INSTALLED_DIR}")
            # if(WIN32)
                # string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_PREFIX "${PKGCONFIG_PREFIX}")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${PKGCONFIG_PREFIX}")
        endif()
        set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/")
        if(WIN32)
            string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" PKGCONFIG_INSTALLED_DIR "${PKGCONFIG_INSTALLED_DIR}")
        endif()
        if(ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}: ${PKGCONFIG_SHARE_DIR}: $ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}: ${PKGCONFIG_SHARE_DIR}")
        endif()

        # Normalize flags for meson (i.e. " /string /with /flags " -> ['/string', '/with', '/flags'])
        set(CFLAGS "-Dc_args=[${MESON_COMMON_CFLAGS} ${MESON_RELEASE_CFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" CFLAGS ${CFLAGS}) # Seperate compiler arguments with comma and enclose in '
        string(REGEX REPLACE " *\\\]" "']" CFLAGS ${CFLAGS}) # Add trailing ' at end
        string(REGEX REPLACE "\\\['," "[" CFLAGS ${CFLAGS}) # Remove prepended ', introduced in #1
        string(REGEX REPLACE "\\\['\\\]" "[]" CFLAGS ${CFLAGS}) # Remove trailing ' introduced in #2 if no elements
        set(CXXFLAGS "-Dcpp_args=[${MESON_COMMON_CXXFLAGS} ${MESON_RELEASE_CXXFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['," "[" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['\\\]" "[]" CXXFLAGS ${CXXFLAGS})
        set(LDFLAGS "[${MESON_COMMON_LDFLAGS} ${MESON_RELEASE_LDFLAGS}]")
        string(REGEX REPLACE " +(/|-)" "','\\1" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE " *\\\]" "']" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['," "[" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['\\\]" "[]" LDFLAGS ${LDFLAGS})
        set(CLDFLAGS "-Dc_link_args=${LDFLAGS}")
        set(CXXLDFLAGS "-Dcpp_link_args=${LDFLAGS}")
        
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_RELEASE} ${_vcm_SOURCE_PATH} ${CFLAGS} ${CXXFLAGS} ${CLDFLAGS} ${CXXLDFLAGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        #Copy meson log files into buildtree for CI
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/meson-logs/meson-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/meson-logs/meson-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/meson-log.txt" "${CURRENT_BUILDTREES_DIR}/meson-log-rel.txt")
        endif()
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/meson-logs/install-log.txt")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/meson-logs/install-log.txt" DESTINATION "${CURRENT_BUILDTREES_DIR}")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/install-log.txt" "${CURRENT_BUILDTREES_DIR}/install-log-rel.txt")
        endif()
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
        
        #Restore PKG_CONFIG_PATH
        if(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_RELEASE}")
            unset(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE)
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        
    endif()

endfunction()
