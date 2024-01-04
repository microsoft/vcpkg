# nanobind distributes source code to build on-demand.
# The source code is installed into the 'share/${PORT}' directory with
# subdirectories for source `src` and header `include` files
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)

# Both of these patches will be included in the next release, and they are
# required for packaging nanobind
# https://github.com/wjakob/nanobind/pull/356
vcpkg_download_distfile(INSTALL_RULES
    URLS https://github.com/wjakob/nanobind/commit/5bde6527dc43535982a36ffa02d41275c5e484d9.patch?full_index=1
    SHA512 67bb606483f91bf5dce80881e5ec9f290679c244a745f4c22ef13fd67268cdc81f66f0f1bca9331e567dad06293777a943beaeadf92b7e4e1436e88533daed48
    FILENAME nanobind-5bde6527dc43535982a36ffa02d41275c5e484d9.patch
)
# https://github.com/wjakob/nanobind/pull/359
vcpkg_download_distfile(MINIMIZE_CMAKE_DEPENDENCIES
    URLS https://github.com/wjakob/nanobind/commit/978dbb1d6aaeee7530d57cf3e8d558e099a4eec6.patch?full_index=1
    SHA512 2737235a7aeb111e6dcb4f6d4a96ce7a41f4737a7032a18ebd2a632083849f1a8e48180eda4bdca39d284c0997a546806bcbc7b648cb0c01a9a35f96ba587c8e
    FILENAME nanobind-978dbb1d6aaeee7530d57cf3e8d558e099a4eec6.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind
    REF "v${VERSION}"
    SHA512 72bb066f6884c0ceb2672f26087daf4eb6453a339b7bc81d8abc6b52a0380663d69797193d863979118a5fbc29487a9f6aed4b0e60a53be297ab6b4e0f7f828c
    HEAD_REF master
    PATCHES
        "${INSTALL_RULES}"
        "${MINIMIZE_CMAKE_DEPENDENCIES}"
        find_dependency_python.patch
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
