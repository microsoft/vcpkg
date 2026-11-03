set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Signalsmith-Audio/dsp
    REF "v${VERSION}"
    SHA512 e52dda91560a50f99d7408fb44838a7045abe1296a7a57b5200aa470662300216d9f3d20a37e9e8bcb0c6d4010b8688e722072fa15299dcd2a7a2226cf572c0a
    HEAD_REF main
)

# Only the top-level headers: since 1.7.0, include/signalsmith-dsp/ holds
# one-line forwarders (#include "../../fft.h") that break once installed.
file(GLOB SIGNALSMITH_DSP_HEADERS "${SOURCE_PATH}/*.h")
file(INSTALL ${SIGNALSMITH_DSP_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/signalsmith-dsp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
