vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effolkronium/random
    REF v1.4.1
    SHA512 215fd34ea3a99c955a1fcd70d6c317e3829b3c562c737d22be1371213b3e14346b2f61fc76afbbcc55e26b4fdf630fa428b8bc34104170cbfc4afebcf24d160b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRandom_BuildTests=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME effolkronium_random CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)