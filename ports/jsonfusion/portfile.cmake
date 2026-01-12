vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tucher/JsonFusion
    REF "v${VERSION}"
    SHA512 7c37b8a36c0bca64a18bff652f8056ebc19f9eb3ed6ca1f661a050a6019d7ad4a9360df58f9839ec142316256af054f51f7321c94eaa4ce9e6300306406df556
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/JsonFusion" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/pfr" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")
# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
