set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO joaoleal/CppADCodeGen
    REF "v${VERSION}"
    SHA512 e197b9a9cb5e091dceead33e3d82a77f8b2a80e5e37d99b23d67ded19f6a7fb0b5b99e4322b9cb053b98d0e730cdab547a73b3073d921109acf83d7aade2e3fa
    HEAD_REF master
    PATCHES
        change_main_cmake.diff
        undef_CONST.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/epl-v10.txt" "${SOURCE_PATH}/gpl3.txt")
