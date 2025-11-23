 vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v0.1.5
    SHA512 9930b817d17dbc593d1b0ae30d7bc19e94f77782ed1af7ed05419a447244522497d70502ca432f0ad597e2d25ff838b935c1e859366c724e7b1ccc7bfc2b5ca0 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
            -DUNILINK_BUILD_TESTS=OFF    
)

vcpkg_cmake_build()
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/unilink"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)

