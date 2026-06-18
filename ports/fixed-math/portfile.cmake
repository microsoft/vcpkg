vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arturbac/fixed_math
    REF "v${VERSION}"
    SHA512 fc1415e205cc5f2a63ad8019397c9aad082a7f256d050f894b3e2b6f3824396142333004a3a11a024594d7c95e5b302e8cab75faa9fc3563a5e04db1791efaf6
    HEAD_REF master
    PATCHES
        disable-cpm.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DFIXEDMATH_ENABLE_UNIT_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME fixed_math CONFIG_PATH lib/cmake/fixed_math)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")
