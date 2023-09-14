# This port needs to be updated at the same time as libbson

vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF "${VERSION}"
    SHA512 242416638bf6722ccda67ecc15cf78f8531f1a4ae0e89fd66cde74221d7b98b859442f5b70628802972961e69156fd7afcc916d7a83cc134d5723eb0b6e15cc9
    HEAD_REF master
    PATCHES
        disable-dynamic-when-static.patch
        fix-include-directory.patch # vcpkg legacy decision
        fix-dependencies.patch
        fix-mingw.patch
        pkgconfig.patch
)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${VERSION}")

# Cannot use string(COMPARE EQUAL ...)
set(ENABLE_STATIC OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        icu         ENABLE_ICU
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DUSE_SYSTEM_LIBBSON=ON
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SHM_COUNTERS=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_TESTS=OFF
        -DENABLE_UNINSTALL=OFF
        -DENABLE_ZLIB=SYSTEM
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET} # for host pkgconf in PATH
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME mongoc-1.0 CONFIG_PATH "lib/cmake/mongoc-1.0" DO_NOT_DELETE_PARENT_CONFIG_PATH)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h"
        "#define MONGOC_MACROS_H" "#define MONGOC_MACROS_H\n#ifndef MONGOC_STATIC\n#define MONGOC_STATIC\n#endif")
    vcpkg_cmake_config_fixup(PACKAGE_NAME libmongoc-static-1.0 CONFIG_PATH "lib/cmake/libmongoc-static-1.0")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/libmongoc-1.0-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libmongoc-1.0 CONFIG_PATH "lib/cmake/libmongoc-1.0")
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
