vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 fe4a3d85c97d4bc7b1fc0e65582df0a113a67dff13d1634eb0a74d330e226e4b0b10a99060061e1033089d5a3cd7863be362ba3df2e975607127e73126f6d54e
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware_MIT.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware" RENAME "vmaware.hpp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
