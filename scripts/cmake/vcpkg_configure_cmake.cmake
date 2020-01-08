## # vcpkg_configure_cmake
##
## Configure CMake for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_cmake(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [PREFER_NINJA]
##     [DISABLE_PARALLEL_CONFIGURE]
##     [NO_CHARSET_FLAG]
##     [GENERATOR <"NMake Makefiles">]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `CMakeLists.txt`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PREFER_NINJA
## Indicates that, when available, Vcpkg should use Ninja to perform the build.
## This should be specified unless the port is known to not work under Ninja.
##
## ### DISABLE_PARALLEL_CONFIGURE
## Disables running the CMake configure step in parallel.
## This is needed for libraries which write back into their source directory during configure.
##
## ### NO_CHARSET_FLAG
## Disables passing `utf-8` as the default character set to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`.
##
## This is needed for libraries that set their own source code's character set.
##
## ### GENERATOR
## Specifies the precise generator to use.
##
## This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build.
## If used for this purpose, it should be set to "NMake Makefiles".
##
## ### OPTIONS
## Additional options passed to CMake during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to CMake. To see the full list, examine the source.
##
## ## Examples
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_configure_cmake)
    cmake_parse_arguments(_csc 
        "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE;NO_CHARSET_FLAG"
        "SOURCE_PATH;GENERATOR"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )

    if(NOT VCPKG_PLATFORM_TOOLSET AND NOT DEFINED VCPKG_DEFAULT_CMAKE_GENERATOR)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()

    if(NOT DEFINED VCPKG_DEFAULT_CMAKE_GENERATOR)
        vcpkg_determine_cmake_generator(VCPKG_DEFAULT_CMAKE_GENERATOR ${_csc_PREFER_NINJA})
    endif()

    
    if(_csc_GENERATOR) #If the Generator is defined in the function call there is probably a good reason for it
        message(STATUS "VCPKG_DEFAULT_CMAKE_GENERATOR overwritten by port file! CMake generator is: ${_csc_GENERATOR}")
        set(GENERATOR ${_csc_GENERATOR})
    else()
        set(GENERATOR ${VCPKG_DEFAULT_CMAKE_GENERATOR})
    endif()

    # If we use Ninja, make sure it's on PATH
    if(GENERATOR STREQUAL "Ninja")
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)

        vcpkg_add_to_path("${NINJA_PATH}")

        list(APPEND _csc_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(VCPKG_TARGET_IS_UWP AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            message(WARNING "Please update your UWP triplet to include VCPKG_CMAKE_SYSTEM_VERSION.")
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        endif()
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=ON)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=OFF)
    else()
        message(FATAL_ERROR
            "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". "
            "It must be \"static\" or \"dynamic\"")
    endif()
    
    macro(check_both_vars_are_set var1 var2)
        if((NOT DEFINED ${var1} OR NOT DEFINED ${var2}) AND (DEFINED ${var1} OR DEFINED ${var2}))
            message(FATAL_ERROR "Both ${var1} and ${var2} must be set.")
        endif()
    endmacro()
    
    check_both_vars_are_set(VCPKG_CXX_FLAGS_DEBUG VCPKG_C_FLAGS_DEBUG)
    check_both_vars_are_set(VCPKG_CXX_FLAGS_RELEASE VCPKG_C_FLAGS_RELEASE)
    check_both_vars_are_set(VCPKG_CXX_FLAGS VCPKG_C_FLAGS)

    set(VCPKG_SET_CHARSET_FLAG ON)
    if(_csc_NO_CHARSET_FLAG)
        set(VCPKG_SET_CHARSET_FLAG OFF)
    endif()

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        if(VCPKG_TARGET_IS_WINDOWS)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        elseif(VCPKG_TARGET_IS_LINUX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_TARGET_IS_ANDROID)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_TARGET_IS_OSX)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_TARGET_IS_FREEBSD)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        endif()
    endif()


    list(APPEND _csc_OPTIONS
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_SET_CHARSET_FLAG=${VCPKG_SET_CHARSET_FLAG}"        
        "-DVCPKG_APPLOCAL_DEPS=OFF"
        "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
        "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
        "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
        "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
        "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
        "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
        "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
        "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
    )
    
    #Add toolset option if available
    if(VCPKG_PLATFORM_TOOLSET AND NOT GENERATOR STREQUAL "Ninja")
        list(APPEND _csc_OPTIONS
            "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
        )
        set(toolset_option "-T${VCPKG_PLATFORM_TOOLSET}")
    else()
        unset(toolset_option)
    endif()

    if(GENERATOR STREQUAL "Ninja" AND VCPKG_TARGET_IS_WINDOWS AND DEFINED VCPKG_PLATFORM_TOOLSET)
        if( (NOT DEFINED VCPKG_CXX_COMPILER OR NOT DEFINED VCPKG_C_COMPILER OR NOT DEFINED VCPKG_LINKER) 
            AND (DEFINED VCPKG_C_COMPILER OR DEFINED VCPKG_CXX_COMPILER OR DEFINED VCPKG_LINKER))
            message(FATAL_ERROR "All three variables VCPKG_C_COMPILER, VCPKG_CXX_COMPILER and VCPKG_LINKER must be set.")
        endif()
        if(NOT VCPKG_C_COMPILER OR NOT VCPKG_CXX_COMPILER OR NOT VCPKG_LINKER)
            vcpkg_determine_compiler_and_linker()
            message(STATUS "Detected VCPKG_C_COMPILER=${VCPKG_C_COMPILER}")
            message(STATUS "Detected VCPKG_CXX_COMPILER=${VCPKG_CXX_COMPILER}")
            message(STATUS "Detected VCPKG_LINKER=${VCPKG_LINKER}")
        endif()
    endif()

    if(DEFINED VCPKG_C_COMPILER)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_C_COMPILER:FILEPATH=${VCPKG_C_COMPILER}")
    endif()
    if(DEFINED VCPKG_CXX_COMPILER)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_CXX_COMPILER:FILEPATH=${VCPKG_CXX_COMPILER}")
    endif()
    if(DEFINED VCPKG_LINKER)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_LINKER:FILEPATH=${VCPKG_LINKER}")
    endif()
    if(DEFINED VCPKG_AR)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_AR:FILEPATH=${VCPKG_AR}")
    endif()
    if(DEFINED VCPKG_RC_COMPILER)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_RC_COMPILER:FILEPATH=${VCPKG_RC_COMPILER}")
    endif()
    if(DEFINED VCPKG_RANLIB)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_RANLIB:FILEPATH=${VCPKG_RANLIB}")
    endif()
    if(DEFINED VCPKG_NM)
        list(APPEND _csc_BUILD_TOOLS "-DCMAKE_NM:FILEPATH=${VCPKG_NM}")
    endif()
    # Sets configuration variables for macOS builds
    foreach(config_var  INSTALL_NAME_DIR OSX_DEPLOYMENT_TARGET OSX_SYSROOT)
        if(DEFINED VCPKG_${config_var})
            list(APPEND _csc_OPTIONS "-DCMAKE_${config_var}=${VCPKG_${config_var}}")
        endif()
    endforeach()

    set(rel_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        "${VCPKG_ADDITIONAL_CMAKE_OPTIONS}" "${VCPKG_ADDITIONAL_CMAKE_OPTIONS_RELEASE}"
        -G ${GENERATOR} ${toolset_option}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
        ${_csc_BUILD_TOOLS})
    set(dbg_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        "${VCPKG_ADDITIONAL_CMAKE_OPTIONS}" "${VCPKG_ADDITIONAL_CMAKE_OPTIONS_DEBUG}"
        -G ${GENERATOR} ${toolset_option}
        -DCMAKE_BUILD_TYPE=Debug
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
        ${_csc_BUILD_TOOLS})

    set(_csc_DISABLE_PARALLEL_CONFIGURE "1") # Parallel configure is currently disabled?
    if(VCPKG_IS_NINJA_HOST AND CMAKE_HOST_WIN32 AND NOT _csc_DISABLE_PARALLEL_CONFIGURE) #VCPKG_IS_NINJA_HOST is currently not set. Fix it when you change the line above. 

    #parallelize the configure step
        set(_contents
            "rule CreateProcess\n  command = $process\n\n"
        )

        macro(_build_cmakecache whereat build_type)
            set(${build_type}_line "build ${whereat}/CMakeCache.txt: CreateProcess\n  process = cmd /c \"cd ${whereat} &&")
            foreach(arg ${${build_type}_command})
                set(${build_type}_line "${${build_type}_line} \"${arg}\"")
            endforeach()
            set(_contents "${_contents}${${build_type}_line}\"\n\n")
        endmacro()

        if(NOT DEFINED VCPKG_BUILD_TYPE)
            _build_cmakecache(".." "rel")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        elseif(VCPKG_BUILD_TYPE STREQUAL "release")
            _build_cmakecache(".." "rel")
        elseif(VCPKG_BUILD_TYPE STREQUAL "debug")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        endif()

        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure)
        file(WRITE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja "${_contents}")

        message(STATUS "Configuring ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ninja -v
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure
            LOGNAME config-${TARGET_TRIPLET}
        )
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                LOGNAME config-${TARGET_TRIPLET}-rel
            )
        endif()
    endif()

    set(_VCPKG_CMAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
endfunction()
