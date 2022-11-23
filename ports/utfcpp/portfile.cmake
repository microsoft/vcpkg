vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v3.2.2
    SHA512 b3d338bbb859eb6c6d38525a2d23062c3f5486bbc85e160e1e118ac557823d4ea128554fdf7a03288f7a3a6ba2c06830d6e51a714d0b5fc6a8001a870d560ac8
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)