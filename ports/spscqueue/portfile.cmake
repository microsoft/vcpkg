vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/SPSCQueue
    REF "v${VERSION}"
    SHA512 f8bcaf802ea0d168dc68827d542ce76f4e28f374670f9598518063623712895e3f9974a5a5ba336b01b44a559066c42e4717228ac92e589feb8168c0797cade5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPSCQueue)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
