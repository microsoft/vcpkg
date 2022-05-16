vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF v2022.03.21.00
    SHA512 81a7b764c2c2e17fd5df32a69ecb368eb01df04df6dbd1155a40b68fc39cda4f86ce81afc5c89425a5751ef7f4dbb8a40df8b5095685e72ce5e9043c0a74682e
    HEAD_REF master
    PATCHES
        0001-fix-libsodium.patch
        0002-fix-libevent.patch
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGMock.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGlog.cmake
    ${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
