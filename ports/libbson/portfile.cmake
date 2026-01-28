vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF "${VERSION}"
    SHA512 2f751bf33410f084e083fc73d8ebb138e40c956e9bccb2ca460d33ab5e6b75793e1910defb1d5faad849a9668e0afc5024179ad323beacd75a12538f2abda270
    HEAD_REF master
    PATCHES
        fix-include-directory.patch # vcpkg legacy decision
)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${VERSION}")

# Cannot use string(COMPARE EQUAL ...)
set(ENABLE_STATIC OFF)
set(ENABLE_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # because it writes the file VERSION_CURRENT in the source directory
    OPTIONS
        "-DBUILD_VERSION=${VERSION}"
        -DENABLE_BSON=ON
        -DENABLE_EXAMPLES=OFF
        -DENABLE_MONGOC=OFF
        -DENABLE_SASL=OFF
        -DENABLE_SNAPPY=OFF
        -DENABLE_SRV=OFF
        -DENABLE_SSL=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_TESTS=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_UNINSTALL=OFF
        -DENABLE_ZLIB=SYSTEM
        -DENABLE_ZSTD=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME bson-1.0 CONFIG_PATH "lib/cmake/bson-1.0" DO_NOT_DELETE_PARENT_CONFIG_PATH)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bson/bson-macros.h"
        "#define BSON_MACROS_H" "#define BSON_MACROS_H\n#ifndef BSON_STATIC\n#define BSON_STATIC\n#endif")
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-static-1.0 CONFIG_PATH "lib/cmake/libbson-static-1.0")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/libbson-1.0")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/libbson-1.0-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libbson-1.0")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-1.0 CONFIG_PATH "lib/cmake/libbson-1.0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/mongo-c-driver"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION  "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/THIRD_PARTY_NOTICES"
        "${SOURCE_PATH}/src/libbson/THIRD_PARTY_NOTICES"
)
