vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DNKpp/mimicpp
    REF "v${VERSION}"
    SHA512 a1c9496c28ad7940a91e6491d9a5992533c72fe3dcd19a3397ae40bc0de363bc796db1168a3caf66c8fc6718a100ab83cb0458e2b68e564efd2cf146db45b221
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMIMICPP_BUILD_TESTS=OFF
        -DMIMICPP_BUILD_EXAMPLES=OFF
        -DMIMICPP_CONFIGURE_DOXYGEN=OFF
        -DMIMICPP_ENABLE_AMALGAMATE_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/mimipp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
