vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF "v${VERSION}"
    SHA512 adc1fa27cde4f15b5dc05dcaa414689173c9479da844dced50581754e4e92fac8efed0b2634d45a8e0345a171365e2b1cbec55e4da3668b61a12109b1f194c70
    HEAD_REF master
    PATCHES
        0001-remove-Werror.patch
        0002-fix-threads.patch
        0003-disable-tests.patch # also avoids old vendored gtest that fails on MSVC 19.51+ due to removed std::tr1
        0004-remove-rev.patch # https://github.com/intel/hyperscan/pull/482
        0005-fix-openssl-vectorcall.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        "-DRAGEL=${CURRENT_HOST_INSTALLED_DIR}/tools/ragel${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
