vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF "v${VERSION}"
    SHA512 18be93b4125d629e5d81019dbd9bda48ce9e0e5c35b59a94642878f9bb0d589017e1167be7d6379e3dc262cd0653fc9354e16bd16ad500f4c3fe0b99bcf85796
    HEAD_REF master
    PATCHES
        fix-build.patch
)

# Prefer installed config files
file(REMOVE
    "${SOURCE_PATH}/fizz/cmake/FindGMock.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGflags.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGlog.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fizz)
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake" "lib/cmake/fizz" "share/fizz")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/fizz/crypto/aead/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/record/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/server/test/facebook"
    "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test"
    "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
