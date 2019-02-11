include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/lest
    REF v1.34.0
    SHA512 aca8a13915ecb2542c0401e17e4d1395ddc9d6299b6cc6521ccb0477aec8dbfe9e7e4e9838fcc2ef15a83cdf8161fa2ed3beeac5fdc825e1b86936f219e9a62d
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/lest RENAME copyright)
