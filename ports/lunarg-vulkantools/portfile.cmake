set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 b8d1a20a64fe36ddacc2c68298e7a73bbac2030439eaab7de228b6df480348fee5a0a1d72708d5b70aee7c58700b76a41f78b781ef5c9c74a7d59f6675f53e83
    HEAD_REF main
    PATCHES
        disable-qtdeploy.patch
        static-linkage.patch
        # Backport of https://github.com/LunarG/VulkanTools/pull/2707
        0001-apidump-Add-missing-calling-convention-attributes.patch
)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES jsonschema OUT_PYTHON_VAR PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Qt6=ON
        "-DPython3_EXECUTABLE=${PYTHON3}"
        "-DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}"
    OPTIONS_RELEASE
        "-DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}"
    OPTIONS_DEBUG
        "-DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}/debug"
)
vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES vkconfig vkconfig-gui AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
