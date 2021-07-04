vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/zlib-ng
    REF 2.0.3
    SHA512 e1afe91e1a8b4c54a004b672f539ae68f7dc1f1b08ba93514c0de674230354c944d496753f00ad272f16ef322705f275b5b72dac6c2a757ec741ef3f1ea1d59a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DZLIB_FULL_VERSION=2.0.3
        -DZLIB_ENABLE_TESTS=OFF
        -DWITH_NEW_STRATEGIES=ON
    OPTIONS_RELEASE
        -DWITH_OPTIM=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
)
file(INSTALL ${SOURCE_PATH}/LICENSE.md
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)