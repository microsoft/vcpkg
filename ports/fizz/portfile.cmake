include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF v2018.10.15.00
    SHA512 bf16050eebb8fa131927064a2467ee8cc20ba9a214cf232f38067afa9cb71414fa19ab1c65d7f2fb3e6dff651065aadeed02724fb4660fedb0c44da9073222c0
    HEAD_REF master
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
    ${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGlog.cmake
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/fizz")
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake _contents)
string(REPLACE "lib/cmake/fizz" "share/fizz" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake "${_contents}")

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fizz RENAME copyright)
