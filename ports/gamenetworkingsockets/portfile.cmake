vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF v1.2.0
    SHA512 d179fd8f221236beb161723ca133c1f7c574f5d8d9364aaa0de27c64c8661b26b17e3395f42f5245276a05a1399146e56e462d3ec1bb23847955225a99f8d2e3
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
