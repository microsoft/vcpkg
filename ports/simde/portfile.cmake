# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simd-everywhere/simde
    REF "v${VERSION}"
    SHA512 9add192021014f503699dedff8644ad8079a6381302fe56b91950a3b498b58ba7d069a4779007738edfad1ec57dbce02d462bd833a517240e8ff992e3867868a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/simde" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
