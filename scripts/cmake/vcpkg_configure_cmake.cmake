function(z_vcpkg_configure_cmake_both_or_neither_set var1 var2)
    if(DEFINED "${var1}" AND NOT DEFINED "${var2}")
        message(FATAL_ERROR "If ${var1} is set, ${var2} must be set.")
    endif()
    if(NOT DEFINED "${var1}" AND DEFINED "${var2}")
        message(FATAL_ERROR "If ${var2} is set, ${var1} must be set.")
    endif()
endfunction()
function(z_vcpkg_configure_cmake_build_cmakecache out_var whereat build_type)
    set(line "build ${whereat}/CMakeCache.txt: CreateProcess\n")
    string(APPEND line "  process = \"${CMAKE_COMMAND}\" -E chdir \"${whereat}\"")
    foreach(arg IN LISTS "${build_type}_command")
        string(APPEND line " \"${arg}\"")
    endforeach()
    set("${out_var}" "${${out_var}}${line}\n\n" PARENT_SCOPE)
endfunction()

function(z_vcpkg_get_visual_studio_generator)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_GENERATOR;OUT_ARCH" "")
    
    if (NOT DEFINED arg_OUT_GENERATOR)
        message(FATAL_ERROR "OUT_GENERATOR must be defined.")
    endif()
    if(NOT DEFINED arg_OUT_ARCH)
        message(FATAL_ERROR "OUT_ARCH must be defined.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
            message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(DEFINED ENV{VisualStudioVersion})
        if("$ENV{VisualStudioVersion}" VERSION_LESS_EQUAL  "12.99" AND
           "$ENV{VisualStudioVersion}" VERSION_GREATER_EQUAL  "12.0" AND
           NOT "${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
            set(generator "Visual Studio 12 2013")
        elseif("$ENV{VisualStudioVersion}" VERSION_LESS_EQUAL  "14.99" AND
               NOT "${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
            set(generator "Visual Studio 14 2015")
        elseif("$ENV{VisualStudioVersion}" VERSION_LESS_EQUAL  "15.99")
            set(generator "Visual Studio 15 2017")
        elseif("$ENV{VisualStudioVersion}" VERSION_LESS_EQUAL  "16.99")
            set(generator "Visual Studio 16 2019")
        elseif("$ENV{VisualStudioVersion}" VERSION_LESS_EQUAL  "17.99")
            set(generator "Visual Studio 17 2022")
        endif()
    endif()

    if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86")
        set(generator_arch "Win32")
    elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
        set(generator_arch "x64")
    elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm")
        set(generator_arch "ARM")
    elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
        set(generator_arch "ARM64")
    endif()
    set(${arg_OUT_GENERATOR} "${generator}" PARENT_SCOPE)
    set(${arg_OUT_ARCH} "${generator_arch}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_select_default_vcpkg_chainload_toolchain)
    # Try avoiding adding more defaults here. 
    # Set VCPKG_CHAINLOAD_TOOLCHAIN_FILE explicitly in the triplet.
    if(DEFINED Z_VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${Z_VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    elseif(VCPKG_TARGET_IS_MINGW)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
    elseif(VCPKG_TARGET_IS_WINDOWS)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    elseif(VCPKG_TARGET_IS_LINUX)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
    elseif(VCPKG_TARGET_IS_ANDROID)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
    elseif(VCPKG_TARGET_IS_OSX)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
    elseif(VCPKG_TARGET_IS_IOS)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/ios.cmake")
    elseif(VCPKG_TARGET_IS_FREEBSD)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
    elseif(VCPKG_TARGET_IS_OPENBSD)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/openbsd.cmake")
    endif()
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${VCPKG_CHAINLOAD_TOOLCHAIN_FILE} PARENT_SCOPE)
endfunction()


function(vcpkg_configure_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE;NO_CHARSET_FLAG;Z_GET_CMAKE_VARS_USAGE"
        "SOURCE_PATH;GENERATOR;LOGNAME"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;MAYBE_UNUSED_VARIABLES"
    )

    if(NOT arg_Z_GET_CMAKE_VARS_USAGE AND Z_VCPKG_CMAKE_CONFIGURE_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-cmake; using both vcpkg-cmake and vcpkg_configure_cmake in the same port is unsupported.")
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified")
    endif()
    if(NOT DEFINED arg_LOGNAME)
        set(arg_LOGNAME "config-${TARGET_TRIPLET}")
    endif()

    vcpkg_list(SET manually_specified_variables)

    if(arg_Z_GET_CMAKE_VARS_USAGE)
        set(configuring_message "Getting CMake variables for ${TARGET_TRIPLET}")
    else()
        set(configuring_message "Configuring ${TARGET_TRIPLET}")

        foreach(option IN LISTS arg_OPTIONS arg_OPTIONS_RELEASE arg_OPTIONS_DEBUG)
            if("${option}" MATCHES "^-D([^:=]*)[:=]")
                vcpkg_list(APPEND manually_specified_variables "${CMAKE_MATCH_1}")
            endif()
        endforeach()
        vcpkg_list(REMOVE_DUPLICATES manually_specified_variables)
        foreach(maybe_unused_var IN LISTS arg_MAYBE_UNUSED_VARIABLES)
            vcpkg_list(REMOVE_ITEM manually_specified_variables "${maybe_unused_var}")
        endforeach()
        debug_message("manually specified variables: ${manually_specified_variables}")
    endif()

    set(ninja_can_be_used ON) # Ninja as generator
    set(ninja_host ON) # Ninja as parallel configurator

    if(NOT arg_PREFER_NINJA AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(ninja_can_be_used OFF)
    endif()

    if(VCPKG_HOST_IS_WINDOWS)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(host_arch "$ENV{PROCESSOR_ARCHITEW6432}")
        else()
            set(host_arch "$ENV{PROCESSOR_ARCHITECTURE}")
        endif()

        if("${host_arch}" STREQUAL "x86")
            # Prebuilt ninja binaries are only provided for x64 hosts
            set(ninja_can_be_used OFF)
            set(ninja_host OFF)
        endif()
    endif()

    set(generator "Ninja") # the default generator is always ninja!
    set(generator_arch "")
    if(DEFINED arg_GENERATOR)
        set(generator "${arg_GENERATOR}")
    elseif(NOT ninja_can_be_used)
        set(generator "")
        z_vcpkg_get_visual_studio_generator(OUT_GENERATOR generator OUT_ARCH generator_arch)
        if("${generator}" STREQUAL "" OR "${generator_arch}" STREQUAL "")
            message(FATAL_ERROR
                "Unable to determine appropriate generator for triplet ${TARGET_TRIPLET}:
    ENV{VisualStudioVersion} : $ENV{VisualStudioVersion}
    platform toolset: ${VCPKG_PLATFORM_TOOLSET}
    architecture    : ${VCPKG_TARGET_ARCHITECTURE}")
        endif()
        if(DEFINED VCPKG_PLATFORM_TOOLSET)
            vcpkg_list(APPEND arg_OPTIONS "-T${VCPKG_PLATFORM_TOOLSET}")
        endif()
    endif()

    # If we use Ninja, make sure it's on PATH
    if("${generator}" STREQUAL "Ninja" AND NOT DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(ninja_path "${NINJA}" DIRECTORY)
        vcpkg_add_to_path("${ninja_path}")
        vcpkg_list(APPEND arg_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    file(REMOVE_RECURSE
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        vcpkg_list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(VCPKG_TARGET_IS_UWP AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        elseif(VCPKG_TARGET_IS_ANDROID AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 21)
        endif()
    endif()

    if(DEFINED VCPKG_XBOX_CONSOLE_TARGET)
        vcpkg_list(APPEND arg_OPTIONS "-DXBOX_CONSOLE_TARGET=${VCPKG_XBOX_CONSOLE_TARGET}")
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        vcpkg_list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()

    if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
        vcpkg_list(APPEND arg_OPTIONS -DBUILD_SHARED_LIBS=ON)
    elseif("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS -DBUILD_SHARED_LIBS=OFF)
    else()
        message(FATAL_ERROR
            "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\".
    It must be \"static\" or \"dynamic\"")
    endif()

    z_vcpkg_configure_cmake_both_or_neither_set(VCPKG_CXX_FLAGS_DEBUG VCPKG_C_FLAGS_DEBUG)
    z_vcpkg_configure_cmake_both_or_neither_set(VCPKG_CXX_FLAGS_RELEASE VCPKG_C_FLAGS_RELEASE)
    z_vcpkg_configure_cmake_both_or_neither_set(VCPKG_CXX_FLAGS VCPKG_C_FLAGS)

    set(vcpkg_set_charset_flag ON)
    if(arg_NO_CHARSET_FLAG)
        set(vcpkg_set_charset_flag OFF)
    endif()

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        z_vcpkg_select_default_vcpkg_chainload_toolchain()
    endif()

    vcpkg_list(APPEND arg_OPTIONS
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_SET_CHARSET_FLAG=${vcpkg_set_charset_flag}"
        "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
        "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
        "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DVCPKG_APPLOCAL_DEPS=OFF"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON"
        "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
        "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
        "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
        "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
        "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
        "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
        "-DVCPKG_LINKER_FLAGS_RELEASE=${VCPKG_LINKER_FLAGS_RELEASE}"
        "-DVCPKG_LINKER_FLAGS_DEBUG=${VCPKG_LINKER_FLAGS_DEBUG}"
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
        "-D_VCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}"
        "-DZ_VCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}"
        "-D_VCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DVCPKG_MANIFEST_INSTALL=OFF"
    )

    if(NOT "${generator_arch}" STREQUAL "")
        vcpkg_list(APPEND arg_OPTIONS "-A${generator_arch}")
    endif()

    # Sets configuration variables for macOS builds
    foreach(config_var IN ITEMS INSTALL_NAME_DIR OSX_DEPLOYMENT_TARGET OSX_SYSROOT OSX_ARCHITECTURES)
        if(DEFINED "VCPKG_${config_var}")
            vcpkg_list(APPEND arg_OPTIONS "-DCMAKE_${config_var}=${VCPKG_${config_var}}")
        endif()
    endforeach()

    # Allow overrides / additional configuration variables from triplets
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS)
        vcpkg_list(APPEND arg_OPTIONS ${VCPKG_CMAKE_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE)
        vcpkg_list(APPEND arg_OPTIONS_RELEASE ${VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS_DEBUG)
        vcpkg_list(APPEND arg_OPTIONS_DEBUG ${VCPKG_CMAKE_CONFIGURE_OPTIONS_DEBUG})
    endif()

    vcpkg_list(SET rel_command
        "${CMAKE_COMMAND}" "${arg_SOURCE_PATH}" 
        -G "${generator}"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
        ${arg_OPTIONS} ${arg_OPTIONS_RELEASE})
    vcpkg_list(SET dbg_command
        "${CMAKE_COMMAND}" "${arg_SOURCE_PATH}" 
        -G "${generator}"
        "-DCMAKE_BUILD_TYPE=Debug"
        "-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
        ${arg_OPTIONS} ${arg_OPTIONS_DEBUG})

    if(ninja_host AND CMAKE_HOST_WIN32 AND NOT arg_DISABLE_PARALLEL_CONFIGURE)
        vcpkg_list(APPEND arg_OPTIONS "-DCMAKE_DISABLE_SOURCE_CHANGES=ON")

        vcpkg_find_acquire_program(NINJA)
        if(NOT DEFINED ninja_path)
            # if ninja_path was defined above, we've already done this
            get_filename_component(ninja_path "${NINJA}" DIRECTORY)
            vcpkg_add_to_path("${ninja_path}")
        endif()

        #parallelize the configure step
        set(ninja_configure_contents
            "rule CreateProcess\n  command = \$process\n\n"
        )

        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "release")
            z_vcpkg_configure_cmake_build_cmakecache(ninja_configure_contents ".." "rel")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "debug")
            z_vcpkg_configure_cmake_build_cmakecache(ninja_configure_contents "../../${TARGET_TRIPLET}-dbg" "dbg")
        endif()

        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure")
        file(WRITE
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja"
            "${ninja_configure_contents}")

        message(STATUS "${configuring_message}")
        vcpkg_execute_required_process(
            COMMAND "${NINJA}" -v
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure"
            LOGNAME "${arg_LOGNAME}"
            SAVE_LOG_FILES
                "../../${TARGET_TRIPLET}-dbg/CMakeCache.txt" ALIAS "dbg-CMakeCache.txt.log"
                "../CMakeCache.txt" ALIAS "rel-CMakeCache.txt.log"
        )
        
        vcpkg_list(APPEND config_logs
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out.log"
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-err.log")
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "debug")
            message(STATUS "${configuring_message}-dbg")
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                LOGNAME "${arg_LOGNAME}-dbg"
                SAVE_LOG_FILES CMakeCache.txt
            )
            vcpkg_list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-dbg-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-dbg-err.log")
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "release")
            message(STATUS "${configuring_message}-rel")
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                LOGNAME "${arg_LOGNAME}-rel"
                SAVE_LOG_FILES CMakeCache.txt
            )
            vcpkg_list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-rel-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-rel-err.log")
        endif()
    endif()
    
    # Check unused variables
    vcpkg_list(SET all_unused_variables)
    foreach(config_log IN LISTS config_logs)
        if(NOT EXISTS "${config_log}")
            continue()
        endif()
        file(READ "${config_log}" log_contents)
        debug_message("Reading configure log ${config_log}...")
        if(NOT "${log_contents}" MATCHES "Manually-specified variables were not used by the project:\n\n((    [^\n]*\n)*)")
            continue()
        endif()
        string(STRIP "${CMAKE_MATCH_1}" unused_variables) # remove leading `    ` and trailing `\n`
        string(REPLACE "\n    " ";" unused_variables "${unused_variables}")
        debug_message("unused variables: ${unused_variables}")

        foreach(unused_variable IN LISTS unused_variables)
            if("${unused_variable}" IN_LIST manually_specified_variables)
                debug_message("manually specified unused variable: ${unused_variable}")
                vcpkg_list(APPEND all_unused_variables "${unused_variable}")
            else()
                debug_message("unused variable (not manually specified): ${unused_variable}")
            endif()
        endforeach()
    endforeach()

    if(NOT "${all_unused_variables}" STREQUAL "")
        vcpkg_list(REMOVE_DUPLICATES all_unused_variables)
        vcpkg_list(JOIN all_unused_variables "\n    " all_unused_variables)
        message(WARNING "The following variables are not used in CMakeLists.txt:
    ${all_unused_variables}
Please recheck them and remove the unnecessary options from the `vcpkg_configure_cmake` call.
If these options should still be passed for whatever reason, please use the `MAYBE_UNUSED_VARIABLES` argument.")
    endif()

    if(NOT arg_Z_GET_CMAKE_VARS_USAGE)
        set(Z_VCPKG_CMAKE_GENERATOR "${generator}" PARENT_SCOPE)
    endif()
endfunction()
