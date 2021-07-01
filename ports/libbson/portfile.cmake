# This port needs to be updated at the same time as mongo-c-driver
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 00c59aa4a1f72e49e55b211f28650c66c542739e # 1.17.6
    SHA512 9191c64def45ff268cb5d2ce08782265fb8e0567237c8d3311b91e996bd938d629578a7b50e8db29c4b3aa5bc96f93361f6d918e9cfd4861e5f5c5554cf4616d
    HEAD_REF master
#    PATCHES
#        fix-uwp.patch
#        fix-static-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/vcpkg.json _contents)
string(REGEX MATCH "\"version\":[ ]*\"[^ \"\n]+" _contents "${_contents}")
string(REGEX REPLACE "\"version\":[ ]*\"(.+)" "\\1" BUILD_VERSION "${_contents}")

file(WRITE "${BUILD_VERSION}" ${SOURCE_PATH}/VERSION_CURRENT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DENABLE_MONGOC=OFF
        -DENABLE_BSON=ON
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DBUILD_VERSION=${BUILD_VERSION}
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(PORT_POSTFIX "1.0")

vcpkg_cmake_config_fixup(PACKAGE_NAME bson-${PORT_POSTFIX} CONFIG_PATH "lib/cmake/bson-${PORT_POSTFIX}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-${PORT_POSTFIX} CONFIG_PATH "lib/cmake/libbson-static-${PORT_POSTFIX}")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libbson-${PORT_POSTFIX} CONFIG_PATH "lib/cmake/libbson-${PORT_POSTFIX}")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/mongo-c-driver")

# This rename is needed because the official examples expect to use #include <bson.h>
# See Microsoft/vcpkg#904
file(RENAME
    "${CURRENT_PACKAGES_DIR}/include/libbson-${PORT_POSTFIX}"
    "${CURRENT_PACKAGES_DIR}/temp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/temp" "${CURRENT_PACKAGES_DIR}/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/bson/bson-macros.h
        "define BSON_API __declspec(dllimport)" "define BSON_API")
        
    file(RENAME
	    "${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX}/libbson-static-${PORT_POSTFIX}-config.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX}/libbson-${PORT_POSTFIX}-config.cmake")
    file(RENAME
	    "${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX}/libbson-static-${PORT_POSTFIX}-config-version.cmake"
        "${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX}/libbson-${PORT_POSTFIX}-config-version.cmake")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/bson-${PORT_POSTFIX}/bson-targets.cmake"
    "include/libbson-1.0" "include/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libbson-${PORT_POSTFIX}/libbson-${PORT_POSTFIX}-config.cmake"
    "include/libbson-1.0" "include/")

file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
