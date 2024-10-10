vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF "v${VERSION}"
    SHA512 b56e4e79aa3660ee728c1698b7a5256727b505d993103ad3cc6555e9b38cf81e6f26d5cbc717bdc6f386a6062ee47065277778ca6dd78cacb35f2d5e8c897723
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOX2D_UNIT_TESTS=OFF
        -DBOX2D_SAMPLES=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
