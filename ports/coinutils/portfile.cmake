vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF aae9b0b807a920c41d7782d7bf2775afb17a12c6 # I don't trust the release tags. They seem to point to a different fork with an outdates file structure?
    SHA512 a515e62846698bcc3df15aabcce89d9052e30dffe2112ab5eb54c0c5def199140bd25435ef17e453c873239ab63fd03dd4cee5e4c4bfae5521f549917e025efe
)

vcpkg_from_github(
    OUT_SOURCE_PATH BUILD_SCRIPTS_PATH
    REPO coin-or-tools/BuildTools
    REF 1e473af11438bc0a9e8506252e31fc14b902a31e
    SHA512 c142163a270848d1e1300a70713ee03ec822cc9d7583ba7aa685c02b7c25e0d4c0f7d958aad320dbf1824cc88fe0a49dc3357e0fe11588dc8c30e7fec8d239f6
)

file(COPY "${BUILD_SCRIPTS_PATH}/" DESTINATION "${SOURCE_PATH}/BuildTools")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coinutils" RENAME copyright)
