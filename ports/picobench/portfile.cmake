# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iboB/picobench
    REF "v${VERSION}"
    SHA512 d45160c4c15b9b1f90c2263e76b51aa9d675d7f782b7c41c00725a3faf45d2105624594dd149e85c74e6d9d37a358d92dc26841a813fa7ef43990afdbb8c2b8c
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/picobench/picobench.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/picobench")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
