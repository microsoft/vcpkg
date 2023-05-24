vcpkg_minimum_required(VERSION 2022-12-14)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v${VERSION}
    SHA512 760977df613abfb34fb7864cbbe90e8f2cf1f42b8502427a5e9c2a756ce87655120b7490ebdaa6c926a2cb56caef9ead0e0e10fb7cb732cf99a5b43c0cca411b
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
endif()

# Header only
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
