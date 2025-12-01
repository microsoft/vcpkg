vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF "v${VERSION}"
    SHA512 083b92079bf324fb9e50b3d6291ee3654b8e4e2926c292c9dc092b1c4ce336ce4d4bbea7e14d52291340c692887b8ab92d1f9f3d50aed6092b5465242572bfdc
    HEAD_REF dev
    PATCHES
        0001-use-local-packages.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dsaucer_no_polyfill=ON
        -Dsaucer_prefer_remote=OFF
        -DCPM_USE_LOCAL_PACKAGES=ON
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
