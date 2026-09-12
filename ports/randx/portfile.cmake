vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lidaixingchen/RandX
    REF v${VERSION}
    SHA512 e01f127eb556f0a024e8d2ed0d367ec3170821f1163810a7f7a84e116e155e664def51255b2eb0819553df5dd25c62cc4d68716e009c1c7290989d7e18aed7d2
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME RandX CONFIG_PATH lib/cmake/RandX)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
