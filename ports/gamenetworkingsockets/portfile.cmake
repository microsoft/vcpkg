vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF b99aa75ed9b1ec57d5c90ee009f8de8882eeca13 # v1.4.0
    SHA512 1776a6a66d2c6546a8a3d71123544ea9590ab6b123d4a92eebd38c0a195f09a55185b999250c518527e1d8983176732429901a2f781a883715e6695b597229f5
    HEAD_REF master
)

set(CRYPTO_BACKEND OpenSSL)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DUSE_CRYPTO=${CRYPTO_BACKEND}
        -DUSE_CRYPTO25519=${CRYPTO_BACKEND}
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/GameNetworkingSockets" TARGET_PATH "share/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
