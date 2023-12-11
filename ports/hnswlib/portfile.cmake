vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/hnswlib
    REF "v${VERSION}"
    SHA512 2bac86547374ef762083f33b5209c7c02c89b3270442dda2bc80fbc7b6a33766cb81248841deddc2ca1f7c49e3e19889955f45c91d0b601d1c883a5e1c930794
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHNSWLIB_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hnswlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
