set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH BUILD_SCRIPTS_PATH
    REPO coin-or-tools/BuildTools
    REF 1e473af11438bc0a9e8506252e31fc14b902a31e
    SHA512 c142163a270848d1e1300a70713ee03ec822cc9d7583ba7aa685c02b7c25e0d4c0f7d958aad320dbf1824cc88fe0a49dc3357e0fe11588dc8c30e7fec8d239f6
    PATCHES buildtools.patch
            buildtools2.patch
            disable-mkl.diff
)

file(COPY "${BUILD_SCRIPTS_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/BuildTools")

file(INSTALL "${BUILD_SCRIPTS_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
