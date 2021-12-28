# This port needs to be updated at the same time as libbson
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 00c59aa4a1f72e49e55b211f28650c66c542739e # 1.17.6
    SHA512 9191c64def45ff268cb5d2ce08782265fb8e0567237c8d3311b91e996bd938d629578a7b50e8db29c4b3aa5bc96f93361f6d918e9cfd4861e5f5c5554cf4616d
    HEAD_REF master
    PATCHES
        fix-dependency-libbson.patch
        disable-static-when-dynamic-build.patch
        fix-arm-build.patch
        fix-dependencies.patch
        disable-source-write.patch
        fix-include-directory.patch
        fix-static-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "snappy" ENABLE_SNAPPY
        "icu"    ENABLE_ICU
        "zstd"   ENABLE_ZSTD
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENABLE_SSL "WINDOWS")
else()
    set(ENABLE_SSL "OPENSSL")
endif()

if(VCPKG_TARGET_IS_ANDROID)
    set(ENABLE_SRV OFF)
    set(ENABLE_SHM_COUNTERS OFF)
else()
    set(ENABLE_SRV AUTO)
    set(ENABLE_SHM_COUNTERS AUTO)
endif()

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _contents)
string(JSON BUILD_VERSION GET "${_contents}" version)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${BUILD_VERSION}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBSON_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DENABLE_MONGOC=ON
        -DENABLE_BSON=SYSTEM
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_SRV=${ENABLE_SRV}
        -DENABLE_SHM_COUNTERS=${ENABLE_SHM_COUNTERS}
        -DENABLE_SSL=${ENABLE_SSL}
        -DENABLE_ZLIB=SYSTEM
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_PythonInterp
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME mongoc-1.0 CONFIG_PATH "lib/cmake/mongoc-1.0" DO_NOT_DELETE_PARENT_CONFIG_PATH)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_cmake_config_fixup(PACKAGE_NAME libmongoc-1.0 CONFIG_PATH "lib/cmake/libmongoc-static-1.0")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libmongoc-1.0 CONFIG_PATH "lib/cmake/libmongoc-1.0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h"
        "define MONGOC_API __declspec(dllimport)" "define MONGOC_API")

     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-static-1.0-config.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake")
     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-static-1.0-config-version.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config-version.cmake")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

# Create cmake files for _both_ find_package(mongo-c-driver) and find_package(libmongoc-static-1.0)/find_package(libmongoc-1.0)
file(READ "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake" LIBMONGOC_CONFIG_CMAKE)

# Patch: Set _IMPORT_PREFIX and replace PACKAGE_PREFIX_DIR
string(REPLACE
[[
get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
]]
[[
# VCPKG PATCH SET IMPORT_PREFIX
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()
]]
    LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
string(REPLACE [[PACKAGE_PREFIX_DIR]] [[_IMPORT_PREFIX]] LIBMONGOC_CONFIG_CMAKE "${LIBMONGOC_CONFIG_CMAKE}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libmongoc-1.0/libmongoc-1.0-config.cmake" "${LIBMONGOC_CONFIG_CMAKE}")

file(COPY "${SOURCE_PATH}/THIRD_PARTY_NOTICES" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_fixup_pkgconfig()
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/uninstall.sh")