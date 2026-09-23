# nanobind distributes source code to build on-demand.
# The source code is installed into the 'share/${PORT}' directory with
# subdirectories for source `src` and header `include` files
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind
    REF "v${VERSION}"
    SHA512 122e9f09745df06806fc98792079c1ecaca37a9c5e6ddd6630e6a9375255ac849fac117b389da717d987ff8d5f9e00796837376f2e0ae621cc0187964369df57
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNB_USE_SUBMODULE_DEPS:BOOL=OFF
        -DNB_TEST:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
