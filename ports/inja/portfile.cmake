include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF v1.0.0
    SHA512 39598df84766a0d2a28dc92e083e27b7072600372e0313727cd5dd1fe6ad1efc055dc98055247f5cb1fc4096ffb37b59995107f3456a4495bd01381ac6c74a2b
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/src/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/src/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/inja RENAME copyright)
vcpkg_copy_pdbs()
