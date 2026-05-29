set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Signalsmith-Audio/dsp
    REF "v${VERSION}"
    SHA512 bd50af30fca5d2c4823dc92032c54d1868d211296a46ed727b03a3500c4636d853e62e1284eb4bd17e3867876415ff46d99d00e23eaa873f154b8a971200f241
    HEAD_REF main
)

file(
    INSTALL "${SOURCE_PATH}/include/signalsmith-dsp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
