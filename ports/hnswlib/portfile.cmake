vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/hnswlib
    REF "v${VERSION}"
    SHA512 aab0a55a43595c811902780b245b4e50f69f64af167a5252861a085b465539a40e4a5d136915d06ed123b268dc00569fbc99253609c084476738be061ae0e8a2
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHNSWLIB_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hnswlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
