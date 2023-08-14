vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 505c697d0abef5da2ff3be35aa4ea3687597c3e9 # v1.4.1
    SHA512 3e4b4da138f2b356169e6504aa899c9eca4fba5b5fcaed2a0ae8a2f5828976dd00af9f3262c75bd6d820300da87ebe32da152fecddc278a651f3b33eb59142df
    HEAD_REF master
    PATCHES
        fix-depend-protobuf.patch
)

set(CRYPTO_BACKEND OpenSSL)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DUSE_CRYPTO=${CRYPTO_BACKEND}
        -DUSE_CRYPTO25519=${CRYPTO_BACKEND}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
