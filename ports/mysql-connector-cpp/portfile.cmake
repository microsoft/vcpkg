vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-connector-cpp
    REF "${VERSION}"
    SHA512 aa432822d4c9d7f1328bf59e261c362570f6b2237a5a9f730f96f079aba14bdc689f400ab2857c4cdd1dca025eb09eaaf2b26328f3b42d117f24b9182dc2cc0a
    HEAD_REF master
    PATCHES
        depfindprotobuf.diff
        disable-telemetry.diff
        dont-preload-cache.diff
        lib-name-static.diff
        merge-archives.diff
        save-linker-opts.diff
        export-targets.patch
        protobuf-source.patch  # Disables upstream log event handling!
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/mysql-connector-cpp-config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(REMOVE_RECURSE
    "${SOURCE_PATH}/cdk/extra/common"
    "${SOURCE_PATH}/cdk/extra/exprtest"
    "${SOURCE_PATH}/cdk/extra/lz4"
    "${SOURCE_PATH}/cdk/extra/ngs_mockup"
    "${SOURCE_PATH}/cdk/extra/process_launcher"
    "${SOURCE_PATH}/cdk/extra/protobuf"
    "${SOURCE_PATH}/cdk/extra/rapidjson"
    "${SOURCE_PATH}/cdk/extra/zlib"
    "${SOURCE_PATH}/cdk/extra/zstd"
    "${SOURCE_PATH}/jdbc/extra/otel/opentelemetry-cpp-1.12.0"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS options
    FEATURES
        jdbc    WITH_JDBC
)

if(VCPKG_CROSSCOMPILING AND EXISTS "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/save_linker_opts${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    vcpkg_list(APPEND options "-DWITH_SAVE_LINKER_OPTS=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/save_linker_opts${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_MSVCRT)

# Preparing to merge STATIC library: connector (xapi;devapi)
# CMake Error at cmake/libutils.cmake:297 (message):
#   Sorry but building static connector on Windows using MSVC toolset works
#   only with msbuild at the moment.
# Call Stack (most recent call first):
#   CMakeLists.txt:413 (merge_libraries)
set(USE_MSBUILD_ARG)
if(BUILD_STATIC)
    set(USE_MSBUILD_ARG WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${USE_MSBUILD_ARG}
    OPTIONS
        ${options}
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        "-DWITH_PROTOC=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DBUILD_STATIC=${BUILD_STATIC}
        -DMYSQLCLIENT_STATIC_LINKING=${BUILD_STATIC}
        -DSTATIC_MSVCRT=${STATIC_MSVCRT}
        -DINSTALL_LIB_DIR=lib
        -DINSTALL_LIB_DIR_DEBUG=lib
        -DINSTALL_LIB_DIR_STATIC=lib
        -DINSTALL_LIB_DIR_STATIC_DEBUG=lib
        -DTELEMETRY=OFF
        -DWITH_DOC=OFF
        -DWITH_HEADER_CHECKS=OFF
        -DWITH_SSL=system
        -DWITH_TESTS=OFF
    MAYBE_UNUSED_VARIABLES
        TELEMETRY
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mysql-connector-cpp)
configure_file("${CURRENT_PORT_DIR}/mysql-concpp-config.cmake" "${CURRENT_PACKAGES_DIR}/share/mysql-concpp/mysql-concpp-config.cmake" @ONLY)

if(NOT VCPKG_CROSSCOMPILING AND EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libutils/save_linker_opts${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES save_linker_opts
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libutils"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
    )
endif()

if(BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mysqlx/common/api.h" "defined STATIC_CONCPP" "(1)")
    if(WITH_JDBC)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/jdbc/cppconn/build_config.h" "ifdef STATIC_CONCPP" "if 1")
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/INFO_SRC"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_SRC"
    "${CURRENT_PACKAGES_DIR}/mysql-concpp-config.cmake"
    "${CURRENT_PACKAGES_DIR}/mysql-concpp-config-version.cmake"
    "${CURRENT_PACKAGES_DIR}/debug/mysql-concpp-config.cmake"
    "${CURRENT_PACKAGES_DIR}/debug/mysql-concpp-config-version.cmake"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
