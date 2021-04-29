vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 681ce028953088fc585c239bdf39c4cd9f516737 #2021-04-26
    SHA512 9d5453aa1e82a672a05c2c54c94c446e2b4a2bb46474d3a0c191a57c146aa58c35974ebecf46b59a68f7c74e10b2c3baf240c3d4e99728cb9d349fcf051b3512
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
