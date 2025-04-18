vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 be149227b9a06980c737248077726ab2157265304cf840773cdf84c3bcaba8d0fd922a5a2ada5dbf73646a0d02888933b21a8aa9c5c18158525d09d89688097f
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware_MIT.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware" RENAME "vmaware.hpp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
