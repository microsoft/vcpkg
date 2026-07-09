# nanobind distributes source code to build on-demand.
# The source code is installed into the 'share/${PORT}' directory with
# subdirectories for source `src` and header `include` files
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind
    REF "v${VERSION}"
    SHA512 8ab384572d8142b29fdccab2e3693e576cee4cbd6c8d8ac54b3426e45dba6618beb4ccb3e413d41fc405d09935da1fd65f75ef46cf6f78156c2273052fe3e22a
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
