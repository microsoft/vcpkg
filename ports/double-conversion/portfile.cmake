vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF "v${VERSION}"
    SHA512 51e84eb7a5c407f7bc8f8b8ca19932ece5c9d8ac18aedff7b7620fc67369d9b2aa8c5a6b133e7f8633d7cc5e3788bad6e60b0e48ac08d0a4bc5e4abe7cee1334
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Rename exported target files into something vcpkg_cmake_config_fixup expects
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
