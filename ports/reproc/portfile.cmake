vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF "v${VERSION}"
    SHA512 9a3af907ac8d8870022fbc2f172acb3a3cc5b5ec5c68a2882390ab1a0cd8a2ad354d4357180f86ba93af55caa12645c6ec28d549b6599be986ffa2d649d0da19
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREPROC++=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

foreach(TARGET reproc reproc++)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME ${TARGET}
    )
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
