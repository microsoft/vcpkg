set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(cmake_commands "")
if("cmake-current" IN_LIST FEATURES)
    list(APPEND cmake_commands "${CMAKE_COMMAND}")
endif()
if("cmake-3-7" IN_LIST FEATURES)
    set(cmake_version 3.7.2)
    string(REGEX REPLACE "([^.]*[.][^.]*).*" "\\1" cmake_major_minor "${cmake_version}")
    if(VCPKG_HOST_IS_WINDOWS)
        set(name "cmake-${cmake_version}-win32-x86")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.zip"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.zip"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.zip"
            SHA512 c359a22e2e688da1513db195280d6e8987bc8d570a0c543f1b1dfc8572fe4fd6c23d951ec5d5eae640fcca3bef3ae469083511474796ade8c6319d8bc4e4b38d
        )
        set(cmake_bin_dir "/bin")
    elseif(VCPKG_HOST_IS_OSX)
        set(name "cmake-${cmake_version}-Darwin-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 8e41608f4dd998020acf2bd1b0dab4aec37b3ea9e228f2c4a457cd1c0339d94db38a0548b4b07a9e3605f9beb11a3f6737a72813586c4ad5f730d74038a14c2b
        )
        set(cmake_bin_dir "/CMake.app/Contents/bin")
    elseif(VCPKG_HOST_IS_LINUX)
        set(name "cmake-${cmake_version}-Linux-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 459909fcfb9c74993c3d4ab9db4e31ea940515b670db44d039de611d813099895e695467cc8da24824315486e38e2f3e246aa92d6236c51103822ec8a39e3168
        )
        set(cmake_bin_dir "/bin")
    else()
        message(FATAL_ERROR "Unable to test feature 'cmake-3-7' for '${HOST_TRIPLET}' host.")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH legacy_cmake
        ARCHIVE "${legacy_cmake_archive}"
        REF "${cmake_version}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${name}"
    )
    list(APPEND cmake_commands "${legacy_cmake}${cmake_bin_dir}/cmake")
endif()

if(DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
    set(NINJA "ninja")
else()
    vcpkg_find_acquire_program(NINJA)
endif()

if(NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    z_vcpkg_select_default_vcpkg_chainload_toolchain()
endif()

function(get_packages out_packages cmake_version)
    set(packages "")
    if("find-package" IN_LIST FEATURES)
        file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" vcpkg_json)
        string(JSON packages_json GET "${vcpkg_json}" "features" "find-package" "dependencies")
        string(JSON packages_count LENGTH "${packages_json}")
        if(packages_count GREATER 0)
            math(EXPR last "${packages_count} - 1")
            foreach(i RANGE 0 ${last})
                # Some ports may be excluded via platform expressions,
                # because they don't support particular platforms.
                # Using the installed vcpkg_abi_info.txt as an indicator.
                string(JSON port GET "${packages_json}" "${i}" "name")
                if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/share/${port}/vcpkg_abi_info.txt")
                    continue()
                endif()
                string(JSON since ERROR_VARIABLE since_not_found GET "${packages_json}" "${i}" "\$since")
                if(since AND cmake_version VERSION_LESS since)
                    continue()
                endif()
                if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/share/${port}/vcpkg_abi_info.txt")
                    continue()
                endif()
                string(JSON package GET "${packages_json}" "${i}" "\$package")
                list(APPEND packages "${package}")
            endforeach()
        endif()
    endif()
    if("pkg-check-modules" IN_LIST FEATURES)
        list(APPEND packages "ZLIBviaPkgConfig")
    endif()
    set("${out_packages}" "${packages}" PARENT_SCOPE)
endfunction()

function(test_cmake_project)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "CMAKE_COMMAND;NAME" "OPTIONS")
    if(NOT arg_NAME)
        message(FATAL_ERROR "The NAME argument is mandatory.")
    endif()
    if(NOT arg_CMAKE_COMMAND)
        set(arg_CMAKE_COMMAND "${CMAKE_COMMAND}")
    endif()

    execute_process(
        COMMAND "${arg_CMAKE_COMMAND}" --version
        OUTPUT_VARIABLE cmake_version_output
        RESULT_VARIABLE cmake_version_result
    )
    string(REGEX MATCH "[1-9][0-9]*\\.[0-9]*\\.[0-9]*" cmake_version "${cmake_version_output}")
    if(cmake_version_result OR NOT cmake_version)
        message(FATAL_ERROR "Unable to determine version for '${arg_CMAKE_COMMAND}'.")
    endif()

    set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-${arg_NAME}")
    set(base_options
        -G "Ninja"
        "-DCMAKE_MAKE_PROGRAM=${NINJA}"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}"
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}"
        "-DVCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DCMAKE_INSTALL_PREFIX=${build_dir}/install"
        "-DVCPKG_MANIFEST_MODE=OFF"
        "-DCHECK_CMAKE_VERSION=${cmake_version}"
    )

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME AND VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND base_options "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            list(APPEND base_options "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
        endif()
        if(DEFINED VCPKG_PLATFORM_TOOLSET)
            list(APPEND base_options "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}")
        endif()
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND base_options -DBUILD_SHARED_LIBS=ON)
    else()
        list(APPEND base_options -DBUILD_SHARED_LIBS=OFF)
    endif()

    message(STATUS "Running tests with CMake ${cmake_version} for '${arg_NAME}'")
    file(REMOVE_RECURSE "${build_dir}")
    file(MAKE_DIRECTORY "${build_dir}")
    vcpkg_execute_required_process(
        COMMAND
            "${arg_CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/project"
            ${base_options}
            ${arg_OPTIONS}
        WORKING_DIRECTORY "${build_dir}"
        LOGNAME "${TARGET_TRIPLET}-${cmake_version}-${arg_NAME}-config"
    )
    vcpkg_execute_required_process(
        COMMAND
            "${arg_CMAKE_COMMAND}" --build . --target install
        WORKING_DIRECTORY "${build_dir}"
        LOGNAME "${TARGET_TRIPLET}-${cmake_version}-${arg_NAME}-build"
    )
    # To produce better error messages for failing wrappers,
    # we run execute_process directly here, for each wrapper.
    string(REPLACE " OFF:" ":" message
    "  CMake ${cmake_version}: @step@ with `find_package(@package@)` failed.\n"
    "  See logs for more information:\n"
    "    @log_out@\n"
    "    @log_err@\n"
    )
    if(DEFINED ENV{BUILD_REASON}) # On Azure Pipelines, add extra markup.
        string(REPLACE "  CMake" "##vso[task.logissue type=error]CMake" message "${message}")
    endif()
    get_packages(packages "${cmake_version}")
    foreach(package IN LISTS packages)
        string(MAKE_C_IDENTIFIER "${package}" package_string)
        set(find_package_build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-find-package-${package_string}-${arg_NAME}")
        set(log_out "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-find-package-${package_string}-${arg_NAME}-out.log")
        set(log_err "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-find-package-${package_string}-${arg_NAME}-err.log")

        message(STATUS "  find_package(${package})")
        file(REMOVE_RECURSE "${find_package_build_dir}")
        file(MAKE_DIRECTORY "${find_package_build_dir}")
        execute_process(
            COMMAND
                "${arg_CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/project"
                ${base_options}
                ${arg_OPTIONS}
                "-DFIND_PACKAGES=${package}"
            OUTPUT_FILE "${log_out}"
            ERROR_FILE "${log_err}"
            RESULT_VARIABLE package_result
            WORKING_DIRECTORY "${find_package_build_dir}"
        )
        if(package_result)
            set(step "configuration")
            string(CONFIGURE "${message}" package_message @ONLY)
            message(SEND_ERROR "${package_message}")
        else()
            set(log_out "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-find-package-${package_string}-${arg_NAME}-build-out.log")
            set(log_err "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${cmake_version}-find-package-${package_string}-${arg_NAME}-build-err.log")
            execute_process(
                COMMAND
                    "${arg_CMAKE_COMMAND}" --build .
                OUTPUT_FILE "${log_out}"
                ERROR_FILE "${log_err}"
                RESULT_VARIABLE package_result
                WORKING_DIRECTORY "${find_package_build_dir}"
            )
            if(package_result)
                set(step "build")
                string(CONFIGURE "${message}" package_message @ONLY)
                message(SEND_ERROR "${package_message}")
            endif()
        endif()
    endforeach()
endfunction()

foreach(executable IN LISTS cmake_commands)
    test_cmake_project(NAME "release"
        CMAKE_COMMAND "${executable}"
        OPTIONS
            "-DCMAKE_BUILD_TYPE=Release"
    )
    test_cmake_project(NAME "debug"
        CMAKE_COMMAND "${executable}"
        OPTIONS
            "-DCMAKE_BUILD_TYPE=Debug"
    )
endforeach()
