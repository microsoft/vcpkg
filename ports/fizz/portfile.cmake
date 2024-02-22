vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF "v${VERSION}"
    SHA512 f3bb6c4262fc0c588f51460750353769e618487bef3b77cad61d0af221ad8864920dac370c70f41fb4de063cf2b55aecdd8811cbddde96c2a63c0bf4d09f0fc0
    HEAD_REF master
    PATCHES
        0001-fix-libsodium.patch
        0002-fix-libevent.patch
        0003-fix-deps.patch
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test" "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
