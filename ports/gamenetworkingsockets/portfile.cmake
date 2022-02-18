vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 9875f39ad3fae8c913daa310c7ff0a7a54b1e6c2 # v1.3.0
    SHA512 edf814ef10a11b67045d90d589a3bd6471fa46bc3f16cf1e83d1806df6bb48306dcda4096a2ff80fee78b24ce36d164cd46808680c9f5f8f546455fce7bf9aa0
    HEAD_REF master
)

set(CRYPTO_BACKEND OpenSSL)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGAMENETWORKINGSOCKETS_BUILD_TESTS=OFF
        -DGAMENETWORKINGSOCKETS_BUILD_EXAMPLES=OFF
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
