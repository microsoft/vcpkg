
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hikogui/hikogui
    REF v0.8.1
    SHA512 1a711aeb83d4d84e89ba4895aea321b1e5120fc20e8124237ee575b14955edcfa991965cb80628e7c485a44ba13245ba76781582339f62939a8180a629de996a
    HEAD_REF main
)

set(ENV{VULKAN_SDK} "${CURRENT_INSTALLED_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
