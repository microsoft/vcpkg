set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(cmake_commands "")
if("cmake-current" IN_LIST FEATURES)
    list(APPEND cmake_commands "${CMAKE_COMMAND}")
endif()
if("cmake-3-16" IN_LIST FEATURES)
    # For convenient updates, use 
    # vcpkg install ... --cmake-args=-DVCPKG_CMAKE_USER_UPDATE=1
    set(cmake_version 3.16.3)
    set(legacy_cmake_archive NOTFOUND)
    string(REGEX REPLACE "([^.]*[.][^.]*).*" "\\1" cmake_major_minor "${cmake_version}")
    if(VCPKG_HOST_IS_WINDOWS OR VCPKG_CMAKE_USER_UPDATE)
        set(name "cmake-${cmake_version}-win64-x64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.zip"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.zip"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.zip"
            SHA512 724d22f3736f0f3503ceb6b49ebec64cd569c4c16ad4fae8ac38918b09ee67e3eaa8072e30546f14f4c13bb94c5639ec940ea1b4695c94225b2a597bb4da1ede
        )
        set(cmake_bin_dir "/bin")
    endif()
    if(VCPKG_HOST_IS_OSX OR VCPKG_CMAKE_USER_UPDATE)
        set(name "cmake-${cmake_version}-Darwin-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 3e59e2406f4e088b60922fbf23e92e1be3bb34c00f919625210fd93c059b5e6785afa40d3a501f36b281cde29de592f2ccffade6fa3980d0cf31dc845483184f
        )
        set(cmake_bin_dir "/CMake.app/Contents/bin")
    endif()
    if(VCPKG_HOST_IS_LINUX OR VCPKG_CMAKE_USER_UPDATE)
        set(name "cmake-${cmake_version}-Linux-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 03be16ad06fcabe40a36d0a510fdb58f5612108aed70cef7f68879d82b9e04ad62a9d0c30f3406df618ec219c74fc27b4be533d970bc60ac22333951d6cabe1a
        )
        set(cmake_bin_dir "/bin")
    endif()
    if(NOT legacy_cmake_archive)
        message(FATAL_ERROR "Unable to test feature 'cmake-3-16' for '${HOST_TRIPLET}' host.")
    endif()
    if(VCPKG_CMAKE_USER_UPDATE)
        message(STATUS "All downloads are up-to-date.")
        message(FATAL_ERROR "Stopping due to VCPKG_CMAKE_USER_UPDATE being enabled.")
    endif()
    
    vcpkg_extract_source_archive(legacy_cmake
        ARCHIVE "${legacy_cmake_archive}"
        SOURCE_BASE "${cmake_version}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cmake"
    )
    list(APPEND cmake_commands "${legacy_cmake}${cmake_bin_dir}/cmake")
endif()

vcpkg_find_acquire_program(NINJA)

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
        # Interface: CMake
        -G "Ninja"
        "-DCMAKE_MAKE_PROGRAM=${NINJA}"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DCMAKE_INSTALL_PREFIX=${build_dir}/install"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        # Interface: vcpkg.cmake
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}"
        "-DVCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DVCPKG_MANIFEST_MODE=OFF"
        # Interface: project/CMakeLists.txt
        "-DCHECK_CMAKE_VERSION=${cmake_version}"
    )

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME AND VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        # Interface: CMake
        list(APPEND base_options "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            list(APPEND base_options "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
        endif()
    endif()

    if(DEFINED VCPKG_XBOX_CONSOLE_TARGET)
        list(APPEND arg_OPTIONS "-DXBOX_CONSOLE_TARGET=${VCPKG_XBOX_CONSOLE_TARGET}")
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
                --trace-expand
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
