vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v${VERSION}
    SHA512 5135b13a03ee814cb35e04459b2d91b8fbe91cd518a604c41062b4ad42b739fce1acf946b01904309e0edffb874f5e81f69d28afdc8b6f759ef2d675ca0c0db0
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
