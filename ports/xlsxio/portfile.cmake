vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brechtsanders/xlsxio
    REF e3acace39e5fb153f5ce3500a4952c2bf93175bd
    SHA512 8148b89c43cf45653c583d51fb8050714d3cd0a76ab9a05d46604f3671a06487e4fc58d3f6f9f2a9f9b57a9f9fe1863ef07017c74197f151390576c5aac360ea
    HEAD_REF master
    PATCHES fix-dependencies.patch
)

file(REMOVE ${SOURCE_PATH}/CMake/FindMinizip.cmake)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libzip WITH_LIBZIP
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)    
    set(BUILD_STATIC ON)
    set(BUILD_SHARED OFF)
else()
   set(BUILD_SHARED ON)
   set(BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_SHARED=${BUILD_SHARED}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DWITH_WIDE=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PC_FILES=OFF
        -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
