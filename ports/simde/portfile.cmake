# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simd-everywhere/simde
    REF "v${VERSION}"
    SHA512 5244498eea52194236870557bb2453037d0d9143fcfdf22ceab5fe6c7d572ae82ee52b23264ea9098d9b3979cd5a9d431d2e874ffbb72296b103d7faf27b3856
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/simde" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
