vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yixuan/spectra
    REF v0.8.1
    SHA512 7cd2699234f7b15216e616323ef298124a7333b6efe4185299f8b326856ae515f904a47eeee5631292037567e5c1559b83e17aae503fccd94225c3947db3e90d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spectra RENAME copyright)
