vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quiet/libcorrect
    REF ee82e6673a806dfdf0a969b975ab36596ecc5401
    SHA512 a75593ca6c54c3cb4bbdb0bbf2c8aa98fa512e43aaa3434d5a6b23c60b976a0e4d7771999fc56883ff09f4352e2a697f576c5289f64b5bff5a5089eec06dd0ea
    HEAD_REF master
    PATCHES
        fix-ninja.patch
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHAVE_LIBFEC=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
