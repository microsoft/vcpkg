# This port needs to be updated at the same time as mongo-c-driver
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 416faa30539b9e8069a80549b94dbe5d3e9b24fb # debian/1.17.5-1
    SHA512 8f590c90467dbbdfff7952474a71ba8df05243a4731fb8be8b5dcb2afb83e63fe8bf1c24f4984162c1d905782ceaa613b255c8abe03972eac5124a93d16dea20
    HEAD_REF master
    PATCHES
        enable-build-static-or-dynamic.patch
        fix-uwp.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/CONTROL _contents)
string(REGEX MATCH "\nVersion:[ ]*[^ \n]+" _contents "${_contents}")
string(REGEX REPLACE ".+Version:[ ]*([\\.0-9]+).*" "\\1" BUILD_VERSION "${_contents}")

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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bson-${PORT_POSTFIX} TARGET_PATH share/bson-${PORT_POSTFIX})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver)

# This rename is needed because the official examples expect to use #include <bson.h>
# See Microsoft/vcpkg#904
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libbson-${PORT_POSTFIX}
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/bson/bson-macros.h
        "define BSON_API __declspec(dllimport)" "define BSON_API")

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/bson-1.0/bson-targets.cmake
    "include/libbson-1.0" "include/")

file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})