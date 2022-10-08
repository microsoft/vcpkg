vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v3.2.1
    SHA512 5798487f12b1bc55d3e06aed38f7604271ca3402963efcf85d181fd590d8a088d21e961e77698e60dc2cdae8cf4506645903442c45fd328201752d9589180e0d
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