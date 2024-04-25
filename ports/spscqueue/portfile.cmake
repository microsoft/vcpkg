vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/SPSCQueue
    REF v1.1
    SHA512 148d60b3677f9d96603413577ff7062d8830bfec955cf3631bea66e5937ee0564d3ff51d05bf9417e5f964e761b7d7fbb8a871e5b6e0fe21112479b4830b0025
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
