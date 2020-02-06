## # vcpkg_configure_make
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [DISABLE_AUTO_HOST]
##     [DISABLE_AUTO_DST]
##     [GENERATOR]
##     [NO_DEBUG]
##     [SKIP_CONFIGURE]
##     [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]+
##     [PKG_CONFIG_PATHS <$CONFIG_PATH>]
##     [PKG_CONFIG_PATHS_DEBUG <$CONFIG_PATH>]
##     [PKG_CONFIG_PATHS_RELEASE <$CONFIG_PATH>]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PROJECT_SUBPATH
## Specifies the directory containing the ``configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
## Should use `GENERATOR NMake` first.
##
## ### NO_DEBUG
## This port doesn't support debug mode.
##
## ### SKIP_CONFIGURE
## Skip configure process
##
## ### AUTOCONFIG
## Need to use autoconfig to generate configure file.
##
## ### DISABLE_AUTO_HOST
## Don't set host automatically, the default value is `i686`.
## If use this option, you will need to set host manually.
##
## ### DISABLE_AUTO_DST
## Don't set installation path automatically, the default value is `${CURRENT_PACKAGES_DIR}` and `${CURRENT_PACKAGES_DIR}/debug`
## If use this option, you will need to set dst path manually.
##
## ### GENERATOR
## Specifies the precise generator to use.
## NMake: nmake(windows) make(unix)
## MAKE: make(windows) make(unix)
##
## ### PRERUN_SHELL
## Script that needs to be called before configuration
##
## ### OPTIONS
## Additional options passed to configure during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.
##
## ### PKG_CONFIG_PATHS(_RELEASE|_DEBUG)
## Appends the listed PATHS to the enviorment variable PKG_CONFIG_PATH
##
## ## Notes
## This command supplies many common arguments to configure. To see the full list, examine the source.
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
macro(_vcpkg_get_mingw_vars)
    set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    set(MINGW_W w64)
    set(MINGW_PACKAGES)
    #message(STATUS "${HOST_ARCH}")
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(MINGW_HOST x86_64-w64-mingw32)
        set(HOST_ARCH x64)
        set(BITS 64)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(MINGW_HOST i686-w64-mingw32)
        set(HOST_ARCH x86)
        set(BITS 32)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)64$")
        set(MINGW_HOST i686-w64-mingw32)
        set(HOST_ARCH x86)
        set(BITS 32)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)$")
        set(HOST_ARCH x86)
        set(BITS 32)
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_get_msys_toolchain!" )
    else()
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_get_msys_toolchain!" )
    endif()
    set(TARGET_ARCH ${VCPKG_TARGET_ARCHITECTURE})
    
    if(NOT "${HOST_ARCH}" STREQUAL "${TARGET_ARCH}")
        list(APPEND MINGW_PACKAGES mingw-w64-cross-gcc)
        if(${HOST_ARCH} MATCHES "x64" AND ${TARGET_ARCH} MATCHES "x86")
            set(MINGW_HOST i686)
            set(MINGW_TARGET i686-w64-mingw32)
            set(MINGW_NAME mingw64)
        elseif(${HOST_ARCH} MATCHES "x86|ARM64" AND ${TARGET_ARCH} MATCHES "x64")            
            set(MINGW_TOOLCHAIN x86_64)
            set(MINGW_TARGET x86_64-w64-mingw32)
            set(MINGW_NAME mingw32)
        else()
            message(FATAL_ERROR "Unsupported host/target architecture combination ${HOST_ARCH}/${TARGET_ARCH} in _vcpkg_get_msys_toolchain!" )
        endif()
    else()
        if(${TARGET_ARCH} MATCHES "x64")
            set(MINGW_HOST_TYPE x86_64)
            set(MINGW_NAME mingw64)
            set(MINGW_TARGET x86_64-w64-mingw32)
        elseif(${TARGET_ARCH} MATCHES "x86|ARM64")
            set(MINGW_HOST_TYPE i686)
            set(MINGW_NAME mingw32)
            set(MINGW_TARGET i686-w64-mingw32)
        endif()
    endif()
    
    set(MINGW_TOOLCHAIN mingw-${MINGW_W}-${MINGW_HOST_TYPE})
    set(MINGW_PACKAGES_LIST gcc make pkg-config)
    
    foreach(_pack ${MINGW_PACKAGES_LIST})
        list(APPEND MINGW_PACKAGES ${MINGW_TOOLCHAIN}-${_pack})
    endforeach()    
    message(STATUS "MINGW_PACKAGES:${MINGW_PACKAGES}")
endmacro()


function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;DISABLE_AUTO_HOST;DISABLE_AUTO_DST;NO_DEBUG;SKIP_CONFIGURE"
        "SOURCE_PATH;PROJECT_SUBPATH;GENERATOR;PRERUN_SHELL"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;PKG_CONFIG_PATHS;PKG_CONFIG_PATHS_DEBUG;PKG_CONFIG_PATHS_RELEASE;CONFIGURE_PATCHES"
        ${ARGN}
    )
    
    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()
    
    if (_csc_OPTIONS_DEBUG STREQUAL _csc_OPTIONS_RELEASE OR NMAKE_OPTION_RELEASE STREQUAL NMAKE_OPTION_DEBUG)
        message(FATAL_ERROR "Detected debug configuration is equal to release configuration, please use NO_DEBUG for vcpkg_configure_make")
    endif()
    # Select compiler
    if(_csc_GENERATOR MATCHES "NMake")
        message(FATAL_ERROR "Sorry, NMake does not supported currently.")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "nmake")
        else()
            set(GENERATOR "make")
        endif()
    elseif(NOT _csc_GENERATOR OR _csc_GENERATOR MATCHES "MAKE")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "make")
        else()
            set(GENERATOR "make")
        endif()
    else()
        message(FATAL_ERROR "${_csc_GENERATOR} not supported.")
    endif()
    if(_csc_PKG_CONFIG_PATHS)
        set(BACKUP_ENV_PKG_CONFIG_PATH $ENV{PKG_CONFIG_PATH})
        foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS)
            file(TO_NATIVE_PATH "${_path}" _path)
            set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
        endforeach()
    endif()
    set(WIN_TARGET_ARCH )
    set(WIN_TARGET_COMPILER )
    # Detect compiler
    if (GENERATOR STREQUAL "nmake")
        message(STATUS "Using generator NMAKE")
        find_program(NMAKE nmake REQUIRED)
    elseif (GENERATOR STREQUAL "make")
        message(STATUS "Using generator make")
        find_program(MAKE make REQUIRED)
    else()
        message(FATAL_ERROR "${GENERATOR} not supported.")
    endif()

    if(${CURRENT_PACKAGES_DIR} MATCHES " " OR ${CURRENT_INSTALLED_DIR} MATCHES " ")
        # Don't bother with whitespaces on Linux. The tools will fail anyway and I tried very hard to make it work!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
    endif()

    # Pre-processing windows configure requirements
    if (CMAKE_HOST_WIN32)
        ##  Please read https://github.com/orlp/dev-on-windows/wiki/Installing-GCC--&-MSYS2
        set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled PARENT_SCOPE) # since we cannot use dumpbin on the generated dll'ds
        vcpkg_find_acquire_program(YASM)
        vcpkg_find_acquire_program(PERL)
        set(MSYS_REQUIRE_PACKAGES diffutils)
        _vcpkg_get_mingw_vars()
        if (_csc_AUTOCONFIG)
            list(APPEND MSYS_REQUIRE_PACKAGES autoconf automake m4 libtool perl pkg-config gcc)
            if(NOT VCPKG_USE_POSIX_TOOLCHAIN)
                list(APPEND MSYS_REQUIRE_PACKAGES ${MINGW_PACKAGES})
            endif()
        endif()
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES})
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
        
        if (NOT _csc_DISABLE_AUTO_HOST)
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                set(BUILD_TARGET "--build=${MINGW_TARGET} --target==${MINGW_TARGET}")
                set(HOST_TYPE --host=i686-w64-mingw32)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
                set(BUILD_TARGET "--build=${MINGW_TARGET} --target==${MINGW_TARGET}")
                set(HOST_TYPE --host=x86_64-w64-mingw64)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
                set(BUILD_TARGET --target=arm-pc-mingw32)
                set(HOST_TYPE --host=i686-w64-mingw32)
            endif()
            #x86_64-pc-mingw32 #x86_64-w64-mingw32 #--enable-secure-api #--enable-64bit #
        endif()

        vcpkg_add_to_path("${YASM_EXE_PATH}")
        if(NOT VCPKG_USE_POSIX_TOOLCHAIN)
            if(HOST_ARCH MATCHES "x86|arm")
                vcpkg_add_to_path("${MSYS_ROOT}/mingw32/bin")
                vcpkg_add_to_path("${MSYS_ROOT}/mingw32/i686-w64-mingw32/bin")
            elseif(HOST_ARCH STREQUAL x64)
                vcpkg_add_to_path("${MSYS_ROOT}/mingw64/bin")
                vcpkg_add_to_path("${MSYS_ROOT}/mingw64/x86_64-w64-mingw32/bin")
            endif()
        endif()
        
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        vcpkg_add_to_path("${PERL_EXE_PATH}")
        set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")
    elseif (_csc_AUTOCONFIG)
        find_program(AUTORECONF autoreconf REQUIRED)
        find_program(LIBTOOL libtool REQUIRED)
    endif()

    if(NOT ENV{PKG_CONFIG})
        find_program(PKGCONFIG pkg-config REQUIRED)
        message(STATUS "Using pkg-config from: ${PKGCONFIG}")
    else()
        message(STATUS "PKG_CONF ENV found! Using: $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    if(WIN32)
        string(REPLACE " " "\\\ " _VCPKG_PREFIX ${CURRENT_PACKAGES_DIR})
        #string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PREFIX "${_VCPKG_PREFIX}")
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        set(EXTRA_QUOTES "\\\"")
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX ${CURRENT_PACKAGES_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES)
    endif()

    if (NOT _csc_DISABLE_AUTO_DST)
        set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
                                "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}${EXTRA_QUOTES}"
                                "--bindir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/bin${EXTRA_QUOTES}"
                                "--sbindir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/bin${EXTRA_QUOTES}"
                                "--libdir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/lib${EXTRA_QUOTES}"
                                "--includedir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/include${EXTRA_QUOTES}"
                                "--mandir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/share/${PORT}${EXTRA_QUOTES}"
                                "--docdir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/share/${PORT}${EXTRA_QUOTES}")
        set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_RELEASE}
                                "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug${EXTRA_QUOTES}"
                                "--bindir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug/bin${EXTRA_QUOTES}"
                                "--sbindir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug/bin${EXTRA_QUOTES}"
                                "--libdir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug/lib${EXTRA_QUOTES}"
                                "--includedir=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug/include${EXTRA_QUOTES}")
    endif()

    set(base_cmd)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(_csc_OPTIONS ${_csc_OPTIONS} --enable-shared --disable-static)
    else()
        set(_csc_OPTIONS ${_csc_OPTIONS} --enable-static --disable-shared)
    endif()
    file(RELATIVE_PATH RELATIVE_BUILD_PATH "${CURRENT_BUILDTREES_DIR}" "${_csc_SOURCE_PATH}")
    
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc)
        
        if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            if (VCPKG_TARGET_IS_UWP)
                set(_csc_OPTIONS ${_csc_OPTIONS} --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib)
            endif()
        endif()
        # Load toolchains
        if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        endif()
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
        
        if(VCPKG_TARGET_IS_UWP)
            set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
            set(_csc_OPTIONS ${_csc_OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00)
        endif()
        
        list(JOIN _csc_OPTIONS " " _csc_OPTIONS)
        list(JOIN _csc_OPTIONS_RELEASE " " _csc_OPTIONS_RELEASE)
        list(JOIN _csc_OPTIONS_DEBUG " " _csc_OPTIONS_DEBUG)

        set(rel_command
            ${base_cmd} -c "${COMPILER_CC} eval ./../${RELATIVE_BUILD_PATH}/configure \"${BUILD_TARGET} ${HOST_TYPE} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}\"")
        set(dbg_command
            ${base_cmd} -c "${COMPILER_CC} eval ./../${RELATIVE_BUILD_PATH}/configure \"${BUILD_TARGET} ${HOST_TYPE} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}\"")

    else()
        set(rel_command "./../${RELATIVE_BUILD_PATH}/configure" ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE})
        set(dbg_command "./../${RELATIVE_BUILD_PATH}/configure" ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG})
        
    endif()

    # Backup enviromnent variables
    set(C_FLAGS_BACKUP "$ENV{CFLAGS}")
    set(CXX_FLAGS_BACKUP "$ENV{CXXFLAGS}")
    set(LD_FLAGS_BACKUP "$ENV{LDFLAGS}")
    set(INCLUDE_PATH_BACKUP "$ENV{INCLUDE_PATH}")
    set(INCLUDE_BACKUP "$ENV{INCLUDE}")
    set(C_INCLUDE_PATH_BACKUP "$ENV{C_INCLUDE_PATH}")
    set(CPLUS_INCLUDE_PATH_BACKUP "$ENV{CPLUS_INCLUDE_PATH}")
    set(LD_LIBRARY_PATH_BACKUP "$ENV{LD_LIBRARY_PATH}")
    set(LIBRARY_PATH_BACKUP "$ENV{LIBRARY_PATH}")

    # Setup include enviromnent
    set(ENV{INCLUDE} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_PATH_BACKUP}")
    set(ENV{INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${CPLUS_INCLUDE_PATH_BACKUP}")

    # Setup global flags
    set(C_FLAGS_GLOBAL "$ENV{CFLAGS} ${VCPKG_C_FLAGS}")
    set(CXX_FLAGS_GLOBAL "$ENV{CXXFLAGS} ${VCPKG_CXX_FLAGS}")
    set(LD_FLAGS_GLOBAL "$ENV{LDFLAGS} ${VCPKG_LINKER_FLAGS}")
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        string(APPEND C_FLAGS_GLOBAL " -fPIC")
        string(APPEND CXX_FLAGS_GLOBAL " -fPIC")
    endif()

    set(SRC_DIR "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")
    if (_csc_AUTOCONFIG)
        message(STATUS "Generating configure for ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "autoreconf -vfi"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        else()
            vcpkg_execute_required_process(
                COMMAND autoreconf -vfi
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        endif()
        message(STATUS "Finished configure for ${TARGET_TRIPLET}")
    endif()

    # Configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT _csc_NO_DEBUG)
        if(_csc_PKG_CONFIG_PATHS_DEBUG)
            set(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS_DEBUG)
                file(TO_NATIVE_PATH "${_path}" _path)
                if(ENV{PKG_CONFIG_PATH})
                    set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
                else()
                    set(ENV{PKG_CONFIG_PATH} "${_path}")
                endif()
            endforeach()
        endif()

        # Setup debug enviromnent
        if (CMAKE_HOST_WIN32)
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}/debug")
        else()
            set(ENV{CFLAGS} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(ENV{LDFLAGS} "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_DEBUG}")
            set(ENV{LIBRARY_PATH} "${LIBRARY_PATH_BACKUP}${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/")
            set(ENV{LD_LIBRARY_PATH} "${LD_LIBRARY_PATH_BACKUP}${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}/debug")
        endif()

        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(PRJ_DIR "${TAR_DIR}/${_csc_PROJECT_SUBPATH}")
        
        file(MAKE_DIRECTORY "${TAR_DIR}")

        # if (NOT CMAKE_HOST_WIN32)
            # file(GLOB_RECURSE SOURCE_FILES ${_csc_SOURCE_PATH}/*)
            # foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
                # get_filename_component(DST_DIR ${ONE_SOUCRCE_FILE} PATH)
                # string(REPLACE "${_csc_SOURCE_PATH}" "${OBJ_DIR}" DST_DIR "${DST_DIR}")
                # file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${DST_DIR})
            # endforeach()
        # endif()

        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "${_csc_PRERUN_SHELL}"
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()

        if (NOT _csc_SKIP_CONFIGURE)
            if(_csc_CONFIGURE_PATCHES)
                vcpkg_apply_patches(SOURCE_PATH "${PRJ_DIR}" PATCHES "${_csc_CONFIGURE_PATCHES}")
            endif()
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()
        
        if(_csc_PKG_CONFIG_PATHS_DEBUG)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_DEBUG}")
        endif()
    endif()

    # Configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(_csc_PKG_CONFIG_PATHS_RELEASE)
            set(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS_RELEASE)
                file(TO_NATIVE_PATH "${_path}" _path)
                if(ENV{PKG_CONFIG_PATH})
                    set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
                else()
                    set(ENV{PKG_CONFIG_PATH} "${_path}")
                endif()
            endforeach()
        endif()

        # Setup release enviromnent
        if (CMAKE_HOST_WIN32)
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}")
        else()
            set(ENV{CFLAGS} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_RELEASE}")
            set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_RELEASE}")
            set(ENV{LDFLAGS} "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_RELEASE}")
            set(ENV{LIBRARY_PATH} "${LIBRARY_PATH_BACKUP}${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/")
            set(ENV{LD_LIBRARY_PATH} "${LD_LIBRARY_PATH_BACKUP}${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}")
        endif()
        
        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(PRJ_DIR "${TAR_DIR}/${_csc_PROJECT_SUBPATH}")
        
        file(MAKE_DIRECTORY ${TAR_DIR})
        
        # if (NOT CMAKE_HOST_WIN32)
            # ##COPY SOURCES
            # file(GLOB_RECURSE SOURCE_FILES ${_csc_SOURCE_PATH}/*)
            # foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
                # get_filename_component(DST_DIR ${ONE_SOUCRCE_FILE} PATH)
                # string(REPLACE "${_csc_SOURCE_PATH}" "${OBJ_DIR}" DST_DIR "${DST_DIR}")
                # file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${DST_DIR})
            # endforeach()
        # endif()
        
        if (NOT _csc_SKIP_CONFIGURE)
            if(_csc_CONFIGURE_PATCHES)
                vcpkg_apply_patches(SOURCE_PATH "${PRJ_DIR}" PATCHES "${_csc_CONFIGURE_PATCHES}")
            endif()
            message(STATUS "Configuring ${TAR_TRIPLET_DIR}")
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-rel
            )
        endif()
        
        if(_csc_PKG_CONFIG_PATHS_RELEASE)
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_RELEASE}")
        endif()
    endif()
    
    # Restore enviromnent
    set(ENV{CFLAGS} "${C_FLAGS_BACKUP}")
    set(ENV{CXXFLAGS} "${CXX_FLAGS_BACKUP}")
    set(ENV{LDFLAGS} "${LD_FLAGS_BACKUP}")

    set(ENV{INCLUDE} "${INCLUDE_BACKUP}")
    set(ENV{INCLUDE_PATH} "${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${CPLUS_INCLUDE_PATH_BACKUP}")
    set(ENV{LIBRARY_PATH} "${LIBRARY_PATH_BACKUP}")
    set(ENV{LD_LIBRARY_PATH} "${LD_LIBRARY_PATH_BACKUP}")

    if(_csc_PKG_CONFIG_PATHS)
        set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH}")
    endif()

    set(_VCPKG_MAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
    set(_VCPKG_NO_DEBUG ${_csc_NO_DEBUG} PARENT_SCOPE)
    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
