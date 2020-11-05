vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 7743d63325ad20ac87331c110f064f5f55defb40 # v.0.6.11
    SHA512 27f5f217184b4912fc6ae7194f8f2e126b0b7bbc2e19b63c7b44d990be6544a799dce8c8a221a4079fd44b4119ba63c29775d12a2d86e9f1affe0b057d8ad302
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
