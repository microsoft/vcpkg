vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO antlr/antlr4
    HEAD_REF dev
    REF "${VERSION}"
    SHA512 afd8ecab637a0e70cddf98f63c918eab2b907f87207624e20e80a79f885d6502d4ab734a602b1707969d61944410828b689ec2f8b09c15314fe991024cde1613
    PATCHES
        set-export-macro-define-as-private.patch
        add-include-chrono.patch # https://github.com/antlr/antlr4/pull/4738
)

set(RUNTIME_PATH "${SOURCE_PATH}/runtime/Cpp")

message(INFO "Configure at '${RUNTIME_PATH}'")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${RUNTIME_PATH}"
    OPTIONS
        -DANTLR_BUILD_STATIC=${BUILD_STATIC}
        -DANTLR_BUILD_SHARED=${BUILD_SHARED}
        -DANTLR4_INSTALL=ON
        -DANTLR_BUILD_CPP_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-generator CONFIG_PATH lib/cmake/antlr4-generator DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-runtime CONFIG_PATH lib/cmake/antlr4-runtime)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
