vcpkg_check_linkage()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EnzoMassyle/AudioFX
    REF "${VERSION}"
    SHA512  96df27455dac1d8d6f324e4f7db82edad4aff572314402f2335de789863f0ef32cd8243478bf63572dffcff72081b6f20389040e5ae2243046d90fcb7fca8b08
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