set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Signalsmith-Audio/dsp
    REF "v${VERSION}"
    SHA512 f69f513bedd004a7e581493cf375015066abe2f8aa320ec98748656f6810a81b0a6f0d5a53a3f4ac5436d4dd56a263eef622ba62ac644675671b335e1fb290c6
    HEAD_REF main
)

file(GLOB_RECURSE SIGNALSMITH_DSP_HEADERS "${SOURCE_PATH}/*.h")
file(INSTALL ${SIGNALSMITH_DSP_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/signalsmith-dsp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
