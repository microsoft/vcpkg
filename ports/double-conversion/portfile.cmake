vcpkg_download_distfile(PATCH_501_FIX_CMAKE_3_5
    URLS https://github.com/google/double-conversion/commit/101e1ba89dc41ceb75090831da97c43a76cd2906.patch?full_index=1
    SHA512 a946a1909b10f3ac5262cbe5cd358a74cf018325223403749aaeb81570ef3e2f833ee806afdefcd388e56374629de8ccca0a1cef787afa481c79f9e8f8dcaa13
    FILENAME google-double-conversion-101e1ba89dc41ceb75090831da97c43a76cd2906.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF "v${VERSION}"
    SHA512 51e84eb7a5c407f7bc8f8b8ca19932ece5c9d8ac18aedff7b7620fc67369d9b2aa8c5a6b133e7f8633d7cc5e3788bad6e60b0e48ac08d0a4bc5e4abe7cee1334
    HEAD_REF master
    PATCHES
        "${PATCH_501_FIX_CMAKE_3_5}"
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
