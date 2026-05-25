vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saro-lab/dat-vcpkg
        REF "v4.0.0"                # GitHub Release tag name
        SHA512 3d8b7fd4a920c75213a0bca940eb852f14b9874334d04d7889193f5978fe0350bbfbf20e816477db1ed0deb5dd3e3416548403f8107a721938ec4b173e8ba416
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DMAYBE_UNUSED_VARIABLES=ENABLE_TESTING
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME dat CONFIG_PATH share/dat)

if(EXISTS "${SOURCE_PATH}/LICENSE")
    file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT License")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")