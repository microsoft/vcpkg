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
    # --build: the machine you are building on
    # --host: the machine you are building for
    # --target: the machine that GCC will produce binary for
    set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    set(MINGW_W w64)
    set(MINGW_PACKAGES)
    #message(STATUS "${HOST_ARCH}")
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(MSYS_HOST x86_64)
        set(HOST_ARCH x64)
        set(BITS 64)
        #list(APPEND MINGW_PACKAGES mingw-w64-x86_64-cccl)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(MSYS_HOST i686)
        set(HOST_ARCH x86)
        set(BITS 32)
        #list(APPEND MINGW_PACKAGES mingw-w64-i686-cccl)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)64$")
        set(MSYS_HOST arm)
        set(HOST_ARCH arm)
        set(BITS 32)
        #list(APPEND MINGW_PACKAGES mingw-w64-i686-cccl)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)$")
        set(MSYS_HOST arm)
        set(HOST_ARCH arm)
        set(BITS 32)
        #list(APPEND MINGW_PACKAGES mingw-w64-i686-cccl)
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_get_msys_toolchain!" )
    else()
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_get_msys_toolchain!" )
    endif()
    set(TARGET_ARCH ${VCPKG_TARGET_ARCHITECTURE})
endmacro()

function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;DISABLE_AUTO_HOST;DISABLE_AUTO_DST;NO_DEBUG;SKIP_CONFIGURE"
        "SOURCE_PATH;PROJECT_SUBPATH;GENERATOR;PRERUN_SHELL;CONFIGURE_OS"
        "OPTIONS_DEBUG;OPTIONS_RELEASE;OPTIONS;PKG_CONFIG_PATHS_DEBUG;PKG_CONFIG_PATHS_RELEASE;PKG_CONFIG_PATHS;CONFIGURE_PATCHES"
        ${ARGN}
    )
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
    set(LIBPATH_BACKUP "$ENV{LIBPATH}")

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
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
    endif()

    #set(ENV{V} 1)
    # Pre-processing windows configure requirements
    if (CMAKE_HOST_WIN32)
        _vcpkg_get_mingw_vars() # rename to _vcpkg_determine_host
        
        set(MSYS_REQUIRE_PACKAGES diffutils pkg-config binutils libtool make)

        if (_csc_AUTOCONFIG)
            list(APPEND MSYS_REQUIRE_PACKAGES autoconf automake m4 autoconf-archive)
        endif()

        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES})
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")

        file(CREATE_LINK "${MSYS_ROOT}/usr/bin/sort.exe" "${SCRIPTS}/sort.exe" COPY_ON_ERROR)
        file(CREATE_LINK "${MSYS_ROOT}/usr/bin/find.exe" "${SCRIPTS}/find.exe" COPY_ON_ERROR)
        vcpkg_add_to_path(PREPEND "${SCRIPTS}")
         
        # vcpkg_find_acquire_program(YASM)
        # get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        # vcpkg_add_to_path("${YASM_EXE_PATH}")

        # vcpkg_find_acquire_program(PERL)
        # get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
        # vcpkg_add_to_path("${PERL_EXE_PATH}")

        if (NOT _csc_DISABLE_AUTO_HOST)
                # --build: the machine you are building on
                # --host: the machine you are building for
                # --target: the machine that CC will produce binaries for
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                set(BUILD_TARGET "--build=${MSYS_HOST}-pc-mingw32 --target=i686-pc-mingw32 --host=i686-pc-mingw32")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
                set(BUILD_TARGET "--build=${MSYS_HOST}-pc-mingw32 --target=x86_64-pc-mingw32 --host=x86_64-pc-mingw32")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)            
                set(BUILD_TARGET "--build=${MSYS_HOST}-pc-mingw32 --target=arm-pc-mingw32 --host=i686-pc-mingw32")
            endif()
        endif()
        #set(MSVCROOTPATH "$ENV{VCToolsInstallDir}bin\\Host$ENV{VSCMD_ARG_HOST_ARCH}\\$ENV{VSCMD_ARG_TGT_ARCH}")
        #set(MSVCENVROOT "\$(VCToolsInstallDir)bin\\Host\$(VSCMD_ARG_HOST_ARCH)\\\$(VSCMD_ARG_TGT_ARCH)")
        if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
            set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
        elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
        else()
            message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
        endif()
        
        set(ENV{V} "1")
        #set(ENV{CPP} "cl_cp_wrapper")
        #set(ENV{RAWCPP} "cl_cp_wrapper")
        set(COMPILER_CC "CC='cl.exe -nologo' CPP='cl_cpp_wrapper' LD='link.exe -verbose' NM='dumpbin.exe -symbols -headers -all' DLLTOOL='link.exe -verbose -dll' AR='ar_lib_wrapper' AR_FLAGS='--verbose /VERBOSE' RANLIB='echo' ")

        string(REPLACE " " "\\\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PREFIX "${_VCPKG_PREFIX}")
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES)
    endif()

    if(NOT ENV{PKG_CONFIG})
        find_program(PKGCONFIG pkg-config PATHS "${MSYS_ROOT}/usr/bin" REQUIRED)
        message(STATUS "Using pkg-config from: ${PKGCONFIG}")
    else()
        message(STATUS "PKG_CONF ENV found! Using: $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    if (NOT _csc_DISABLE_AUTO_DST)
        set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
                                "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}${EXTRA_QUOTES}"
                                "--bindir='\${prefix}'/tools/${PORT}/bin"
                                "--sbindir='\${prefix}'/tools/${PORT}/sbin"
                                #"--libdir='\${prefix}'/lib"
                                #"--includedir='\${prefix}'/include"
                                "--mandir='\${prefix}'/share/${PORT}"
                                "--docdir='\${prefix}'/share/${PORT}")
        set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
                                "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug${EXTRA_QUOTES}"
                                "--bindir='\${prefix}'/debug/../tools/${PORT}/debug/bin"
                                "--sbindir='\${prefix}'/debug/../tools/${PORT}/debug/sbin"
                                #"--libdir='\${prefix}'/lib"
                                "--includedir='\${prefix}'/../include")
    endif()

    set(base_cmd)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(_csc_OPTIONS ${_csc_OPTIONS} --disable-silent-rules --verbose --enable-shared --disable-static)
    else()
        set(_csc_OPTIONS ${_csc_OPTIONS} --disable-silent-rules --verbose --enable-static --disable-shared)
    endif()
    file(RELATIVE_PATH RELATIVE_BUILD_PATH "${CURRENT_BUILDTREES_DIR}" "${_csc_SOURCE_PATH}")
    
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --norc --verbose --debug)        
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
        #set(PKG_CONFIG_PATH_DEBUG "PKG_CONFIG_PATH=${_VCPKG_INSTALLED}/debug/lib/pkgconfig")
        set(rel_command
            ${base_cmd} -c "echo $PATH & echo $MSVCENVROOT & ${COMPILER_CC} ./../${RELATIVE_BUILD_PATH}/configure ${BUILD_TARGET} ${HOST_TYPE}${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}")
        set(dbg_command
            ${base_cmd} -c "echo $PATH & echo $MSVCENVROOT & ${COMPILER_CC} ./../${RELATIVE_BUILD_PATH}/configure ${BUILD_TARGET} ${HOST_TYPE}${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}")
    else()
        set(rel_command /bin/sh "./../${RELATIVE_BUILD_PATH}/configure" ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE})
        set(dbg_command /bin/sh "./../${RELATIVE_BUILD_PATH}/configure" ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG})
    endif()

    # Setup include enviromnent
    set(ENV{INCLUDE} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_BACKUP}")
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
    else()
        string(APPEND C_FLAGS_GLOBAL " /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
        string(APPEND CXX_FLAGS_GLOBAL " /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
        string(APPEND LD_FLAGS_GLOBAL " /VERBOSE -no-undefined")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            string(APPEND LD_FLAGS_GLOBAL " /machine:x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            string(APPEND LD_FLAGS_GLOBAL " /machine:x86")
        endif()
    endif()

    set(SRC_DIR "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")
    if(EXISTS "${SRC_DIR}/configure")
        set(_csc_AUTOCONFIG FALSE)
    elseif(EXISTS "${SRC_DIR}/configure.ac")
        set(_csc_AUTOCONFIG TRUE)
    endif()
    if (_csc_AUTOCONFIG)
        find_program(AUTORECONF autoreconf REQUIRED)
        find_program(LIBTOOL libtool REQUIRED)
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
        # Apply additional patches to configure after autoconf run
        if(_csc_CONFIGURE_PATCHES)
            vcpkg_apply_patches(SOURCE_PATH "${SRC_DIR}" PATCHES "${_csc_CONFIGURE_PATCHES}")
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
        message(STATUS "Config path $ENV{PKG_CONFIG_PATH}")
        # Setup debug enviromnent
        if (CMAKE_HOST_WIN32)
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_C_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_CXX_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_DEBUG}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}/debug")
        else()
            set(ENV{CFLAGS} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(ENV{LDFLAGS} "-L${_VCPKG_INSTALLED}/debug/lib/ -L${_VCPKG_INSTALLED}/debug/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_DEBUG}")
            set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LIBRARY_PATH_BACKUP}")
            set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}/debug/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/debug/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LD_LIBRARY_PATH_BACKUP}")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}/debug")
        endif()

        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(PRJ_DIR "${TAR_DIR}/${_csc_PROJECT_SUBPATH}")
        
        file(MAKE_DIRECTORY "${TAR_DIR}")

        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "${_csc_PRERUN_SHELL}"
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()

        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
            if(EXISTS "${PRJ_DIR}/libtool" AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                set(_file "${PRJ_DIR}/libtool")
                file(READ "${_file}" _contents)
                string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                file(WRITE "${_file}" "${_contents}")
            endif()
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
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_C_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_CXX_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_RELEASE}")
            string(REGEX REPLACE "[ \t]+/" " -" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}")
        else()
            set(ENV{CFLAGS} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_RELEASE}")
            set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_RELEASE}")
            set(ENV{LDFLAGS} "-L${_VCPKG_INSTALLED}/lib/ -L${_VCPKG_INSTALLED}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_RELEASE}")
            set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LIBRARY_PATH_BACKUP}")
            set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}/lib/manual-link/${VCPKG_HOST_PATH_SEPARATOR}${LD_LIBRARY_PATH_BACKUP}")
            # endif()
            set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}")
        endif()
        
        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(PRJ_DIR "${TAR_DIR}/${_csc_PROJECT_SUBPATH}")
        
        file(MAKE_DIRECTORY ${TAR_DIR})

        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY "${PRJ_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-rel                
            )
            if(EXISTS "${PRJ_DIR}/libtool" AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                set(_file "${PRJ_DIR}/libtool")
                file(READ "${_file}" _contents)
                string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                file(WRITE "${_file}" "${_contents}")
            endif()
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
