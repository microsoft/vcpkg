vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaeddert/liquid-dsp
    REF "v${VERSION}"
    SHA512 04988cfc68ea562a47f16f5232e5eafada29d37e517ccfadd8dac9d83270c2cc2c1b5e9725e92b7cf6fed6d954aaa89b254038a2d7481e87202048a9521e4e22
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_AUTOTESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_SANDBOX=OFF
        -DBUILD_DOC=OFF
        -DCOVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
