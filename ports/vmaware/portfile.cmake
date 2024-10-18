vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 93a074c53f47125c93ea1a940f5aad6ec34857d6610463ee7a6ba4e0de334567b6e3812d39d965026e2a956cb3ea55db5d4ffea26379c846ac64359bf1ee3e8d
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
if("gpl3" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/src/vmaware.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware")
else()
    file(INSTALL "${SOURCE_PATH}/src/vmaware_MIT.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware" RENAME "vmaware.hpp")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
