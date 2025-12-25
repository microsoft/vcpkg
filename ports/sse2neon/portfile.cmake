#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DLTcollab/sse2neon
    REF "v${VERSION}"
    SHA512  d38574112127b67fd0f7cabcb96ca8850731c0e51ba5acf757281f4ce58bbf99a15f61bc3e33eabfdd6d2fd0070e170ff7795a3d7b93fb5665069fd7df9b9507
    HEAD_REF master
)

# Copy header file
file(COPY "${SOURCE_PATH}/sse2neon.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sse2neon/")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
