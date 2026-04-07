#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DLTcollab/sse2neon
    REF "v${VERSION}"
    SHA512  ea154fd525cac66e7a26b818b67f370f0386e43fb2fce31f8d2673f99f01c45d746ddc0aa9174da6f233128ec87b669a74892847f529aceb9392a6328bbe5559
    HEAD_REF master
)

# Copy header file
file(COPY "${SOURCE_PATH}/sse2neon.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sse2neon/")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
