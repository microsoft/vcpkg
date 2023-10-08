macro(z_vcpkg_determine_autotools_host_cpu out_var)
    # TODO: the host system processor architecture can differ from the host triplet target architecture
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch $ENV{PROCESSOR_ARCHITEW6432})
    elseif(DEFINED ENV{PROCESSOR_ARCHITECTURE})
        set(host_arch $ENV{PROCESSOR_ARCHITECTURE})
    else()
        set(host_arch "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    endif()
    if(host_arch MATCHES "(amd|AMD)64")
        set(${out_var} x86_64)
    elseif(host_arch MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(host_arch MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(host_arch MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported host architecture ${host_arch} in z_vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(host_arch)
endmacro()

macro(z_vcpkg_determine_autotools_target_cpu out_var)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)64")
        set(${out_var} x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(${out_var} aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(${out_var} arm)
    else()
        message(FATAL_ERROR "Unsupported VCPKG_TARGET_ARCHITECTURE architecture ${VCPKG_TARGET_ARCHITECTURE} in z_vcpkg_determine_autotools_target_cpu!" )
    endif()
endmacro()

macro(z_vcpkg_set_arch_mac out_var value)
    # Better match the arch behavior of config.guess
    # See: https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
    if("${value}" MATCHES "^(ARM|arm)64$")
        set(${out_var} "aarch64")
    else()
        set(${out_var} "${value}")
    endif()
endmacro()

macro(z_vcpkg_determine_autotools_host_arch_mac out_var)
    z_vcpkg_set_arch_mac(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
endmacro()

macro(z_vcpkg_determine_autotools_target_arch_mac out_var)
    list(LENGTH VCPKG_OSX_ARCHITECTURES osx_archs_num)
    if(osx_archs_num EQUAL 0)
        z_vcpkg_set_arch_mac(${out_var} "${VCPKG_DETECTED_CMAKE_HOST_SYSTEM_PROCESSOR}")
    elseif(osx_archs_num GREATER_EQUAL 2)
        set(${out_var} "universal")
    else()
        z_vcpkg_set_arch_mac(${out_var} "${VCPKG_OSX_ARCHITECTURES}")
    endif()
    unset(osx_archs_num)
endmacro()

macro(z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags flag_suffix)
    string(REGEX MATCHALL "( |^)(-D|-isysroot|--sysroot=|-isystem|-m?[Aa][Rr][Cc][Hh]|--target=|-target) ?[^ ]+" CPPFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
    string(REGEX MATCHALL "( |^)(-D|-isysroot|--sysroot=|-isystem|-m?[Aa][Rr][Cc][Hh]|--target=|-target) ?[^ ]+" CXXPPFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    list(JOIN CXXPPFLAGS_${flag_suffix} "|" CXXREGEX)
    if(CXXREGEX)
        list(FILTER CPPFLAGS_${flag_suffix} INCLUDE REGEX "(${CXXREGEX})")
    else()
        set(CPPFLAGS_${flag_suffix})
    endif()
    list(JOIN CPPFLAGS_${flag_suffix} "|" CPPREGEX)
    list(JOIN CPPFLAGS_${flag_suffix} " " CPPFLAGS_${flag_suffix})
    set(CPPFLAGS_${flag_suffix} "${CPPFLAGS_${flag_suffix}}")
    if(CPPREGEX)
        string(REGEX REPLACE "(${CPPREGEX})" "" CFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
        string(REGEX REPLACE "(${CPPREGEX})" "" CXXFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    else()
        set(CFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_C_FLAGS_${flag_suffix}}")
        set(CXXFLAGS_${flag_suffix} "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_${flag_suffix}}")
    endif()
    string(REGEX REPLACE " +" " " CPPFLAGS_${flag_suffix} "${CPPFLAGS_${flag_suffix}}")
    string(REGEX REPLACE " +" " " CFLAGS_${flag_suffix} "${CFLAGS_${flag_suffix}}")
    string(REGEX REPLACE " +" " " CXXFLAGS_${flag_suffix} "${CXXFLAGS_${flag_suffix}}")
    string(STRIP "${CPPFLAGS_${flag_suffix}}" CPPFLAGS_${flag_suffix})
    string(STRIP "${CFLAGS_${flag_suffix}}" CFLAGS_${flag_suffix})
    string(STRIP "${CXXFLAGS_${flag_suffix}}" CXXFLAGS_${flag_suffix})
    # libtool tries to filter CFLAGS passed to the link stage via a whitelist.
    # that approach is flawed since it fails to pass flags unknown to libtool
    # but required for linking to the link stage (e.g. -fsanitize=<x>).
    # libtool has an -R option so we need to guard against -RTC by using -Xcompiler
    # while configuring there might be a lot of unknown compiler option warnings due to that
    # just ignore them.
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC" OR VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
      separate_arguments(CFLAGS_LIST NATIVE_COMMAND "${CFLAGS_${flag_suffix}}")
      list(JOIN CFLAGS_LIST " -Xcompiler " CFLAGS_${var_suffix})
      string(PREPEND CFLAGS_${var_suffix} "-Xcompiler ")
    endif()
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC" OR VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
      separate_arguments(CXXFLAGS_LIST NATIVE_COMMAND "${CXXFLAGS_${flag_suffix}}")
      list(JOIN CXXFLAGS_LIST " -Xcompiler " CXXFLAGS_${var_suffix})
      string(PREPEND CXXFLAGS_${var_suffix} "-Xcompiler ")
    endif()
    debug_message("CPPFLAGS_${flag_suffix}: ${CPPFLAGS_${flag_suffix}}")
    debug_message("CFLAGS_${flag_suffix}: ${CFLAGS_${flag_suffix}}")
    debug_message("CXXFLAGS_${flag_suffix}: ${CXXFLAGS_${flag_suffix}}")
endmacro()

macro(z_vcpkg_append_to_configure_environment inoutstring var defaultval)
    # Allows to overwrite settings in custom triplets via the environment on windows
    if(CMAKE_HOST_WIN32 AND DEFINED ENV{${var}})
        string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
    else()
        string(APPEND ${inoutstring} " ${var}='${defaultval}'")
    endif()
endmacro()

macro(z_convert_to_list input output)
    string(REGEX MATCHALL "(( +|^ *)[^ ]+)" ${output} "${${input}}")
endmacro()

function(vcpkg_configure_make)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;NO_DEBUG;USE_WRAPPERS;NO_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(arg_USE_WRAPPERS AND arg_NO_WRAPPERS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed conflicting options USE_WRAPPERS and NO_WRAPPERS. Please remove one of them!")
    endif()

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    debug_message("Including cmake vars from: ${cmake_vars_file}")
    include("${cmake_vars_file}")

    # Remove outer quotes from cmake variables which will be forwarded via makefile/shell variables
    # substituted into makefile commands (e.g. Android NDK has "--sysroot=...")
    foreach(var IN ITEMS VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG
                         VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE
                         VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG
                         VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE
                         VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG
                         VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE
                         VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_DEBUG
                         VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_RELEASE
                         VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES
                         VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES
    )
        separate_arguments(cmake_list NATIVE_COMMAND "${${var}}")
        list(JOIN cmake_list " " "${var}")
    endforeach()

    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(arg_BUILD_TRIPLET ${VCPKG_MAKE_BUILD_TRIPLET}) # Triplet overwrite for crosscompiling
    endif()

    set(src_dir "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    set(requires_autogen OFF) # use autogen.sh
    set(requires_autoconfig OFF) # use autotools and configure.ac
    if(EXISTS "${src_dir}/configure" AND EXISTS "${src_dir}/configure.ac" AND arg_AUTOCONFIG) # remove configure; rerun autoconf
        set(requires_autoconfig ON)
        file(REMOVE "${SRC_DIR}/configure") # remove possible outdated configure scripts
    elseif(EXISTS "${src_dir}/configure" AND NOT arg_SKIP_CONFIGURE) # run normally; no autoconf or autogen required
    elseif(EXISTS "${src_dir}/configure.ac") # Run autoconfig
        set(requires_autoconfig ON)
        set(arg_AUTOCONFIG ON)
    elseif(EXISTS "${src_dir}/autogen.sh") # Run autogen
        set(requires_autogen ON)
    else()
        message(FATAL_ERROR "Could not determine method to configure make")
    endif()

    debug_message("requires_autogen:${requires_autogen}")
    debug_message("requires_autoconfig:${requires_autoconfig}")

    if(CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe") #only applies to windows (clang-)cl and lib
        if(arg_AUTOCONFIG)
            set(arg_USE_WRAPPERS ON)
        else()
            # Keep the setting from portfiles.
            # Without autotools we assume a custom configure script which correctly handles cl and lib.
            # Otherwise the port needs to set CC|CXX|AR and probably CPP.
        endif()
    else()
        set(arg_USE_WRAPPERS OFF)
    endif()
    if(arg_NO_WRAPPERS)
        set(arg_USE_WRAPPERS OFF)
    endif()

    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(cm_FLAGS AR AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
    list(TRANSFORM cm_FLAGS APPEND "FLAGS")
    vcpkg_backup_env_variables(VARS ${cm_FLAGS})


    # FC fotran compiler | FF Fortran 77 compiler 
    # LDFLAGS -> pass -L flags
    # LIBS -> pass -l flags

    #Used by gcc/linux
    vcpkg_backup_env_variables(VARS C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH)

    #Used by cl
    vcpkg_backup_env_variables(VARS INCLUDE LIB LIBPATH)

    set(vcm_paths_with_spaces OFF)
    if(CURRENT_PACKAGES_DIR MATCHES " " OR CURRENT_INSTALLED_DIR MATCHES " ")
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
        set(vcm_paths_with_spaces ON)
    endif()

    set(configure_env "V=1")

    # Establish a bash environment as expected by autotools.
    if(CMAKE_HOST_WIN32)
        list(APPEND msys_require_packages autoconf-wrapper automake-wrapper binutils libtool make pkgconf which)
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${msys_require_packages} ${arg_ADDITIONAL_MSYS_PACKAGES})
        set(base_cmd "${MSYS_ROOT}/usr/bin/bash.exe" --noprofile --norc --debug)
        vcpkg_list(SET add_to_env)
        if(arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS)
            vcpkg_list(APPEND add_to_env "${SCRIPTS}/buildsystems/make_wrapper") # Other required wrappers are also located there
            vcpkg_list(APPEND add_to_env "${MSYS_ROOT}/usr/share/automake-1.16")
        endif()
        cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path_list NORMALIZE)
        cmake_path(CONVERT "$ENV{SystemRoot}" TO_CMAKE_PATH_LIST system_root NORMALIZE)
        cmake_path(CONVERT "$ENV{LOCALAPPDATA}" TO_CMAKE_PATH_LIST local_app_data NORMALIZE)
        file(REAL_PATH "${system_root}" system_root)
        string(TOUPPER "${system_root}" system_root_upper)

        message(DEBUG "path_list:${path_list}") # Just to have --trace-expand output

        vcpkg_list(SET find_system_dirs 
            "${system_root}/system32"
            "${system_root}/System32"
            "${system_root}/system32/"
            "${system_root}/System32/"
            "${system_root_upper}/system32"
            "${system_root_upper}/System32"
            "${system_root_upper}/system32/"
            "${system_root_upper}/System32/"
            "${local_app_data}/Microsoft/WindowsApps"
            "${local_app_data}/Microsoft/WindowsApps/"
        )

        string(TOUPPER "${find_system_dirs}" find_system_dirs_upper)

        set(index 0)
        set(appending TRUE)
        foreach(item IN LISTS path_list)
            if(item IN_LIST find_system_dirs OR item IN_LIST find_system_dirs_upper)
                set(appending FALSE)
                break()
            endif()
            math(EXPR index "${index} + 1")
        endforeach()

        if(appending)
            message(WARNING "Unable to find system dir in the PATH variable! Appending required msys paths!")
        endif()
        vcpkg_list(INSERT path_list "${index}" ${add_to_env} "${MSYS_ROOT}/usr/bin")

        cmake_path(CONVERT "${path_list}" TO_NATIVE_PATH_LIST native_path_list)
        set(ENV{PATH} "${native_path_list}")
    else()
        find_program(base_cmd bash REQUIRED)
    endif()

   # macOS - cross-compiling support
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
        if (requires_autoconfig AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_arch_mac(BUILD_ARCH) # machine you are building on => --build=
            z_vcpkg_determine_autotools_target_arch_mac(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}" OR NOT VCPKG_TARGET_IS_OSX) # we don't need to specify the additional flags if we build natively.
                set(arg_BUILD_TRIPLET "--host=${TARGET_ARCH}-apple-darwin") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            debug_message("Using make triplet: ${arg_BUILD_TRIPLET}")
        endif()
    endif()

    # Linux - cross-compiling support
    if(VCPKG_TARGET_IS_LINUX)
        if (requires_autoconfig AND NOT arg_BUILD_TRIPLET OR arg_DETERMINE_BUILD_TRIPLET)
            # The regex below takes the prefix from the resulting CMAKE_C_COMPILER variable eg. arm-linux-gnueabihf-gcc 
            # set in the common toolchains/linux.cmake
            # This is used via --host as a prefix for all other bin tools as well. 
            # Setting the compiler directly via CC=arm-linux-gnueabihf-gcc does not work acording to: 
            # https://www.gnu.org/software/autoconf/manual/autoconf-2.65/html_node/Specifying-Target-Triplets.html
            if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "([^\/]*)-gcc$" AND CMAKE_MATCH_1)
                set(arg_BUILD_TRIPLET "--host=${CMAKE_MATCH_1}") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            debug_message("Using make triplet: ${arg_BUILD_TRIPLET}")
        endif()
    endif()

    # Pre-processing windows configure requirements
    if (VCPKG_TARGET_IS_WINDOWS)
        if (arg_DETERMINE_BUILD_TRIPLET OR NOT arg_BUILD_TRIPLET)
            z_vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => machine you are building on => --build=
            z_vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(CMAKE_HOST_WIN32)
                # Respect host triplet when determining --build
                if(NOT VCPKG_CROSSCOMPILING)
                    set(_win32_build_arch "${TARGET_ARCH}")
                else()
                    set(_win32_build_arch "${BUILD_ARCH}")
                endif()

                # This is required since we are running in a msys
                # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
                set(arg_BUILD_TRIPLET "--build=${_win32_build_arch}-pc-mingw32")
            endif()
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32) # we don't need to specify the additional flags if we build nativly, this does not hold when we are not on windows
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-pc-mingw32") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
            if(VCPKG_TARGET_IS_UWP AND NOT arg_BUILD_TRIPLET MATCHES "--host")
                # Needs to be different from --build to enable cross builds.
                string(APPEND arg_BUILD_TRIPLET " --host=${TARGET_ARCH}-unknown-mingw32")
            endif()
            debug_message("Using make triplet: ${arg_BUILD_TRIPLET}")
        endif()

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
        if (arg_USE_WRAPPERS)
            z_vcpkg_append_to_configure_environment(configure_env CPP "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")

            z_vcpkg_append_to_configure_environment(configure_env CC "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            if(NOT arg_BUILD_TRIPLET MATCHES "--host")
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                # Silly trick to make configure accept CC_FOR_BUILD but in reallity CC_FOR_BUILD is deactivated. 
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()
            z_vcpkg_append_to_configure_environment(configure_env CXX "compile ${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "windres-rc ${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib ${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "ar-lib lib.exe -verbose")
            endif()
        else()
            z_vcpkg_append_to_configure_environment(configure_env CPP "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
            z_vcpkg_append_to_configure_environment(configure_env CC "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
            if(NOT arg_BUILD_TRIPLET MATCHES "--host")
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "${VCPKG_DETECTED_CMAKE_C_COMPILER} -E")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env CC_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CPP_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
                z_vcpkg_append_to_configure_environment(configure_env CXX_FOR_BUILD "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            endif()
            z_vcpkg_append_to_configure_environment(configure_env CXX "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env RC "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            z_vcpkg_append_to_configure_environment(configure_env WINDRES "${VCPKG_DETECTED_CMAKE_RC_COMPILER}")
            if(VCPKG_DETECTED_CMAKE_AR)
                z_vcpkg_append_to_configure_environment(configure_env AR "${VCPKG_DETECTED_CMAKE_AR}")
            else()
                z_vcpkg_append_to_configure_environment(configure_env AR "lib.exe -verbose")
            endif()
        endif()
        z_vcpkg_append_to_configure_environment(configure_env LD "${VCPKG_DETECTED_CMAKE_LINKER} -verbose")
        if(VCPKG_DETECTED_CMAKE_RANLIB)
            z_vcpkg_append_to_configure_environment(configure_env RANLIB "${VCPKG_DETECTED_CMAKE_RANLIB}") # Trick to ignore the RANLIB call
        else()
            z_vcpkg_append_to_configure_environment(configure_env RANLIB ":")
        endif()
        if(VCPKG_DETECTED_CMAKE_OBJDUMP) #Objdump is required to make shared libraries. Otherwise define lt_cv_deplibs_check_method=pass_all
            z_vcpkg_append_to_configure_environment(configure_env OBJDUMP "${VCPKG_DETECTED_CMAKE_OBJDUMP}") # Trick to ignore the RANLIB call
        endif()
        if(VCPKG_DETECTED_CMAKE_STRIP) # If required set the ENV variable STRIP in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env STRIP "${VCPKG_DETECTED_CMAKE_STRIP}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env STRIP ":")
            list(APPEND arg_OPTIONS ac_cv_prog_ac_ct_STRIP=:)
        endif()
        if(VCPKG_DETECTED_CMAKE_NM) # If required set the ENV variable NM in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env NM "${VCPKG_DETECTED_CMAKE_NM}") 
        else()
            # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
            # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
            z_vcpkg_append_to_configure_environment(configure_env NM "dumpbin.exe -symbols -headers")
        endif()
        if(VCPKG_DETECTED_CMAKE_DLLTOOL) # If required set the ENV variable DLLTOOL in the portfile correctly
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "${VCPKG_DETECTED_CMAKE_DLLTOOL}") 
        else()
            z_vcpkg_append_to_configure_environment(configure_env DLLTOOL "link.exe -verbose -dll")
        endif()
        z_vcpkg_append_to_configure_environment(configure_env CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        z_vcpkg_append_to_configure_environment(configure_env AS ":")   # If required set the ENV variable AS in the portfile correctly

        foreach(_env IN LISTS arg_CONFIGURE_ENVIRONMENT_VARIABLES)
            z_vcpkg_append_to_configure_environment(configure_env ${_env} "${${_env}}")
        endforeach()
        debug_message("configure_env: '${configure_env}'")
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 

        # Variables not correctly detected by configure. In release builds.
        list(APPEND arg_OPTIONS gl_cv_double_slash_root=yes
                                 ac_cv_func_memmove=yes)
        #list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all) # Just ignore libtool checks 
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND arg_OPTIONS gl_cv_host_cpu_c_abi=no)
            # Currently needed for arm64 because objdump yields: "unrecognised machine type (0xaa64) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]$")
            # Currently needed for arm because objdump yields: "unrecognised machine type (0x1c4) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        endif()
    else()
        # Because OSX dosn't like CMAKE_C(XX)_COMPILER (cc) in CC/CXX and rather wants to have gcc/g++
        function(z_vcpkg_make_set_env envvar cmakevar)
            set(prog "${VCPKG_DETECTED_CMAKE_${cmakevar}} ${ARGN}")
            string(STRIP "${prog}" prog)
            if(DEFINED ENV{${envvar}})
                return()
            endif()
            if(VCPKG_DETECTED_CMAKE_${cmakevar})
                set(ENV{${envvar}} "${prog}")
            endif()
        endfunction()
        z_vcpkg_make_set_env(CC C_COMPILER)
        if(NOT arg_BUILD_TRIPLET MATCHES "--host")
            z_vcpkg_make_set_env(CC_FOR_BUILD C_COMPILER)
            z_vcpkg_make_set_env(CPP_FOR_BUILD C_COMPILER "-E")
            z_vcpkg_make_set_env(CXX_FOR_BUILD C_COMPILER)
        else()
            set(ENV{CC_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CPP_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
            set(ENV{CXX_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
        endif()
        z_vcpkg_make_set_env(CXX CXX_COMPILER)
        z_vcpkg_make_set_env(NM NM)
        z_vcpkg_make_set_env(RC RC)
        z_vcpkg_make_set_env(WINDRES RC)
        z_vcpkg_make_set_env(DLLTOOL DLLTOOL)
        z_vcpkg_make_set_env(STRIP STRIP)
        z_vcpkg_make_set_env(OBJDUMP OBJDUMP)
        z_vcpkg_make_set_env(RANLIB RANLIB)
        z_vcpkg_make_set_env(AR AR)
        z_vcpkg_make_set_env(LD LINKER)
        unset(z_vcpkg_make_set_env)
    endif()

    # Some PATH handling for dealing with spaces....some tools will still fail with that!
    # In particular, the libtool install command is unable to install correctly to paths with spaces.
    # CURRENT_INSTALLED_DIR: Pristine native path (unprotected spaces, Windows drive letters)
    # z_vcpkg_installed_path:      Native path with escaped space characters
    # z_vcpkg_prefix_path:         Path with unprotected spaces, but drive letters transformed for mingw/msys
    string(REPLACE " " "\\ " z_vcpkg_installed_path "${CURRENT_INSTALLED_DIR}")
    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" z_vcpkg_prefix_path "${CURRENT_INSTALLED_DIR}")
    else()
        set(z_vcpkg_prefix_path "${CURRENT_INSTALLED_DIR}")
    endif()

    # Cleanup previous build dirs
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    # Set configure paths
    set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE} "--prefix=${z_vcpkg_prefix_path}")
    set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG} "--prefix=${z_vcpkg_prefix_path}/debug")
    if(NOT arg_NO_ADDITIONAL_PATHS)
        # ${prefix} has an extra backslash to prevent early expansion when calling `bash -c configure "..."`.
        set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE}
                            # Important: These should all be relative to prefix!
                            "--bindir=\\\${prefix}/tools/${PORT}/bin"
                            "--sbindir=\\\${prefix}/tools/${PORT}/sbin"
                            "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                            #"--includedir='\${prefix}'/include" # already the default!
                            "--mandir=\\\${prefix}/share/${PORT}"
                            "--docdir=\\\${prefix}/share/${PORT}"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
        set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG}
                            # Important: These should all be relative to prefix!
                            "--bindir=\\\${prefix}/../tools/${PORT}/debug/bin"
                            "--sbindir=\\\${prefix}/../tools/${PORT}/debug/sbin"
                            "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                            "--includedir=\\\${prefix}/../include"
                            "--datarootdir=\\\${prefix}/share/${PORT}")
    endif()
    # Setup common options
    if(NOT arg_DISABLE_VERBOSE_FLAGS)
        list(APPEND arg_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND arg_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND arg_OPTIONS --disable-shared --enable-static)
    endif()

    # Can be set in the triplet to append options for configure
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS)
        list(APPEND arg_OPTIONS ${VCPKG_CONFIGURE_MAKE_OPTIONS})
    endif()
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE ${VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG ${VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG})
    endif()

    file(RELATIVE_PATH relative_build_path "${CURRENT_BUILDTREES_DIR}" "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

    # Used by CL 
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    # Used by GCC
    vcpkg_host_path_list(PREPEND ENV{C_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{CPLUS_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")

    # Flags should be set in the toolchain instead (Setting this up correctly requires a function named vcpkg_determined_cmake_compiler_flags which can also be used to setup CC and CXX etc.)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_backup_env_variables(VARS _CL_ _LINK_)
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to: 
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCToolsInstallDir)
            set(_replacement -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}")
            # Can somebody please check if CMake's compiler flags for UWP are correct?
            set(ENV{_CL_} "$ENV{_CL_} -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        endif()
    endif()

    z_convert_to_list(VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES c_libs_list)
    z_convert_to_list(VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES cxx_libs_list)
    set(all_libs_list ${c_libs_list} ${cxx_libs_list})
    list(REMOVE_DUPLICATES all_libs_list)
    list(TRANSFORM all_libs_list STRIP)
    #Do lib list transformation from name.lib to -lname if necessary
    set(x_vcpkg_transform_libs ON)
    if(VCPKG_TARGET_IS_UWP)
        set(x_vcpkg_transform_libs OFF)
        # Avoid libtool choke: "Warning: linker path does not have real file for library -lWindowsApp."
        # The problem with the choke is that libtool always falls back to built a static library even if a dynamic was requested. 
        # Note: Env LIBPATH;LIB are on the search path for libtool by default on windows. 
        # It even does unix/dos-short/unix transformation with the path to get rid of spaces. 
    endif()
    set(l_prefix)
    if(x_vcpkg_transform_libs)
        set(l_prefix "-l")
        list(TRANSFORM all_libs_list REPLACE "(.dll.lib|.lib|.a|.so)$" "")
        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM all_libs_list "uuid")
        endif()
        list(TRANSFORM all_libs_list REPLACE "^(${l_prefix})" "")
    endif()
    list(JOIN all_libs_list " ${l_prefix}" all_libs_string)
    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # libtool must be told explicitly that there is no dynamic linkage for uuid.
        # The "-Wl,..." syntax is understood by libtool and gcc, but no by ld.
        string(REPLACE " -luuid" " -Wl,-Bstatic,-luuid,-Bdynamic" all_libs_string "${all_libs_string}")
    endif()

    if(all_libs_string)
        set(all_libs_string "${l_prefix}${all_libs_string}")
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${all_libs_string}")
        else()
            set(ENV{LIBS} "${all_libs_string}")
        endif()
    endif()
    debug_message("ENV{LIBS}:$ENV{LIBS}")

    # Run autoconf if necessary
    if (arg_AUTOCONFIG OR requires_autoconfig AND NOT arg_NO_AUTOCONFIG)
        find_program(AUTORECONF autoreconf)
        if(NOT AUTORECONF)
            message(FATAL_ERROR "${PORT} requires autoconf from the system package manager (example: \"sudo apt-get install autoconf\")")
        endif()
        message(STATUS "Generating configure for ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "autoreconf -vfi"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "${AUTORECONF}" -vfi
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()
    if(requires_autogen)
        message(STATUS "Generating configure for ${TARGET_TRIPLET} via autogen.sh")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "./autogen.sh"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "autoconf-${TARGET_TRIPLET}"
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()

    if (arg_PRERUN_SHELL)
        message(STATUS "Prerun shell with ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "${arg_PRERUN_SHELL}"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "prerun-${TARGET_TRIPLET}"
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "${base_cmd}" -c "${arg_PRERUN_SHELL}"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "prerun-${TARGET_TRIPLET}"
            )
        endif()
    endif()

    macro(z_vcpkg_setup_make_linker_flags_vars var_suffix)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
        else() # dynamic
            set(LINKER_FLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
        endif()
        set(ARFLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_${var_suffix}}")
        set(LDFLAGS_${var_suffix} "${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_${var_suffix}}")
        if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES [[cl\.exe$]])
            if(NOT vcm_paths_with_spaces)
                string(APPEND LDFLAGS_${var_suffix} " -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            if(DEFINED ENV{_LINK_})
                set(LINK_ENV_${var_suffix} "$ENV{_LINK_} ${LINKER_FLAGS_${var_suffix}}")
            else()
                set(LINK_ENV_${var_suffix} "${LINKER_FLAGS_${var_suffix}}")
            endif()
        else()
            set(link_required_dirs "")
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib")
                set(link_required_dirs "-L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib")
            endif()
            if(EXISTS "{CURRENT_INSTALLED_DIR}${path_suffix_${var_suffix}}/lib/manual-link")
                set(link_required_dirs "${link_required_dirs} -L${z_vcpkg_installed_path}${path_suffix_${var_suffix}}/lib/manual-link")
            endif()
            string(STRIP "${link_required_dirs}" link_required_dirs)
            if(link_required_dirs)
                string(PREPEND LDFLAGS_${var_suffix} "${link_required_dirs} ")
                # ARFLAGS doesn't need -L search paths since it just bundles object files
            endif()
            if(ARFLAGS_${var_suffix})
                # ARFLAGS need to know the command for creating an archive (Maybe needs user customization?)
                # or extract it from CMake via CMAKE_${lang}_ARCHIVE_CREATE ?
                # or from CMAKE_${lang}_${rule} with rule being one of CREATE_SHARED_MODULE CREATE_SHARED_LIBRARY LINK_EXECUTABLE
                string(PREPEND ARFLAGS_${var_suffix} "cr ")
            endif()
            string(STRIP "${LDFLAGS_${var_suffix}}" LDFLAGS_${var_suffix})
            string(STRIP "${ARFLAGS_${var_suffix}}" ARFLAGS_${var_suffix})
            if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_DETECTED_CMAKE_LINKER MATCHES [[link\.exe$]])
                # Do not touch autotools quirks incoming!
                # -Xlinker is repeated three times because:
                # - libtool script eats -Xlinker
                # - the compile wrapper eats -Xlinker
                # - passing through both tools requires 3 -Xlinker; two being eaten in the first script.
                # passing only through one script will keep one -Xlinker (done in configure)
                # but cl will just ignore those with a warning. (Just like -Xcompiler)
                separate_arguments(LDFLAGS_LIST NATIVE_COMMAND "${LDFLAGS_${var_suffix}}")
                list(JOIN LDFLAGS_LIST " -Xlinker -Xlinker -Xlinker " LDFLAGS_${var_suffix})
                string(PREPEND LDFLAGS_${var_suffix} "-Xlinker -Xlinker -Xlinker ")
            endif()
        endif()
    endmacro()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT arg_NO_DEBUG)
        set(var_suffix DEBUG)
        set(path_suffix_${var_suffix} "/debug")
        set(short_name_${var_suffix} "dbg")
        list(APPEND all_buildtypes ${var_suffix})
        z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${var_suffix})
        z_vcpkg_setup_make_linker_flags_vars(${var_suffix})
        unset(var_suffix)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(var_suffix RELEASE)
        set(path_suffix_${var_suffix} "")
        set(short_name_${var_suffix} "rel")
        list(APPEND all_buildtypes ${var_suffix})
        z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags(${var_suffix})
        z_vcpkg_setup_make_linker_flags_vars(${var_suffix})
        unset(var_suffix)
    endif()

    foreach(var IN ITEMS arg_OPTIONS arg_OPTIONS_RELEASE arg_OPTIONS_DEBUG)
        vcpkg_list(SET tmp)
        foreach(element IN LISTS "${var}")
            string(REPLACE [["]] [[\"]] element "${element}")
            vcpkg_list(APPEND tmp "\"${element}\"")
        endforeach()
        vcpkg_list(JOIN tmp " " "${var}")
    endforeach()

    foreach(current_buildtype IN LISTS all_buildtypes)
        foreach(ENV_VAR ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(backup_config_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${current_buildtype}}")
        endforeach()

        set(target_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
        file(MAKE_DIRECTORY "${target_dir}")
        file(RELATIVE_PATH relative_build_path "${target_dir}" "${src_dir}")

        if(arg_COPY_SOURCE)
            file(COPY "${src_dir}/" DESTINATION "${target_dir}")
            set(relative_build_path .)
        endif()

        # Setup PKG_CONFIG_PATH
        if ("${current_buildtype}" STREQUAL "DEBUG")
            z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}/debug")
        else()
            z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}")
        endif()

        # Setup environment
        set(ENV{CPPFLAGS} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CPPFLAGS_FOR_BUILD} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS_FOR_BUILD} "${CFLAGS_${current_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${current_buildtype}}")
        #set(ENV{CXXFLAGS_FOR_BUILD} "${CXXFLAGS_${current_buildtype}}") -> doesn't exist officially
        set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS_FOR_BUILD} "${LDFLAGS_${current_buildtype}}")
        if(ARFLAGS_${current_buildtype} AND NOT (arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS))
            # Target windows with wrappers enabled cannot forward ARFLAGS since it breaks the wrapper
            set(ENV{ARFLAGS} "${ARFLAGS_${current_buildtype}}")
        endif()
        # https://www.gnu.org/software/libtool/manual/html_node/Link-mode.html
        # -avoid-version is handled specially by libtool link mode, this flag is not forwarded to linker,
        # and libtool tries to avoid versioning for shared libraries and no symbolic links are created.
        if(VCPKG_TARGET_IS_ANDROID)
            set(ENV{LDFLAGS} "-avoid-version $ENV{LDFLAGS}")
            set(ENV{LDFLAGS_FOR_BUILD} "-avoid-version $ENV{LDFLAGS_FOR_BUILD}")
        endif()

        if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
            # configure not using all flags to check if compiler works ...
            set(ENV{CC} "$ENV{CC} $ENV{CPPFLAGS} $ENV{CFLAGS}")
            set(ENV{CC_FOR_BUILD} "$ENV{CC_FOR_BUILD} $ENV{CPPFLAGS} $ENV{CFLAGS}")
        endif()

        if(LINK_ENV_${current_buildtype})
            set(link_config_backup "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${current_buildtype}}")
        else()
            unset(link_config_backup)
        endif()

        vcpkg_list(APPEND lib_env_vars LIB LIBPATH LIBRARY_PATH) # LD_LIBRARY_PATH)
        foreach(lib_env_var IN LISTS lib_env_vars)
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
            endif()
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
            endif()
        endforeach()
        unset(lib_env_vars)

        set(command "${base_cmd}" -c "${configure_env} ./${relative_build_path}/configure ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${current_buildtype}}")
        
        if(arg_ADD_BIN_TO_PATH)
            set(path_backup $ENV{PATH})
            vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/bin")
        endif()
        debug_message("Configure command:'${command}'")
        if (NOT arg_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${target_dir}"
                LOGNAME "config-${TARGET_TRIPLET}-${short_name_${current_buildtype}}"
                SAVE_LOG_FILES config.log
            )
            if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                file(GLOB_RECURSE libtool_files "${target_dir}*/libtool")
                foreach(lt_file IN LISTS libtool_files)
                    file(READ "${lt_file}" _contents)
                    string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                    file(WRITE "${lt_file}" "${_contents}")
                endforeach()
            endif()
        endif()
        z_vcpkg_restore_pkgconfig_path()
        
        if(DEFINED link_config_backup)
            set(ENV{_LINK_} "${link_config_backup}")
        endif()
        
        if(arg_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${path_backup}")
        endif()
        # Restore environment (config dependent)
        foreach(ENV_VAR IN LISTS ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(backup_config_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${backup_config_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # Export matching make program for vcpkg_build_make (cache variable)
    if(CMAKE_HOST_WIN32 AND MSYS_ROOT)
        find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    elseif(VCPKG_HOST_IS_OPENBSD)
        find_program(Z_VCPKG_MAKE gmake REQUIRED)
    else()
        find_program(Z_VCPKG_MAKE make REQUIRED)
    endif()

    # Restore environment
    vcpkg_restore_env_variables(VARS ${cm_FLAGS} LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    set(_VCPKG_PROJECT_SOURCE_PATH ${arg_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${arg_PROJECT_SUBPATH} PARENT_SCOPE)
    set(_VCPKG_MAKE_NO_DEBUG ${arg_NO_DEBUG} PARENT_SCOPE)
endfunction()
