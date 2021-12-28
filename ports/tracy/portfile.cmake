vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF b7a27d02afe1941eed8f64f2164447ff1a06daa6
    SHA512 027adffc1e362610016a86c7e37c97dc836d14ca0c8579281f0d53c443c58c206ad80d33936a18668c2695b9009cbbb7acbc16ec516b83f796870dc527e469e1
    HEAD_REF master
    PATCHES
        add-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")