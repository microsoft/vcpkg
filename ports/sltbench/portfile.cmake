vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    MISSING_STDDEF_H
    URLS https://github.com/ivafanas/sltbench/commit/ec702203f406d3b1db71dac6bd39337d175cdc2c.patch?full_index=1
    SHA512 ada4ac8519dc7c5537438423d83cee99cd85b84172c402438800f70f6a550875819ea94be8cffcb174a45715e6709e1fd777415424aabf65a1b3e4430b503af1
    FILENAME ec702203f406d3b1db71dac6bd39337d175cdc2c.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivafanas/sltbench
    REF 52c7c7852abc3159185eb79e699ad77fadfc35bd
    SHA512 0c66b51f5a950a09df47019775941554538bc3642788f61aaf8c5ec3644d5fef721391f73c3fddfd9529159f9b81c7d7ed76c7995a79f37adaf8d0ff55a99d4b
    HEAD_REF master
    PATCHES
        "${MISSING_STDDEF_H}"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" WINDOWS_USE_MSBUILD)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
