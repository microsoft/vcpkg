vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-connector-cpp
    REF 8.0.31
    SHA512 29c8e36d0ffe32600cc3c41040bfffbf2f6d36953ccd20e8c8ada99b2378ee0ae7f07929c84a84c6b4a58899775bae22fda7c470801400e9ac9feed941393577
    HEAD_REF master
    PATCHES
        fix-static-build8.patch
        export-targets.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/mysql-connector-cpp-config.cmake.in" DESTINATION "${SOURCE_PATH}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_MSVCRT)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jdbc WITH_JDBC
)

if("jdbc" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DMYSQL_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include/mysql")   
    list(APPEND FEATURE_OPTIONS -DBOOST_ROOT=ON)
    list(APPEND FEATURE_OPTIONS -DBoost_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include")
endif()

# Use mysql-connector-cpp's own build process.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DWITH_SSL=${CURRENT_INSTALLED_DIR}"
        -DBUILD_STATIC=${BUILD_STATIC}
        -DSTATIC_MSVCRT=${STATIC_MSVCRT}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mysql-connector-cpp)

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/INFO_SRC"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_SRC"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
