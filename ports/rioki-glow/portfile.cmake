vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/glow
    REF v0.2.1
    SHA512 410d0bcc98f9587321dceab498ed84fe2cffbf1f38ba59592d5f7eded9eea67c17e40415966d14f548b7e91f23e17fc0162c216c34b905c641647f90274af5b1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "rioki_glow")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
