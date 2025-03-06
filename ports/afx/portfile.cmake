vcpkg_check_linkage()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EnzoMassyle/AudioFX
    REF ${VERSION}
    SHA512 6d7a32756e3d904ba646ce0ffcb34f7e20bc80e5e36c9dea6399af5a2000088ef6bb07546929868a3152975e42a1993d4a2a200861d422fd3acd97d22fc6ae27
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)


vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "AFX" CONFIG_PATH "share/cmake/AFX")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)