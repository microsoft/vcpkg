vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF v0.6.2
    SHA512 36175387ae86e6f602544c516a875ac7fe0a3bde52e3e3c09f8852a804dd252694e17c638723aa3d36219d4588981cfd2261086bcf561d175e7c038e3a69e2ff
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpuid)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
