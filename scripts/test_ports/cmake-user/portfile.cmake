set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(cmake_version OFF)
if("cmake-3-4" IN_LIST FEATURES)
    set(cmake_version 3.4.3)
    string(REGEX REPLACE "([^.]*[.][^.]*).*" "\\1" cmake_major_minor "${cmake_version}")
    if(HOST_TRIPLET MATCHES "^x.*-(windows|mingw)")
        set(name "cmake-${cmake_version}-win32-x86")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.zip"
            URLS "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${name}.zip"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.zip"
            SHA512 c74a8f85ce04a2c0f68fd315a9a7e2fee5cc98af9e8117cca6b35a4f0942cae2d101672e5936a8bfc20289c8c82da582531495308657348a1121e3f568588bd3
        )
        set(cmake_bin_dir "/bin")
    elseif(HOST_TRIPLET MATCHES "^x.*-osx")
        set(name "cmake-${cmake_version}-Darwin-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v3.4.3/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 c3da566a19e95b8f91bf601518b9c49304b9bb8500f5a086eb2c867514176278e51dd893952b8ab54a2839ed02c898036c7985fe0bb761db9ccb988343463ea2
        )
        set(cmake_bin_dir "/CMake.app/Contents/bin")
    elseif(HOST_TRIPLET MATCHES "^x.*-linux")
        set(name "cmake-${cmake_version}-Linux-x86_64")
        vcpkg_download_distfile(legacy_cmake_archive
            FILENAME "${name}.tar.gz"
            URLS "https://github.com/Kitware/CMake/releases/download/v3.4.3/${name}.tar.gz"
                 "https://cmake.org/files/v${cmake_major_minor}/${name}.tar.gz"
            SHA512 455b8f940ccda0ba1169d3620db67c0bf89284126386408cd28b76b66c59c4c2ea5ad8def0095166e7524f6cf5202f117a2fa49e1525f93ed711657a5d2ae988
        )
        set(cmake_bin_dir "/bin")
    else()
        message(FATAL_ERROR "Unable to test feature 'cmake-3-4' for '${HOST_TRIPLET}' host.")
    endif()

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH legacy_cmake
        ARCHIVE "${legacy_cmake_archive}"
        REF "${cmake_version}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${name}"
    )
    set(CMAKE_COMMAND "${legacy_cmake}${cmake_bin_dir}/cmake")
endif()

set(packages "")
if("find-package" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" vcpkg_json)
    string(JSON packages_json GET "${vcpkg_json}" "features" "find-package" "dependencies")
    string(JSON packages_count LENGTH "${packages_json}")
    if(packages_count GREATER 0)
        math(EXPR last "${packages_count} - 1")
        foreach(i RANGE 0 ${last})
            string(JSON package GET "${packages_json}" ${i} "$package")
            list(APPEND packages "${package}")
        endforeach()
    endif()
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        list(REMOVE_ITEM packages "Curses")
    endif()
endif()

if(DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
    set(NINJA "ninja")
else()
    vcpkg_find_acquire_program(NINJA)
endif()

function(test_cmake_project)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "NAME" "OPTIONS")
    if(NOT arg_NAME)
        message(FATAL_ERROR "The NAME argument is mandatory.")
    endif()

    set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${arg_NAME}")
    set(base_options
        -G "Ninja"
        "-DCMAKE_MAKE_PROGRAM=${NINJA}"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DVCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DCMAKE_INSTALL_PREFIX=${build_dir}/install"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_MANIFEST_MODE=OFF"
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

    message(STATUS "Running tests for '${arg_NAME}'")
    file(REMOVE_RECURSE "${build_dir}")
    file(MAKE_DIRECTORY "${build_dir}")
    vcpkg_execute_required_process(
        COMMAND
            "${CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/project"
            ${base_options}
            ${arg_OPTIONS}
        WORKING_DIRECTORY "${build_dir}"
        LOGNAME "${TARGET_TRIPLET}-${arg_NAME}-config"
    )
    vcpkg_execute_required_process(
        COMMAND
            "${CMAKE_COMMAND}" --build . --target install
        WORKING_DIRECTORY "${build_dir}"
        LOGNAME "${TARGET_TRIPLET}-${arg_NAME}-build"
    )
    # To produce better error messages for failing wrappers,
    # we run execute_process directly here, for each wrapper.
    string(REPLACE " OFF:" ":" message
    "  CMake ${cmake_version}: `find_package(@package@)` failed.\n"
    "  See logs for more information:\n"
    "    @log_out@\n"
    "    @log_err@\n"
    )
    if(DEFINED ENV{BUILD_REASON}) # On Azure Pipelines, add extra markup.
        string(REPLACE "  CMake" "##vso[task.logissue type=error]CMake" message "${message}")
    endif()
    foreach(package IN LISTS packages)
        string(MAKE_C_IDENTIFIER "${package}" package_string)
        set(find_package_build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-find-package-${package_string}-${arg_NAME}")
        set(log_out "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-find-package-${package_string}-${arg_NAME}-out.log")
        set(log_err "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-find-package-${package_string}-${arg_NAME}-err.log")

        message(STATUS "  find_package(${package})")
        file(REMOVE_RECURSE "${find_package_build_dir}")
        file(MAKE_DIRECTORY "${find_package_build_dir}")
        execute_process(
            COMMAND
                "${CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/project"
                ${base_options}
                ${arg_OPTIONS}
                "-DFIND_PACKAGES=${package}"
            OUTPUT_FILE "${log_out}"
            ERROR_FILE "${log_err}"
            RESULT_VARIABLE package_result
            WORKING_DIRECTORY "${find_package_build_dir}"
        )
        if(package_result)
            string(CONFIGURE "${message}" package_message @ONLY)
            message(SEND_ERROR "${package_message}")
        endif()
    endforeach()
endfunction()

test_cmake_project(NAME "release"
    OPTIONS
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_PREFIX_PATH=SYSTEM_LIBS" # for testing VCPKG_PREFER_SYSTEM_LIBS
        "-DVCPKG_PREFER_SYSTEM_LIBS=OFF"
        "-DCHECK_CMAKE_VERSION=${cmake_version}"
)
test_cmake_project(NAME "debug"
    OPTIONS
        "-DCMAKE_BUILD_TYPE=Debug"
        "-DCMAKE_PREFIX_PATH=SYSTEM_LIBS" # for testing VCPKG_PREFER_SYSTEM_LIBS
        "-DVCPKG_PREFER_SYSTEM_LIBS=ON"
        "-DCHECK_CMAKE_VERSION=${cmake_version}"
)
