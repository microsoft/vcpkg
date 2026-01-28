vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 ff6bdb4c34a08df59ccedb1714ce2ade7656c3f664ed4e11b2e05f9ed4d94f608a566a93aa16784000ed0fd2cca6f34c624db27f2e3fe2f06cb48df6ec161ac3
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
