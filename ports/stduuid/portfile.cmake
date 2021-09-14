vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusbancila/stduuid
    REF 5890c94bfac2f00f22a1c1481e5839c51d6a6f3f
    SHA512 82c5dc652c5c7cf0a51d4ec5d61203df1f55498d31b1a1812603391a09c95908d2cb3db396bd2e28c9ed42913cbc4c66b514fb5381bafdf50f6e32cbf545c3b9
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test UUID_BUILD_TESTS
        system-gen UUID_SYSTEM_GENERATOR
        cxx20-span UUID_USING_CXX20_SPAN
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
