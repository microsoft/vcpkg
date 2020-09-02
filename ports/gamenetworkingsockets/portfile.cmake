vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 78f45903de3df698f9ec94cdce2f34bd0088f145
    SHA512 1bf2fb2613eca28a787c741b2bac2bebd1c534edc81270b0b3585ef433b427ff799b2caeb00c28e5bd991ea3a0dd76267151b4aced648a0d3c39aa4817dc009d
    HEAD_REF master
)

if(openssl IN_LIST FEATURES)
    set(CRYPTO_BACKEND OpenSSL)
endif()

if(libsodium IN_LIST FEATURES)
    set(CRYPTO_BACKEND libsodium)
endif()

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