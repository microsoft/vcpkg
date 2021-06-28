#[===[.md:
# vcpkg_configure_make

Configure configure for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_make(
    SOURCE_PATH <${SOURCE_PATH}>
    [AUTOCONFIG]
    [USE_WRAPPERS]
    [DETERMINE_BUILD_TRIPLET]
    [BUILD_TRIPLET "--host=x64 --build=i686-unknown-pc"]
    [NO_ADDITIONAL_PATHS]
    [CONFIG_DEPENDENT_ENVIRONMENT <SOME_VAR>...]
    [CONFIGURE_ENVIRONMENT_VARIABLES <SOME_ENVVAR>...]
    [ADD_BIN_TO_PATH]
    [NO_DEBUG]
    [SKIP_CONFIGURE]
    [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the directory containing the ``configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### SKIP_CONFIGURE
Skip configure process

### USE_WRAPPERS
Use autotools ar-lib and compile wrappers (only applies to windows cl and lib)

### BUILD_TRIPLET
Used to pass custom --build/--target/--host to configure. Can be globally overwritten by VCPKG_MAKE_BUILD_TRIPLET

### DETERMINE_BUILD_TRIPLET
For ports having a configure script following the autotools rules for selecting the triplet

### NO_ADDITIONAL_PATHS
Don't pass any additional paths except for --prefix to the configure call

### AUTOCONFIG
Need to use autoconfig to generate configure file.

### PRERUN_SHELL
Script that needs to be called before configuration (do not use for batch files which simply call autoconf or configure)

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during configure such that executables can run against the in-tree DLLs.

## DISABLE_VERBOSE_FLAGS
do not pass '--disable-silent-rules --verbose' to configure

### OPTIONS
Additional options passed to configure during the configuration.

### OPTIONS_RELEASE
Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.

### CONFIG_DEPENDENT_ENVIRONMENT
List of additional configuration dependent environment variables to set. 
Pass SOMEVAR to set the environment and have SOMEVAR_(DEBUG|RELEASE) set in the portfile to the appropriate values
General environment variables can be set from within the portfile itself. 

### CONFIGURE_ENVIRONMENT_VARIABLES
List of additional environment variables to pass via the configure call. 

## Notes
This command supplies many common arguments to configure. To see the full list, examine the source.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
#]===]

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
    # TODO: the host system processor architecture can differ from the host triplet target architecture
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    elseif(DEFINED ENV{PROCESSOR_ARCHITECTURE})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    else()
        set(HOST_ARCH "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
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

macro(_vcpkg_determine_autotools_host_arch_mac out_var)
    set(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
endmacro()

macro(_vcpkg_determine_autotools_target_arch_mac out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES _num_osx_archs)
    if(_num_osx_archs EQUAL 0)
        set(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    elseif(_num_osx_archs GREATER_EQUAL 2)
        set(${out_var} "universal")
    else()
        # Better match the arch behavior of config.guess
        # See: https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
        if(VCPKG_OSX_ARCHITECTURES MATCHES "^(ARM|arm)64$")
            set(${out_var} "aarch64")
        else()
            set(${out_var} "${VCPKG_OSX_ARCHITECTURES}")
        endif()
    endif()
    unset(_num_osx_archs)
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

macro(_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags _SUFFIX)
    string(REGEX MATCHALL "( |^)-D[^ ]+" CPPFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${_SUFFIX}}")
    string(REGEX MATCHALL "( |^)-D[^ ]+" CXXPPFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${_SUFFIX}}")
    list(JOIN CXXPPFLAGS_${_SUFFIX} "|" CXXREGEX)
    if(CXXREGEX)
        list(FILTER CPPFLAGS_${_SUFFIX} INCLUDE REGEX "(${CXXREGEX})")
    else()
        set(CPPFLAGS_${_SUFFIX})
    endif()
    list(JOIN CPPFLAGS_${_SUFFIX} "|" CPPREGEX)
    list(JOIN CPPFLAGS_${_SUFFIX} " " CPPFLAGS_${_SUFFIX})
    set(CPPFLAGS_${_SUFFIX} "${CPPFLAGS_${_SUFFIX}}")
    if(CPPREGEX)
        string(REGEX REPLACE "(${CPPREGEX})" "" CFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${_SUFFIX}}")
        string(REGEX REPLACE "(${CPPREGEX})" "" CXXFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${_SUFFIX}}")
    else()
        set(CFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${_SUFFIX}}")
        set(CXXFLAGS_${_SUFFIX} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${_SUFFIX}}")
    endif()
    string(REGEX REPLACE " +" " " CPPFLAGS_${_SUFFIX} "${CPPFLAGS_${_SUFFIX}}")
    string(REGEX REPLACE " +" " " CFLAGS_${_SUFFIX} "${CFLAGS_${_SUFFIX}}")
    string(REGEX REPLACE " +" " " CXXFLAGS_${_SUFFIX} "${CXXFLAGS_${_SUFFIX}}")
    # libtool has and -R option so we need to guard against -RTC by using -Xcompiler
    # while configuring there might be a lot of unknown compiler option warnings due to that
    # just ignore them. 
    string(REGEX REPLACE "((-|/)RTC[^ ]+)" "-Xcompiler \\1" CFLAGS_${_SUFFIX} "${CFLAGS_${_SUFFIX}}")
    string(REGEX REPLACE "((-|/)RTC[^ ]+)" "-Xcompiler \\1" CXXFLAGS_${_SUFFIX} "${CXXFLAGS_${_SUFFIX}}")
    string(STRIP "${CPPFLAGS_${_SUFFIX}}" CPPFLAGS_${_SUFFIX})
    string(STRIP "${CFLAGS_${_SUFFIX}}" CFLAGS_${_SUFFIX})
    string(STRIP "${CXXFLAGS_${_SUFFIX}}" CXXFLAGS_${_SUFFIX})
    debug_message("CPPFLAGS_${_SUFFIX}: ${CPPFLAGS_${_SUFFIX}}")
    debug_message("CFLAGS_${_SUFFIX}: ${CFLAGS_${_SUFFIX}}")
    debug_message("CXXFLAGS_${_SUFFIX}: ${CXXFLAGS_${_SUFFIX}}")
endmacro()

function(vcpkg_configure_make)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _csc
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;USE_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")
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

    if(CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe") #only applies to windows (clang-)cl and lib
        if(_csc_AUTOCONFIG)
            set(_csc_USE_WRAPPERS TRUE)
        else()
            # Keep the setting from portfiles.
            # Without autotools we assume a custom configure script which correctly handles cl and lib.
            # Otherwise the port needs to set CC|CXX|AR and probably CPP.
        endif()
    else()
        set(_csc_USE_WRAPPERS FALSE)
    endif()

    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(_cm_FLAGS AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
    list(TRANSFORM _cm_FLAGS APPEND "FLAGS")
    _vcpkg_backup_env_variables(${_cm_FLAGS})


    # FC fotran compiler | FF Fortran 77 compiler 
    # LDFLAGS -> pass -L flags
    # LIBS -> pass -l flags

    #Used by gcc/linux
    _vcpkg_backup_env_variables(C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH)

    #Used by cl
    _vcpkg_backup_env_variables(INCLUDE LIB LIBPATH)

    set(_vcm_paths_with_spaces FALSE)
    if(CURRENT_PACKAGES_DIR MATCHES " " OR CURRENT_INSTALLED_DIR MATCHES " ")
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
        set(_vcm_paths_with_spaces TRUE)
    endif()

    # Pre-processing windows configure requirements
    if (VCPKG_TARGET_IS_WINDOWS)
        if(CMAKE_HOST_WIN32)
            list(APPEND MSYS_REQUIRE_PACKAGES binutils libtool autoconf automake-wrapper automake1.16 m4)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES} ${_csc_ADDITIONAL_MSYS_PACKAGES})
        endif()
        if (_csc_AUTOCONFIG AND NOT _csc_BUILD_TRIPLET OR _csc_DETERMINE_BUILD_TRIPLET OR VCPKG_CROSSCOMPILING AND NOT _csc_BUILD_TRIPLET)
            _vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => machine you are building on => --build=
            _vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(CMAKE_HOST_WIN32)
                set(_csc_BUILD_TRIPLET "--build=${BUILD_ARCH}-pc-mingw32")  # This is required since we are running in a msys
                                                                            # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
            endif()
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32) # we don't need to specify the additional flags if we build nativly, this does not hold when we are not on windows
                string(APPEND _csc_BUILD_TRIPLET " --host=${TARGET_ARCH}-pc-mingw32") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            if(VCPKG_TARGET_IS_UWP AND NOT _csc_BUILD_TRIPLET MATCHES "--host")
                # Needs to be different from --build to enable cross builds.
                string(APPEND _csc_BUILD_TRIPLET " --host=${TARGET_ARCH}-unknown-mingw32")
            endif()
            debug_message("Using make triplet: ${_csc_BUILD_TRIPLET}")
        endif()
        if(CMAKE_HOST_WIN32)
            set(APPEND_ENV)
            if(_csc_USE_WRAPPERS)
                set(APPEND_ENV ";${MSYS_ROOT}/usr/share/automake-1.16")
                string(APPEND APPEND_ENV ";${SCRIPTS}/buildsystems/make_wrapper") # Other required wrappers are also located there
            endif()
            # This inserts msys before system32 (which masks sort.exe and find.exe) but after MSVC (which avoids masking link.exe)
            string(REPLACE ";$ENV{SystemRoot}\\System32;" "${APPEND_ENV};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "$ENV{PATH}")
            string(REPLACE ";$ENV{SystemRoot}\\system32;" "${APPEND_ENV};${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
            set(ENV{PATH} "${NEWPATH}")
            set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")
        endif()

        macro(_vcpkg_append_to_configure_environment inoutstring var defaultval)
            # Allows to overwrite settings in custom triplets via the environment on windows
            if(CMAKE_HOST_WIN32 AND DEFINED ENV{${var}})
                string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
            else()
                string(APPEND ${inoutstring} " ${var}='${defaultval}'")
            endif()
        endmacro()

        set(CONFIGURE_ENV "V=1")
        # Remove full filepaths due to spaces and prepend filepaths to PATH (cross-compiling tools are unlikely on path by default)
        set(progs VCPKG_DETECTED_CMAKE_C_COMPILER VCPKG_DETECTED_CMAKE_CXX_COMPILER VCPKG_DETECTED_CMAKE_AR
                  VCPKG_DETECTED_CMAKE_LINKER VCPKG_DETECTED_CMAKE_RANLIB VCPKG_DETECTED_CMAKE_OBJDUMP
                  VCPKG_DETECTED_CMAKE_STRIP VCPKG_DETECTED_CMAKE_NM VCPKG_DETECTED_CMAKE_DLLTOOL VCPKG_DETECTED_CMAKE_RC_COMPILER)
        foreach(prog IN LISTS progs)
            if(${prog})
                set(path "${${prog}}")
                unset(prog_found CACHE)
                get_filename_component(${prog} "${${prog}}" NAME)
                find_program(prog_found ${${prog}} PATHS ENV PATH NO_DEFAULT_PATH)
                if(NOT path STREQUAL prog_found)
                    get_filename_component(path "${path}" DIRECTORY)
                    vcpkg_add_to_path(PREPEND ${path})
                endif()
            endif()
        endforeach()
        if (_csc_USE_WRAPPERS)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")

            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV RC "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV WINDRES "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            else()
                _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "ar-lib lib.exe -verbose")
            endif()
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV RC "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV WINDRES "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "lib.exe -verbose")
            endif()
        endif()
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV LD "${VCPKG_DETECTED_CMAKE_LINKER} -verbose")
        if(VCPKG_DETECTED_CMAKE_RANLIB)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV RANLIB "${VCPKG_DETECTED_CMAKE_RANLIB}") # Trick to ignore the RANLIB call
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV RANLIB ":")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # Trick to ignore the RANLIB call
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # If required set the ENV variable STRIP in the portfile correctly
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV STRIP "${VCPKG_DETECTED_CMAKE_STRIP}") 
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV STRIP ":")
            list(APPEND _csc_OPTIONS ac_cv_prog_ac_ct_STRIP=:)
        endif()
        if(VCPKG_DETECTED_CMAKE_NM) # If required set the ENV variable NM in the portfile correctly
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV NM "${VCPKG_DETECTED_CMAKE_NM}") 
        else()
            # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
            # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV NM "dumpbin.exe -symbols -headers")
        endif()
        if(VCPKG_DETECTED_CMAKE_DLLTOOL) # If required set the ENV variable DLLTOOL in the portfile correctly
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV DLLTOOL "${VCPKG_DETECTED_CMAKE_DLLTOOL}") 
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV DLLTOOL "link.exe -verbose -dll")
        endif()
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV AS ":")   # If required set the ENV variable AS in the portfile correctly

        foreach(_env IN LISTS _csc_CONFIGURE_ENVIRONMENT_VARIABLES)
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV ${_env} "${${_env}}")
        endforeach()
        debug_message("CONFIGURE_ENV: '${CONFIGURE_ENV}'")
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 

        # Variables not correctly detected by configure. In release builds.
        list(APPEND _csc_OPTIONS gl_cv_double_slash_root=yes
                                 ac_cv_func_memmove=yes)
        #list(APPEND _csc_OPTIONS lt_cv_deplibs_check_method=pass_all) # Just ignore libtool checks 
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND _csc_OPTIONS gl_cv_host_cpu_c_abi=no)
            # Currently needed for arm64 because objdump yields: "unrecognised machine type (0xaa64) in Import Library Format archive"
            list(APPEND _csc_OPTIONS lt_cv_deplibs_check_method=pass_all)
        elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]$")
            # Currently needed for arm because objdump yields: "unrecognised machine type (0x1c4) in Import Library Format archive"
            list(APPEND _csc_OPTIONS lt_cv_deplibs_check_method=pass_all)
        endif()
    endif()

    if(CMAKE_HOST_WIN32)
        #Some PATH handling for dealing with spaces....some tools will still fail with that!
        string(REPLACE " " "\\\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PREFIX "${_VCPKG_PREFIX}")
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(prefix_var "'\${prefix}'") # Windows needs extra quotes or else the variable gets expanded in the makefile!
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES)
        set(prefix_var "\${prefix}")
    endif()

    # macOS - cross-compiling support
    if(VCPKG_TARGET_IS_OSX)
        if (_csc_AUTOCONFIG AND NOT _csc_BUILD_TRIPLET OR _csc_DETERMINE_BUILD_TRIPLET)
            _vcpkg_determine_autotools_host_arch_mac(BUILD_ARCH) # machine you are building on => --build=
            _vcpkg_determine_autotools_target_arch_mac(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}") # we don't need to specify the additional flags if we build natively.
                set(_csc_BUILD_TRIPLET "--host=${TARGET_ARCH}-apple-darwin") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            debug_message("Using make triplet: ${_csc_BUILD_TRIPLET}")
        endif()
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

    # Can be set in the triplet to append options for configure
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS)
        list(APPEND _csc_OPTIONS ${VCPKG_MAKE_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE)
        list(APPEND _csc_OPTIONS_RELEASE ${VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG)
        list(APPEND _csc_OPTIONS_DEBUG ${VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG})
    endif()

    file(RELATIVE_PATH RELATIVE_BUILD_PATH "${CURRENT_BUILDTREES_DIR}" "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    set(base_cmd)
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc --debug)
    else()
        find_program(base_cmd bash REQUIRED)
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        list(JOIN _csc_OPTIONS " " _csc_OPTIONS)
        list(JOIN _csc_OPTIONS_RELEASE " " _csc_OPTIONS_RELEASE)
        list(JOIN _csc_OPTIONS_DEBUG " " _csc_OPTIONS_DEBUG)
    endif()
    
    # Setup include environment (since these are buildtype independent restoring them is unnecessary)
    macro(prepend_include_path var)
        if("${${var}_BACKUP}" STREQUAL "")
            set(ENV{${var}} "${_VCPKG_INSTALLED}/include")
        else()
            set(ENV{${var}} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${${var}_BACKUP}")
        endif()
    endmacro()
    # Used by CL 
    prepend_include_path(INCLUDE)
    # Used by GCC
    prepend_include_path(C_INCLUDE_PATH)
    prepend_include_path(CPLUS_INCLUDE_PATH)

    # Flags should be set in the toolchain instead (Setting this up correctly requires a function named vcpkg_determined_cmake_compiler_flags which can also be used to setup CC and CXX etc.)
    if(VCPKG_TARGET_IS_WINDOWS)
        _vcpkg_backup_env_variables(_CL_ _LINK_)
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to: 
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            string(REPLACE "\\" "/" VCToolsInstallDir "$ENV{VCToolsInstallDir}")
            # Can somebody please check if CMake's compiler flags for UWP are correct?
            set(ENV{_CL_} "$ENV{_CL_} /D_UNICODE /DUNICODE /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB_ -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            string(APPEND VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE " -ZW:nostdlib")
            string(APPEND VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG " -ZW:nostdlib")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES} /MANIFEST /DYNAMICBASE /WINMD:NO /APPCONTAINER") 
        endif()
    endif()

    macro(convert_to_list input output)
        string(REGEX MATCHALL "(( +|^ *)[^ ]+)" ${output} "${${input}}")
    endmacro()
    convert_to_list(VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES C_LIBS_LIST)
    convert_to_list(VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES CXX_LIBS_LIST)
    set(ALL_LIBS_LIST ${C_LIBS_LIST} ${CXX_LIBS_LIST})
    list(REMOVE_DUPLICATES ALL_LIBS_LIST)
    list(TRANSFORM ALL_LIBS_LIST STRIP)
    #Do lib list transformation from name.lib to -lname if necessary
    set(_VCPKG_TRANSFORM_LIBS TRUE)
    if(VCPKG_TARGET_IS_UWP)
        set(_VCPKG_TRANSFORM_LIBS FALSE)
        # Avoid libtool choke: "Warning: linker path does not have real file for library -lWindowsApp."
        # The problem with the choke is that libtool always falls back to built a static library even if a dynamic was requested. 
        # Note: Env LIBPATH;LIB are on the search path for libtool by default on windows. 
        # It even does unix/dos-short/unix transformation with the path to get rid of spaces. 
    endif()
    set(_lprefix)
    if(_VCPKG_TRANSFORM_LIBS)
        set(_lprefix "-l")
        list(TRANSFORM ALL_LIBS_LIST REPLACE "(.dll.lib|.lib|.a|.so)$" "")
        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM ALL_LIBS_LIST "uuid")
        endif()
        list(TRANSFORM ALL_LIBS_LIST REPLACE "^(${_lprefix})" "")
    endif()
    list(JOIN ALL_LIBS_LIST " ${_lprefix}" ALL_LIBS_STRING)
    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # libtool must be told explicitly that there is no dynamic linkage for uuid.
        # The "-Wl,..." syntax is understood by libtool and gcc, but no by ld.
        string(REPLACE " -luuid" " -Wl,-Bstatic,-luuid,-Bdynamic" ALL_LIBS_STRING "${ALL_LIBS_STRING}")
    endif()

    if(ALL_LIBS_STRING)
        set(ALL_LIBS_STRING "${_lprefix}${ALL_LIBS_STRING}")
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${ALL_LIBS_STRING}")
        else()
            set(ENV{LIBS} "${ALL_LIBS_STRING}")
        endif()
    endif()
    debug_message("ENV{LIBS}:$ENV{LIBS}")
    vcpkg_find_acquire_program(PKGCONFIG)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT PKGCONFIG STREQUAL "--static")
        set(PKGCONFIG "${PKGCONFIG} --static") # Is this still required or was the PR changing the pc files accordingly merged?
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
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(LINKER_FLAGS_${_VAR_SUFFIX} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else() # dynamic
            set(LINKER_FLAGS_${_VAR_SUFFIX} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        _vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
            if(NOT _vcm_paths_with_spaces)
                set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
            endif()
            if(DEFINED ENV{_LINK_})
                set(LINK_ENV_${_VAR_SUFFIX} "$ENV{_LINK_} ${LINKER_FLAGS_${_VAR_SUFFIX}}")
            else()
                set(LINK_ENV_${_VAR_SUFFIX} "${LINKER_FLAGS_${_VAR_SUFFIX}}")
            endif()
        else()
            set(_link_dirs)
            if(EXISTS "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib")
                set(_link_dirs "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib")
            endif()
            if(EXISTS "{_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
                set(_link_dirs "${_link_dirs} -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
            endif()
            string(STRIP "${_link_dirs}" _link_dirs)
            set(LDFLAGS_${_VAR_SUFFIX} "${_link_dirs} ${LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        unset(_VAR_SUFFIX)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_VAR_SUFFIX RELEASE)
        set(PATH_SUFFIX_${_VAR_SUFFIX} "")
        set(SHORT_NAME_${_VAR_SUFFIX} "rel")
        list(APPEND _buildtypes ${_VAR_SUFFIX})
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(LINKER_FLAGS_${_VAR_SUFFIX} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else() # dynamic
            set(LINKER_FLAGS_${_VAR_SUFFIX} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        _vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
            if(NOT _vcm_paths_with_spaces)
                set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
            endif()
            if(DEFINED ENV{_LINK_})
                set(LINK_ENV_${_VAR_SUFFIX} "$ENV{_LINK_} ${LINKER_FLAGS_${_VAR_SUFFIX}}")
            else()
                set(LINK_ENV_${_VAR_SUFFIX} "${LINKER_FLAGS_${_VAR_SUFFIX}}")
            endif()
        else()
            set(_link_dirs)
            if(EXISTS "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib")
                set(_link_dirs "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib")
            endif()
            if(EXISTS "{_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
                set(_link_dirs "${_link_dirs} -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link")
            endif()
            string(STRIP "${_link_dirs}" _link_dirs)
            set(LDFLAGS_${_VAR_SUFFIX} "${_link_dirs} ${LINKER_FLAGS_${_VAR_SUFFIX}}")
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

        # Setup PKG_CONFIG_PATH
        set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}${PATH_SUFFIX_${_buildtype}}/lib/pkgconfig")
        set(PKGCONFIG_INSTALLED_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
        if(ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}")
        endif()

        # Setup environment
        set(ENV{CPPFLAGS} "${CPPFLAGS_${_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${_buildtype}}")
        set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${_buildtype}}")

        # https://www.gnu.org/software/libtool/manual/html_node/Link-mode.html
        # -avoid-version is handled specially by libtool link mode, this flag is not forwarded to linker,
        # and libtool tries to avoid versioning for shared libraries and no symbolic links are created.
        if(VCPKG_TARGET_IS_ANDROID)
            set(ENV{LDFLAGS} "-avoid-version $ENV{LDFLAGS}")
        endif()

        if(LINK_ENV_${_VAR_SUFFIX})
            set(_LINK_CONFIG_BACKUP "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${_VAR_SUFFIX}}")
        endif()
        set(ENV{PKG_CONFIG} "${PKGCONFIG}")

        set(_lib_env_vars LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)
        foreach(_lib_env_var IN LISTS _lib_env_vars)
            set(_link_path)
            if(EXISTS "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib")
                set(_link_path "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib")
            endif()
            if(EXISTS "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link")
                if(_link_path)
                    set(_link_path "${_link_path}${VCPKG_HOST_PATH_SEPARATOR}")
                endif()
                set(_link_path "${_link_path}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link")
            endif()
            set(ENV{${_lib_env_var}} "${_link_path}${${_lib_env_var}_PATHLIKE_CONCAT}")
        endforeach()
        unset(_link_path)
        unset(_lib_env_vars)

        if(CMAKE_HOST_WIN32)
            set(command "${base_cmd}" -c "${CONFIGURE_ENV} ./${RELATIVE_BUILD_PATH}/configure ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}}")
        elseif(VCPKG_TARGET_IS_WINDOWS)
            set(command "${base_cmd}" -c "${CONFIGURE_ENV} $@" -- "./${RELATIVE_BUILD_PATH}/configure" ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}})
        else()
            set(command "${base_cmd}" "./${RELATIVE_BUILD_PATH}/configure" ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}})
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
            if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                file(GLOB_RECURSE LIBTOOL_FILES "${TAR_DIR}*/libtool")
                foreach(lt_file IN LISTS LIBTOOL_FILES)
                    file(READ "${lt_file}" _contents)
                    string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                    file(WRITE "${lt_file}" "${_contents}")
                endforeach()
            endif()
            
            if(EXISTS "${TAR_DIR}/config.log")
                file(RENAME "${TAR_DIR}/config.log" "${CURRENT_BUILDTREES_DIR}/config.log-${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}.log")
            endif()
        endif()

        if(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype}}")
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        unset(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})
        
        if(_LINK_CONFIG_BACKUP)
            set(ENV{_LINK_} "${_LINK_CONFIG_BACKUP}")
            unset(_LINK_CONFIG_BACKUP)
        endif()
        
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
    _vcpkg_restore_env_variables(${_cm_FLAGS} LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
