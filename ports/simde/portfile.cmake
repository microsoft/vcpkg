# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simd-everywhere/simde
    REF "v${VERSION}"
    SHA512 4e42d7140c0afae507773527c6c0c07e6f0cdad59a1d42ebcf4bd223fc9f71e91a2e3db7746aca3c0c5ad2a13333c2322ce1e384c7d699ddfe33bed6f107aec5
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/simde" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
