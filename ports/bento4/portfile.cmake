vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axiomatic-systems/Bento4
    REF "v${VERSION}"
    SHA512 2c5b9b5cc2aaa6a59eaaf3cf47f91b8748362319c6bf9b954d8fc1fe309fda42e28f03a704783bef215b05578cec1832c6ae07d8f53a2173009e135ae630fae5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bento4)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Documents/LICENSE.txt")
