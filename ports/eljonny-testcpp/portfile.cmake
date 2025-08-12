vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eljonny/TestCPP
    REF "v${VERSION}"
    SHA512 a47803b2e36cc5ed6055d27865d61225368daaebefe615d22afb2055b4da6ff44a8da8a4bee72f7f35bb9a53ebc12229143b16401391cef130818f105a42df3e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    DO_NOT_DELETE_PARENT_CONFIG_PATH
    CONFIG_PATH "lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
