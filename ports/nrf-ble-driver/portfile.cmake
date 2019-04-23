include(vcpkg_common_functions)

message(
"nrf-ble-driver currently requires the following libraries from the system package manager:
    libudev-dev
These can be installed on Ubuntu systems via sudo apt install libudev-dev"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NordicSemiconductor/pc-ble-driver
    REF v4.1.0
    SHA512 f8a995826caf4022f68b149d0f3619d1d656e3960a927eda29c634bf06cad8341c95a5b51ec7e50b28814f5332a4800faf88eb5b4e8ebec153f9cad05b3a703e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_EXAMPLES= -DDISABLE_TESTS= -DNRF_BLE_DRIVER_VERSION=4.1.0 -DCONNECTIVITY_VERSION=4.1.0
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)