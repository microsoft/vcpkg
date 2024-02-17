vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO antlr/antlr4
    HEAD_REF dev
    REF "${VERSION}"
    SHA512 79ac3cdfc8f2368c647d06aec85d87507629a75527205ff2cbf7d9802989b0c6e6a8fac76148ad101f539c9ef922e431e22ba489f899f847ccc3d3d889bb2b70
    PATCHES
        set-export-macro-define-as-private.patch
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
