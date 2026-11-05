# nanobind distributes source code to build on-demand.
# The source code is installed into the 'share/${PORT}' directory with
# subdirectories for source `src` and header `include` files
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind
    REF "v${VERSION}"
    SHA512 3cbf96c73323dc71bc6fc463e087857493c7711ffcb2a8f4fe2a479bd3f0268d0b3c4bab7138d87e98475ec34a5f51be273d5522cb1ec63d90a1a83badd90a75
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
