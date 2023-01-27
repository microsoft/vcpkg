vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF v2.0.9
    SHA512 bf6945bfb600ade35dab34c7f570ee4f69a77612547ad874bbbd989a4e594a6a219c222a22c90c5e36f205aae4d5cd1a5e4651caed5433db275d414c6769bf49
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm         MI_SEE_ASM
        secure      MI_SECURE
        override    MI_OVERRIDE
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MI_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MI_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DMI_DEBUG_FULL=ON
    OPTIONS_RELEASE
        -DMI_DEBUG_FULL=OFF
    OPTIONS
        -DMI_USE_CXX=ON
        -DMI_BUILD_TESTS=OFF
        -DMI_BUILD_OBJECT=OFF
        ${FEATURE_OPTIONS}
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
        -DMI_INSTALL_TOPLEVEL=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mimalloc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/mimalloc.h"
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
