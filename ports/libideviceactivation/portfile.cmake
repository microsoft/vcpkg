vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libideviceactivation
    REF fbe0476cfeddc2fc317ceb900eec12302c1d4c11 # v1.3.17
    SHA512 18fdf1b42744da33e0f0f037e83a72b76cc0b63a0b712e78d9736adcde113582327f3712bc2bfa7b6fdb692465700a9106286f383fd7d11f9351ca7939b20e24
    HEAD_REF msvc-master
)

configure_file("${CURRENT_PORT_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
