include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ipkn/crow
    REF v0.1
    SHA512 5a97c5b8cda3ffe79001aa382d4391eddde30027401bbb1d9c85c70ea715f556d3659f5eac0b9d9192c19d13718f19ad6bdf49d67bef03b21e75300d60e7d02a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/crow RENAME copyright)
