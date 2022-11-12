# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF f97f29836cb9c8c5657979f1aeac42b46d4e51d0
    SHA512 d03ef87156e2019b8bd180ccad6c8faa1fa32b5b538143fbdfcc8134b25d2addb60ceaae6cbd42b81d6676450d242d8bef964443628fb714ead39a40d018c63a
    HEAD_REF v1.3.234
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
