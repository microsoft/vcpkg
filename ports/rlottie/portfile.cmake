vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Samsung/rlottie
        REF e3026b1e1a516fff3c22d2b1b9f26ec864f89a82
        SHA512 3b9985606d9c475e77ecb018cfe65cde1170f10e9d2c3e18b60178d3954a4870e5141aa06bb79e803fcdbcf98742bcf72a359625a3b1409125ec3a4a1b0126c4
        PATCHES
            vcpkg.patch
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DLIB_INSTALL_DIR=lib
            -DLOTTIE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/rlottie")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/AUTHORS")
