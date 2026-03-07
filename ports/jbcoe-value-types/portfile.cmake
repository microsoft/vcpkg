vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbcoe/value_types
    REF 6f50aff4d406f35dd427654184ea20263712ccfe #v1.0.1
    SHA512 97c200314313d2a76503fbe046d210e4402a8436abdaadb894f0d0f0207489f0347952ee9afb1fa3b82b97fce22fa67567298f956ce9ef80a56f8393fa002bfe
    HEAD_REF main
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_SANITIZERS=OFF
        -DENABLE_CODE_COVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME xyz_value_types CONFIG_PATH lib/cmake/xyz_value_types)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" )

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
