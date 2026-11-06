vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  VcDevel/Vc
    REF "${VERSION}"
    SHA512 6525a72beae5270e31fe288b6b61cb2c3e431354bda3965b5fea5d743a3a76b33baaa28ef6f024353970a5b9e877fdc27a76754201f97cf21284ee1abdf16665
    HEAD_REF 1.4
    PATCHES 
       correct_cmake_config_path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Vc/")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
