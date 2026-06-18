# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iboB/picobench
    REF "v${VERSION}"
    SHA512 b09de960f88c6acf0257bc0276afa783b475f42c75c8429f32554df0c100a7dcfeb0f6d8f7a98fc1f10eaab3bcd04b38e382dce5cc05630fdf9ecfc1bcda449b
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/picobench/picobench.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/picobench")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
