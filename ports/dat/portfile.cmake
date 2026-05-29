vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saro-lab/dat-vcpkg
        REF "v4.0.0"                # GitHub Release tag name
        SHA512 805e32044a98034a7236fffcb5be668d16e43b64f47a50ad161193de5af9ecd6bef7eaba32b01c21571402e9325e892c18a0a9220d8b059918fc87acf6ef59b3
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