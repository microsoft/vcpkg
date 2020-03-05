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
    cmake_parse_arguments(_vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;PKG_CONFIG_PATHS;PKG_CONFIG_PATHS_DEBUG;PKG_CONFIG_PATHS_RELEASE" ${ARGN})
    
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    if(WIN32)
        set(_VCPKG_PREFIX ${CURRENT_PACKAGES_DIR})
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES "\\\"")
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX "${CURRENT_PACKAGES_DIR}")
        string(REPLACE " " "\ " _VCPKG_INSTALLED "${CURRENT_INSTALLED_DIR}")
        set(EXTRA_QUOTES)
    endif()

    # use the same compiler options as in vcpkg_configure_cmake
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(_MESON_FLAG_SUFFIX "_INIT")
        if(NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME OR _TARGETTING_UWP)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
            set(_MESON_FLAG_SUFFIX "")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
        endif()
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    
    if(_vcm_PKG_CONFIG_PATHS)
        set(BACKUP_ENV_PKG_CONFIG_PATH $ENV{PKG_CONFIG_PATH})
        foreach(_path IN LISTS _vcm_PKG_CONFIG_PATHS)
            file(TO_NATIVE_PATH "${_path}" _path)
            set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
        endforeach()
    endif()
    
    string(APPEND MESON_COMMON_CFLAGS " ${CMAKE_C_FLAGS${_MESON_FLAG_SUFFIX}}") #-I\"${CURRENT_INSTALLED_DIR}/include\"
    string(APPEND MESON_COMMON_CXXFLAGS " ${CMAKE_CXX_FLAGS${_MESON_FLAG_SUFFIX}}") #-I\"${CURRENT_INSTALLED_DIR}/include\"

    string(APPEND MESON_DEBUG_CFLAGS " ${CMAKE_C_FLAGS_DEBUG${_MESON_FLAG_SUFFIX}}")
    string(APPEND MESON_DEBUG_CXXFLAGS " ${CMAKE_CXX_FLAGS_DEBUG${_MESON_FLAG_SUFFIX}}")

    string(APPEND MESON_RELEASE_CFLAGS " ${CMAKE_C_FLAGS_RELEASE${_MESON_FLAG_SUFFIX}}")
    string(APPEND MESON_RELEASE_CXXFLAGS " ${CMAKE_CXX_FLAGS_RELEASE${_MESON_FLAG_SUFFIX}}")
    
    if(VCPKG_TARGET_IS_WINDOWS)
        string(APPEND MESON_COMMON_LDFLAGS " /DEBUG")
        string(APPEND MESON_RELEASE_LDFLAGS " /INCREMENTAL:NO /OPT:REF /OPT:ICF")
    endif()
    
    # select meson cmd-line options
    list(APPEND _vcm_OPTIONS -Dcmake_prefix_path=${CURRENT_INSTALLED_DIR})
    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _vcm_OPTIONS --default-library shared)
    else()
        list(APPEND _vcm_OPTIONS --default-library static)
    endif()
    
    list(APPEND _vcm_OPTIONS_DEBUG --prefix ${CURRENT_PACKAGES_DIR}/debug --includedir ../include --libdir lib)
    list(APPEND _vcm_OPTIONS_RELEASE --prefix  ${CURRENT_PACKAGES_DIR} --libdir lib --optimization 3 )
    
    vcpkg_find_acquire_program(MESON)
    
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
        message(STATUS "PKG_CONF ENV found: $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()
    
    # configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(PKGCONFIG)
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}")
        endif()
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        if(_vcm_PKG_CONFIG_PATHS_RELEASE)
            set(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _vcm_PKG_CONFIG_PATHS_RELEASE)
                file(TO_NATIVE_PATH "${_path}" _path)
                set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
            endforeach()
        endif()

        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

        #set(ENV{LDFLAGS} "${MESON_COMMON_LDFLAGS} ${MESON_RELEASE_LDFLAGS}") #-L${CURRENT_INSTALLED_DIR}/lib -L${CURRENT_INSTALLED_DIR}/lib/manual-link 
        
        set(CFLAGS "-Dc_args=[${MESON_COMMON_CFLAGS} ${MESON_RELEASE_CFLAGS}]")
        string(REGEX REPLACE " +/" "','/" CFLAGS ${CFLAGS})
        string(REGEX REPLACE "\\\[\'," "[" CFLAGS ${CFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CFLAGS ${CFLAGS})
        set(CXXFLAGS "-Dcpp_args=[${MESON_COMMON_CXXFLAGS} ${MESON_RELEASE_CXXFLAGS}]")
        string(REGEX REPLACE " +/" "','/" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['," "[" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CXXFLAGS ${CXXFLAGS})
        set(LDFLAGS "[${MESON_COMMON_LDFLAGS} ${MESON_RELEASE_LDFLAGS}]")
        string(REGEX REPLACE " +/" "','/" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['," "[" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE " *\\\]" "']" LDFLAGS ${LDFLAGS})
        set(CLDFLAGS "-Dc_link_args=${LDFLAGS}")
        set(CXXLDFLAGS "-Dcpp_link_args=${LDFLAGS}")
        #message(STATUS "C:${CFLAGS}\nCXX:${CXXFLAGS}\nCLD:${CLDFLAGS}\nCXXLD:${CXXLDFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_RELEASE} ${_vcm_SOURCE_PATH} ${CFLAGS} ${CXXFLAGS} ${CLDFLAGS} ${CXXLDFLAGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
        if(_vcm_PKG_CONFIG_PATHS_RELEASE)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_RELEASE}")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(PKGCONFIG)
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}/debug")
        endif()
        # configure debug
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        if(_vcm_PKG_CONFIG_PATHS_DEBUG)
            set(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _vcm_PKG_CONFIG_PATHS_DEBUG)
                file(TO_NATIVE_PATH "${_path}" _path)
                set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
            endforeach()
        endif()
        
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(CFLAGS "-Dc_args=[${MESON_COMMON_CFLAGS} ${MESON_DEBUG_CFLAGS}]")
        string(REGEX REPLACE " +/" "','-" CFLAGS ${CFLAGS})
        string(REGEX REPLACE "\\\[\'," "[" CFLAGS ${CFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CFLAGS ${CFLAGS})
        set(CXXFLAGS "-Dcpp_args=[${MESON_COMMON_CXXFLAGS} ${MESON_DEBUG_CXXFLAGS}]")
        string(REGEX REPLACE " +/" "','-" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE "\\\['," "[" CXXFLAGS ${CXXFLAGS})
        string(REGEX REPLACE " *\\\]" "']" CXXFLAGS ${CXXFLAGS})
        set(LDFLAGS "[${MESON_COMMON_LDFLAGS} ${MESON_DEBUG_LDFLAGS}]")
        string(REGEX REPLACE " +/" "','-" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE "\\\['," "[" LDFLAGS ${LDFLAGS})
        string(REGEX REPLACE " *\\\]" "']" LDFLAGS ${LDFLAGS})
        set(CLDFLAGS "-Dc_link_args=${LDFLAGS}")
        set(CXXLDFLAGS "-Dcpp_link_args=${LDFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_DEBUG} ${_vcm_SOURCE_PATH} ${CFLAGS} ${CXXFLAGS} ${CLDFLAGS} ${CXXLDFLAGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
        if(_vcm_PKG_CONFIG_PATHS_RELEASE)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_RELEASE}")
        endif()
    endif()
    if(_vcm_PKG_CONFIG_PATHS)
        set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH}")
    endif()
endfunction()
