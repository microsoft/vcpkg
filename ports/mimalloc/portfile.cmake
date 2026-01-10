vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 a674dbe119e080630de0af12a972af9fb1ac3611413fd5a7eb14f61e47af620f6368a28e8849757136fcc1c3c4f8f776cfa0f351d3f0ef463eff98fdf8c4db52
    HEAD_REF dev3
    PATCHES
        pkgconfig-cxx.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        override    MI_OVERRIDE
        secure      MI_SECURE
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MI_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MI_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMI_USE_CXX=ON
        -DMI_BUILD_OBJECT=OFF
        -DMI_BUILD_TESTS=OFF
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
        -DMI_INSTALL_TOPLEVEL=ON
    OPTIONS_DEBUG
        -DMI_DEBUG_FULL=ON
    OPTIONS_RELEASE
        -DMI_DEBUG_FULL=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mimalloc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/mimalloc.h"
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
