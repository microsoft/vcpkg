vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/variant-lite
    REF v3.0.0
    SHA512 e85f27179a997777e3f9ad1db5f424f0838c474904c9df6a6b9cce817ca57144b0e23d561b9514edd97f8fff88b2a372c5afccc46a15b35e4b7d287e6b197a9e
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVARIANT_LITE_OPT_BUILD_TESTS=OFF
        -DVARIANT_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright
)
