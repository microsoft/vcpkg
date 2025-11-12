vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adi5423/RelNo_D1
    REF v1.0.0
    SHA512 0fd5db9d72eb96ac4c22fd549891a7e9394d55da6121a16b36f4650b85254d536fadcaf610efeb004ed78678d9c2bac9ed53e18d09abcd215a4e7a2d1d67cd67
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_build()
vcpkg_cmake_install()

# The important part
# Tell vcpkg where to find your installed config files (if none exist, this will skip safely)
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/RelNo_D1")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RelNo_D1)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/RelNo_D1")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/RelNo_D1)
else()
    message(WARNING "No CMake config directory found for RelNo_D1. Skipping config fixup.")
endif()

# Clean up empty debug files (optional but good practice)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# License
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/relno-d1 RENAME copyright)
