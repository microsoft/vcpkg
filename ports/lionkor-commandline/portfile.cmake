vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lionkor/commandline
    REF 4a8000d6b767263a79c589fcc74099a4454e07a9
    SHA512 81ee2716b7048e51d26f75033be7a6d3a1aec9bfef833ad067112b26144023dfad8f5f8d145b4162dba2de3ad09de223dbe9143cf9e2f5f5102374d3412aebf7
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
