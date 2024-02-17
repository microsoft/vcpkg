#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DLTcollab/sse2neon
    REF "v${VERSION}"
    SHA512  d11f8e42eaccd045354b5359991562a1d2d26a796e7f44687fdd610067fef37528e2add046632cf15bd7d068b4949371fed91673b121ba893d40b10b6232e33d
    HEAD_REF master
)

# Copy header file
file(COPY "${SOURCE_PATH}/sse2neon.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sse2neon/")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
