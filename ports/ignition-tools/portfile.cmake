set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/gz-tools
    REF ignition-tools_1.5.0
    SHA512 3e8267fc16295e269a1fb4867235bca858fea0f5f048831b0dc5f087907897042edb0f4757aef1bad824f3f109959286a441ca5315b6815c557e7deba9f8d151
    HEAD_REF ign-tools1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ignition-tools")
vcpkg_fixup_pkgconfig()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB DEBUG_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
    file(COPY ${DEBUG_TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB RELEASE_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
    file(COPY ${RELEASE_TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/bin" 
    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
