vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/tabulate
    REF v1.5
    SHA512 324c9f2427d4d0e568b63fcd7bd81f4eee6743d7106af5ead134f81d637f190f77122f28cc42b9e95f7782f5058492b1903eadb44e1c3061a636b32bb93d0ed2
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
