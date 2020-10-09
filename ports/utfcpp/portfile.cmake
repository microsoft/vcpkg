vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v3.1.1
    SHA512 720e2eba5c04f0bc4903a287138149a9cd432bc68bb163fe36b2e0d26d8bf616b4665f389b4a9c97af6ae7869e78973d97db976a4745512a241eebf774608997
    HEAD_REF master
    PATCHES fix-test.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUTF8_INSTALL=ON
        -DUTF8_SAMPLES=OFF
        -DUTF8_TESTS=OFF
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/utf8cpp)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/utf8cpp TARGET_PATH share/utf8cpp)
endif()

# Header only
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)