vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 0
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware_MIT.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware" RENAME "vmaware.hpp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
