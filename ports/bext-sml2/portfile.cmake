# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qlibs/sml
    REF "v${VERSION}"
    SHA512 8c2406f1d35145b4f5896c41c8d1a616444cb151cc468f670daefc1b7dc4bd8aa6c9acc3c2c733158c0e6a21b4077cac4b519eea2b0fd3bc549dae726d0a23d7 
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/sml2"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
