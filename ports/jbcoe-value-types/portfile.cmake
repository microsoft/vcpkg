vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbcoe/value_types
    REF 0f3f7275bb374c6a2581fe65c0f158bfcc8cefa3 #v1.0.0
    SHA512 821cd420f79b3fb8eede18fde50beef49c1ce910476a4ac5aa71cd2cbb7ad89063f0a8f66cd8de2ea778ad302bee068ebc774e35b4ee456196e687748d82986f
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
