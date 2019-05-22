include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yixuan/spectra
    REF v0.8.0
    SHA512 186bcd8efd5dc6cf0aa81b909184e056d1df1e55870c700f0ca060f504fa997e3ce27c3d15d7b4c74422e4d18bcbd471558392a89e307693b89cc1f480fecc71
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spectra RENAME copyright)
