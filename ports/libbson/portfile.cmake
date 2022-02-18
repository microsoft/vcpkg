# This port needs to be updated at the same time as mongo-c-driver
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 00c59aa4a1f72e49e55b211f28650c66c542739e # 1.17.6
    SHA512 9191c64def45ff268cb5d2ce08782265fb8e0567237c8d3311b91e996bd938d629578a7b50e8db29c4b3aa5bc96f93361f6d918e9cfd4861e5f5c5554cf4616d
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        fix-static-cmake.patch
        disable-source-write.patch
        fix-include-directory.patch
        fix-static-cmake-2.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _contents)
string(JSON BUILD_VERSION GET "${_contents}" version)
file(WRITE "${SOURCE_PATH}/VERSION_CURRENT" "${BUILD_VERSION}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_MONGOC=OFF
        -DENABLE_BSON=ON
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_PythonInterp
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()


vcpkg_cmake_config_fixup(PACKAGE_NAME bson-1.0 CONFIG_PATH "lib/cmake/bson-1.0" DO_NOT_DELETE_PARENT_CONFIG_PATH)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-1.0 CONFIG_PATH "lib/cmake/libbson-static-1.0")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-1.0 CONFIG_PATH "lib/cmake/libbson-1.0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/mongo-c-driver")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bson/bson-macros.h"
        "define BSON_API __declspec(dllimport)" "define BSON_API")

     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libbson-1.0/libbson-static-1.0-config.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libbson-1.0/libbson-1.0-config.cmake")
     file(RENAME
        "${CURRENT_PACKAGES_DIR}/share/libbson-1.0/libbson-static-1.0-config-version.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libbson-1.0/libbson-1.0-config-version.cmake")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(COPY "${SOURCE_PATH}/THIRD_PARTY_NOTICES" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libbson")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_fixup_pkgconfig()
