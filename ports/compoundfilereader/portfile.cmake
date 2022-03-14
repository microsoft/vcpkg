vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/compoundfilereader
    REF v0.1.0
    SHA512 0ebb3ad02e4723d5e00a553d608dd8760614a3d83785c0e96a6d9a04df7e92486f6a4ecc0f7327a593776865abe697d21125554d547e89c838c69ab2da24d906
)

file(COPY "${SOURCE_PATH}/src/include/compoundfilereader.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/include/utf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
