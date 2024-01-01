vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/s2geometry
    REF v0.10.0
    SHA512 04fe955f71b584bca7e492b935ec6061ce1348ff1731797451cdaa538adb88274cb1634d91a844d5d6e3ad0ed11e865322002115d2e746d9a0127f38cabc34e3
    HEAD_REF main
    PATCHES
        CMakeLists.txt.patch
        Config.cmake.in.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-s2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/s2geometry/" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/s2geometry/")
