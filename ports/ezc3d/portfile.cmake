if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(EZC3D_SHARED OFF)
else()
    set(EZC3D_SHARED ON)
endif()


vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF Release_1.3.7
    SHA512 5beb0909a4ddc56f5965b5f2edcfd2c8d68d473b172778ebe21bc134e1b4931cac1e6529676866d4238b41041658041a72ccd44879b9685d85f857a4e0df23ec
    HEAD_REF dev
    PATCHES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DBUILD_SHARED_LIBS=${EZC3D_SHARED}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# # Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()