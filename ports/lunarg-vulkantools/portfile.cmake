set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 f9724dacf5a9be1241f7414cf6eb7159bc75779650441a68c20f29b7bfbb3472418bf7611ae034f16ff80708e30c1ce62b088af429c408d57273a3b3628a57ed
    HEAD_REF main
    PATCHES
        disable-qtdeploy.patch
        static-linkage.patch
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
