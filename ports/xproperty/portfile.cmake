# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xproperty
    REF ${VERSION}
    SHA512 5c7332b3f27ee8d81ca7cefc0666a4f8a4eb71697efe22da3fa6176d45b7ba26b09dd3b5b30b68d13c4b4fa4090ebecb73528ebceec4b699a7ad2d3e66bef745
    HEAD_REF master
    PATCHES
        fix-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
