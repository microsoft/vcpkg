vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zenomt/rtmfp-cpp
    REF "v${VERSION}"
    SHA512 e83df63d01207300f53dcbece150e8c2db8630f19a5b477292285833ad3406a09037c3055181b9f67b6a6a0f528e1c36f72577c86451591161fd3ccd945f5841
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rtmfp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(LICENSE_FILES "${SOURCE_PATH}/LICENSE")
# Copyright and license
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
