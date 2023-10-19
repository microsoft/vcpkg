set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF "v${VERSION}"
    SHA512 1ce12c8158a2f3bcddec104ceacedaea4031b4c88fc0fa1f1fae8dfa8df81c846861df9d01e8f294d79b9e4ab8c51bd1289f404eed24d07abc760688fee13090
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUTF8_INSTALL=ON
        -DUTF8_SAMPLES=OFF
        -DUTF8_TESTS=OFF
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH lib/cmake/utf8cpp)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
