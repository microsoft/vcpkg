## # vcpkg_configure_make
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [USE_WRAPPERS]
##     [BUILD_TRIPLET "--host=x64 --build=i686-unknown-pc"]
##     [NO_ADDITIONAL_PATHS]
##     [CONFIG_DEPENDENT_ENVIRONMENT <SOME_VAR>...]
##     [CONFIGURE_ENVIRONMENT_VARIABLES <SOME_ENVVAR>...]
##     [ADD_BIN_TO_PATH]
##     [NO_DEBUG]
##     [SKIP_CONFIGURE]
##     [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
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
##
## ### SKIP_CONFIGURE
## Skip configure process
##
## ### USE_WRAPPERS
## Use autotools ar-lib and compile wrappers (only applies to windows cl and lib)
##
## ### BUILD_TRIPLET
## Used to pass custom --build/--target/--host to configure. Can be globally overwritten by VCPKG_MAKE_BUILD_TRIPLET
##
## ### DETERMINE_BUILD_TRIPLET
## For ports having a configure script following the autotools rules for selecting the triplet
##
## ### NO_ADDITIONAL_PATHS
## Don't pass any additional paths except for --prefix to the configure call
##
## ### AUTOCONFIG
## Need to use autoconfig to generate configure file.
##
## ### PRERUN_SHELL
## Script that needs to be called before configuration (do not use for batch files which simply call autoconf or configure)
##
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during configure such that executables can run against the in-tree DLLs.
##
## ## DISABLE_VERBOSE_FLAGS
## do not pass '--disable-silent-rules --verbose' to configure
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
## ### CONFIG_DEPENDENT_ENVIRONMENT
## List of additional configuration dependent environment variables to set. 
## Pass SOMEVAR to set the environment and have SOMEVAR_(DEBUG|RELEASE) set in the portfile to the appropriate values
## General environment variables can be set from within the portfile itself. 
##
## ### CONFIGURE_ENVIRONMENT_VARIABLES
## List of additional environment variables to pass via the configure call. 
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
macro(_vcpkg_determine_host_mingw out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(${out_var} mingw64)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(${out_var} mingw32)
    else()
        message(FATAL_ERROR "Unsupported mingw architecture ${HOST_ARCH} in _vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(HOST_ARCH)
endmacro()

macro(_vcpkg_determine_autotools_host_cpu out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(${out_var} x86_64)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(HOST_ARCH)
endmacro()

macro(_vcpkg_determine_autotools_target_cpu out_var)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)64")
        set(${out_var} x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported VCPKG_TARGET_ARCHITECTURE architecture ${VCPKG_TARGET_ARCHITECTURE} in _vcpkg_determine_autotools_target_cpu!" )
    endif()
endmacro()

macro(_vcpkg_backup_env_variable envvar)
    if(DEFINED ENV{${envvar}})
        set(${envvar}_BACKUP "$ENV{${envvar}}")
        set(${envvar}_PATHLIKE_CONCAT "${VCPKG_HOST_PATH_SEPARATOR}$ENV{${envvar}}")
    else()
        set(${envvar}_BACKUP)
        set(${envvar}_PATHLIKE_CONCAT)
    endif()
endmacro()

macro(_vcpkg_backup_env_variables)
    foreach(_var ${ARGV})
        _vcpkg_backup_env_variable(${_var})
    endforeach()
endmacro()

macro(_vcpkg_restore_env_variable envvar)
    if(${envvar}_BACKUP)
        set(ENV{${envvar}} "${${envvar}_BACKUP}")
    else()
        unset(ENV{${envvar}})
    endif()
endmacro()

macro(_vcpkg_restore_env_variables)
    foreach(_var ${ARGV})
        _vcpkg_restore_env_variable(${_var})
    endforeach()
endmacro()

function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;USE_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT"
        ${ARGN}
    )
    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(_csc_BUILD_TRIPLET ${VCPKG_MAKE_BUILD_TRIPLET}) # Triplet overwrite for crosscompiling
    endif()

    set(SRC_DIR "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    set(REQUIRES_AUTOGEN FALSE) # use autogen.sh
    set(REQUIRES_AUTOCONFIG FALSE) # use autotools and configure.ac
    if(EXISTS "${SRC_DIR}/configure" AND "${SRC_DIR}/configure.ac") # remove configure; rerun autoconf
        if(NOT VCPKG_MAINTAINER_SKIP_AUTOCONFIG) # If fixing bugs skipping autoconfig saves a lot of time
            set(REQUIRES_AUTOCONFIG TRUE)
            file(REMOVE "${SRC_DIR}/configure") # remove possible autodated configure scripts
            set(_csc_AUTOCONFIG ON)
        endif()
    elseif(EXISTS "${SRC_DIR}/configure" AND NOT _csc_SKIP_CONFIGURE) # run normally; no autoconf or autgen required
    elseif(EXISTS "${SRC_DIR}/configure.ac") # Run autoconfig
        set(REQUIRES_AUTOCONFIG TRUE)
        set(_csc_AUTOCONFIG ON)
    elseif(EXISTS "${SRC_DIR}/autogen.sh") # Run autogen
        set(REQUIRES_AUTOGEN TRUE)
    else()
        message(FATAL_ERROR "Could not determine method to configure make")
    endif()

    debug_message("REQUIRES_AUTOGEN:${REQUIRES_AUTOGEN}")
    debug_message("REQUIRES_AUTOCONFIG:${REQUIRES_AUTOCONFIG}")
    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(FLAGPREFIXES CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y)
    foreach(_prefix IN LISTS FLAGPREFIXES)
        _vcpkg_backup_env_variable(${prefix}FLAGS)
    endforeach()

    # FC fotran compiler | FF Fortran 77 compiler 
    # LDFLAGS -> pass -L flags
    # LIBS -> pass -l flags

    #Used by gcc/linux
    _vcpkg_backup_env_variables(C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH)

    #Used by cl
    _vcpkg_backup_env_variables(INCLUDE LIB LIBPATH)

    if(CURRENT_PACKAGES_DIR MATCHES " " OR CURRENT_INSTALLED_DIR MATCHES " ")
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
    endif()

    # Pre-processing windows configure requirements
    if (CMAKE_HOST_WIN32)
        list(APPEND MSYS_REQUIRE_PACKAGES binutils libtool autoconf automake-wrapper automake1.16 m4)
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES})
        
        if (_csc_AUTOCONFIG AND NOT _csc_BUILD_TRIPLET OR _csc_DETERMINE_BUILD_TRIPLET)
            _vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => machine you are building on => --build=
            _vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            set(_csc_BUILD_TRIPLET "--build=${BUILD_ARCH}-pc-mingw32")  # This is required since we are running in a msys
                                                                        # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}") # we don't need to specify the additional flags if we build nativly. 
                string(APPEND _csc_BUILD_TRIPLET " --host=${TARGET_ARCH}-pc-mingw32") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            if(VCPKG_TARGET_IS_UWP AND NOT _csc_BUILD_TRIPLET MATCHES "--host")
                # Needs to be different from --build to enable cross builds.
                string(APPEND _csc_BUILD_TRIPLET " --host=${TARGET_ARCH}-unknown-mingw32")
            endif()
            debug_message("Using make triplet: ${_csc_BUILD_TRIPLET}")
        endif()
        set(APPEND_ENV)
        if(_csc_AUTOCONFIG OR _csc_USE_WRAPPERS)
            set(APPEND_ENV ";${MSYS_ROOT}/usr/share/automake-1.16")
        endif()
        # This inserts msys before system32 (which masks sort.exe and find.exe) but after MSVC (which avoids masking link.exe)
        string(REPLACE ";$ENV{SystemRoot}\\System32;" "${APPEND_ENV};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "$ENV{PATH}")
        string(REPLACE ";$ENV{SystemRoot}\\system32;" "${APPEND_ENV};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
        set(ENV{PATH} "${NEWPATH}")
        set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")

        macro(_vcpkg_append_to_configure_environment inoutstring var defaultval)
            # Allows to overwrite settings in custom triplets via the environment
            if(DEFINED ENV{${var}})
                string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
            else()
                string(APPEND ${inoutstring} " ${var}='${defaultval}'")
            endif()
        endmacro()

        set(CONFIGURE_ENV "V=1")
        if (_csc_AUTOCONFIG OR _csc_USE_WRAPPERS)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "compile cl.exe -nologo -E")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "compile cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "compile cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "ar-lib lib.exe -verbose")
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "cl.exe -nologo -E")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "lib.exe -verbose")
        endif()
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV LD "link.exe -verbose")
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV RANLIB ":") # Trick to ignore the RANLIB call
        #_vcpkg_append_to_configure_environment(CONFIGURE_ENV OBJDUMP ":") ' Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV STRIP ":")   # If required set the ENV variable STRIP in the portfile correctly
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV NM "dumpbin.exe -symbols -headers")
        # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
        # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV DLLTOOL "link.exe -verbose -dll")

        foreach(_env IN LISTS _csc_CONFIGURE_ENVIRONMENT_VARIABLES)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV ${_env} "${${_env}}")
        endforeach()
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 
    
        #Some PATH handling for dealing with spaces....some tools will still fail with that!
        string(REPLACE " " "\\\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PREFIX "${_VCPKG_PREFIX}")
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        set(prefix_var "'\${prefix}'") # Windows needs extra quotes or else the variable gets expanded in the makefile!
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(_VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES)
        set(prefix_var "\${prefix}")
    endif()

    # Cleanup previous build dirs
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    # Set configure paths
    set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE} "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}${EXTRA_QUOTES}")
    set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG} "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug${EXTRA_QUOTES}")
    if(NOT _csc_NO_ADDITIONAL_PATHS)
        set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/tools/${PORT}/bin"
                            "--sbindir=${prefix_var}/tools/${PORT}/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            #"--includedir='\${prefix}'/include" # already the default!
                            "--mandir=${prefix_var}/share/${PORT}"
                            "--docdir=${prefix_var}/share/${PORT}"
                            "--datarootdir=${prefix_var}/share/${PORT}")
        set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/../tools/${PORT}/debug/bin"
                            "--sbindir=${prefix_var}/../tools/${PORT}/debug/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            "--includedir=${prefix_var}/../include"
                            "--datarootdir=${prefix_var}/share/${PORT}")
    endif()
    # Setup common options
    if(NOT DISABLE_VERBOSE_FLAGS)
        list(APPEND _csc_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND _csc_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND _csc_OPTIONS --disable-shared --enable-static)
    endif()

    file(RELATIVE_PATH RELATIVE_BUILD_PATH "${CURRENT_BUILDTREES_DIR}" "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    set(base_cmd)
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc --debug)
        # Load toolchains
        if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        endif()
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
        #Join the options list as a string with spaces between options
        list(JOIN _csc_OPTIONS " " _csc_OPTIONS)
        list(JOIN _csc_OPTIONS_RELEASE " " _csc_OPTIONS_RELEASE)
        list(JOIN _csc_OPTIONS_DEBUG " " _csc_OPTIONS_DEBUG)
    endif()
    
    # Setup include environment (since these are buildtype independent restoring them is unnecessary)
    # Used by CL 
    set(ENV{INCLUDE} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_BACKUP}")
    # Used by GCC
    set(ENV{C_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${CPLUS_INCLUDE_PATH_BACKUP}")

    # Setup global flags -> TODO: Further improve with toolchain file in mind!
    set(CPP_FLAGS_GLOBAL "$ENV{CPPFLAGS} -I${_VCPKG_INSTALLED}/include")
    set(C_FLAGS_GLOBAL "$ENV{CFLAGS} ${VCPKG_C_FLAGS}")
    set(CXX_FLAGS_GLOBAL "$ENV{CXXFLAGS} ${VCPKG_CXX_FLAGS}")
    set(LD_FLAGS_GLOBAL "$ENV{LDFLAGS} ${VCPKG_LINKER_FLAGS}")
    # Flags should be set in the toolchain instead (Setting this up correctly requires a function named vcpkg_determined_cmake_compiler_flags which can also be used to setup CC and CXX etc.)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        string(APPEND C_FLAGS_GLOBAL " -fPIC")
        string(APPEND CXX_FLAGS_GLOBAL " -fPIC")
    else()
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        string(APPEND CPP_FLAGS_GLOBAL " /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to: 
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            string(REPLACE "\\" "/" VCToolsInstallDir "$ENV{VCToolsInstallDir}")
            set(ENV{_CL_} "$ENV{_CL_} /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB_ -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} /MANIFEST /DYNAMICBASE WindowsApp.lib /WINMD:NO /APPCONTAINER")
        endif()
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            set(ENV{_LINK_} "$ENV{_LINK_} -MACHINE:x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            set(ENV{_LINK_} "$ENV{_LINK_} -MACHINE:x86")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
            set(ENV{_LINK_} "$ENV{_LINK_} -MACHINE:ARM")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
            set(ENV{_LINK_} "$ENV{_LINK_} -MACHINE:ARM64")
        endif()
    endif()
    
    vcpkg_find_acquire_program(PKGCONFIG)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT PKGCONFIG STREQUAL "--static")
        set(PKGCONFIG "${PKGCONFIG} --static")
    endif()
    # Run autoconf if necessary
    set(_GENERATED_CONFIGURE FALSE)
    if (_csc_AUTOCONFIG OR REQUIRES_AUTOCONFIG)
        find_program(AUTORECONF autoreconf)
        if(NOT AUTORECONF)
            message(FATAL_ERROR "${PORT} requires autoconf from the system package manager (example: \"sudo apt-get install autoconf\")")
        endif()
        message(STATUS "Generating configure for ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "autoreconf -vfi"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        else()
            vcpkg_execute_required_process(
                COMMAND ${AUTORECONF} -vfi
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()
    if(REQUIRES_AUTOGEN)
        message(STATUS "Generating configure for ${TARGET_TRIPLET} via autogen.sh")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "./autogen.sh"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "./autogen.sh"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()

    if (_csc_PRERUN_SHELL)
        message(STATUS "Prerun shell with ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ${base_cmd} -c "${_csc_PRERUN_SHELL}"
            WORKING_DIRECTORY "${SRC_DIR}"
            LOGNAME prerun-${TARGET_TRIPLET}
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT _csc_NO_DEBUG)
        set(_VAR_SUFFIX DEBUG)
        set(PATH_SUFFIX_${_VAR_SUFFIX} "/debug")
        set(SHORT_NAME_${_VAR_SUFFIX} "dbg")
        list(APPEND _buildtypes ${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32) # Flags should be set in the toolchain instead
            string(REGEX REPLACE "[ \t]+/" " -" CPPFLAGS_${_VAR_SUFFIX} "${CPP_FLAGS_GLOBAL}")
            string(REGEX REPLACE "[ \t]+/" " -" CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_C_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_CXX_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else()
            set(CPPFLAGS_${_VAR_SUFFIX} "${CPP_FLAGS_GLOBAL}")
            set(CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/ -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        unset(_VAR_SUFFIX)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_VAR_SUFFIX RELEASE)
        set(PATH_SUFFIX_${_VAR_SUFFIX} "")
        set(SHORT_NAME_${_VAR_SUFFIX} "rel")
        list(APPEND _buildtypes ${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32) # Flags should be set in the toolchain 
            string(REGEX REPLACE "[ \t]+/" " -" CPPFLAGS_${_VAR_SUFFIX} "${CPP_FLAGS_GLOBAL}")
            string(REGEX REPLACE "[ \t]+/" " -" CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_C_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_CXX_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else()
            set(CPPFLAGS_${_VAR_SUFFIX} "${CPP_FLAGS_GLOBAL}")
            set(CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/ -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        unset(_VAR_SUFFIX)
    endif()

    foreach(_buildtype IN LISTS _buildtypes)
        foreach(ENV_VAR ${_csc_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(BACKUP_CONFIG_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${_buildtype}}")
        endforeach()

        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}")
        file(MAKE_DIRECTORY "${TAR_DIR}")
        file(RELATIVE_PATH RELATIVE_BUILD_PATH "${TAR_DIR}" "${SRC_DIR}")

        if(_csc_COPY_SOURCE)
            file(COPY "${SRC_DIR}/" DESTINATION "${TAR_DIR}")
            set(RELATIVE_BUILD_PATH .)
        endif()

        set(PKGCONFIG_INSTALLED_DIR "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${_buildtype}}/lib/pkgconfig")
        set(PKGCONFIG_INSTALLED_SHARE_DIR "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")

        if(ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}")
        endif()

        # Setup environment
        set(ENV{CPPFLAGS} ${CPPFLAGS_${_buildtype}})
        set(ENV{CFLAGS} ${CFLAGS_${_buildtype}})
        set(ENV{CXXFLAGS} ${CXXFLAGS_${_buildtype}})
        set(ENV{LDFLAGS} ${LDFLAGS_${_buildtype}})
        set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}")

        set(ENV{LIB} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LIB_PATHLIKE_CONCAT}")
        set(ENV{LIBPATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LIBPATH_PATHLIKE_CONCAT}")
        set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LIBRARY_PATH_PATHLIKE_CONCAT}")
        set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LD_LIBRARY_PATH_PATHLIKE_CONCAT}")

        if (CMAKE_HOST_WIN32)
            set(command ${base_cmd} -c "${CONFIGURE_ENV} ./${RELATIVE_BUILD_PATH}/configure ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}}")
        else()
            set(command /bin/bash "./${RELATIVE_BUILD_PATH}/configure" ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}})
        endif()
        if(_csc_ADD_BIN_TO_PATH)
            set(PATH_BACKUP $ENV{PATH})
            vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_buildtype}}/bin")
        endif()
        debug_message("Configure command:'${command}'")
        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${TAR_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}
            )
            if(EXISTS "${TAR_DIR}/libtool" AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                set(_file "${TAR_DIR}/libtool")
                file(READ "${_file}" _contents)
                string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                file(WRITE "${_file}" "${_contents}")
            endif()
        endif()

        if(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype}}")
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        unset(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})

        if(_csc_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${PATH_BACKUP}")
        endif()
        # Restore environment (config dependent)
        foreach(ENV_VAR ${_csc_CONFIG_DEPENDENT_ENVIRONMENT})
            if(BACKUP_CONFIG_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${BACKUP_CONFIG_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # Restore environment
    foreach(_prefix IN LISTS FLAGPREFIXES)
        _vcpkg_restore_env_variable(${prefix}FLAGS)
    endforeach()

    _vcpkg_restore_env_variables(LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
