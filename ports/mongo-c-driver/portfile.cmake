# This port needs to be updated at the same time as libbson
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF "${VERSION}"
    SHA512 1f1346a52db7241af832d7d5db107512a73af75546818e6600e420505f48c613b08cc332e76337670fe4b19ca057a2b04385b05279e76385adcf42276190123a
    HEAD_REF master
    PATCHES
        disable-dynamic-when-static.patch
        fix-dependencies.patch
        fix-include-directory.patch
        fix-mingw.patch
        remove_abs_patch.cmake
)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${VERSION}")
file(TOUCH "${SOURCE_PATH}/src/utf8proc-editable")
file(GLOB vendored_libs "${SOURCE_PATH}/src/utf8proc-*" "${SOURCE_PATH}/src/zlib-*/*.h")
file(REMOVE_RECURSE ${vendored_libs})

# Cannot use string(COMPARE EQUAL ...)
set(ENABLE_STATIC OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        snappy      ENABLE_SNAPPY
        zstd        ENABLE_ZSTD
)

if("openssl" IN_LIST FEATURES)
    list(APPEND OPTIONS -DENABLE_SSL=OPENSSL)
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -DENABLE_SSL=WINDOWS)
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    list(APPEND OPTIONS -DENABLE_SSL=DARWIN)
else()
    list(APPEND OPTIONS -DENABLE_SSL=OFF)
endif()

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_list(APPEND OPTIONS -DENABLE_SRV=OFF)
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${OPTIONS}
        "-DBUILD_VERSION=${VERSION}"
        -DUSE_BUNDLED_UTF8PROC=OFF
        -DUSE_SYSTEM_LIBBSON=ON
        -DENABLE_CLIENT_SIDE_ENCRYPTION=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SASL=OFF
        -DENABLE_SHM_COUNTERS=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_TESTS=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_UNINSTALL=OFF
        -DENABLE_ZLIB=SYSTEM
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if("snappy" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/mongoc2-static.pc" " -lSnappy::snappy" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/mongoc2-static.pc" "Requires: " "Requires: snappy ")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/mongoc2-static.pc" " -lSnappy::snappy" "")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/mongoc2-static.pc" "Requires: " "Requires: snappy ")
    endif()
endif()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME "mongoc-${VERSION}" CONFIG_PATH "lib/cmake/mongoc-${VERSION}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h"
        "#define MONGOC_MACROS_H" "#define MONGOC_MACROS_H\n#ifndef MONGOC_STATIC\n#define MONGOC_STATIC\n#endif")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION  "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/THIRD_PARTY_NOTICES"
        "${SOURCE_PATH}/src/libmongoc/THIRD_PARTY_NOTICES"
)
