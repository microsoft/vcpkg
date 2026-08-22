set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Signalsmith-Audio/signalsmith-stretch
    REF "${VERSION}"
    SHA512 cc014fcd64a3bd04a4d389a2b2cbc63025d8672d54eafb5f5bdf03428246581ecf57006f6ced38b608e50afa59cfaf5a92693ce234537ca8e92f4d3b75193568
    HEAD_REF main
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmd"
    "${SOURCE_PATH}/dsp"
    "${SOURCE_PATH}/web"
)

# Adjust include path to the VCPKG port signalsmith-dsp
file(READ "${SOURCE_PATH}/signalsmith-stretch.h" _header_content)
string(REPLACE "#include \"dsp/spectral.h\"" "#include <signalsmith-dsp/spectral.h>" _header_content "${_header_content}")
string(REPLACE "#include \"dsp/delay.h\"" "#include <signalsmith-dsp/delay.h>" _header_content "${_header_content}")
string(REPLACE "#include \"dsp/perf.h\"" "#include <signalsmith-dsp/perf.h>" _header_content "${_header_content}")
file(WRITE "${SOURCE_PATH}/signalsmith-stretch.h" "${_header_content}")

file(INSTALL "${SOURCE_PATH}/signalsmith-stretch.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/signalsmith-stretch")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
