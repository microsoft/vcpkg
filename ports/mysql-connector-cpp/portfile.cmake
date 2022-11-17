vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-connector-cpp
    REF 8.0.30
    SHA512 fd6d8a03ba66ca028b3748218c60a721c9e2c79867c6cf2ea95d2649d3a252e9bd307986b149897dcc1d24a11785666c5480225a20c4baba7c87b376b7289a13
    HEAD_REF master
    PATCHES
        fix-static-build8.patch
        export-targets.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/mysql-connector-cpp-config.cmake.in" DESTINATION "${SOURCE_PATH}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_MSVCRT)

# Use mysql-connector-cpp's own build process.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
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
