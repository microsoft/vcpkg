vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adi5423/RelNo_D1
    REF v1.0.0
    SHA512 0fd5db9d72eb96ac4c22fd549891a7e9394d55da6121a16b36f4650b85254d536fadcaf610efeb004ed78678d9c2bac9ed53e18d09abcd215a4e7a2d1d67cd67
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_build()
vcpkg_cmake_install()

# Always run fixup even if lib/cmake doesn’t exist (it no-ops safely)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RelNo_D1)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# License
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/relno-d1 RENAME copyright)
