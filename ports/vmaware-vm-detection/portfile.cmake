vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 585e2918b48da4c9a01c46e35440b19b9a4b6544aeb10fb6e4439d8071a4f9da033c8f33941749480dcaa54c6d1bf4129ef0649eeef6df5a97a73fb61ea0185b
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
