# Only provides dynamic library
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF 30cb46bf7e52db51d43138c8128489ab36bcc4b6 #v1.3.221
    SHA512 6b964153b253d0cce7a814d170577121cff69ef0c39c2f53c4cec1cc33b782bb10341ebe6166349dd2e93a62e0ba8ced3cf7e102ad472b974c78f8819010bfe6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
