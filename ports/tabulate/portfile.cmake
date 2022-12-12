vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/tabulate
    REF v1.4
    SHA512 37d69d53f1c628955f2a35779dbf3053c5b449f7069d846b697b541df1719b00e9b72e9d6de361d9733b7e7543c25e444b1aa139f72000730eeeafa022bbf3c1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtabulate_BUILD_TESTS=OFF
        -DSAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/LICENSE.termcolor" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
