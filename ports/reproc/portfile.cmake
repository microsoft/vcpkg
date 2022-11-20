vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v14.2.4
    SHA512 c592521960f1950d626261738091d25efdf764ee1a0c72a58c28c66eaebf6073b2c978f1dc2c8dbe89b0be7ec1629a3a45cb1fafa0ebe21b5df8d4d27c992675
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

file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
