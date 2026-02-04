vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fix8mt/conjure_enum
    REF "v${VERSION}"
    SHA512 af8127f2d958227a7168a7d808d7ff7f699b250c04b4a079f6ef9e034ee6d165e4d51054c2ec4dcec64291d3e11c507d73937dbee22e9bc5fcbdb73e127e0275
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/fix8/conjure_enum.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
