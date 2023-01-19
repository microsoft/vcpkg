vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO civetweb/civetweb
    REF eefb26f82b233268fc98577d265352720d477ba4 # v1.15
    SHA512 5ce962e31b3c07b7110cbc645458dba9c0e26e693fbe3b4a7ffe8a28563827049a22fc5596a911fbcea4d88a9adbef3f82000ff61027ff4387f40e4a4045c26d
    HEAD_REF master
    PATCHES
        disable_warnings.patch # cl will simply ignore the other invalid options. 
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CIVETWEB_ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCIVETWEB_BUILD_TESTING=OFF
        -DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF
        -DCIVETWEB_ENABLE_ASAN=OFF
        -DCIVETWEB_ENABLE_CXX=ON
        -DCIVETWEB_ENABLE_IPV6=ON
        -DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF
        -DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF
        -DCIVETWEB_ENABLE_WEBSOCKETS=ON
        -DCIVETWEB_ALLOW_WARNINGS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/civetweb)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
