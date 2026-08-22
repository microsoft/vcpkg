# nanobind distributes source code to build on-demand.
# The source code is installed into the 'share/${PORT}' directory with
# subdirectories for source `src` and header `include` files
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind
    REF "v${VERSION}"
    SHA512 376c4e86cec0e97fe9d6d844fe4e79c1cbfdd2d6355d68ee5b8acff4329983044ea0f22d0948f731ee82009afa7bba837f4f849967c831bad9ea322ffb52fc00
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
