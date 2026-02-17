vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF "${VERSION}"
    SHA512 1f1346a52db7241af832d7d5db107512a73af75546818e6600e420505f48c613b08cc332e76337670fe4b19ca057a2b04385b05279e76385adcf42276190123a
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

vcpkg_cmake_config_fixup(PACKAGE_NAME "bson-${VERSION}" CONFIG_PATH "lib/cmake/bson-${VERSION}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bson/macros.h"
        "#define BSON_MACROS_H" "#define BSON_MACROS_H\n#ifndef BSON_STATIC\n#define BSON_STATIC\n#endif")
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
