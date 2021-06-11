# This port needs to be updated at the same time as libbson
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-c-driver
    REF 416faa30539b9e8069a80549b94dbe5d3e9b24fb # debian/1.17.5-1
    SHA512 8f590c90467dbbdfff7952474a71ba8df05243a4731fb8be8b5dcb2afb83e63fe8bf1c24f4984162c1d905782ceaa613b255c8abe03972eac5124a93d16dea20
    HEAD_REF master
    PATCHES
        disable-static-when-dynamic-build.patch
        fix-arm-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "snappy" ENABLE_SNAPPY
        "icu"    ENABLE_ICU
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

file(READ ${CMAKE_CURRENT_LIST_DIR}/CONTROL _contents)
string(REGEX MATCH "\nVersion:[ ]*[^ \n]+" _contents "${_contents}")
string(REGEX REPLACE ".+Version:[ ]*([\\.0-9]+).*" "\\1" BUILD_VERSION "${_contents}")

file(WRITE "${BUILD_VERSION}" ${SOURCE_PATH}/VERSION_CURRENT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(PORT_POSTFIX "1.0")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mongoc-${PORT_POSTFIX} TARGET_PATH share/mongoc-${PORT_POSTFIX})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # drop the __declspec(dllimport) when building static
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/mongoc/mongoc-macros.h
        "define MONGOC_API __declspec(dllimport)" "define MONGOC_API")

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(COPY ${SOURCE_PATH}/THIRD_PARTY_NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)