vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF "v${VERSION}"
    SHA512 c0e620097eb7820e4cc9e89ea616c4870b47cb5dcfe8f449bda6cf32412af6d5450c70ce0bb92cbaff01306dcd6c31d649f94ab8751b3dc7a661605d96f65996
    HEAD_REF main
    PATCHES
        remove-register.patch
        folly-has-liburing.diff
        fix-dependency.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPROXYGEN_PYTHON=${PYTHON3}"
        -DVCPKG_LOCK_FIND_PACKAGE_gflags=ON
        -DCMAKE_INSTALL_DIR=share/proxygen
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(TOOL_NAMES hq proxygen_curl proxygen_echo proxygen_h3datagram_client proxygen_httperf2 proxygen_proxy proxygen_push proxygen_static AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
