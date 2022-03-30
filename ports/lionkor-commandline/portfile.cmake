vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lionkor/commandline
    REF 01434c11aaf82d37a126dc70f5aa02cc523dbbb4
    SHA512 fb9554c07d13aa4c5d84f8288ad39e67ab302da4b286172e0f8fbc22b351234a83fb60f1c085a238d10477a379fded32302338cbddbe7ee0fdda54c6c4a75593
    HEAD_REF master
    PATCHES
        add-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
