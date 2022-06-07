vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF v1.0.0
    SHA512 ff774683765dfe976220eb01a8eec06399485678a7d43b1bebdd93aef30b17707363081ca8c23aa6ef7732522b73810e9fe523db4007db1970fde2698ed4fda7
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
