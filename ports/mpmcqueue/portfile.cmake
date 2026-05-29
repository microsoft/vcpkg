# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/MPMCQueue
    REF 28d05c021d68fc5280b593329d1982ed02f9d7b3
    SHA512 e3305ecac05d48814d75adcb85fa165eec3a439a17dd99f8b0d2c095e40b2f98bd4bcf167cf8268f84d09aa172ab66b30573d9d3ad4908c10dc5bec632529b8a
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MPMCQueue)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
