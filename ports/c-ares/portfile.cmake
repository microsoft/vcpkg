vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF "v${VERSION}"
    SHA512 5924d706341e35ad467bf48c88a8f53617d5fb94546b1d9dd24a7091cc84763e52f9bbdfa39abdf1aa55099d4b87116af56bf584b99a5c8f5e554ecf9d7bc8a8
    HEAD_REF main
    PATCHES
        avoid-docs.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCARES_STATIC=${BUILD_STATIC}
        -DCARES_SHARED=${BUILD_SHARED}
        -DCARES_BUILD_TOOLS=OFF
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_CONTAINER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c-ares)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/ares.h"
        "#  ifdef CARES_STATICLIB" "#if 1"
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin") # Empty folders
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
